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

		phy_dv : out std_logic;
		phy_bs : out std_logic;
		phy_d  : out std_logic;
		clk  : in  std_logic;
		cken : buffer std_logic;

		flush_req : in std_logic := '0';
		flush_rdy : buffer std_logic := '0';

		dev_addr    : in std_logic_vector(0 to 7-1) := (others => '0');
		dev_endp    : in std_logic_vector(0 to 4-1) := (others => '0');
		dev_ackrx   : out std_logic;
		dev_acktx   : out std_logic;
		tksetup_req : in std_logic := '0';
		tksetup_rdy : buffer std_logic := '0';
		tkstall_req : buffer std_logic := '0';
		tkstall_rdy : in  std_logic;
		tkin_req    : in std_logic;
		tkin_rdy    : buffer std_logic :='0';
		tkout_req   : in std_logic;
		tkout_rdy   : buffer std_logic :='0';
		sof_tick    : out std_logic;


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


	signal phyerr    : std_logic;
	signal tkerr     : std_logic;
	signal crcerr    : std_logic;

	signal tkdata    : std_logic_vector(0 to 11-1);

	signal tp_phy    : std_logic_vector(1 to 32);
	signal tp_rqst   : std_logic_vector(1 to 32);
	signal tp_pkt    : std_logic_vector(1 to 32);

begin

	tp(1 to 3) <= tp_phy (1 to 3);
	tp(4 to 7) <= tp_rqst(1 to 4);
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
		phy_dv   => phy_dv,
		phy_bs   => phy_bs,
		phy_d    => phy_d,

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
		tkdata   => tkdata,

		pkt_txpid => pkt_txpid,
		pkt_txen  => pkt_txen,
		pkt_txbs  => pkt_txbs,
		pkt_txd   => pkt_txd,

		phy_txen  => phy_txen,
		phy_txbs  => phy_txbs,
		phy_txd   => phy_txd);

	usbflow_e : entity hdl4fpga.usbhostflow
	port map (
		tp        => tp_rqst,

		clk       => clk,
		cken      => cken,
		flush_req => flush_req,
		flush_rdy => flush_rdy,
		tksetup_req => tksetup_req,
		tksetup_rdy => tksetup_rdy,
		tkstall_req => tkstall_req,
		tkstall_rdy => tkstall_rdy,
		tkin_req  => tkin_req,
		tkin_rdy  => tkin_rdy,
		tkout_req  => tkout_req,
		tkout_rdy  => tkout_rdy,
		sof_tick  => sof_tick,

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

		tx_req    => tx_req,
		tx_rdy    => tx_rdy,

		txpid     => pkt_txpid,
		txen      => pkt_txen,
		txbs      => pkt_txbs,
		txd       => pkt_txd,

		dev_ackrx => dev_ackrx,
		dev_acktx => dev_acktx,

		dev_txen  => txen,
		dev_txbs  => txbs,
		dev_txd   => txd,
  
		dev_rxdv  => rxdv,
		dev_rxbs  => rxbs,
		dev_rxd   => rxd,
		dev_addr  => dev_addr,
		dev_endp  => dev_endp);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbhostdvr is
   	generic (
		oversampling  : natural := 0;
		watermark     : natural := 0;
		bit_stuffing  : natural := 6);
	port (
		tp   : out std_logic_vector(1 to 32);

		dp   : inout std_logic := 'Z';
		dn   : inout std_logic := 'Z';
		phy_dv : out std_logic;
		phy_bs : out std_logic;
		phy_d  : out std_logic;

		clk  : in  std_logic;
		cken : buffer std_logic;

		setup_req : in std_logic := '0';
		setup_rdy : buffer std_logic := '0');

end;

architecture def of usbhostdvr is

	signal dev_addr    : std_logic_vector(7-1 downto 0);
	signal dev_endp    : std_logic_vector(4-1 downto 0);
	signal dev_ackrx   : std_logic;
	signal dev_acktx   : std_logic;
	signal flush_req   : std_logic;
	signal flush_rdy   : std_logic;
	signal tksetup_req : std_logic;
	signal tksetup_rdy : std_logic;
	signal tkstall_req : std_logic;
	signal tkstall_rdy : std_logic;
	signal tkin_req    : std_logic;
	signal tkout_req   : std_logic;
	signal tkout_rdy   : std_logic;
	signal tkin_rdy    : std_logic;
	signal sof_tick    : std_logic;

	signal dev_txen : std_logic;
	signal dev_txbs : std_logic;
	signal dev_txd  : std_logic;

	signal dev_rxdv : std_logic;
	signal dev_rxbs : std_logic := '0';
	signal dev_rxd  : std_logic;
	signal tp1 : std_logic_vector(1 to 32);
	signal tp2 : std_logic_vector(1 to 32);
begin

	tp <= tp2(1 to 8) & tp1(1 to 24);
	dev_rxbs <= '0';
	usbhost_e : entity hdl4fpga.usbhost
	generic map (
		oversampling  => oversampling,
		watermark     => watermark,
		bit_stuffing  => bit_stuffing)
	port map (
		tp        => tp2,
		dp        => dp,
		dn        => dn,
		clk       => clk,
		cken      => cken,
		phy_dv   => phy_dv,
		phy_bs   => phy_bs,
		phy_d    => phy_d,
		flush_req => flush_req,
		flush_rdy => flush_rdy,
		tksetup_req => tksetup_req,
		tksetup_rdy => tksetup_rdy,
		tkstall_req => tkstall_req,
		tkstall_rdy => tkstall_rdy,
		tkin_req  => tkin_req,
		tkin_rdy  => tkin_rdy,
		tkout_req => tkout_req,
		tkout_rdy => tkout_rdy,
		sof_tick  => sof_tick,
		dev_ackrx => dev_ackrx,
		dev_acktx => dev_acktx,
		dev_addr  => dev_addr,
		dev_endp  => dev_endp,
		txen      => dev_txen, 
		txbs      => dev_txbs,
		txd       => dev_txd,
		rxdv      => dev_rxdv, 
		rxbs      => dev_rxbs,
		rxd       => dev_rxd);

	rqstdvr_e : entity hdl4fpga.usbhostrqst
	port map (
		tp   => tp1,
		clk       => clk,
		cken      => cken,

		setup_req => setup_req,
		setup_rdy => setup_rdy,
		flush_req => flush_req,
		flush_rdy => flush_rdy,
		tksetup_req => tksetup_req,
		tksetup_rdy => tksetup_rdy,
		tkstall_req => tkstall_req,
		tkstall_rdy => tkstall_rdy,
		tkin_req => tkin_req,
		tkin_rdy => tkin_rdy,
		tkout_req => tkout_req,
		tkout_rdy => tkout_rdy,
		sof_tick  => sof_tick,

		dev_ackrx => dev_ackrx,
		dev_acktx => dev_acktx,
		dev_addr  => dev_addr,
		dev_endp  => dev_endp,

		rxdv      => dev_rxdv,
		rxbs      => dev_rxbs,
		rxd       => dev_rxd,
		txen      => dev_txen,
		txbs      => dev_txbs,
		txd       => dev_txd);

end;
