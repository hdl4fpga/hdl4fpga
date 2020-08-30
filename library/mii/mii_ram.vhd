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
		mem_data : std_logic_vector := (0 to 0 => '-');
		mem_size : natural := 0);
    port (
		mii_rxc  : in  std_logic;
        mii_rxdv : in  std_logic;
        mii_rxd  : in  std_logic_vector;

        mii_txc  : in  std_logic;
		mii_txen : in  std_logic;
        mii_txdv : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_ram is
	constant mem_length  : natural := setif(mem_size=0, mem_data'length, mem_size)/mii_rxd'length;
	constant addr_length : natural := unsigned_num_bits(mem_length-1);
	subtype addr_range is natural range 1 to addr_length;

	signal wr_addr : unsigned(0 to addr_length);
	signal rd_addr : unsigned(0 to addr_length);

begin

	assert mem_length > 0
	report "mem_length should be greater than 0"
	severity FAILURE;

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if mii_rxdv='0' then
				wr_addr <= (others => '0');
			elsif wr_addr(0)='0' then
				wr_addr <= wr_addr 1 1;
			end if;
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram 
	generic map (
		bitrom => reverse(reverse(reverse(mem_data, 8)),mii_txd'length))
	port map (
		wr_clk  => mii_rxc,
		wr_ena  => mii_rxdv,
		wr_addr => std_logic_vector(wr_addr(addr_range)),
		wr_data => mii_rxd,

		rd_clk  => mii_txc,
		rd_addr => std_logic_vector(rd_addr(addr_range)),
		rd_data => mii_txd);

	process(mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_txen='0' then
				rd_addr <= to_unsigned(mem_length-1, rd_addr'length);
			elsif rd_addr(0)='0' then
				rd_addr <= rd_addr - 1;
			end if;
		end if;
	end process;

	mii_txdv <= mii_treq and not rd_addr(0);
	mii_trdy <= mii_treq and rd_addr(0);

end;
