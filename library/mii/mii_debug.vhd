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

entity mii_debug is
	generic (
		cga_bitrom : std_logic_vector := (1 to 0 => '-');
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		btn       : in  std_logic:= '0';
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		video_clk : in  std_logic;
		video_dot : out std_logic;
		video_blank : out std_logic;
		video_hs  : out std_logic;
		video_vs  : out std_logic);
	end;

architecture struct of mii_debug is

	signal nodata : std_logic_vector(mii_txd'range);

	signal video_rxc  : std_logic;
	signal video_rxdv : std_logic;
	signal video_rxd  : std_logic_vector(mii_txd'range);
	signal myipcfg_vld: std_logic;
	signal udpdport_vld : std_logic_vector(0 to 0);
begin

--	mii_ipcfg_e : entity hdl4fpga.mii_ipcfg
--	generic map (
--		mac       => x"00_40_00_01_02_03")
--	port map (
--		mii_req   => mii_req,
--
--		mii_rxc   => mii_rxc,
--		mii_rxdv  => mii_rxdv,
--		mii_rxd   => mii_rxd,
--		udpdports_val => x"0000",
--		udpdports_vld => udpdport_vld,
--
--		myipcfg_vld =>  myipcfg_vld,
--		mii_txc   => mii_txc,
--		mii_txdv  => mii_txdv,
--		mii_txd   => mii_txd);
--
	video_rxc <= mii_rxc;
--	process (video_rxc)
--	begin
--		if rising_edge(video_rxc) then
--			video_rxdv <= myipcfg_vld; -- and udpdport_vld(0);
--			video_rxd  <= reverse(mii_rxd);
--		end if;
--	end process;

	udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
	port map (
		ipcfg_req   => mii_req,

		phy_rxc     => mii_rxc,
		phy_rx_dv   => mii_rxdv,
		phy_rx_d    => mii_rxd,

		phy_txc     => mii_txc, 
		phy_tx_en   => mii_txdv,
		phy_tx_d    => mii_txd,
	
		chaini_sel  => '0',

		chaini_data => nodata,

		chaino_frm  => video_rxdv,
		chaino_data => video_rxd);
	
	mii_display_e : entity hdl4fpga.mii_display
	generic map (
		cga_bitrom => cga_bitrom)
	port map (
		mii_rxc   => video_rxc,
		mii_rxdv  => video_rxdv,
		mii_rxd   => video_rxd,

		video_clk => video_clk,
		video_dot => video_dot,
		video_blank => video_blank,
		video_hs  => video_hs,
		video_vs  => video_vs);

end;
