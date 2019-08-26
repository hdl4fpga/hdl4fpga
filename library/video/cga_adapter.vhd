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
use hdl4fpga.cgafonts.all;

entity cga_adapter is
	generic (
		cga_bitrom  : std_logic_vector := (0 to 0 => '-');
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_height : natural := 16;
		font_width  : natural := 8);
	port (
		cga_clk     : in  std_logic;
		cga_we      : in  std_logic := '1';
		cga_addr    : in  std_logic_vector;
		cga_data    : in  std_logic_vector;

		video_clk   : in std_logic;
		video_addr  : in std_logic_vector;
		font_hcntr  : in std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);
		font_vcntr  : in std_logic_vector(unsigned_num_bits(font_height-1)-1 downto 0);
		video_hon   : in std_logic;

		video_dot : out std_logic);
end;

architecture struct of cga_adapter is
	signal font_col : std_logic_vector(font_hcntr'range);
	signal font_row : std_logic_vector(font_vcntr'range);

	signal cga_code : std_logic_vector(byte'range);
	signal dll      : std_logic_vector(cga_code'range);

	signal video_on  : std_logic;
	signal char_dot  : std_logic;
begin

	cgamem_e : entity hdl4fpga.bram
	generic map (
		bitrom => cga_bitrom)
	port map (
		clka  => cga_clk,
		addra => cga_addr,
		wea   => cga_we,
		dia   => cga_data,
		doa   => dll,

		clkb  => video_clk,
		addrb => video_addr,
		dib   => dll,
		dob   => cga_code);

	vsync_e : entity hdl4fpga.align
	generic map (
		n   => font_row'length,
		d   => (font_row'range => 2))
	port map (
		clk => video_clk,
		di  => font_vcntr,
		do  => font_row);

	hsync_e : entity hdl4fpga.align
	generic map (
		n   => font_col'length,
		d   => (font_col'range => 2))
	port map (
		clk => video_clk,
		di  => font_hcntr,
		do  => font_col);

	rom_e : entity hdl4fpga.cga_rom
	generic map (
		font_bitrom => font_bitrom,
		font_height => font_height,
		font_width  => font_width)
	port map (
		clk         => video_clk,
		char_col    => font_col,
		char_row    => font_row,
		char_code   => cga_code,
		char_dot    => char_dot);

	don_e : entity hdl4fpga.align
	generic map (
		n     => 1,
		d     => (1 to 1 => 4))
	port map (
		clk   => video_clk,
		di(0) => video_hon,
		do(0) => video_on);

	video_dot <= char_dot and video_on;

end;
