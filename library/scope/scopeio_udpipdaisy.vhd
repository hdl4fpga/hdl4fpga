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
use hdl4fpga.scopeiopkg.all;

entity scopeio_udpipdaisy is
	generic (
		preamble_disable : boolean := false;
		crc_disable      : boolean := false
	);
	port (
		ipcfg_req   : in  std_logic := '-';

		phy_rxc     : in  std_logic;
		phy_rx_dv   : in  std_logic;
		phy_rx_d    : in  std_logic_vector;

		phy_txc     : in  std_logic;
		phy_tx_en   : out std_logic;
		phy_tx_d    : out std_logic_vector;
	
		chaini_sel  : in  std_logic := '0';

		chaini_clk  : in  std_logic := '0';
		chaini_frm  : in  std_logic := '0';
		chaini_irdy : in  std_logic := '0';
		chaini_data : in  std_logic_vector;

		chaino_clk  : out std_logic;
		chaino_frm  : out std_logic;
		chaino_irdy : out std_logic;
		chaino_data : out std_logic_vector);
	
end;

architecture beh of scopeio_udpipdaisy is

	constant ipaddr_size : std_logic_vector := x"03";
	constant xx : std_logic_vector := rid_ipaddr & ipaddr_size;

	signal udpso_dv   : std_logic;
	signal udpso_d    : std_logic_vector(phy_rx_d'range);

	signal hdr_trdy   : std_logic;
	signal hdr_dv     : std_logic;
	signal hdr_d      : std_logic_vector(phy_tx_d'range);

	signal ipaddr_dv  : std_logic;
	signal ipaddr_d   : std_logic_vector(phy_tx_d'range);

	signal myipcfg_dv : std_logic;
	signal mymac_dv : std_logic;
	signal frm : std_logic_vector(0 to 0);
begin

	assert phy_rx_d'length=chaini_data'length 
	report "phy_rx_d'length is not equal chaini_data'length"
	severity failure;

	miiip_e : entity hdl4fpga.scopeio_miiudp
	generic map (
		preamble_disable => preamble_disable,
		crc_disable      => crc_disable
	)
	port map (
		mii_rxc     => phy_rxc,
		mii_rxdv    => phy_rx_dv,
		mii_rxd     => phy_rx_d,

		mii_req     => ipcfg_req,
		mii_txc     => phy_txc,
		mii_txdv    => phy_tx_en,
		mii_txd     => phy_tx_d,

		myipcfg_vld => myipcfg_dv,
		mymac_vld => mymac_dv,
		so_dv       => udpso_dv,
		so_data     => udpso_d);

	hdr_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(xx,8))
    port map (
        mii_txc  => phy_rxc,
		mii_treq => myipcfg_dv,
		mii_trdy => hdr_trdy,
        mii_txdv => hdr_dv,
        mii_txd  => hdr_d);

	phy_rxd_e : entity hdl4fpga.align
	generic map (
		n => phy_rx_d'length,
		d => (0 to phy_rx_d'length-1 => xx'length/phy_rx_d'length))
	port map (
		clk => phy_rxc,
		di  => phy_rx_d,
		do  => ipaddr_d);

	phy_rxdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => xx'length/phy_rx_d'length))
	port map (
		clk   => phy_rxc,
		di(0) => myipcfg_dv,
		do(0) => ipaddr_dv);

	frm <= word2byte(word2byte(hdr_dv & ipaddr_dv, ipaddr_dv) & udpso_dv, udpso_dv);

	chaino_clk  <= chaini_clk  when chaini_sel='1' else phy_rxc;
	chaino_frm  <= chaini_frm  when chaini_sel='1' else frm(0); 
	chaino_irdy <= chaini_irdy when chaini_sel='1' else frm(0);
	chaino_data <= chaini_data when chaini_sel='1' else reverse(word2byte(word2byte(hdr_d  & ipaddr_d,  ipaddr_dv) & udpso_d,  udpso_dv));

end;
