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
library ecp3;
use ecp3.components.all;

entity mii_iob is
	generic (
		xd_len : natural);
	port (
		mii_rxc  : in  std_logic := '-';
		mii_rxdv : out std_logic;
		mii_rxd  : out std_logic_vector(0 to xd_len-1);

		iob_rxdv : in  std_logic := '-';
		iob_rxd  : in  std_logic_vector(0 to xd_len-1) := (others => '-');

		mii_txc  : in  std_logic;
		mii_txen : in std_logic;
		mii_txd  : in std_logic_vector(0 to xd_len-1);

		iob_gtxclk : out std_logic;
		iob_txen : out std_logic;
		iob_txd  : out std_logic_vector(0 to xd_len-1));
end;

architecture def of mii_iob is
	attribute oddrapps : string;
	attribute oddrapps of gtx_clk_i : label is "SCLK_ALIGNED";
begin

	--------
	-- rx --
	--------

	rxdv_e : entity hdl4fpga.ff
	port map (
		clk => mii_rxc,
		d => iob_rxdv,
		q => mii_rxdv);

	rxd_e : for i in mii_rxd'range generate
		ffd_e : entity hdl4fpga.ff
		port map (
			clk => mii_rxc,
			d => iob_rxd(i),
			q => mii_rxd(i));
	end generate;

	--------
	-- tx --
	--------

	txen_e : entity hdl4fpga.ff
	port map (
		clk  => mii_txc,
		d => mii_txen,
		q => iob_txen);

	txd_e : for i in mii_txd'range generate
		ffd_e : entity hdl4fpga.ff
		port map (
			clk => mii_txc,
			d => mii_txd(i),
			q => iob_txd(i));
	end generate;

	gtx_clk_i : oddrxd1
	port map (
		sclk => mii_txc,
		da => '0',
		db => '1',
		q  => iob_gtxclk);
end;
