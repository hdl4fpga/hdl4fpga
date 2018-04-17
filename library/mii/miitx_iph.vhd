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

entity miitx_iph is
	generic (
		mem_data : std_logic_vector);
    port (
		ip_len   : in  std_logic_vector(0 to 16-1);
		ip_src   : in  std_logic_vector(0 to 4*8-1);
		ip_dst   : in  std_logic_vector(0 to 4*8-1);
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_iph is
	subtype word is std_logic_vector(0 to 16-1);
	type word_vector is array (natural range <>) of word;

	function init_mem (
		constant data : std_logic_vector)
		return word_vector is
		variable val : word_vector(0 to data'length/word'length-1) := (others => (others => '-'));

	begin
		for i in val'range loop
			val(i) := word2byte(data, i, word'length);
		end loop;

		return val;
	end;

	signal mem : word_vector(0 to ) := init_mem(mem_data);

begin

	process ()
		variable addr   : unsigned(0 to 4);
		variable we     : std_logic;
		variable data   : word;
		variable chksum : unsigned(word'range);
	begin
		if rising_edge() then
			mem(addr) <= data;
			case addr is 
			when "0001" =>
				we     := '1';
				data   := ip_len;
				chksum := chksum + ip_len;
			when "0101" =>
				we     := '1';
				data   := std_logic_vector(chksum);
				chksum := (others => '0');
			when "0110" | "0111" => 
				we     := '1';
				data   := word2byte(ip_src, , word'length);
				chksum := chksum + unsigned(word2byte(ip_src, , word'length));
			when "1000" | "1001" => 
				we     := '1';
				data   := word2byte(ip_dst, , word'length);
				chksum := chksum + unsigned(word2byte(ip_dst, , word'length));
			when others =>
				we     := '0';
				data   := (others => '-');
				chksum := chksum + mem(to_unsigned(addr));
			end case;
		end if;
	end process;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				cntr <= to_unsigned(mem_size*2**nib-1, cntr'length);
			elsif cntr(0)='0' then
				cntr <= cntr - 1;
			end if;
		end if;
	end process;

	mii_trdy <= mii_treq and cntr(0);
	mii_txen <= mii_treq and not cntr(0);

	mii_txd <= mem(to_integer(unsigned(cntr(1 to addr_size))));
end;
