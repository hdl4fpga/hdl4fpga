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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity mii_1cksm is
	generic (
		cksm_init : std_logic_vector);
	port (
		mii_clk  : in  std_logic;
		mii_frm  : in  std_logic := '1';
		mii_irdy : in  std_logic;
		mii_trdy : out std_logic := '1';
		mii_data : in  std_logic_vector;
		mii_cksm : buffer std_logic_vector);
end;

architecture beh of mii_1cksm is

	signal ci  : std_logic;
	signal op1 : unsigned(mii_data'range);
	signal op2 : unsigned(mii_data'range);
	signal sum : unsigned(mii_data'range);
	signal co  : std_logic;

begin

	op1 <= unsigned(mii_cksm(mii_data'reverse_range));
	op2 <= unsigned(reverse(mii_data)) when mii_frm='1' else (op2'range => '0');

	adder_p: process(op1, op2, ci)
		variable arg1 : unsigned(0 to mii_data'length+1);
		variable arg2 : unsigned(0 to mii_data'length+1);
		variable val  : unsigned(0 to mii_data'length+1);
	begin
		arg1 := "0" & unsigned(op1) & ci;
		arg2 := "0" & unsigned(op2) & "1";
		val  := arg1 + arg2;
		sum  <= val(1 to mii_data'length);
		co   <= val(0);
	end process;

	process (mii_clk)
		variable aux : unsigned(mii_cksm'range);
	begin
		if rising_edge(mii_clk) then
			aux := unsigned(mii_cksm);
			if mii_frm='0' then
				ci  <= '0';
				aux := (others => '0');
				aux := unsigned(reverse(reverse(cksm_init, mii_data'length),8)) rol mii_data'length;
			elsif mii_irdy='1' then
				aux(mii_data'reverse_range) := sum;
				aux := aux rol mii_data'length;
				ci  <= co;
			end if;
			mii_cksm <= std_logic_vector(aux);
		end if;
	end process;

end;
