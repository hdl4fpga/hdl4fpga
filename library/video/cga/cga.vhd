--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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
		bitrom : std_logic_vector;	-- Font Bit Rom
		height : natural;			-- Character's Height
		width  : natural;			-- Character's Width
		row_offset  : integer := 0;
		row_reverse : boolean := false;
		col_offset  : integer := 0;
		col_reverse : boolean := false);

	port (
		sys_clk  : in std_logic;
		sys_row  : in std_logic_vector;
		sys_col  : in std_logic_vector;
		sys_we   : in std_logic;
		sys_code : in std_logic_vector;

		vga_clk : in  std_logic;
		vga_row : in  std_logic_vector;
		vga_col : in  std_logic_vector;
		vga_dot : out std_logic);

	constant num_of_char : natural := bitrom'length/(width*height);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of cga is

	signal cga_row : std_logic_vector(vga_row'length-1 downto 0);
	signal cga_col : std_logic_vector(vga_col'length-1 downto 0);
	signal cga_sel : std_logic_vector(unsigned_num_bits(width-1)-1 downto 0);

	signal cgaram_row  : std_logic_vector(vga_row'length-1 downto vga_row'length-sys_row'length);
	signal cgaram_col  : std_logic_vector(vga_col'length-1 downto vga_col'length-sys_col'length);
	signal cgaram_code : std_logic_vector(sys_code'length-1 downto 0);

	signal font_code : std_logic_vector(sys_code'length-1 downto 0);
	signal font_row  : std_logic_vector(vga_row'length-sys_row'length-1 downto 0);
	signal font_line : std_logic_vector(width-1 downto 0);

	signal cga_line  : std_logic_vector(width-1 downto 0);

begin

	cga_row <= vga_row;
	cga_col <= vga_col;

	cga_line   <= font_line;
	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			cgaram_row <= cga_row(cgaram_row'range);
			cgaram_col <= cga_col(cgaram_col'range);
		end if;
	end process;

	fontrow_e : entity hdl4fpga.align
	generic map (
		n => font_row'length,
		d => (font_row'range => 3))
	port map (
		clk => vga_clk,
		di  => cga_row(font_row'range),
		do  => font_row);

	cgaram_e  : entity hdl4fpga.cgaram
	port map (
		wr_clk  => sys_clk,
		wr_ena  => sys_we,
		wr_row  => sys_row,
		wr_col  => sys_col,
		wr_code => sys_code,

		rd_clk  => vga_clk,
		rd_row  => cgaram_row,
		rd_col  => cgaram_col,
		rd_code => cgaram_code);

	fontcode_e : entity hdl4fpga.align
	generic map (
		n => cgaram_code'length,
		d => (cgaram_code'range => 1))
	port map (
		clk => vga_clk,
		di  => cgaram_code,
		do  => font_code);

	fontrom_e : entity hdl4fpga.fontrom
	generic map (
		bitrom => bitrom,
		height => height,
		width  => width,
		row_offset  => col_offset,
		row_reverse => row_reverse,
		col_offset  => col_offset,
		col_reverse => col_reverse)
	port map (
		clk  => vga_clk,
		code => font_code,
		row  => font_row,
		data => font_line);

	cgasel_e : entity hdl4fpga.align
	generic map (
		n => cga_sel'length,
		d => (cga_sel'range => 4))
	port map (
		clk => vga_clk,
		di  => cga_col(cga_sel'range),
		do  => cga_sel);

	mux_e : entity hdl4fpga.mux
	generic map (
		m => cga_sel'length)
	port map (
		sel => cga_sel,
		di  => cga_line,
		do  => vga_dot);
end;
