--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity miitx_crc is
    port (
		mii_g    : in  std_logic_vector(31 downto 0) := x"04c11db7";
		mii_ini  : in  std_logic_vector(31 downto 0) := (others => '1');
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_ted  : in  std_logic;
		mii_txi  : in  std_logic_vector(0 to 4-1);
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector(0 to 4-1));
end;

architecture def of miitx_crc is
	signal xp : std_logic_vector(31 downto 0);
	signal cnt : std_logic_vector (0 to 7-1);

	function next_crc32w4 (
		data: std_logic_vector(3 downto 0);
		crc:  std_logic_vector(31 downto 0))
		return std_logic_vector is

		variable d:      std_logic_vector(data'range);
		variable c:      std_logic_vector(crc'range);
		variable newcrc: std_logic_vector(crc'range);

	begin
		d := Data;
		c := crc;

		newcrc(0)  := d(0) xor c(28);
		newcrc(1)  := d(1) xor d(0)  xor c(28) xor c(29);
		newcrc(2)  := d(2) xor d(1)  xor d(0)  xor c(28) xor c(29) xor c(30);
		newcrc(3)  := d(3) xor d(2)  xor d(1)  xor c(29) xor c(30) xor c(31);
		newcrc(4)  := d(3) xor d(2)  xor d(0)  xor c(0)  xor c(28) xor c(30) xor c(31);
		newcrc(5)  := d(3) xor d(1)  xor d(0)  xor c(1)  xor c(28) xor c(29) xor c(31);
		newcrc(6)  := d(2) xor d(1)  xor c(2)  xor c(29) xor c(30);
		newcrc(7)  := d(3) xor d(2)  xor d(0)  xor c(3)  xor c(28) xor c(30) xor c(31);
		newcrc(8)  := d(3) xor d(1)  xor d(0)  xor c(4)  xor c(28) xor c(29) xor c(31);
		newcrc(9)  := d(2) xor d(1)  xor c(5)  xor c(29) xor c(30);
		newcrc(10) := d(3) xor d(2)  xor d(0)  xor c(6)  xor c(28) xor c(30) xor c(31);
		newcrc(11) := d(3) xor d(1)  xor d(0)  xor c(7)  xor c(28) xor c(29) xor c(31);
		newcrc(12) := d(2) xor d(1)  xor d(0)  xor c(8)  xor c(28) xor c(29) xor c(30);
		newcrc(13) := d(3) xor d(2)  xor d(1)  xor c(9)  xor c(29) xor c(30) xor c(31);
		newcrc(14) := d(3) xor d(2)  xor c(10) xor c(30) xor c(31);
		newcrc(15) := d(3) xor c(11) xor c(31);
		newcrc(16) := d(0) xor c(12) xor c(28);
		newcrc(17) := d(1) xor c(13) xor c(29);
		newcrc(18) := d(2) xor c(14) xor c(30);
		newcrc(19) := d(3) xor c(15) xor c(31);
		newcrc(20) := c(16);
		newcrc(21) := c(17);
		newcrc(22) := d(0) xor c(18) xor c(28);
		newcrc(23) := d(1) xor d(0)  xor c(19) xor c(28) xor c(29);
		newcrc(24) := d(2) xor d(1)  xor c(20) xor c(29) xor c(30);
		newcrc(25) := d(3) xor d(2)  xor c(21) xor c(30) xor c(31);
		newcrc(26) := d(3) xor d(0)  xor c(22) xor c(28) xor c(31);
		newcrc(27) := d(1) xor c(23) xor c(29);
		newcrc(28) := d(2) xor c(24) xor c(30);
		newcrc(29) := d(3) xor c(25) xor c(31);
		newcrc(30) := c(26);
		newcrc(31) := c(27);
		return newcrc;
	end;
begin
	mii_txd  <= not xp(31 downto 28);
	mii_txen <= not mii_ted and mii_treq and cnt(0);
	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				xp <= mii_ini;
				cnt <= (others => '0');
			elsif mii_ted='1' then
				cnt <= (others => '1');
				xp <= next_crc32w4(mii_txi, xp);
			else
				xp <= xp(27 downto 0) & (1 to 4 => '1');
				cnt <= cnt sll 1;
			end if;
		end if;
	end process;
end;

