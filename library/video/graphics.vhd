--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;

--		mode600p   => (pll => (clkos_div => 2, clkop_div => 128, clkfb_div => 1, clki_div => 5, clkos2_div => 16, clkos3_div => 2, clkop_phase => 127), mode => pclk40_00m800x600at60),
--			in_red    => video_pixel(0   to  0+5-1),
--			in_green  => video_pixel(0+5 to  5+5-1),
--			in_blue   => video_pixel(6+5 to 11+5-1),
entity graphics is
	generic (
		video_width  : natural);
	port (
		ctlr_inirdy  : in  std_logic;
		ctlr_clk     : in  std_logic;
		ctlr_di_dv   : in  std_logic;
		ctlr_di      : in  std_logic_vector;
		base_addr    : in  std_logic_vector;
		dmacfg_clk   : in   std_logic;
		dmacfg_req   : buffer std_logic;
		dmacfg_rdy   : in  std_logic;
		dma_req      : buffer std_logic;
		dma_rdy      : in  std_logic;
		dma_len      : out std_logic_vector;
		dma_addr     : buffer std_logic_vector;
		video_clk    : in  std_logic;
		video_hzon   : in  std_logic;
		video_vton   : in  std_logic;
		video_pixel  : out std_logic_vector);
end;

architecture def of graphics is

	constant wordperbyte : natural := video_pixel'length/ctlr_di'length;
--	constant line_size   : natural := 2**unsigned_num_bits(modeline_data(video_mode)(0)-1);
--	constant fifo_size   : natural := 2**unsigned_num_bits(3*modeline_data(video_mode)(0)-1);
	constant line_size   : natural := 2**unsigned_num_bits(video_width-1)*wordperbyte;
	constant fifo_size   : natural := 2*line_size*wordperbyte;
	constant maxdma_len  : natural := fifo_size*wordperbyte;
	constant water_mark  : natural := (fifo_size-line_size)*wordperbyte;

	signal level         : unsigned(0 to unsigned_num_bits(maxdma_len-1));

	signal video_frm     : std_logic;
	signal video_on      : std_logic;
	signal vt_req        : std_logic;
	signal hz_req        : std_logic;
	signal trans_rdy     : bit;
	signal trans_req     : bit;

	signal src_irdy      : std_logic;
	signal src_data      : std_logic_vector(ctlr_di'range);

	signal dma_step      : unsigned(dma_addr'range);

	signal debug_dmacfg_req : std_logic;
	signal debug_dmacfg_rdy : std_logic;
	signal debug_dma_req    : std_logic;
	signal debug_dma_rdy    : std_logic;

	signal dmaddr_req : bit;
	signal dmaddr_rdy : bit;

	signal vram_irdy : std_logic;
	signal des_data  : std_logic_vector(video_pixel'range);
	signal vram_data : std_logic_vector(video_pixel'range);

begin

	debug_dmacfg_req <= dmacfg_req xor  to_stdulogic(to_bit(dmacfg_rdy));
	debug_dmacfg_rdy <= dmacfg_req xnor to_stdulogic(to_bit(dmacfg_rdy));
	debug_dma_req    <= dma_req    xor  to_stdulogic(to_bit(dma_rdy));
	debug_dma_rdy    <= dma_req    xnor to_stdulogic(to_bit(dma_rdy));

	dmacfg_p : process(dmacfg_clk)
		variable req : bit;
		variable rdy : bit;
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				trans_rdy  <= '0';
				dmacfg_req <= '0';
				dmaddr_req <= '0';
			elsif (req xor trans_rdy)='1' then
				if (dmaddr_req xor rdy)='0' then
					if (to_stdulogic(to_bit(dmacfg_req)) xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
						dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
					else
						trans_rdy  <= req;
						dmaddr_req <= not rdy;
					end if;
				end if;
			end if;
			req := trans_req;
			rdy := dmaddr_rdy;
		end if;
	end process;

	dmaddr_p : process(ctlr_clk)
		variable req : bit;
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_inirdy='0' then
				dma_req    <= '0';
				dmaddr_rdy <= '0';
			elsif (dmacfg_req xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
				if (req xor dmaddr_rdy)='1' then
					if (dma_req xor to_stdulogic(to_bit(dma_rdy)))='0' then
						dma_req <= not to_stdulogic(to_bit(dma_rdy));
					else
						dmaddr_rdy <= req;
					end if;
				end if;
			end if;
			req := dmaddr_req;
		end if;
	end process;

	process (video_clk)
		variable rdy       : bit;
		variable hzon_lat  : std_logic;
		variable vton_lat2 : std_logic;
		variable vton_lat  : std_logic;
	begin
		if rising_edge(video_clk) then
			if (trans_req xor rdy)='0' then
				if vt_req='1' then
					vt_req     <= '0';
					hz_req     <= '0';
					level      <= to_unsigned(maxdma_len, level'length);
--					dma_len    <= (dma_len'range => '0');
--					dma_addr   <= base_addr;
					dma_len    <= std_logic_vector(to_unsigned(maxdma_len-1, dma_len'length));
					dma_addr   <= base_addr;
					dma_step   <= resize(to_unsigned(maxdma_len, level'length), dma_step'length);
					trans_req  <= not rdy;
				elsif hz_req='1' then
					vt_req     <= '0';
					hz_req     <= '0';
					level      <= level + line_size;
--					dma_len    <= (dma_len'range => '0');
--					dma_addr   <= base_addr;
					dma_len    <= std_logic_vector(to_unsigned(line_size-1, dma_len'length));
					dma_addr   <= std_logic_vector(unsigned(dma_addr) + dma_step);
					dma_step   <= resize(to_unsigned(line_size, level'length), dma_step'length);
					trans_req  <= not rdy;
				end if;
			end if;
			if vton_lat='0' then
				if vton_lat2='1' then
					vt_req <= '1';
				end if;
			elsif video_vton='1' and hzon_lat='0' and video_hzon='1' then
				level <= level - video_width;
			elsif level <= water_mark then
				if hz_req='0' then
					hz_req <= '1';
				end if;
			end if;

			video_frm <= not setif(video_vton='0' and vton_lat='1');
			hzon_lat  := video_hzon;
			vton_lat2 := vton_lat;
			vton_lat  := video_vton;
			rdy := trans_rdy;
		end if;
	end process;

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => ctlr_clk,
		serdes_frm => ctlr_di_dv,
		ser_irdy   => '1',
		ser_data   => ctlr_di,

		des_irdy   => vram_irdy,
		des_data   => des_data);
	vram_data <= reverse(des_data);

	video_on <= video_hzon and video_vton;
	vram_e : entity hdl4fpga.fifo
	generic map (
		max_depth => fifo_size,
		async_mode => true,
		latency   => 2,
		check_sov => true,
		check_dov => true,
		gray_code => false)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => vram_irdy,
		src_data => vram_data,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_on,
		dst_data => video_pixel);

end;
