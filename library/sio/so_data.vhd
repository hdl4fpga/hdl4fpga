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

entity so_data is
	port (
		sio_clk   : in  std_logic;
		si_frm    : in  std_logic;
		si_length : in  std_logic_vector(8-1 downto 0);
		si_irdy   : in  std_logic;
		si_trdy   : out std_logic;
		si_data   : in  std_logic_vector;

		so_frm    : buffer std_logic;
		so_irdy   : buffer std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector);

	constant rid : unsigned(0 to 8-1) := x"18";
end;

architecture def of so_data is
begin

	process (si_frm, si_irdy, sio_clk)
		variable shr_frm  : unsigned(0 to 16/si_data'length-1) := (others => '0');
		variable shr_irdy : unsigned(shr_frm'range);
		variable shr_data : unsigned(0 to 8-1);
	begin
		if rising_edge(sio_clk) then
    		if si_frm='1' then
				if shr_frm(0)='0' then
					if si_irdy='1' then
						shr_data(0 to si_data'length-1) := unsigned(si_data);
						shr_data := rotate_left(shr_data, si_data'length);
					elsif shr_irdy(0)='1' then
						shr_data(0 to si_data'length-1) := unsigned(si_data);
						shr_data := rotate_left(shr_data, si_data'length);
					end if;
				else
					shr_data(0 to si_data'length-1) := unsigned(si_data);
					shr_data := rotate_left(shr_data, si_data'length);
				end if;
				if shr_frm(shr_frm'length/2-1 to shr_frm'length/2)="01" then
					shr_data := unsigned(reverse(si_length, 8));
				end if;
				shr_frm(0)  := si_frm;
				shr_irdy(0) := si_irdy;
				shr_frm  := rotate_left(shr_frm,  1);
				shr_irdy := rotate_left(shr_irdy, 1);
			elsif shr_frm(0)='1' then
				shr_data(0 to si_data'length-1) := unsigned(si_data);
				shr_data := rotate_left(shr_data, si_data'length);
				shr_frm(0)  := si_frm;
				shr_irdy(0) := si_irdy;
				shr_frm  := rotate_left(shr_frm,  1);
				shr_irdy := rotate_left(shr_irdy, 1);
			else
				shr_data := reverse(rid, 8);
				shr_irdy := (others => '1');
    		end if;
		end if;

		so_frm <= si_frm or shr_frm(0);
		if shr_frm(0)='0' then
			if si_frm='1' then
				so_irdy <= si_irdy or shr_irdy(0);
			else
				so_irdy <= '0';
			end if;
		else
			so_irdy <= shr_irdy(0);
		end if;
		so_data <= std_logic_vector(shr_data(0 to si_data'length-1));
	end process;

end;
