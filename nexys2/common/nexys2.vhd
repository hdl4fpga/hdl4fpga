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

entity nexys2 is
	port (
		xtal  : in  std_logic := '1';

		s3s_anodes     : out std_logic_vector(3 downto 0) := (3 downto 0 => 'Z');
		s3s_segment_a  : out std_logic := 'Z';
		s3s_segment_b  : out std_logic := 'Z';
		s3s_segment_c  : out std_logic := 'Z';
		s3s_segment_d  : out std_logic := 'Z';
		s3s_segment_e  : out std_logic := 'Z';
		s3s_segment_f  : out std_logic := 'Z';
		s3s_segment_g  : out std_logic := 'Z';
		s3s_segment_dp : out std_logic := 'Z';

		switch         : in  std_logic_vector(7 downto 0) := (7 downto 0 => '0');
		button         : in  std_logic_vector(3 downto 0) := (3 downto 0 => '0');
		led            : out std_logic_vector(7 downto 0) := (7 downto 0 => 'Z');

		ps2_clk        : inout std_logic := 'Z';
		ps2_data       : inout std_logic := 'Z';

		rs232_rxd      : in  std_logic := '0';
		rs232_txd      : out std_logic := 'Z';

		vga_red        : out std_logic_vector(3-1 downto 0);
		vga_green      : out std_logic_vector(3-1 downto 0);
		vga_blue       : out std_logic_vector(2-1 downto 0);
		vga_hsync      : out std_logic;
		vga_vsync      : out std_logic);

	attribute loc                   : string;
	
	------------------------------------
	-- Digilent/NEXYS2 SPARTAN-3E Kit --
	------------------------------------

	attribute loc of xtal           : signal is "B8";
	attribute loc of led            : signal is "P4 E4 P16 E16 K14 K15 J15 J14";
	attribute loc of button         : signal is "B18 D18 E18 H13";
	attribute loc of switch         : signal is "R17 N17 L13 L14 K17 K18 H18 G18";
	attribute loc of s3s_anodes     : signal is "F15 C18 H17 F17";
	attribute loc of s3s_segment_a  : signal is "L18";
	attribute loc of s3s_segment_b  : signal is "F18";
	attribute loc of s3s_segment_c  : signal is "D17";
	attribute loc of s3s_segment_d  : signal is "D16";
	attribute loc of s3s_segment_e  : signal is "G14";
	attribute loc of s3s_segment_f  : signal is "J17";
	attribute loc of s3s_segment_g  : signal is "H14";
	attribute loc of s3s_segment_dp : signal is "C17";
	
	attribute loc of ps2_clk        : signal is "R12";
	attribute loc of ps2_data       : signal is "P11";
	
	attribute loc of rs232_rxd      : signal is "U6";
	attribute loc of rs232_txd      : signal is "P9";

	attribute loc of vga_red        : signal is "R8 T8 R9";
	attribute loc of vga_green      : signal is "P6 P8 N8";
	attribute loc of vga_blue       : signal is "U4 U5";
	attribute loc of vga_hsync      : signal is "T4";
	attribute loc of vga_vsync      : signal is "U3";

end;
