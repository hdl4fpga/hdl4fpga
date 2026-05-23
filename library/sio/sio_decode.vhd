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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

entity sio_decode is
	generic (
		rids : string);
	port (
		clk        : in  std_logic;
		frm        : in  std_logic;
		irdy       : in  std_logic;
		trdy       : buffer std_logic := '1';
		data       : in  std_logic_vector;
		
		rid_act    : in  std_logic;
		pyl_act    : in  std_logic := '1';

		pyl_frm    : out std_logic_vector(0 to length(rids)-1);
		pyl_irdy   : out std_logic_vector(0 to length(rids)-1);
		pyl_trdy   : in  std_logic_vector(0 to length(rids)-1) := (others => '1'));

end;

architecture beh of sio_decode is
	constant length : natural := length(rids);
begin
	process (frm, irdy, rid_act, pyl_act, clk)
		variable rid : unsigned(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if rid_act='1' then
				rid(data'reverse_range) := reverse(unsigned(data));
				rid := rotate_right(rid, data'length);
			end if;
		end if;
		pyl_frm  <= (others => '0');
		pyl_irdy <= (others => '0');
		for i in 0 to length-1 loop
			if hdo(rids)**("["&natural'image(i)&"]")=std_logic_vector(rid) then
				pyl_frm(i)  <= frm  and pyl_act;
				pyl_irdy(i) <= irdy and pyl_act;
			end if;
		end loop;
	end process;
end;
