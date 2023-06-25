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
	signal tx_req    : std_logic;
	signal tx_rdy    : std_logic;
	signal pkt_txpid : std_logic_vector(4-1 downto 0);
	signal pkt_txen  : std_logic;
	signal pkt_txbs  : std_logic;
	signal pkt_txd   : std_logic;
	signal phy_txen  : std_logic;
	signal phy_txbs  : std_logic;
	signal phy_txd   : std_logic;

	signal rx_req    : std_logic;
	signal rx_rdy    : std_logic;
	signal phy_rxdv  : std_logic;
	signal phy_rxbs  : std_logic;
	signal phy_rxpid : std_logic_vector(4-1 downto 0);
	signal phy_rxd   : std_logic;

	signal rxtoken   : std_logic_vector(0 to 7+4+5-1);
	signal rxrqst    : std_logic_vector(0 to 8*8+8-1);

begin

  	usbphy_e : entity hdl4fpga.usbphyerr
   	generic map (
		oversampling => oversampling,
		watermark    => watermark,
		bit_stuffing => bit_stuffing)
	port map (
		tp    => tp,
		dp    => dp,
		dn    => dn,
		clk   => clk,
		cken  => cken,

		txen  => phy_txen,
		txbs  => phy_txbs,
		txd   => phy_txd,

		rxdv  => phy_rxdv,
		rxpid => phy_rxpid,
		rxbs  => phy_rxbs,
		rxd   => phy_rxd);

	usbpktrx_e : entity hdl4fpga.usbpkt_rx
	port map (
		clk      => clk,
		cken     => cken,
				   
		rx_req   => rx_req,
		rx_rdy   => rx_rdy,
				   
		rxdv     => phy_rxdv,
		rxpid    => phy_rxpid,
		rxbs     => phy_rxbs,
		rxd      => phy_rxd,
				   
		rxtoken  => rxtoken,
		rxrqst   => rxrqst);

	usbfiforx_e : entity hdl4fpga.usbfifo_rx
	port map (
		clk    => clk,
		cken   => cken,

		rxdv   => phy_rxdv,
		rxbs   => phy_rxbs,
		rxd    => phy_rxd);

	usbpkttx_e : entity hdl4fpga.usbpkt_tx
	port map (
		clk       => clk,
		cken      => cken,
	
		tx_req    => tx_req,
		tx_rdy    => tx_rdy,

		pkt_txpid => pkt_txpid,
		pkt_txen  => pkt_txen,
		pkt_txbs  => pkt_txbs,
		pkt_txd   => pkt_txd,

		phy_txen  => phy_txen,
		phy_txbs  => phy_txbs,
		phy_txd   => phy_txd);

	usbrqst_e : entity hdl4fpga.usbrqst_dev
	port map (
		clk     => clk,
		cken    => cken,

		rx_req  => rx_req,
		rx_rdy  => rx_rdy,
		rxpid   => phy_rxpid,

		rxtoken => rxtoken,
		rxrqst  => rxrqst,

		tx_req  => tx_req,
		tx_rdy  => tx_rdy,

		txpid   => pkt_txpid,
		txen    => pkt_txen,
		txbs    => pkt_txbs,
		txd     => pkt_txd);


	txbs <= phy_txbs;
	rxbs <= phy_rxbs;

end;