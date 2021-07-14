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
	signal op1 : std_logic_vector(mii_data'length-1 downto 0);
	signal op2 : std_logic_vector(mii_data'length-1 downto 0);
	signal sum : std_logic_vector(mii_data'length-1 downto 0);
	signal co  : std_logic;
	signal acc : std_logic_vector(mii_cksm'length-1 downto 0);

begin

	op1 <= acc(sum'range);
	op2 <= reverse(mii_data) when mii_irdy='1' else (op2'range => '0');

	adder_e : entity hdl4fpga.adder
	port map (
		ci  => ci,
		a   => op1,
		b   => op2,
		s   => sum,
		co  => co);

	process (mii_cksm, mii_clk)
		variable aux : std_logic_vector(acc'range);
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				ci <= '0';
				acc <= (others => '0');
			else
				if mii_irdy='1' then
					ci  <= co;
					acc <= mii_cksm;
				end if;
			end if;
		end if;
	end process;
	mii_cksm <= sum & acc(acc'length-1 downto sum'length);

end;
