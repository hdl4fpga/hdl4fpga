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
use hdl4fpga.base.all;

entity usbdev is
   	generic (
		oversampling : natural := 0;
		watermark    : natural := 0;
		bit_stuffing : natural := 6);
	port (
		tp   : out std_logic_vector(1 to 32);
		dp   : inout std_logic := 'Z';
		dn   : inout std_logic := 'Z';
		clk  : in  std_logic;
		cken : buffer std_logic;

		txen : in  std_logic := '0';
		txbs : buffer std_logic;
		txd  : in  std_logic := '-';

		rxdv : out std_logic;
		rxbs : buffer std_logic;
		rxd  : buffer std_logic);
end;

architecture def of usbdev is
		signal phy_txen : std_logic;
		signal phy_txbs : std_logic;
		signal phy_txd  : std_logic;

		signal phy_rxdv : std_logic;
		signal phy_rxbs : std_logic;
		signal phy_rxd  : std_logic;
begin

  	frwk_e : entity hdl4fpga.usbfrwk_dev
	port map (
		clk  => clk,
		cken => cken,

		txen => phy_txen,
		txbs => phy_txbs,
		txd  => phy_txd,

		rxdv => phy_rxdv,
		rxbs => phy_rxbs,
		rxd  => phy_rxd);

  	usbprtl_e : entity hdl4fpga.usbprtl
   	generic map (
		oversampling => oversampling,
		watermark    => watermark,
		bit_stuffing => bit_stuffing)
	port map (
		dp   => dp,
		dn   => dn,
		clk  => clk,
		cken => cken,

		txen => phy_txen,
		txbs => phy_txbs,
		txd  => phy_txd,

		rxdv => phy_rxdv,
		rxbs => phy_rxbs,
		rxd  => phy_rxd);
	tp(1) <= phy_txen or phy_rxdv;
	tp(2) <= phy_txbs or phy_rxbs;
	tp(3) <= phy_txd when phy_txen='1' else phy_rxd;
	txbs <= phy_txbs;
	rxbs <= phy_rxbs;

end;