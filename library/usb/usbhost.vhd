-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbhost is
   	generic (
		oversampling  : natural := 0;
		watermark     : natural := 0;
		bit_stuffing  : natural := 6);
	port (
		tp   : out std_logic_vector(1 to 32);

		dp   : inout std_logic := 'Z';
		dn   : inout std_logic := 'Z';

		clk  : in  std_logic;
		cken : buffer std_logic;

		dev_addr : buffer std_logic_vector(0 to 7-1);
		dev_endp : buffer std_logic_vector(0 to 4-1);
		dev_cfgd : buffer std_logic;
		setup_req : in std_logic;
		setup_rdy : buffer std_logic;

		txen : in  std_logic := '-';
		txbs : out std_logic;
		txd  : in  std_logic := '-';

		rxdv : out std_logic;
		rxbs : inout std_logic;
		rxd  : out std_logic);
end;

architecture def of usbhost is
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

	usbdevflow_e : entity hdl4fpga.usbhostflow
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

	usbrqst_e : entity hdl4fpga.usbhostrqst
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

