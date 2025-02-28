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

library hdl4fpga;
use hdl4fpga.base.all;

entity sio_cmp is
    port (
        si_clk   : in  std_logic;
        si_frm   : in  std_logic;
		si1_irdy : in  std_logic;
		si1_trdy : out std_logic;
        si1_data : in  std_logic_vector;
		si2_irdy : in  std_logic;
		si2_trdy : out std_logic;
        si2_data : in  std_logic_vector;
		si_equ   : buffer std_logic);
end;

architecture def of sio_cmp is
	signal cy : std_logic;
begin

	process (si_clk)
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				cy <= '1';
			elsif si1_irdy='1' and si2_irdy='1' then
				cy <= si_equ;
			end if;
		end if;
	end process;
	si1_trdy <= si1_irdy and si2_irdy;
	si2_trdy <= si1_irdy and si2_irdy;
	si_equ   <= setif(si1_data=si2_data) and cy; 

end;





