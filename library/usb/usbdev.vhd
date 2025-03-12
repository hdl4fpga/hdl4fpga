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
use hdl4fpga.usbpkg.all;

entity usbdev is
   	generic (
		oversampling  : natural := 0;
		watermark     : natural := 0;
		bit_stuffing  : natural := 6;
		device_dscptr : std_logic_vector := (
			reverse(x"12")    & -- bLength
			reverse(decriptortypes_ids(device)) & -- bDescriptorType
			reverse(x"0110")  & -- bcdUSB
			reverse(x"00")    & -- bDeviceClass
			reverse(x"00")    & -- bDeviceSubClass
			reverse(x"00")    & -- bDeviceProtocol
			reverse(x"40")    & -- bMaxPacketSize0
			reverse(x"1234")  & -- idVendor
			reverse(x"abcd")  & -- idProduct
			reverse(x"0100")  & -- bcdDevice
			reverse(x"01")    & -- iManufacturer
			reverse(x"00")    & -- iProduct
			reverse(x"00")    & -- iSerialNumber
			reverse(x"01"));    -- bNumConfigurations
		config_dscptr : std_logic_vector := (
			reverse(x"09")    & -- bLength
			reverse(decriptortypes_ids(config)) & -- bDescriptorType
			reverse(x"0020")  & -- wTotalLength
			reverse(x"01")    & -- bNumInterfaces
			reverse(x"01")    & -- bConfigurationValue
			reverse(x"00")    & -- iConfiguration
			reverse(x"c0")    & -- bmAttribute
			reverse(x"32"));    -- MaxPower
		string_dscptr : std_logic_vector := (
			reverse(x"04")    & 
			reverse(decriptortypes_ids(hdl4fpga.usbpkg.string)) & -- bDescriptorType
			reverse(x"0409")  &
			reverse(x"12")    & 
			reverse(decriptortypes_ids(hdl4fpga.usbpkg.string)) & -- bDescriptorType
			reverse(to_utf16("HDL4FPGA"),16));
		interface_dscptr : std_logic_vector := (
			reverse(x"09")    & -- bLength
			reverse(decriptortypes_ids(interface)) & -- bDescriptorType
			reverse(x"00")    & -- bInterfaceNumber
			reverse(x"00")    & -- bAlternateSetting
			reverse(x"02")    & -- bNumEndpoints
			reverse(x"00")    & -- bInterfaceClass
			reverse(x"00")    & -- bInterfaceSubClass
			reverse(x"00")    & -- bIntefaceProtocol
			reverse(x"00"));    -- iInterface
		endpoint_dscptr : std_logic_vector := (
			reverse(x"07")    & -- bLength
			reverse(decriptortypes_ids(endpoint)) & -- bDescriptorType
			reverse(x"01")    & -- bEndpointAddress
			reverse(x"02")    & -- bmAttibutes
			reverse(x"0040")  & -- wMaxPacketSize
			reverse(x"00")    & -- bInterval
			reverse(x"07")    & -- bLength
			reverse(decriptortypes_ids(endpoint)) & -- bDescriptorType
			reverse(x"81")    & -- bEndpointAddress
			reverse(x"02")    & -- bmAttibutes
			reverse(x"0040")  & -- wMaxPacketSize
			reverse(x"00")));   -- Interval
	port (
		tp   : out std_logic_vector(1 to 32);

		dp   : inout std_logic := 'Z';
		dn   : inout std_logic := 'Z';

		clk  : in  std_logic;
		cken : buffer std_logic;

		dev_addr : buffer std_logic_vector(0 to 7-1);
		dev_endp : buffer std_logic_vector(0 to 4-1);
		dev_cfgd : buffer std_logic;

		txen : in  std_logic := '-';
		txbs : out std_logic;
		txd  : in  std_logic := '-';

		rxdv : out std_logic;
		rxbs : inout std_logic;
		rxd  : out std_logic);
end;

architecture def of usbdev is
	signal tx_req    : std_logic := '0';
	signal tx_rdy    : std_logic := '0';
	signal pkt_txpid : std_logic_vector(4-1 downto 0);
	signal pkt_txen  : std_logic;
	signal pkt_txbs  : std_logic;
	signal pkt_txd   : std_logic;
	signal phy_txen  : std_logic;
	signal phy_txbs  : std_logic;
	signal phy_txd   : std_logic;

	signal rx_req    : std_logic := '0';
	signal rx_rdy    : std_logic := '0';
	signal phy_rxdv  : std_logic;
	signal phy_rxbs  : std_logic;
	signal phy_rxpid : std_logic_vector(4-1 downto 0);
	signal phy_rxpidv : std_logic;
	signal phy_rxd   : std_logic;

	signal rqst_rxdv : std_logic;
	signal rqst_rxbs : std_logic;
	signal rqst_rxd  : std_logic;
	signal rqst_txen : std_logic;
	signal rqst_txbs : std_logic;
	signal rqst_txd  : std_logic;

	signal phyerr    : std_logic;
	signal tkerr     : std_logic;
	signal crcerr    : std_logic;

	signal rqst_req    : bit;
	signal rqst_rdy    : bit;
	signal rqstin_req  : bit;
	signal rqstin_rdy  : bit;
	signal rqstack_req : bit;
	signal rqstack_rdy : bit;

	signal tkdata    : std_logic_vector(0 to 11-1);

	signal tp_phy    : std_logic_vector(1 to 32);
	signal tp_rqst   : std_logic_vector(1 to 32);
	signal tp_pkt    : std_logic_vector(1 to 32);

begin

	tp(1 to 3) <= tp_phy (1 to 3);
	tp(4 to 5) <= tp_rqst(11 to 12);
  	usbphycrc_e : entity hdl4fpga.usbphycrc
   	generic map (
		oversampling => oversampling,
		watermark    => watermark,
		bit_stuffing => bit_stuffing)
	port map (
		tp       => tp_phy,
		dp       => dp,
		dn       => dn,
		clk      => clk,
		cken     => cken,

		txen     => phy_txen,
		txbs     => phy_txbs,
		txd      => phy_txd,

		rxdv     => phy_rxdv,
		rxpid    => phy_rxpid,
		rxpidv   => phy_rxpidv,
		rxbs     => phy_rxbs,
		rxd      => phy_rxd,
		phyerr   => phyerr,
		tkerr    => tkerr,
		crcerr   => crcerr);

	usbpktrx_e : entity hdl4fpga.usbpkt_rx
	port map (
		clk      => clk,
		cken     => cken,
				   
		rx_req   => rx_req,
		rx_rdy   => rx_rdy,
				   
		rxpidv   => phy_rxpidv,
		rxdv     => phy_rxdv,
		rxpid    => phy_rxpid,
		tkdata   => tkdata,
		rxbs     => phy_rxbs,
		rxd      => phy_rxd,
		phyerr   => phyerr,
		tkerr    => tkerr,
		crcerr   => crcerr);

	usbpkttx_e : entity hdl4fpga.usbpkt_tx
	port map (
		tp        => tp_pkt,
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

	usbdevflow_e : entity hdl4fpga.usbdevflow
	port map (
		tp        => tp_rqst,

		clk       => clk,
		cken      => cken,

		rx_req    => rx_req,
		rx_rdy    => rx_rdy,
		rxpid     => phy_rxpid,
		rxdv      => phy_rxdv,
		rxbs      => phy_rxbs,
		rxd       => phy_rxd,
		tkdata    => tkdata,
		phyerr    => phyerr,
		tkerr     => tkerr,
		crcerr    => crcerr,
		rqstin_req  => rqstin_req,
		rqstin_rdy  => rqstin_rdy,
		rqstack_req => rqstack_req,
		rqstack_rdy => rqstack_rdy,

		tx_req    => tx_req,
		tx_rdy    => tx_rdy,

		txpid     => pkt_txpid,
		txen      => pkt_txen,
		txbs      => pkt_txbs,
		txd       => pkt_txd,

		dev_txen  => txen,
		dev_txbs  => txbs,
		dev_txd   => txd,
  
		dev_rxdv  => rxdv,
		dev_rxbs  => rxbs,
		dev_rxd   => rxd,
		dev_addr  => dev_addr,
		dev_endp  => dev_endp,
		dev_cfgd  => dev_cfgd,

		rqst_req  => rqst_req,
		rqst_rdy  => rqst_rdy,
		rqst_rxdv => rqst_rxdv,
		rqst_rxbs => rqst_rxbs,
		rqst_rxd  => rqst_rxd,
		rqst_txen => rqst_txen,
		rqst_txbs => rqst_txbs,
		rqst_txd  => rqst_txd);

	usbrqst_e : entity hdl4fpga.usbdevrqst
	generic map (
		device_dscptr    => device_dscptr,
		config_dscptr    => config_dscptr,  
		interface_dscptr => interface_dscptr,
		endpoint_dscptr  => endpoint_dscptr,
		string_dscptr    => string_dscptr)
	port map (
		clk       => clk,
		cken      => cken,

		dev_addr  => dev_addr,
		dev_cfgd  => dev_cfgd,
		rqst_req  => rqst_req,
		rqst_rdy  => rqst_rdy,
		in_req    => rqstin_req,
		in_rdy    => rqstin_rdy,
		ack_req   => rqstack_req,
		ack_rdy   => rqstack_rdy,
		phyerr    => phyerr,
		tkerr     => tkerr,
		crcerr    => crcerr,

		rxpidv    => rqst_rxdv,
		rxbs      => rqst_rxbs,
		rxd       => rqst_rxd,
		txen      => rqst_txen,
		txbs      => rqst_txbs,
		txd       => rqst_txd);

end;