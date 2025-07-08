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

use work.hdo.all;

library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end;

architecture hdo_tb of testbench is

	constant sdram_chip : string := "{" &
		"fmly : sdr,"             &
		"orgz : {"                &
			"addr:{"              &
				"ba  :  2,"       &
				"row : 13,"       &
				"col :  9},"      &
			"data:{"              &
				"dm :  2,"        &
				"dq : 16}},"      &
		"tmng : {"                &
			"tWR   : 25.0e-9,"    &
			"tRCD  : 15.0e-9,"    &
			"tRP   : 15.00e-9,"   &
			"tMRD  : 15.0e-9,"    &
			"tRFC  : 66.0e-9,"    &
			"tREFI : 7.8125e-6}}";

	constant sdram_addr : string := sdram_chip**".orgz.addr";

	signal  ba  : std_logic_vector(0 to  sdram_addr**".ba"-1);
	signal  row : std_logic_vector(0 to  sdram_addr**".row"-1);
	signal  col : std_logic_vector(0 to  sdram_addr**".col"-1);

	signal dq : std_logic_vector(0 to sdram_chip**".orgz.data.dq"-1);
	signal dm : std_logic_vector(0 to sdram_chip**".orgz.data.dm"-1);

	constant twr : real := sdram_chip**".tmng.tWR";
begin

	process
	begin
		report "sdram_addr : " & sdram_addr;
		report "bank   right : " & natural'image(ba'right);
		report "row    right : " & natural'image(row'right);
		report "column right : " & natural'image(col'right);
		report "dq     right : " & natural'image(dq'right);
		report "dm     right : " & natural'image(dm'right);
		report "tWR          : " & real'image(twr);
		wait;
	end process;

end;
