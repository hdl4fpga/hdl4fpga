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

entity sdrdqphy is
	generic (
		byte_size : natural);
	port (
		sys_clk  : in  std_logic;
		phy_dmt  : in  std_logic;
		phy_dmi  : in  std_logic := '-';
		phy_dmo  : out std_logic;
		phy_dqo  : out std_logic_vector(byte_size-1 downto 0);
		phy_dqt  : in  std_logic;
		phy_dqi  : in  std_logic_vector(byte_size-1 downto 0);

		sdr_dmi  : in  std_logic := '-';
		sdr_dmt  : out std_logic;
		sdr_dmo  : out std_logic;
		sdr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		sdr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		sdr_dqo  : out std_logic_vector(byte_size-1 downto 0));

end;

library ecp5u;
use ecp5u.components.all;

architecture ecp of sdrdqphy is

begin
	iddr_g : for i in 0 to byte_size-1 generate
	begin
		ffdt_i : fd1s3ax
		port map (
			ck => sys_clk,
			d  => phy_dqt,
			q  => sdr_dqt(i));

		ffdi_i : fd1s3ax
		port map (
			ck => sys_clk,
			d  => sdr_dqi(i),
			q  => phy_dqo(i));
	end generate;

	dmi_g : fd1s3ax
	port map (
		ck => sys_clk,
		d  => sdr_dmi,
		q  => phy_dmo);

	dqo_g : for i in 0 to byte_size-1 generate
	begin
		ffd_i : fd1s3ax
		port map (
			ck => sys_clk,
			d  => phy_dqi(i),
			q  => sdr_dqo(i));
	end generate;

	dmo_g : fd1s3ax
	port map (
		ck => sys_clk,
		d  => phy_dmi,
		q  => sdr_dmo);

end;
