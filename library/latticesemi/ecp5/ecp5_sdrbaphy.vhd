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

entity ecp5_sdrbaphy is
	generic (
		clk_inv   : std_logic := '0';
		cmmd_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		rst     : in  std_logic;
		sclk    : in  std_logic;
		eclk    : in  std_logic;

		phy_rst : in  std_logic_vector(0 to cmmd_gear-1);
		phy_cs  : in  std_logic_vector(0 to cmmd_gear-1);
		phy_cke : in  std_logic_vector(0 to cmmd_gear-1);
		phy_b   : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		phy_a   : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		phy_ras : in  std_logic_vector(0 to cmmd_gear-1);
		phy_cas : in  std_logic_vector(0 to cmmd_gear-1);
		phy_we  : in  std_logic_vector(0 to cmmd_gear-1);
		phy_odt : in  std_logic_vector(0 to cmmd_gear-1);

		sdr_rst : out std_logic;
		sdr_cs  : out std_logic;
		sdr_ck  : out std_logic;
		sdr_cke : out std_logic;
		sdr_odt : out std_logic;
		sdr_ras : out std_logic;
		sdr_cas : out std_logic;
		sdr_we  : out std_logic;
		sdr_b   : out std_logic_vector(bank_size-1 downto 0);
		sdr_a   : out std_logic_vector(addr_size-1 downto 0));
end;

architecture ecp5 of ecp5_sdrbaphy is
begin

	ck_b : block
		signal ck : std_logic;
	begin
		ck_i : oddrx2f
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			d0   => '0' xor clk_inv,
			d1   => '1' xor clk_inv,
			d2   => '0' xor clk_inv,
			d3   => '1' xor clk_inv,
			q    => ck);

		delay_i : delayg
		generic map (
			del_value  => 0,
			del_mode => "DQS_CMD_CLK")
		port map (
			a => ck,
			z => sdr_ck);

	end block;

	b_g : for i in 0 to bank_size-1 generate
	begin
		oddr_i : oddrx1f
		port map (
			sclk => sclk,
			d0 => phy_b(cmmd_gear*i+0),
			d1 => phy_b(cmmd_gear*i+1),
			q  => sdr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
		oddr_i : oddrx1f
		port map (
			sclk => sclk,
			d0   => phy_a(cmmd_gear*i+0),
			d1   => phy_a(cmmd_gear*i+1),
			q    => sdr_a(i));
	end generate;

	ras_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_ras(0),
		d1   => phy_ras(1),
		q    => sdr_ras);

	cas_i :oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_cas(0),
		d1   => phy_cas(1),
		q    => sdr_cas);

	we_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_we(0),
		d1   => phy_we(1),
		q    => sdr_we);

	cs_b : block
		signal cs : std_logic;
	begin

		cs_i : oshx2a
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk, 
			d0   => phy_cs(0),
			d1   => phy_cs(1),
			q    => cs);

		delay_i : delayg
		generic map (
			del_mode => "DQS_ALIGNED_X2")
		port map (
			a => cs,
			z => sdr_cs);

	end block;

	cke_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_cke(0),
		d1   => phy_cke(1),
		q    => sdr_cke);

	odt_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_odt(0),
		d1   => phy_odt(1),
		q    => sdr_odt);

	rst_i : oddrx1f
	port map (
		sclk => sclk,
		d0   => phy_rst(0),
		d1   => phy_rst(1),
		q    => sdr_rst);

end;
