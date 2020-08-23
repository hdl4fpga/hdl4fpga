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

entity mii_1chksum is
	generic (
		chksum_size : natural);
	port (
		mii_txc   : in  std_logic;
		mii_ena   : in  std_logic := '1';
		mii_txen  : in  std_logic;
		mii_txd   : in  std_logic_vector;

		cksm_init : in  std_logic_vector;
		cksm_txen : out std_logic;
		cksm_txd  : out std_logic_vector);
end;

architecture beh of mii_1chksum is
	signal cksm : unsigned(chksum_size-1 downto 0);
	signal slr  : unsigned(0 to chksum_size/mii_txd'length-1);
	signal ci   : std_logic;
	signal op1  : unsigned(mii_txd'range);
	signal op2  : unsigned(mii_txd'range);
	signal sum  : unsigned(mii_txd'range);
	signal co   : std_logic;
begin

	op1 <= cksm(mii_txd'reverse_range);
	op2 <= unsigned(reverse(mii_txd)) when mii_txen='1' else (op2'range => '0');

	adder_p: process(op1, op2, ci)
		variable arg1 : unsigned(0 to mii_txd'length+1);
		variable arg2 : unsigned(0 to mii_txd'length+1);
		variable val  : unsigned(0 to mii_txd'length+1);
	begin
		arg1 := "0" & unsigned(op1) & ci;
		arg2 := "0" & unsigned(op2) & "1";
		val  := arg1 + arg2;
		sum  <= val(1 to mii_txd'length);
		co   <= val(0);
	end process;

	process (mii_txc)
		variable aux1 : unsigned(cksm'range);
		variable aux2 : unsigned(slr'range);
		variable init : unsigned(cksm'range);
	begin
		if rising_edge(mii_txc) then
			aux1 := cksm;
			aux2 := slr;
			if mii_ena='1' then
				aux1(mii_txd'reverse_range) := sum;
				aux1 := aux1 rol mii_txd'length;
				aux2 := aux2 sll 1;
				ci   <= co;
				if mii_txen='1' then
					aux2(aux2'right) := '1';
				elsif aux2(0)='0' then
					ci   <= '0';
					aux1 := (others => '0');
					aux1 := unsigned(reverse(reverse(cksm_init,4),8)) rol mii_txd'length;
				end if;
			end if;
			cksm <= aux1;
			slr  <= aux2;
		end if;
	end process;

	cksm_txen <= slr(0) and not mii_txen;
	cksm_txd  <= not reverse(std_logic_vector(sum));
end;
