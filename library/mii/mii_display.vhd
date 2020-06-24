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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafonts.all;
use hdl4fpga.videopkg.all;

entity mii_display is
	generic (
		timing_id  : videotiming_ids;
		cga_bitrom : std_logic_vector := (1 to 0 => '-'));
	port (
		mii_rxc   : in  std_logic;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector;

		video_clk : in  std_logic;
		video_dot : out std_logic;
		video_on  : buffer std_logic;
		video_hs  : out std_logic;
		video_vs  : out std_logic);
	end;

architecture struct of mii_display is

	constant font_width      : natural := 8;
	constant font_height     : natural := 16;
	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);

	signal video_von         : std_logic;
	signal video_hon         : std_logic;
	signal video_vcntr       : std_logic_vector(11-1 downto 0);
	signal video_hcntr       : std_logic_vector(11-1 downto 0);

	signal cga_addr          : std_logic_vector(14-1 downto 0);
	signal video_addr        : std_logic_vector(14-1 downto 0);
	signal cga_code          : ascii;
	signal cga_we            : std_logic;

begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		timing_id => timing_id)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_vtsync => video_vs,
		video_hzcntr => video_hcntr,
		video_vtcntr => video_vcntr,
		video_hzon   => video_hon,
		video_vton   => video_von);

	process(mii_rxc)
		variable addr : unsigned(cga_addr'range);
		variable we   : std_logic;
	begin
		if rising_edge(mii_rxc) then
			cga_addr <= std_logic_vector(addr);
			cga_we   <= mii_rxdv or we;
			if mii_rxdv='1' then
				cga_code <= word2byte(to_ascii("0123456789ABCDEF"), mii_rxd, ascii'length);
				addr     := addr + 1;
			elsif we='1' then
				cga_code <= to_ascii(" ");
				addr     := addr + 1;
			end if;
			we := mii_rxdv;
		end if;
	end process;

	video_addr <= std_logic_vector(
		(unsigned(video_vcntr(video_vcntr'left downto fontheight_bits))*(modeline_tab(timing_id)(0)/font_width)) +
		unsigned(video_hcntr(video_hcntr'left downto fontwidth_bits)));

	video_on <= video_hon and video_von;
	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		cga_bitrom  => cga_bitrom,
	  	font_bitrom => psf1cp850x8x16,
		font_height => font_height,
		font_width  => font_width)
	port map (
		cga_clk     => mii_rxc,
		cga_we      => cga_we,
		cga_addr    => cga_addr,
		cga_data    => cga_code,

		video_clk   => video_clk,
		video_addr  => video_addr,
		font_hcntr  => video_hcntr(fontwidth_bits-1 downto 0),
		font_vcntr  => video_vcntr(fontheight_bits-1 downto 0),
		video_on    => video_on,
		video_dot   => video_dot);

end;
