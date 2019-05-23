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

entity scopeio_udpipdaisy is
	port (
		ipcfg_req       : in  std_logic := '-';

		phy_rxc         : in  std_logic;
		phy_rx_dv       : in  std_logic;
		phy_rx_d        : in  std_logic_vector := (0 to 0 => '-');

		ichaini_sel      : in  std_logic;

		ichaini_clk      : in  std_logic;
		ichaini_frm      : in  std_logic;
		ichaini_irdy     : in  std_logic;
		ichaini_data     : in  std_logic_vector;

		ichaino_clk      : out std_logic;
		ichaino_frm      : out std_logic;
		ichaino_irdy     : out std_logic;
		ichaino_data     : out std_logic_vector
	
		phy_txc         : in  std_logic;
		phy_tx_en       : out std_logic;
		phy_tx_d        : out std_logic_vector := (0 to 0 => '-')
	
		ochaini_sel      : in  std_logic;

		ochaini_clk      : in  std_logic;
		ochaini_frm      : in  std_logic;
		ochaini_irdy     : in  std_logic;
		ochaini_data     : in  std_logic_vector;

		ochaino_clk      : out std_logic;
		ochaino_frm      : out std_logic;
		ochaino_irdy     : out std_logic;
		ochaino_data     : out std_logic_vector);
	
end;

architecture beh of scopeio_udpipdaisy is
	signal pkt_data   : std_logic_vector(bridgeo_data'range);

	signal udpso_dv   : std_logic;
	signal udpso_data : std_logic_vector(phy_rx_d'range);

	signal strm_clk   : std_logic;
	signal strm_frm   : std_logic;
	signal strm_irdy  : std_logic;
	signal strm_data  : std_logic_vector(bridgeo_data'range);

	signal pktstrm_clk   : std_logic;
	signal pktstrm_frm   : std_logic;
	signal pktstrm_irdy  : std_logic;
	signal pktstrm_data  : std_logic_vector(bridgeo_data'range);

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

	pkt_clk  <= phy_rxc             when bridgeio_udpip else '-';
	pkt_frm  <= udpso_dv            when bridgeio_udpip else '-';
	pkt_data <= reverse(udpso_data) when bridgeio_udpip else (others => '-');

	chaino_clk  <= chaini_clk;
	chaino_frm  <= chaini_frm  when chaini_sel='1' else strm_frm; 
	chaino_irdy <= chaini_irdy when chaini_sel='1' else strm_irdy;
	chaino_data <= chaini_data when chaini_sel='1' else strm_data;

	pktdata_p : process (udpso_data, bridgeio_udpip, pkt_data)
	begin
		pkt_data <= (others => '-');
		if bridgeo_data'length=pkt_data'length then
			bridgeo_data <= pkt_data;
		end if;

		if bridgeo_stream='1' then
			if bridgeo_data'length=pktstrm_data'length then
				bridgeo_data <= pktstrm_data;
			end if;

			assert bridgeo_data'length=pktstrm_data'length 
			report "bridgeo_data'lengthi not equal pktstrm_data'length"
			severity warning;

		end if;
	end process;

end;
