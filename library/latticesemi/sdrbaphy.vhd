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

entity sdrbaphy is
	generic (
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		sys_clk : in  std_logic;

		phy_cs  : in  std_logic;
		phy_cke : in  std_logic;
		phy_b   : in  std_logic_vector(bank_size-1 downto 0);
		phy_a   : in  std_logic_vector(addr_size-1 downto 0);
		phy_ras : in  std_logic;
		phy_cas : in  std_logic;
		phy_we  : in  std_logic;

		sdr_rst : out std_logic;
		sdr_cs  : out std_logic;
		sdr_clk : out std_logic;
		sdr_cke : out std_logic;
		sdr_odt : out std_logic;
		sdr_ras : out std_logic;
		sdr_cas : out std_logic;
		sdr_we  : out std_logic;
		sdr_b   : out std_logic_vector(bank_size-1 downto 0);
		sdr_a   : out std_logic_vector(addr_size-1 downto 0));
end;

library ecp5u;
use ecp5u.components.all;

architecture ecp of sdrbaphy is
	
begin

	ck_i : oddrx1f
	port map (
		sclk => sys_clk,
		d0 => '0',
		d1 => '1',
		q  => sdr_clk);

	b_g : for i in 0 to bank_size-1 generate
	begin
		ffd_i : fd1s3ax
		port map (
			ck => sys_clk,
			d  => phy_b(i),
			q  => sdr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
	begin
		ffd_i : fd1s3ax
		port map (
			ck => sys_clk,
			d  => phy_a(i),
			q  => sdr_a(i));
	end generate;

	ras_i : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_ras,
		q  => sdr_ras);

	cas_i : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_cas,
		q  => sdr_cas);

	we_i : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_we,
		q  => sdr_we);

	cs_i : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_cs,
		q  => sdr_cs);

	cke_i : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_cke,
		q  => sdr_cke);

end;
