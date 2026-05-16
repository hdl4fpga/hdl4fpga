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

entity sio_pack is
	port (
		sio_clk : in  std_logic;
		si_frm  : in  std_logic;
		si_rid  : in  std_logic_vector(8-1 downto 0);
		si_len  : in  std_logic_vector(8-1 downto 0);
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		so_frm  : out std_logic;
		so_irdy : out std_logic;
		so_trdy : in  std_logic;
		so_data : out std_logic_vector);
end;

architecture def of sio_pack is
begin
	process (si_frm, si_irdy, so_trdy, sio_clk)
		variable shr_frm  : unsigned(0 to 16/si_data'length-1);
		variable shr_irdy : unsigned(shr_frm'range);
		variable shr_data : unsigned(0 to 16-1);
	begin
		if rising_edge(sio_clk) then
			if so_trdy='1' then
				if (si_frm and not shr_frm(shr_frm'right))='1' then
					shr_frm  := (others => '1');
					shr_irdy := (others => '1');
					shr_data := unsigned(reverse(si_rid & si_len, 8));
				end if;
				so_frm  <= shr_frm(0);
				so_irdy <= shr_irdy(0);
				so_data <= std_logic_vector(shr_data(0 to si_data'length-1));
				shr_frm(0) := si_frm;
				shr_frm := rotate_left(shr_frm,  1);
				shr_irdy(0) := si_irdy;
				shr_irdy := rotate_left(shr_irdy, 1);
				shr_data(0 to si_data'length-1) := unsigned(si_data);
				shr_data := rotate_left(shr_data, si_data'length);
			end if;
		end if;
		si_trdy <= so_trdy and ;
	end process;

end;
