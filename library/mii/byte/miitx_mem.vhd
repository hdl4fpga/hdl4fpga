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

entity miitx_mem is
	generic (
		tx_len   : natural := 8;
		mem_data : std_logic_vector);
    port (
		sys_clk  : in std_logic := '-';
		sys_we   : in std_logic := '0';
		sys_addr : in std_logic_vector(0 to 0) := (0 downto 0 => '-');
		sys_data : in byte := (others => '-');

        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector(0 to tx_len-1));
end;

architecture def of miitx_mem is
	constant byte_size : natural := byte'length;
	constant word_size : natural := byte'length;
	constant word_byte : natural := word_size/byte_size;

	constant cntr_size : natural := unsigned_num_bits((mem_data'length+byte_size-1)/byte_size-1);
	constant ramb_size : natural := (mem_data'length+byte_size-1)/byte_size;
	constant addr_size : natural := unsigned_num_bits((mem_data'length+word_size-1)/word_size-1);

	function ramb_init (
		constant arg : std_logic_vector)
		return byte_vector is

		variable aux : std_logic_vector(arg'length-1 downto 0) := (others => '-');
		variable val : byte_vector(2**addr_size-1 downto 0) := (others => (others => '-'));

	begin
	
		aux(arg'length-1 downto 0) := arg;
		for i in 0 to ramb_size-1 loop
			if cntr_size > addr_size then
				val(i/word_byte) := byte2word (
					byte => aux(byte'range), 
					mask => demux(to_unsigned(i mod word_byte, cntr_size-addr_size)),
					word => val(i/word_byte));
			else
				val(i/word_byte) := aux(byte'range);
			end if;
			aux := aux srl byte'length;
		end loop;

		return val;
	end;

	signal ramb : byte_vector(2**addr_size-1 downto 0) := ramb_init(mem_data);
	signal cntr : std_logic_vector(0 to cntr_size);

begin

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			if sys_we='1' then
				ramb(to_integer(unsigned(sys_addr))) <= sys_data;
			end if;
		end if;
	end process;

	process (mii_txc)
		variable ena : std_logic;
	begin
		if rising_edge(mii_txc) then
			cntr <= dec (
				cntr => cntr,
				ena  => not mii_treq or not cntr(0),
				load => not mii_treq,
				data => ramb_size-1);
		end if;
	end process;

	mii_trdy <= cntr(0) and mii_treq;
	mii_txen <= mii_treq and not cntr(0);
	mii_txd  <= reverse(ramb(to_integer(unsigned(cntr(1 to addr_size)))));
--	mii_txd  <= reverse(word2byte(
--		word => ramb(to_integer(unsigned(cntr(1 to addr_size)))),
--		addr => cntr(addr_size+1 to cntr_size)));
end;
