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

entity scopeio_bridge is
	generic (
		istream_esc : std_logic_vector := std_logic_vector(to_unsigned(character'pos('\'), 8));
		istream_eos : std_logic_vector := std_logic_vector(to_unsigned(character'pos(NUL), 8));

		udpip       : boolean := true);

	port (

		bridge_istream : in std_logic;
		bridge_udpip   : in std_logic;

		bridgeo_clk  : in  std_logic;
		bridgeo_frm  : out std_logic;
		bridgeo_irdy : out std_logic;
		bridgeo_data : out std_logic_vector;

		bridgei_clk  : in  std_logic;
		bridgei_frm  : in  std_logic;
		bridgei_irdy : in  std_logic;
		bridgei_data : in  std_logic_vector;

		ipcfg_req    : in  std_logic := '-';

		phy_rxc      : in  std_logic;
		phy_rx_dv    : in  std_logic;
		phy_rx_d     : in  std_logic_vector;

		phy_txc      : in  std_logic;
		phy_tx_en    : out std_logic;
		phy_tx_d     : out std_logic_vector;

		uart_rxc     : in  std_logic;
		uart_rxdv    : in  std_logic;
		uart_rxd     : in  std_logic_vector(8-1 downto 0));


end;

architecture beh of scopeio_bridge is
	signal udpso_dv   : std_logic;
	signal udpso_data : std_logic_vector(phy_rx_d'range);

	signal strm_clk   : std_logic;
	signal strm_frm   : std_logic;
	signal strm_irdy  : std_logic;
	signal strm_data  : std_logic_vector(si_data'range);

begin

	miiip_e : entity hdl4fpga.scopeio_miiudp
	port map (
		mii_rxc  => phy_rxc,
		mii_rxdv => phy_rx_dv,
		mii_rxd  => phy_rx_d,

		mii_req  => ipcfg_req,
		mii_txc  => phy_txc,
		mii_txdv => phy_tx_en,
		mii_txd  => phy_tx_d,

		so_dv    => udpso_dv,
		so_data  => udpso_data);

	strm_clk  <= uart_rxc  when uart else '-';
	strm_frm  <= uart_rxdv when uart else '-';
	strm_data <= uart_rxd  when uart else (others => '-');

	scopeio_istream_e : entity hdl4fpga.scopeio_istream
	generic map (
		esc => istream_esc,
		eos => istream_eos)
	port map (
		clk     => strm_clk,

		rxdv    => strm_frm,
		rxd     => strm_data,

		so_frm  => pktstrm_frm,
		so_irdy => pktstrm_irdy,
		so_data => pktstrm_data);

	pkt_clk  <= phy_rxc             when udpip else '-';
	pkt_frm  <= udpso_dv            when udpip else '-';
	pkt_data <= reverse(udpso_data) when udpip else (others => '-');

	bridgeo_clk  <= pktstrm_clk  when istream else pkt_clk;
	bridgeo_frm  <= pktstrm_frm  when istream else pkt_frm;
	bridgeo_irdy <= pktstrm_irdy when istream else '1';

	process (pktstrm_data, pkt_data)
	begin
		if istream then
			if bridg
		bridgeo_data <= pktstrm_data when istream else pkt_data;
	end process;

end;
