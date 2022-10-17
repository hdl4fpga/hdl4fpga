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
		data_edge  : string  := "SAME_EDGE";
		gear       : natural := 2;
		bank_size  : natural := 2;
		addr_size  : natural := 13);
	port (
		sys_clks  : in  std_logic_vector(0 to 2-1);

		phy_rst  : in  std_logic := '0';
		sys_rst  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_cs   : in  std_logic_vector(gear-1 downto 0);
		sys_cke  : in  std_logic_vector(gear-1 downto 0);
		sys_b    : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras  : in  std_logic_vector(gear-1 downto 0);
		sys_cas  : in  std_logic_vector(gear-1 downto 0);
		sys_we   : in  std_logic_vector(gear-1 downto 0);
		sys_odt  : in  std_logic_vector(gear-1 downto 0);

		sdram_rst  : out std_logic;
		sdram_cs   : out std_logic_vector;
		sdram_cke  : out std_logic_vector;
		sdram_odt  : out std_logic_vector;
		sdram_ras  : out std_logic;
		sdram_cas  : out std_logic;
		sdram_we   : out std_logic;
		sdram_b    : out std_logic_vector(bank_size-1 downto 0);
		sdram_a    : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture xc5v of xc5v_sdrbaphy is

begin

	rst_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_rst,
		q(0) => sdram_rst);

	cke_g : for i in sdram_cke'range generate
		cke_i : entity hdl4fpga.ogbx
		generic map (
			device => hdl4fpga.profiles.xc5v,
			data_edge => data_edge,
			size => 1,
			gear => gear)
		port map (
			rst  => phy_rst,
			clk  => sys_clks,
			d    => sys_cke,
			q(0) => sdram_cke(i));
	end generate;

	cs_g : for i in sdram_cs'range generate
		cs_i : entity hdl4fpga.ogbx
		generic map (
			device => hdl4fpga.profiles.xc5v,
			data_edge => data_edge,
			size => 1,
			gear => gear)
		port map (
			rst  => phy_rst,
			clk  => sys_clks,
			d    => sys_cs,
			q(0) => sdram_cs(i));
	end generate;

	ras_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_ras,
		q(0) => sdram_ras);

	cas_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_cas,
		q(0) => sdram_cas);

	we_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => 1,
		gear => gear)
	port map (
		rst  => phy_rst,
		clk  => sys_clks,
		d    => sys_we,
		q(0) => sdram_we);

	odt_g : for i in sdram_odt'range generate
		odt_i : entity hdl4fpga.ogbx
		generic map (
			device => hdl4fpga.profiles.xc5v,
			data_edge => data_edge,
			size => 1,
			gear => gear)
		port map (
			rst  => phy_rst,
			clk  => sys_clks,
			d    => sys_odt,
			q(0) => sdram_odt(i));
	end generate;

	ba_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => sdram_b'length,
		gear => gear)
	port map (
		rst => phy_rst,
		clk => sys_clks,
		d   => sys_b,
		q   => sdram_b);

	a_i : entity hdl4fpga.ogbx
	generic map (
		device => hdl4fpga.profiles.xc5v,
		data_edge => data_edge,
		size => sdram_a'length,
		gear => gear)
	port map (
		rst => phy_rst,
		clk => sys_clks,
		d   => sys_a,
		q   => sdram_a);

end;
