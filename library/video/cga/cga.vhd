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

entity cga is

	generic (
		bitrom     : std_logic_vector;	-- Font Bit Rom
		cga_width  : natural := 240;
		cga_height : natural := 68;
		char_width : natural);

	port (
		sys_clk  : in  std_logic;
		sys_row  : in  std_logic_vector;
		sys_col  : in  std_logic_vector;
		sys_we   : in  std_logic;
		sys_code : in  std_logic_vector;

		vga_clk  : in  std_logic;
		vga_row  : in  std_logic_vector;
		vga_col  : in  std_logic_vector;
		vga_dot  : out std_logic);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of cga is

	signal cga_row      : std_logic_vector(vga_row'length-1 downto 0);
	signal cga_col      : std_logic_vector(vga_col'length-1 downto 0);
	signal cga_sel      : std_logic_vector(unsigned_num_bits(char_width-1)-1 downto 0);
	signal font_code    : std_logic_vector(sys_code'length-1 downto 0);
	signal font_row     : std_logic_vector(vga_row'length-sys_row'length-1 downto 0);
	signal font_line    : std_logic_vector(0 to char_width-1);
	signal dot          : std_logic_vector(1-1 downto 0);
	signal cgaram_ddo   : std_logic_vector(sys_code'length-1 downto 0);
	signal cgaram_addri : std_logic_vector(unsigned_num_bits(cga_width*cga_height-1)-1 downto 0);
	signal cgaram_addro : std_logic_vector(unsigned_num_bits(cga_width*cga_height-1)-1 downto 0);

	function cgaram_addr (
		constant row : std_logic_vector;
		constant col : std_logic_vector)
		return std_logic_vector is
		variable aux : unsigned(cgaram_addri'range);
	begin
		aux(row'length-1 downto 0) := unsigned(row);
		aux := aux sll 4;
		aux := aux - unsigned(row);
		aux := aux sll 4;
		aux := aux + unsigned(col);
		return std_logic_vector(aux);
	end;

begin

	cga_row <= vga_row;
	cga_col <= vga_col;

	fontrow_e : entity hdl4fpga.align
	generic map (
		n => font_row'length,
		i => (font_row'range => '-'),
		d => (font_row'range => 2))
	port map (
		clk => vga_clk,
		di  => cga_row(font_row'range),
		do  => font_row);

	cgaram_addri <= cgaram_addr(
		row => sys_row,
		col => sys_col);
	cgaram_addro <= cgaram_addr(
		row => cga_row(vga_row'length-1 downto vga_row'length-sys_row'length),
		col => cga_col(vga_col'length-1 downto vga_col'length-sys_col'length));

	dpram_e : entity hdl4fpga.bram
	port map (
		clka  => sys_clk,
		wea   => sys_we,
		addra => cgaram_addri,
		dia   => sys_code,
		doa   => cgaram_ddo,

		clkb  => vga_clk,
		addrb => cgaram_addro,
		dib   => (font_code'range => '-'),
		dob   => font_code);

--	cgaram_e  : entity hdl4fpga.cgaram
--	port map (
--		wr_clk  => sys_clk,
--		wr_ena  => sys_we,
--		wr_row  => sys_row,
--		wr_col  => sys_col,
--		wr_code => sys_code,
--
--		rd_clk  => vga_clk,
--		rd_row  => cga_row(vga_row'length-1 downto vga_row'length-sys_row'length),
--		rd_col  => cga_col(vga_col'length-1 downto vga_col'length-sys_col'length),
--		rd_code => font_code);

	fontrom_e : entity hdl4fpga.fontrom
	generic map (
		bitrom => bitrom)
	port map (
		clk  => vga_clk,
		code => font_code,
		row  => font_row,
		data => font_line);

	cgasel_e : entity hdl4fpga.align
	generic map (
		n => cga_sel'length,
		i => (cga_sel'range => '-'),
		d => (cga_sel'range => 3))
	port map (
		clk => vga_clk,
		di  => cga_col(cga_sel'range),
		do  => cga_sel);

	dot <= word2byte(reverse(font_line), cga_sel);
	vga_dot <= dot(0);
end;
