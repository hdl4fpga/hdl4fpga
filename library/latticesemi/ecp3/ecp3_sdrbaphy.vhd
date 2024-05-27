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

library ecp3;
use ecp3.components.all;

entity ecp3_sdrbaphy is
	generic (
		cmmd_gear  : natural := 2;
		bank_size  : natural := 2;
		addr_size  : natural := 13);
	port (
		sclk       : in  std_logic;
		sclk2x     : in  std_logic;

		phy_rst    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cs     : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cke    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_b      : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		phy_a      : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		phy_ras    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cas    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_we     : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_odt    : in  std_logic_vector(cmmd_gear-1 downto 0);

		sdr_rst    : out std_logic;
		sdr_cs     : out std_logic;
		sdr_ck     : out std_logic;
		sdr_cke    : out std_logic;
		sdr_odt    : out std_logic;
		sdr_ras    : out std_logic;
		sdr_cas    : out std_logic;
		sdr_we     : out std_logic;
		sdr_b      : out std_logic_vector(bank_size-1 downto 0);
		sdr_a      : out std_logic_vector(addr_size-1 downto 0));
end;

architecture ecp3 of ecp3_sdrbaphy is

	attribute oddrapps : string;
	attribute oddrapps of ck_i : label is "SCLK_CENTERED";
	attribute oddrapps of ras_i, cas_i, we_i, cs_i, cke_i, odt_i, rst_i : label is "SCLK_ALIGNED";

begin

	ck_i : oddrxd1
	port map (
		sclk => sclk2x,
		da   => '0',
		db   => '1',
		q    => sdr_ck);

	b_g : for i in 0 to bank_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sclk,
			da   => phy_b(cmmd_gear*i+0),
			db   => phy_b(cmmd_gear*i+1),
			q    => sdr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sclk,
			da   => phy_a(cmmd_gear*i+0),
			db   => phy_a(cmmd_gear*i+1),
			q    => sdr_a(i));
	end generate;

	ras_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_ras(0),
		db   => phy_ras(1),
		q    => sdr_ras);

	cas_i :oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cas(0),
		db   => phy_cas(1),
		q    => sdr_cas);

	we_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_we(0),
		db   => phy_we(1),
		q    => sdr_we);

	cs_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cs(0),
		db   => phy_cs(1),
		q    => sdr_cs);

	cke_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cke(0),
		db   => phy_cke(1),
		q    => sdr_cke);

	odt_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_odt(0),
		db   => phy_odt(1),
		q    => sdr_odt);

	rst_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_rst(0),
		db   => phy_rst(1),
		q    => sdr_rst);

end;
