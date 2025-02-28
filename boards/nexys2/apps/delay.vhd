-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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





