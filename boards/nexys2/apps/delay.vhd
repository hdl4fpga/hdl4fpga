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

library iodev;

architecture xlx of nexys2 is
	signal clk : std_logic;
	signal q : std_logic_vector(0 to 23) := x"00111_111";(others => '1');

	signal segment_a : std_logic;
	signal segment_b : std_logic;
	signal segment_c : std_logic;
	signal segment_d : std_logic;
	signal segment_e : std_logic;
	signal segment_f : std_logic;
	signal segment_g : std_logic;
	signal segment_dp : std_logic;

begin
	dcm : entity work.dcmcsc
	port map (
		rst => button(0),
		clkin => xtal,
		clk0 => clk,
		locked => open);
		
	del : entity work.dlay
	generic map (
		m => 3)
	port map (
		r => button(1),
		a => clk,
		q => open ); --q(1 to 23));
	led(7 downto 3) <= (others => '0');

	led(2 downto 0) <= q(1 to 3);
	seg7_ctlt : entity iodev.seg7
	generic map (
		code_size => 5,
		char_map => 
	--	 abcdefgp	
		"00000000" &
		"01000000" &
		"00100000" &
		"01100000" &
		"00010000" &
		"01010000" &
		"00110000" &
		"01110000" &
		"00001000" &
		"01001000" &
		"00101000" &
		"01101000" &
		"00011000" &
		"01011000" &
		"00111000" &
		"01111000" &
		"00000100" &
		"01000100" &
		"00100100" &
		"01100100" &
		"00010100" &
		"01010100" &
		"00110100" &
		"01110100" &
		"00001100" &
		"01001100" &
		"00101100" &
		"01101100" &
		"00011100" &
		"01011100" &
		"00111100" &
		"01111100")
	port map (
		clock => xtal,
		data  => q(23-19 to 23),
		display_turnon => s3s_anodes,
		segment_a  => segment_a,
		segment_b  => segment_b,
		segment_c  => segment_c,
		segment_d  => segment_d,
		segment_e  => segment_e,
		segment_f  => segment_f,
		segment_g  => segment_g,
		segment_dp => segment_dp);

--		s3s_anodes <= (others => '1');
		s3s_segment_a  <= not segment_a;
		s3s_segment_b  <= not segment_b;
		s3s_segment_c  <= not segment_c;
		s3s_segment_d  <= not segment_d;
		s3s_segment_e  <= not segment_e;
		s3s_segment_f  <= not segment_f;
		s3s_segment_g  <= not segment_g;
		s3s_segment_dp <= not segment_dp;
		rs232_txd <= '1';
end;
