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
		ipcfg_req   : in  std_logic := '-';

		phy_rxc     : in  std_logic;
		phy_rx_dv   : in  std_logic;
		phy_rx_d    : in  std_logic_vector;

		phy_txc     : in  std_logic;
		phy_tx_en   : out std_logic;
		phy_tx_d    : out std_logic_vector;
	
		chaini_sel  : in  std_logic;

		chaini_clk  : in  std_logic;
		chaini_frm  : in  std_logic;
		chaini_irdy : in  std_logic;
		chaini_data : in  std_logic_vector;

		chaino_clk  : out std_logic;
		chaino_frm  : out std_logic;
		chaino_irdy : out std_logic;
		chaino_data : out std_logic_vector);
	
end;

architecture beh of scopeio_udpipdaisy is

	signal udpso_dv   : std_logic;
	signal udpso_data : std_logic_vector(phy_rx_d'range);


begin

	assert phy_rx_d'length=chaini_data'length 
		report "phy_rx_d'lengthi not equal chaini_data'length"
		severity failure;

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

	chaino_clk  <= chaini_clk  when chaini_sel='1' else phy_rxc;
	chaino_frm  <= chaini_frm  when chaini_sel='1' else udpso_dv;
	chaino_irdy <= chaini_irdy when chaini_sel='1' else udpso_dv;
	chaino_data <= chaini_data when chaini_sel='1' else reverse(udpso_data);

end;
