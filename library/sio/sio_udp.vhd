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

entity sio_udp is
	generic (
		default_ipv4a : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		mymac         : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		dchp_req  : in  std_logic;
		dchp_rcvd : in  std_logic;
		myip4a    : buffer std_logic_vector(0 to 32-1);

		sio_clk   : out std_logic;

		si_dv     : in  std_logic;
		si_data   : in  std_logic_vector);

		so_dv     : out std_logic;
		so_data   : out std_logic_vector);
end;

architecture struct of sio_udp is

	signal txc_rxd  : std_logic_vector(mii_rxd'range);
	signal txc_rxdv : std_logic;

	signal dll_rxdv        : std_logic;
	signal dllhwsa_rx      : std_logic_vector(0 to 48-1);
	signal dllcrc32_rxdv   : std_logic;
	signal dllcrc32_equ    : std_logic;
	signal dllcrc32_rxd    : std_logic_vector(mii_rxd'range);
	signal dllcrc32        : std_logic_vector(0 to 32-1);

	signal ipv4sa_rx       : std_logic_vector(0 to 32-1);
	signal udpsp_rx        : std_logic_vector(0 to 16-1);
	signal udpdp_rxdv      : std_logic;
	signal udppl_rxdv      : std_logic;

	signal mysrv_req       : std_logic;
	signal mysrv_rdy       : std_logic;
	signal mysrv_gnt       : std_logic;
	signal mysrv_hwda      : std_logic_vector(0 to 48-1);
	signal mysrv_ipv4da    : std_logic_vector(0 to 32-1);
	signal mysrv_udpdp     : std_logic_vector(0 to 16-1);
	signal mysrv_udpsp     : std_logic_vector(0 to 16-1);

	signal mysrv_udppltxd  : std_logic_vector(mii_rxd'range);
	signal mysrv_udppllen  : std_logic_vector(0 to 16-1);
	signal mysrv_udppltxen : std_logic;

begin

	mii_ipoe_e : entity hdl4fpga.mii_ipoe
	generic map (
		default_ipv4a => default_ipv4a,
		mymac         => mymac)
	port map (
		mii_rxc       => mii_rxc,
		mii_rxd       => mii_rxd,
		mii_rxdv      => mii_rxdv,

		mii_txc       => mii_txc,
		mii_txd       => mii_txd,
		mii_txen      => mii_txen,

		txc_rxdv      => txc_rxdv,
		txc_rxd       => txc_rxd,

		tx_req        => mysrv_req,
		tx_rdy        => mysrv_rdy,
		tx_gnt        => mysrv_gnt,
		dll_hwda      => mysrv_hwda,
		ipv4_da       => mysrv_ipv4da,
		dll_rxdv      => dll_rxdv,
		dllhwsa_rx    => dllhwsa_rx,
		dllcrc32_rxdv => dllcrc32_rxdv,
		dllcrc32_rxd  => dllcrc32_rxd,
		dllcrc32_equ  => dllcrc32_equ,

		ipv4sa_rx     => ipv4sa_rx,
		ipv4a_req     => dhcp_req,
                                      
		udpdp_rxdv    => udpdp_rxdv,
		udppl_rxdv    => udppl_rxdv,
		udpsp_rx      => udpsp_rx,
		udp_sp        => mysrv_udpsp,
		udp_dp        => mysrv_udpdp,
		udppl_len     => mysrv_udppllen,
		udppl_txen    => mysrv_udppltxen,
		udppl_txd     => mysrv_udppltxd);

	miisio_e : entity hdl4fpga.mii_siosrv
	generic map (
		mysrv_port => std_logic_vector(to_unsigned(57001, 16)),
		data       => to_ascii("Hello world"))
	port map (
		mii_txc       => mii_txc,
		mii_txd       => mii_txd,
                                      
		dll_rxdv      => dll_rxdv,
		dll_rxd       => txc_rxd,
                                      
		dllhwsa_rx    => dllhwsa_rx,
		dllcrc32_rxdv => dllcrc32_rxdv,
		dllcrc32_equ  => dllcrc32_equ,
                                      
		ipv4sa_rx     => ipv4sa_rx,
                                      
		udppl_rxdv    => udppl_rxdv,
		udpdp_rxdv    => udpdp_rxdv,
		udpsp_rx      => udpsp_rx,
                                      
		tx_rdy        => mysrv_rdy,
		tx_req        => mysrv_req,
		tx_gnt        => mysrv_gnt,
		dll_hwda      => mysrv_hwda,
		ipv4_da       => mysrv_ipv4da,
		udppl_len     => mysrv_udppllen,
		udp_dp        => mysrv_udpdp,
		udp_sp        => mysrv_udpsp,
		udppl_txen    => mysrv_udppltxen,
		udppl_txd     => mysrv_udppltxd);


end;
