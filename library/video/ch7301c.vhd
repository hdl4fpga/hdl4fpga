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

entity vga2ch7301c_iob is
	port (
		vga_clk : in std_logic;
		vga_clk90 : in std_logic;
		vga_hsync : in std_logic;
		vga_vsync : in std_logic;
		vga_blank : in std_logic;
		vga_frm   : in std_logic;
		vga_red : in std_logic_vector(8-1 downto 0);
		vga_green : in std_logic_vector(8-1 downto 0);
		vga_blue  : in std_logic_vector(8-1 downto 0);

		dvi_xclk_p : out std_logic;
		dvi_xclk_n : out std_logic;
		dvi_v : inout std_logic;
		dvi_h : inout std_logic;
		dvi_de : out std_logic;
		dvi_d : out std_logic_vector(12-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of vga2ch7301c_iob is
	signal dvi_clk : std_logic;
	signal dvi_rword : std_logic_vector(dvi_d'range);
	signal dvi_fword : std_logic_vector(dvi_d'range);
	signal h : std_logic;
	signal v : std_logic;
begin
	h <= not vga_hsync;

	dvi_h_i : entity hdl4fpga.ff
	port map (
		clk => vga_clk,
		d   => h,
		q   => dvi_h);

	v <= not vga_vsync;
	dvi_v_i : entity hdl4fpga.ff
	port map (
		clk => vga_clk,
		d  => v,
		q  => dvi_v);

	dvi_de_i : entity hdl4fpga.ff
	port map (
		clk => vga_clk,
		d  => vga_blank,
		q  => dvi_de);

	dvi_xclk_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => dvi_clk,
		o  => dvi_xclk_p,
		ob => dvi_xclk_n);

	dvi_clk_i : entity hdl4fpga.ddro
	port map (
		clk => vga_clk90,
		dr  => '1',
		df  => '0',
		q   => dvi_clk);

	dvi_rword <= (vga_green(4-1 downto 0) & vga_blue) and vga_blank;
	dvi_fword <= (vga_red & vga_green(8-1 downto 4)) and vga_blank; 

	dviddr_g : for i in dvi_d'range generate
		dac_clk_i : entity hdl4fpga.ddro
		port map (
			clk => vga_clk,
			dr  => dvi_rword(i),
			df  => dvi_fword(i),
			q   => dvi_d(i));
	end generate;
end;
