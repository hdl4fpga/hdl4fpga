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

entity adder is
	port (
		ci : in  std_logic := '0';
		a  : in  std_logic_vector;
		b  : in  std_logic_vector;
		s  : out std_logic_vector;
		co : out std_logic);
end;

architecture def of adder is
	signal sum : unsigned(0 to s'length+1);
begin
	sum <= unsigned('0' & a & ci) + unsigned('0' & b & '1');
	s   <= std_logic_vector(sum(1 to s'length));
	co  <= sum(0);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity adder_ser is
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		ci   : in  std_logic := '0';
		a    : in  std_logic_vector;
		b    : in  std_logic_vector;
		s    : out std_logic_vector;
		co   : out std_logic);
end;

architecture def of adder_ser is
	signal cy   : std_logic; 
	signal cin  : std_logic;
	signal cout : std_logic;
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if ena='1' then
				cin <= cout;
			end if;
		end if;
	end process;
	cin <= ci when load='1' else cy;

	adder_e : entity hdl4fpga.adder
	port map (
		ci => cin,
		a  => a,
		b  => b,
		s  => s,
		co => cout);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity adder_seq is
	generic (
		digits : natural);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		feed : in  std_logic;
		ci   : in  std_logic := '0';
		a    : in  std_logic_vector;
		b    : in  std_logic_vector;
		s    : out std_logic_vector;
		co   : out std_logic);
end;

architecture def of adder_seq is
	alias  a_als : std_logic_vector(a'length-1 downto 0) is a;
	alias  b_als : std_logic_vector(b'length-1 downto 0) is b;
	alias  s_als : std_logic_vector(s'length-1 downto 0) is s;

	signal a_rgtr : std_logic_vector(0 to roundup(b'length, digits)-1);
	signal b_rgtr : std_logic_vector(0 to roundup(a'length, digits)-1);
	signal s_rgtr : std_logic_vector(0 to roundup(s'length, digits)-1);
	signal a_ser : std_logic_vector(digits-1 downto 0);
	signal b_ser : std_logic_vector(digits-1 downto 0);
	signal s_ser : std_logic_vector(digits-1 downto 0);
begin
	process (load, clk)
		variable a_shr : unsigned(a_rgtr'range);
		variable b_shr : unsigned(b_rgtr'range);
		variable s_shr : unsigned(s_rgtr'range);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if load='1' then
					a_shr := unsigned(a);
					b_shr := unsigned(b);
				end if;
				a_shr := shift_right(a_shr, digits);
				b_shr := shift_right(b_shr, digits);

				s_shr := shift_right(s_shr, digits);
				s_shr := unsigned(s_ser);

				a_rgtr <= std_logic_vector(a_ser);
				b_rgtr <= std_logic_vector(b_ser);
				s_rgtr <= std_logic_vector(s_ser);
			end if;
		end if;
	end process;

	a_ser <= a_als(a_ser'range) when load='1' else a_rgtr(a_ser'range);
	b_ser <= b_als(a_ser'range) when load='1' else b_rgtr(a_ser'range);
	adder_e : entity hdl4fpga.adder_ser
	port map (
		clk  => clk,
		ena  => ena,
		load => load,
		ci   => ci,
		a    => a_ser,
		b    => b_ser,
		s    => s_ser,
		co   => co);
end;