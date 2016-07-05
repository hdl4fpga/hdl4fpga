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
		gear       : natural := 2;
		bank_size  : natural := 2;
		addr_size  : natural := 13);
	port (
		sys_clks : in  std_logic_vector;

		sys_rst  : in  std_logic_vector(gear-1 downto 0);
		sys_cs   : in  std_logic_vector(gear-1 downto 0);
		sys_cke  : in  std_logic_vector(gear-1 downto 0);
		sys_b    : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras  : in  std_logic_vector(gear-1 downto 0);
		sys_cas  : in  std_logic_vector(gear-1 downto 0);
		sys_we   : in  std_logic_vector(gear-1 downto 0);
		sys_odt  : in  std_logic_vector(gear-1 downto 0);

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

	signal rst : std_logic_vector(gear-1 downto 0);
	signal cs  : std_logic_vector(gear-1 downto 0);
	signal cke : std_logic_vector(gear-1 downto 0);
	signal b   : std_logic_vector(gear*bank_size-1 downto 0);
	signal a   : std_logic_vector(gear*addr_size-1 downto 0);
	signal ras : std_logic_vector(gear-1 downto 0);
	signal cas : std_logic_vector(gear-1 downto 0);
	signal we  : std_logic_vector(gear-1 downto 0);
	signal odt : std_logic_vector(gear-1 downto 0);

begin

	ba_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clks,
		d   => b,
		q   => ddr_b);

	a_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clks,
		d   => a,
		q   => ddr_a);

	ras_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clks,
		d   => ras,
		q   => ddr_ras);

	cas_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clks,
		d   => cas,
		q   => ddr_cas);

	we_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clks,
		d   => we,
		q   => ddr_we);

	cs_i : entity hdl4fpga.mdr
	port map (
		clk => sys_clk,
		d   => cs,
		q   => ddr_cs);

	cke_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d   => cke(0),
		q   => ddr_cke);

	odt_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d   => odt(0),
		q   => ddr_odt);

	rst_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d   => sys_rst(0),
		q   => ddr_rst);
end;
