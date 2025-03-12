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
use hdl4fpga.base.all;

entity mii_1cksm is
	generic (
		n    : natural;
		init : std_logic_vector := (0 to 0 => '0'));
	port (
		mii_clk   : in  std_logic;
		mii_frm   : in  std_logic := '1';
		mii_irdy  : in  std_logic;
		mii_trdy  : out std_logic := '1';
		mii_end   : in  std_logic := '0';
		mii_empty : out std_logic;
		mii_data  : in  std_logic_vector;
		mii_cksm  : buffer std_logic_vector);
end;

architecture beh of mii_1cksm is

	signal ci  : std_logic;
	signal op1 : std_logic_vector(mii_data'length-1 downto 0);
	signal op2 : std_logic_vector(mii_data'length-1 downto 0);
	signal co  : std_logic;
	signal sum : std_logic_vector(n-1 downto 0);
	signal acc : std_logic_vector(n-1 downto 0);

begin

	op1 <= acc(mii_cksm'length-1 downto 0);
	op2 <= 
		(op2'range => '0') when mii_irdy='0' else
		(op2'range => '0') when mii_end='1'  else
		reverse(mii_data);

	adder_e : entity hdl4fpga.adder
	port map (
		ci  => ci,
		a   => op1,
		b   => op2,
		s   => mii_cksm,
		co  => co);

	process (sum, mii_clk)
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				ci  <= '0';
				acc <= std_logic_vector(resize(unsigned(init), acc'length));
			elsif mii_irdy='1' then
				ci  <= co;
				acc <= sum;
			end if;
		end if;
	end process;

	sum <= mii_cksm & acc(acc'length-1 downto mii_data'length);

	process (mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(n/mii_cksm'length-1));
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				cntr := to_unsigned(n/mii_cksm'length-1, cntr'length);
			elsif mii_irdy='1' then
				if mii_end='1' then
					if cntr(0)='0' then
						cntr := cntr - 1;
					end if;
				end if;
			end if;
			mii_empty <= cntr(0);
		end if;
	end process;

end;
