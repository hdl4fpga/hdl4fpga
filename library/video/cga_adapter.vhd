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
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity cga_adapter is
	port (
		cga_clk     : in  std_logic;
		cga_we      : in  std_logic := '1';
		cga_addr    : in  std_logic_vector;
		cga_data    : in  std_logic_vector;

		video_clk   : in  std_logic;
		video_vcntr : in std_logic_vector;
		video_hcntr : in std_logic_vector;
		video_hon   : in std_logic;

		video_dot : out std_logic);
end;

architecture struct of cga_adapter is
	signal font_col  : std_logic_vector(3-1 downto 0);
	signal font_row  : std_logic_vector(4-1 downto 0);
	signal font_addr : std_logic_vector(8+4-1 downto 0);
	signal font_line : std_logic_vector(8-1 downto 0);

	signal cga_rdata : std_logic_vector(ascii'range);
	signal cga_wdata : std_logic_vector(ascii'length*2-1 downto 0);

	signal video_on  : std_logic;
begin

	cgabram_b : block
		signal video_addr : std_logic_vector(14-1 downto 0);
		signal rd_addr    : std_logic_vector(video_addr'range);
		signal rd_data    : std_logic_vector(cga_rdata'range);
	begin

		process (video_vcntr, video_hcntr)
			variable aux : unsigned(video_addr'range);
		begin
			aux := resize(unsigned(video_vcntr) srl 4, video_addr'length);
			aux := ((aux sll 4) - aux) sll 4;  -- * (1920/8)
			aux := aux + (unsigned(video_hcntr) srl 3);
			video_addr <= std_logic_vector(aux);
		end process;

		rdaddr_e : entity hdl4fpga.align
		generic map (
			n   => video_addr'length,
			d   => (video_addr'range => 1))
		port map (
			clk => video_clk,
			di  => video_addr,
			do  => rd_addr);

		cgaram_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => cga_clk,
			wr_ena  => cga_we,
			wr_addr => cga_addr,
			wr_data => cga_data,
			rd_addr => rd_addr,
			rd_data => rd_data);

		rddata_e : entity hdl4fpga.align
		generic map (
			n => cga_rdata'length,
			d => (cga_rdata'range => 1))
		port map (
			clk => video_clk,
			di  => rd_data,
			do  => cga_rdata);

	end block;

	vsync_e : entity hdl4fpga.align
	generic map (
		n   => font_row'length,
		d   => (font_row'range => 2))
	port map (
		clk => video_clk,
		di  => video_vcntr(4-1 downto 0),
		do  => font_row);

	hsync_e : entity hdl4fpga.align
	generic map (
		n   => font_col'length,
		d   => (font_col'range => 2))
	port map (
		clk => video_clk,
		di  => video_hcntr(font_col'range),
		do  => font_col);

	font_addr <= cga_rdata & font_row;

	rom_e : entity hdl4fpga.cga_rom
	generic (
		font_bitrom => psf1cp850x8x16,
		font_height => 2**font_row'length,
		font_width  => 2**font_col'length);
	port (
		clk  => video_clk,
		font_col => font_col,
		font_height => font_row,
		code => cga_rdata,
		dot  => char_dot);

	don_e : entity hdl4fpga.align
	generic map (
		n    => 1,
		d    => (1 to 1 => 4))
	port map (
		clk   => video_clk,
		di(0) => video_hon,
		do(0) => video_on);

	video_dot <= char_dot and video_on;

end;
