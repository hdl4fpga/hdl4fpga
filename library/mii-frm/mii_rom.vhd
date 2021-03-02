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

entity mii_rom is
	generic (
		mem_data : std_logic_vector);
    port (
        mii_txc  : in  std_logic;
        mii_txen : in  std_logic;
		mii_ena  : in  std_logic := '1';
		mii_txdv : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_rom is

	constant mem_size    : natural := (mem_data'length+mii_txd'length-1)/mii_txd'length;
	constant addr_length : natural := unsigned_num_bits(mem_size-1);
	subtype addr_range is natural range 1 to addr_length;

	signal cntr : unsigned(0 to addr_length);

begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_txen='0' then
				cntr <= to_unsigned(mem_size-1, cntr'length);
			elsif mii_ena='1' then 
				if cntr(0)='0' then
					cntr <= cntr - 1;
				end if;
			end if;
		end if;
	end process;

	mii_txdv <= mii_txen and mii_ena and not cntr(0);

	mem_e : entity hdl4fpga.rom
	generic map (
		bitrom => reverse(reverse(mem_data), mii_txd'length))
	port map (
		addr => std_logic_vector(cntr(addr_range)),
		data => mii_txd);
end;
