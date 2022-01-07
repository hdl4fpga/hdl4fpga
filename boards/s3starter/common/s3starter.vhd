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

entity s3starter is
	port (
		xtal  : in  std_logic := '1';

		expansion_a2 : inout std_logic_vector(4 to 7) := (others => 'Z');

		s3s_anodes     : out std_logic_vector(3 downto 0) := (others => 'Z');
		s3s_segment_a  : out std_logic := 'Z';
		s3s_segment_b  : out std_logic := 'Z';
		s3s_segment_c  : out std_logic := 'Z';
		s3s_segment_d  : out std_logic := 'Z';
		s3s_segment_e  : out std_logic := 'Z';
		s3s_segment_f  : out std_logic := 'Z';
		s3s_segment_g  : out std_logic := 'Z';
		s3s_segment_dp : out std_logic := 'Z';

		switch  : in  std_logic_vector(7 downto 0) := (7 downto 0 => 'Z');
		button  : in  std_logic_vector(3 downto 0) := (3 downto 0 => 'Z');
		led     : out std_logic_vector(7 downto 0) := (7 downto 0 => 'Z');

		vga_red   : out std_logic;
		vga_green : out std_logic;
		vga_blue  : out std_logic;
		vga_hsync : out std_logic;
		vga_vsync : out std_logic;

		ps2_clk   : inout std_logic := 'Z';
		ps2_data  : inout std_logic := 'Z';

		rs232_rxd : in  std_logic := 'Z';
		rs232_txd : out std_logic := 'Z');

	attribute loc : string;
	attribute iostandard : string;
	
	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-------------------------------------------

	attribute loc        of xtal           : signal is "T9";
--	attribute iostandard of xtal           : signal is "LVTTL";

	attribute loc        of led            : signal is "P11 P12 N12 P13 N14 L12 P14 K12";
--	attribute iostandard of led            : signal is "LVTTL";

	attribute loc        of button         : signal is "L14 L13 M14 M13";
	attribute loc        of switch         : signal is "K13 K14 J13 J14 H13 H14 G12 F12";
--	attribute iostandard of button         : signal is "LVTTL";
--	attribute iostandard of switch         : signal is "LVTTL";

	attribute loc        of s3s_anodes     : signal is "E13 F14 G14 D14";
	attribute loc        of s3s_segment_a  : signal is "E14";
	attribute loc        of s3s_segment_b  : signal is "G13";
	attribute loc        of s3s_segment_c  : signal is "N15";
	attribute loc        of s3s_segment_d  : signal is "P15";
	attribute loc        of s3s_segment_e  : signal is "R16";
	attribute loc        of s3s_segment_f  : signal is "F13";
	attribute loc        of s3s_segment_g  : signal is "N16";
	attribute loc        of s3s_segment_dp : signal is "P16";
--	attribute iostandard of s3s_anodes     : signal is "LVTTL";
--	attribute iostandard of s3s_segment_a  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_b  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_c  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_d  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_e  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_f  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_g  : signal is "LVTTL";
--	attribute iostandard of s3s_segment_dp : signal is "LVTTL";

	attribute loc        of vga_red        : signal is "R12";
	attribute loc        of vga_green      : signal is "T12";
	attribute loc        of vga_blue       : signal is "R11";
	attribute loc        of vga_hsync      : signal is "R9";
	attribute loc        of vga_vsync      : signal is "T10";
--	attribute iostandard of vga_red        : signal is "LVTTL";
--	attribute iostandard of vga_green      : signal is "LVTTL";
--	attribute iostandard of vga_blue       : signal is "LVTTL";
--	attribute iostandard of vga_hsync      : signal is "LVTTL";
--	attribute iostandard of vga_vsync      : signal is "LVTTL";

	attribute loc        of ps2_clk        : signal is "M16";
	attribute loc        of ps2_data       : signal is "M15";
--	attribute iostandard of ps2_clk        : signal is "LVTTL";
--	attribute iostandard of ps2_data       : signal is "LVTTL";

	attribute loc        of rs232_rxd      : signal is "T13";
	attribute loc        of rs232_txd      : signal is "R13";
--	attribute iostandard of rs232_rxd      : signal is "LVTTL";
--	attribute iostandard of rs232_txd      : signal is "LVTTL";

	attribute loc        of expansion_a2   : signal is "E6 D5 C5 D6 C6";
--	attribute iostandard of expansion_a2   : signal is "LVTTL";





end;
