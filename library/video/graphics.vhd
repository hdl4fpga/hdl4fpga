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

	constant pslice_size : natural := 2**(unsigned_num_bits(video_width-1));
	constant ppage_size  : natural := 2*pslice_size;
	constant pwater_mark : natural := ppage_size-pslice_size;

	signal level         : unsigned(0 to unsigned_num_bits(ppage_size-1));

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

	signal video_word : std_logic_vector(0 to setif(video_pixel'length < ctlr_di'length, ctlr_di'length, video_pixel'length)-1);
	signal vram_irdy  : std_logic;
	signal vram_data  : std_logic_vector(video_word'range);
	signal serdes_frm : std_logic;

begin

	assert ctlr_di'length mod video_pixel'length=0 or video_pixel'length mod ctlr_di'length=0
	report
		"video_pixel " & natural'image(video_pixel'length) &
		" is not multiple of " &
		"ctlr_di "     & natural'image(ctlr_di'length) &
		" or viceversa"
	severity FAILURE;
	debug_dmacfg_req <= dmacfg_req xor  to_stdulogic(to_bit(dmacfg_rdy));
	debug_dmacfg_rdy <= dmacfg_req xnor to_stdulogic(to_bit(dmacfg_rdy));
	debug_dma_req    <= dma_req    xor  to_stdulogic(to_bit(dma_rdy));
	debug_dma_rdy    <= dma_req    xnor to_stdulogic(to_bit(dma_rdy));

	dmacfg_p : process(dmacfg_clk)
		variable req : bit;
		variable rdy : bit;
	begin
		if rising_edge(dmacfg_clk) then
			req := trans_req;
			rdy := dmaddr_rdy;
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
		end if;
	end process;

	dmaddr_p : process(ctlr_clk)
		variable req : bit;
	begin
		if rising_edge(ctlr_clk) then
			req := dmaddr_req;
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
			serdes_frm <= ctlr_inirdy;
		end if;
	end process;

	process (video_clk)
		constant dataperpixel : natural := video_pixel'length/ctlr_di'length;
		constant dpage_size   : natural := dataperpixel*ppage_size;
		constant dslice_size  : natural := dataperpixel*pslice_size;

		variable rdy       : bit;
		variable hzon_lat  : std_logic;
		variable vton_lat2 : std_logic;
		variable vton_lat  : std_logic;
	begin
		if rising_edge(video_clk) then
			rdy := trans_rdy;
			if (trans_req xor rdy)='0' then
				if vt_req='1' then
					vt_req     <= '0';
					hz_req     <= '0';
					level      <= to_unsigned(ppage_size, level'length);
					dma_len    <= std_logic_vector(to_unsigned(dpage_size-1, dma_len'length));
					dma_addr   <= base_addr;
					dma_step   <= to_unsigned(dpage_size, dma_step'length);
					trans_req  <= not rdy;
				elsif hz_req='1' then
					vt_req     <= '0';
					hz_req     <= '0';
					level      <= level + to_unsigned(pslice_size, level'length);
					dma_len    <= std_logic_vector(to_unsigned(dslice_size-1, dma_len'length));
					dma_addr   <= std_logic_vector(unsigned(dma_addr) + dma_step);
					dma_step   <= to_unsigned(dslice_size, dma_step'length);
					trans_req  <= not rdy;
				end if;
			end if;

			if vton_lat='0' then
				if vton_lat2='1' then
					vt_req <= '1';
				end if;
			elsif video_vton='1' and hzon_lat='0' and video_hzon='1' then
				level <= level - to_unsigned(video_width, level'length);
			elsif level <= to_unsigned(pwater_mark, level'length) then
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

	serdes_g : if ctlr_di'length <= video_pixel'length generate
		signal des_irdy : std_logic;
		signal des_data : std_logic_vector(0 to video_pixel'length-1);
	begin
		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => ctlr_clk,
			serdes_frm => serdes_frm,
			ser_irdy   => ctlr_di_dv,
			ser_data   => ctlr_di,

			des_irdy   => des_irdy,
			des_data   => des_data);

			vram_irdy <= des_irdy;
			vram_data <= reverse(reverse(des_data), ctlr_di'length);
	end generate;

	bypass_input_g : if ctlr_di'length > video_pixel'length generate
		vram_irdy <= ctlr_di_dv;
		vram_data <= ctlr_di;
	end generate;

	video_on <= video_hzon and video_vton;
	vram_e : entity hdl4fpga.fifo
	generic map (
		max_depth  => ppage_size,
		async_mode => true,
		latency    => 2,
		check_sov  => false,
		check_dov  => true,
		gray_code  => false)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => vram_irdy,
		src_data => vram_data,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_on,
		dst_data => video_word);

	bypass_output_g : if ctlr_di'length <= video_pixel'length generate
		video_pixel <= video_word;
	end generate;

	desser_g : if ctlr_di'length > video_pixel'length generate
		desser_e : entity hdl4fpga.desser
		port map (
			desser_clk => video_clk,
			des_frm    => video_frm,
			des_data   => video_word,
			ser_data   => video_pixel);
	end generate;

end;
