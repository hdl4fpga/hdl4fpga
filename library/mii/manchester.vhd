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
use ieee.numeric_std.all;

entity tx_manchester is
	port (
		txc  : in  std_logic;
		txen : in  std_logic;
		txd  : in  std_logic;
		tx   : out std_logic);
end;

architecture def of tx_manchester is
	signal clk_n : std_logic;
begin
	clk_n <= not txc;
	tx    <= txd xor clk_n when txen='1' else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_manchester is
	generic (
		oversampling : natural);
	port (
		rx   : in  std_logic;
		rxc  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of rx_manchester is
begin
	process (rxc)
		variable cntr : natural range 0 to oversampling-1;
	begin
		if rising_edge(rxc) then
			if cntr > 0 then
				if cntr=1 then
					rxd <= rx;
				end if;
				cntr := cntr - 1;
			elsif (to_bit(rx) xor to_bit(rxd))='1' then
				cntr := oversampling-1;
			end if;
		end if;
	end process;
end;




