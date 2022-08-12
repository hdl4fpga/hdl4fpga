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

entity xc5v_sdrbaphy is
	generic (
		DATA_EDGE  : string  := "OPPOSITE_EDGE";
		GEAR       : natural := 2;
		BANK_SIZE  : natural := 2;
		ADDR_SIZE  : natural := 13);
	port (
		sys_clks  : in  std_logic_vector(0 to 2-1);

		phy_rst  : in  std_logic;
		sys_rst  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_cs   : in  std_logic_vector(gear-1 downto 0);
		sys_cke  : in  std_logic_vector(gear-1 downto 0);
		sys_b    : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras  : in  std_logic_vector(gear-1 downto 0);
		sys_cas  : in  std_logic_vector(gear-1 downto 0);
		sys_we   : in  std_logic_vector(gear-1 downto 0);
		sys_odt  : in  std_logic_vector(gear-1 downto 0);

		sdr_rst  : out std_logic;
		sdr_cs   : out std_logic;
		sdr_cke  : out std_logic;
		sdr_odt  : out std_logic;
		sdr_ras  : out std_logic;
		sdr_cas  : out std_logic;
		sdr_we   : out std_logic;
		sdr_b    : out std_logic_vector(bank_size-1 downto 0);
		sdr_a    : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture virtex of xc5v_sdrbaphy is

begin

	rst_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_rst,
		q(0) => sdr_rst);

	cke_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_cke,
		q(0) => sdr_cke);

	cs_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_cs,
		q(0) => sdr_cs);

	ras_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_ras,
		q(0) => sdr_ras);

	cas_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_cas,
		q(0) => sdr_cas);

	we_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_we,
		q(0) => sdr_we);

	odt_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_odt,
		q(0) => sdr_odt);

	ba_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => sdr_b'length,
		gear => gear)
	port map (
		rst => phy_rst,
		clk => sys_clks,
		d   => sys_b,
		q   => sdr_b);

	a_i : entity hdl4fpga.omdr
	generic map (
		DATA_EDGE => DATA_EDGE,
		size => sdr_a'length,
		gear => gear)
	port map (
		rst => phy_rst,
		clk => sys_clks,
		d   => sys_a,
		q   => sdr_a);

end;
