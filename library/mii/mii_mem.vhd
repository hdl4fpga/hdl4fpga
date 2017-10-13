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

entity mii_mem is
	generic (
		mem_data : std_logic_vector);
    port (
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_mem is
	constant mem_size  : natural := (mem_data'length+byte'length-1)/byte'length;
	constant addr_size : natural := unsigned_num_bits((mem_data'length+byte'length-1)/byte'length-1);

	function mem_init (
		constant arg : std_logic_vector)
		return byte_vector is

		variable aux : unsigned(arg'length-1 downto 0) := (others => '-');
		variable val : byte_vector(2**addr_size-1 downto 0) := (others => (others => '-'));

	begin
		aux(arg'length-1 downto 0) := unsigned(arg);
		for i in 0 to mem_size-1 loop
			val(i) := reverse(std_logic_vector(aux(byte'range)));
			aux := aux srl byte'length;
		end loop;

		return val;
	end;

	constant nib : natural := unsigned_num_bits(2*byte'length/mii_txd'length-1)-1;
	constant mem : byte_vector(2**addr_size-1 downto 0) := mem_init(mem_data);

	signal cntr : unsigned(0 to addr_size+nib);

begin

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

	nomuxed_g : if mii_txd'length=byte'length generate
		mii_txd  <= mem(to_integer(unsigned(cntr(1 to addr_size))));
	end generate;

	muxed_g : if mii_txd'length/=byte'length generate
		mii_txd  <= word2byte(
			mem(to_integer(unsigned(cntr(1 to addr_size)))),
			not std_logic_vector(cntr(addr_size+1 to addr_size+nib)));
	end generate;

end;
