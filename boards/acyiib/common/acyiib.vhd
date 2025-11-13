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

entity acyiib is
	generic (
		debug : boolean := false);
	port (
		osc_50mhz : in std_logic;
		p1        : inout std_logic_vector(1 to 24);
		p2        : inout std_logic_vector(3 to 25));

	attribute chip_pin : string;
	attribute chip_pin of osc_50mhz : signal is "17";
	attribute chip_pin of p1        : signal is "40,41,42,43,44,45,47,48,51,52,53,55,57,58,59,60,63,64,65,67,69,70,71,72";
	attribute chip_pin of p2        : signal is "73,74,75,76,79,80,81,86,87,88,89,90,91,92,93,94,96,97,99,100,101,103,104";

	constant osc50mhz_freq : real := 50.0e6;

	alias pin40  is p1(1);
	alias pin41  is p1(2);
	alias pin42  is p1(3);
	alias pin43  is p1(4);
	alias pin44  is p1(5);
	alias pin45  is p1(6);
	alias pin47  is p1(7);
	alias pin48  is p1(8);
	alias pin51  is p1(9);
	alias pin52  is p1(10);
	alias pin53  is p1(11);
	alias pin55  is p1(12);
	alias pin57  is p1(13);
	alias pin58  is p1(14);
	alias pin59  is p1(15);
	alias pin60  is p1(16);
	alias pin63  is p1(17);
	alias pin64  is p1(18);
	alias pin65  is p1(19);
	alias pin67  is p1(20);
	alias pin69  is p1(21);
	alias pin70  is p1(22);
	alias pin71  is p1(23);
	alias pin72  is p1(24);

	alias pin73  is p2(3);
	alias pin74  is p2(4);
	alias pin75  is p2(5);
	-- alias pin76  is p2(6);
	alias pin79  is p2(7);
	alias pin80  is p2(8);
	alias pin81  is p2(9);
	alias pin86  is p2(10);
	alias pin87  is p2(11);
	alias pin88  is p2(12);
	alias pin89  is p2(13);
	alias pin90  is p2(14);
	alias pin91  is p2(15);
	alias pin92  is p2(16);
	alias pin93  is p2(17);
	alias pin94  is p2(18);
	alias pin96  is p2(19);
	alias pin97  is p2(20);
	alias pin99  is p2(21);
	alias pin100 is p2(22);
	alias pin101 is p2(23);
	alias pin103 is p2(24);
	alias pin104 is p2(25);

end;

