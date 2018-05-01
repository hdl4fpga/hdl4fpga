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

entity mii_ram is
	generic (
		mem_size : natural);
    port (
        mii_rxc  : in  std_logic;
		mii_rd   : in  std_logic;
		mii_rdv  : in  std_logic;
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_mem is
	constant addr_size : natural := unsigned_num_bits(mem_size-1);

	signal wr_addr  : unsigned(1 to addr_size);
	signal rd_addr  : unsigned(0 to addr_size);

begin

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => mii_rxc,
		wr_addr => wr_addr,
		wr_ena  => mii_rdv,
		wr_data => mii_rd,

		rd_addr => rd_addr(1 to addr_size),
		rd_data => mii_txd);

	process (mii_rxc)
		variable cntr : unsigned(0 to addr_size);
	begin
		if rising_edge(mii_rxc) then
			if mii_rdv='0' then
				cntr := to_unsigned(mem_size-1, cntr'length);
			elsif cntr(0)='0' then
				cntr := cntr - 1;
			end if;
			wr_addr <= std_logic_vector(cntr(wr_addr'range));
		end if;
	end process;

	process (mii_txc)
		variable cntr : unsigned(0 to addr_size);
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				cntr := to_unsigned(mem_size-1, cntr'length);
			elsif cntr(0)='0' then
				cntr := cntr - 1;
			end if;
			rd_addr  <= std_logic_vector(cntr(rd_addr'range));
		end if;
	end process;

	mii_txen <= mii_treq and not rd_addr(0);
	mii_trdy <= mii_treq and     rd_addr(0);

end;
