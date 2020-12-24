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

entity graphics is
	generic (
		video_width  : natural);
	port (
		ctlr_inirdy  : in  std_logic;
		ctlr_clk     : in  std_logic;
		ctlr_di_dv   : in  std_logic;
		ctlr_di      : in  std_logic_vector;
		base_addr    : in  std_logic_vector;
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

--	constant line_size   : natural := 2**unsigned_num_bits(modeline_data(video_mode)(0)-1);
--	constant fifo_size   : natural := 2**unsigned_num_bits(3*modeline_data(video_mode)(0)-1);
	constant line_size   : natural := 2**unsigned_num_bits(video_width-1);
	constant fifo_size   : natural := 2*line_size;
	constant byteperword : natural := ctlr_di'length/video_pixel'length;
	constant maxdma_len  : natural := fifo_size/byteperword;
	constant water_mark  : natural := (fifo_size-line_size)/byteperword;

	signal level         : unsigned(0 to unsigned_num_bits(maxdma_len-1));

	signal video_frm     : std_logic;
	signal video_on      : std_logic;
	signal vt_req        : std_logic;
	signal hz_req        : std_logic;
	signal trans_req     : std_logic;

	signal src_irdy      : std_logic;
	signal src_data      : std_logic_vector(ctlr_di'range);

	signal dma_step      : unsigned(dma_addr'range);

	signal debug_dmacfg_req : std_logic;
	signal debug_dmacfg_rdy : std_logic;
	signal debug_dma_req    : std_logic;
	signal debug_dma_rdy    : std_logic;

begin

	debug_dmacfg_req <= dmacfg_req xor  to_stdulogic(to_bit(dmacfg_rdy));
	debug_dmacfg_rdy <= dmacfg_req xnor to_stdulogic(to_bit(dmacfg_rdy));
	debug_dma_req    <= dma_req    xor  to_stdulogic(to_bit(dma_rdy));
	debug_dma_rdy    <= dma_req    xnor to_stdulogic(to_bit(dma_rdy));

	dma_p : process (video_clk)
	begin
		if rising_edge(video_clk) then
			if ctlr_inirdy='0' then
				dmacfg_req <= to_stdulogic(to_bit(dmacfg_rdy));
				dma_req    <= to_stdulogic(to_bit(dma_rdy));
				trans_req  <= '0';
			elsif (dmacfg_req xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
				if (dma_req xor to_stdulogic(to_bit(dma_rdy)))='0' then
					if trans_req='0' then
						if vt_req='1' then
							dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
							trans_req  <= '1';
						elsif hz_req='1' then
							dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
							trans_req  <= '1';
						end if;
					else
						dma_req   <= not to_stdulogic(to_bit(dma_rdy));
						trans_req <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	process (video_clk)
		variable hzon_lat  : std_logic;
		variable vton_lat2 : std_logic;
		variable vton_lat  : std_logic;
	begin
		if rising_edge(video_clk) then
			if (dmacfg_req xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
				if trans_req='0' then
					if vt_req='1' then
						vt_req     <= '0';
						hz_req     <= '0';
						level      <= to_unsigned(maxdma_len, level'length);
						dma_len    <= std_logic_vector(to_unsigned(maxdma_len-1, dma_len'length));
						dma_addr   <= base_addr;
						dma_step   <= resize(to_unsigned(maxdma_len, level'length), dma_step'length);
					elsif hz_req='1' then
						vt_req     <= '0';
						hz_req     <= '0';
						level      <= level + line_size;
						dma_len    <= std_logic_vector(to_unsigned(line_size-1, dma_len'length));
						dma_addr   <= std_logic_vector(unsigned(dma_addr) + dma_step);
						dma_step   <= resize(to_unsigned(line_size, level'length), dma_step'length);
					end if;
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
		end if;
	end process;

	video_on <= video_hzon and video_vton;
	vram_e : entity hdl4fpga.fifo
	generic map (
		max_depth => fifo_size,
		out_rgtr  => true, 
		latency   => 3,
		check_sov => false,
		check_dov => false,
		gray_code => true)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => ctlr_di_dv,
		src_data => ctlr_di,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_on,
		dst_data => video_pixel);

end;
