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

entity mii_arbiter is
	port (
		clk   : in  std_ulogic;
		frms  : in  std_logic_vector;
		irdys : in  std_logic_vector;
		trdys : out std_logic_vector;
		gntd  : out std_logic_vector;
		frm   : out std_logic;
		irdy  : out std_ulogic;
		trdy  : in  std_ulogic);
end;

architecture mix of mii_arbiter is
begin

	process (frms, irdys, trdy, clk)
		type states is (s_idle, s_gntd);
		variable state : states;
		variable id : natural range frms'range;
	begin
		if rising_edge(clk) then
			case state is
			when s_idle =>
				gntd <= (gntd'range => '0');
				for i in frms'range loop
					if frms(i)='1' then
						id := i;
						gntd(i) <= '1';
						state   := s_gntd;
						exit;
					end if;
				end loop;
			when s_gntd =>
				if (frms(id) or irdys(id) or trdy)='0' then
					gntd  <= (gntd'range => '0');
					state := s_idle;
				end if;
			end case;
		end if;
		frm  <= '0';
		irdy <= '0';
		trdys <= (trdys'range => '0');
		case state is 
		when s_idle => 
			for i in frms'range loop
				if frms(i)='1' then
					frm  <=  frms(i);
					irdy <= irdys(i);
					trdys(i) <= trdy;
					exit;
				end if;
			end loop;
		when s_gntd =>
			frm  <=  frms(id);
			irdy <= irdys(id);
			trdys(id) <= trdy;
		end case;
	end process;

end;
