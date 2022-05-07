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

library ecp5u;
use ecp5u.components.all;

entity ecp5_ddrbaphy is
	generic (
		cmmd_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		rst     : in  std_logic;
		sclk    : in  std_logic;
		eclk    : in  std_logic;

		phy_rst : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cs  : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cke : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_b   : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		phy_a   : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		phy_ras : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cas : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_we  : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_odt : in  std_logic_vector(cmmd_gear-1 downto 0);

		ddr_rst : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ck  : out std_logic;
		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0));
end;

architecture lscc of ecp5_ddrbaphy is

	attribute oddrapps : string;
	attribute oddrapps of ras_i, cas_i, we_i, cs_i, cke_i, odt_i, rst_i : label is "SCLK_ALIGNED";
	attribute oddrapps of ck_i : label is "SCLK_CENTERED";
	signal cs : std_logic;
begin

	ck_i : oddrx2f
	port map (
		sclk => sclk,
		eclk => eclk,
		d0   => '0',
		d1   => '1',
		d2   => '0',
		d3   => '1',
		q    => ddr_ck);

	b_g : for i in 0 to bank_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrx1f
		port map (
			sclk => sclk,
			d0 => phy_b(cmmd_gear*i+0),
			d1 => phy_b(cmmd_gear*i+1),
			q  => ddr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrx1f
		port map (
			sclk => sclk,
			d0   => phy_a(cmmd_gear*i+0),
			d1   => phy_a(cmmd_gear*i+1),
			q    => ddr_a(i));
	end generate;

	ras_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_ras(0),
		d1   => phy_ras(1),
		q    => ddr_ras);

	cas_i :oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_cas(0),
		d1   => phy_cas(1),
		q    => ddr_cas);

	we_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_we(0),
		d1   => phy_we(1),
		q    => ddr_we);

	cs_i : oshx2a
	port map (
		rst  => rst,
		sclk => sclk,
		eclk => eclk, 
		d0   => phy_cs(0),
		d1   => phy_cs(0),
		q    => ddr_cs);

	cke_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_cke(0),
		d1   => phy_cke(0),
		q    => ddr_cke);

	odt_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_odt(0),
		d1   => phy_odt(0),
		q    => ddr_odt);

	rst_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_rst(0),
		d1   => phy_rst(0),
		q    => ddr_rst);

end;
