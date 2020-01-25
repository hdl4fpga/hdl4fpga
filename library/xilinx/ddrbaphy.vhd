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

entity ddrbaphy is
	generic (
		DATA_EDGE  : string  := "OPPOSITE_EDGE";
		GEAR       : natural := 2;
		BANK_SIZE  : natural := 2;
		ADDR_SIZE  : natural := 13);
	port (
		phy_clks  : in  std_logic_vector(0 to 2-1);

		phy_rst1 : in  std_logic;
		phy_rst  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		phy_cs   : in  std_logic_vector(gear-1 downto 0);
		phy_cke  : in  std_logic_vector(gear-1 downto 0);
		phy_b    : in  std_logic_vector(gear*bank_size-1 downto 0);
		phy_a    : in  std_logic_vector(gear*addr_size-1 downto 0);
		phy_ras  : in  std_logic_vector(gear-1 downto 0);
		phy_cas  : in  std_logic_vector(gear-1 downto 0);
		phy_we   : in  std_logic_vector(gear-1 downto 0);
		phy_odt  : in  std_logic_vector(gear-1 downto 0);

		ddr_rst  : out std_logic;
		ddr_cs   : out std_logic;
		ddr_cke  : out std_logic;
		ddr_odt  : out std_logic;
		ddr_ras  : out std_logic;
		ddr_cas  : out std_logic;
		ddr_we   : out std_logic;
		ddr_b    : out std_logic_vector(bank_size-1 downto 0);
		ddr_a    : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture virtex of ddrbaphy is

begin

	rst_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_rst,
		q(0) => ddr_rst);

	cke_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_cke,
		q(0) => ddr_cke);

	cs_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_cs,
		q(0) => ddr_cs);

	ras_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_ras,
		q(0) => ddr_ras);

	cas_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_cas,
		q(0) => ddr_cas);

	we_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_we,
		q(0) => ddr_we);

	odt_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst1,
		clk  => phy_clks,
		d    => phy_odt,
		q(0) => ddr_odt);

	ba_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => ddr_b'length,
		gear => gear)
	port map (
		rst => phy_rst1,
		clk => phy_clks,
		d   => phy_b,
		q   => ddr_b);

	a_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => ddr_a'length,
		gear => gear)
	port map (
		rst => phy_rst1,
		clk => phy_clks,
		d   => phy_a,
		q   => ddr_a);

end;
