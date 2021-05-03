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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;

entity udp is
	port (
		mii_clk     : in  std_logic;
		miirx_irdy  : in  std_logic;
		frmrx_ptr   : in  std_logic_vector;
		miirx_data  : in  std_logic_vector;

		plrx_frm    : out std_logic;
		plrx_irdy   : out std_logic;
		plrx_trdy   : in  std_logic;
		plrx_data   : out std_logic_vector;

		pltx_frm    : in  std_logic;
		pltx_irdy   : in  std_logic;
		pltx_trdy   : out std_logic;
		pltx_data   : in  std_logic_vector;

		udptx_frm   : out std_logic;
		udptx_irdy  : out std_logic;
		udptx_trdy  : in  std_logic;
		udptx_data  : out std_logic_vector);
end;

architecture def of udp is

	signal udprx_frm      : std_logic;
	signal udpsprx_irdy   : std_logic;
	signal udpdprx_irdy   : std_logic;
	signal udplenrx_irdy  : std_logic;
	signal udpcksmrx_irdy : std_logic;
	signal udpplrx_irdy   : std_logic;

	signal udprx_sp       : std_logic_vector(0 to 16-1);
	signal udprx_dp       : std_logic_vector(0 to 16-1);
	signal udprx_len      : std_logic_vector(0 to 16-1);

	signal udptx_end      : std_logic;
	signal udppl_irdy     : std_logic;
	signal udppltx_frm    : std_logic;
	signal udppltx_trdy   : std_logic;
	signal udppltx_data   : std_logic_vector(miitx_data'range);

begin

	udp_rx_e : entity hdl4fpga.udp_rx
	port map (
		mii_irdy     => miirx_irdy,
		mii_ptr      => frmrx_ptr,
		mii_data     => miirx_data,

		udp_frm      => udprx_frm,
		udpsp_irdy   => udpsprx_irdy,
		udpdp_irdy   => udpdprx_irdy,
		udplen_irdy  => udplenrx_irdy,
		udpcksm_irdy => udpcksmrx_irdy,
		udppl_irdy   => udpplrx_irdy);

	udprxlen_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => udprx_frm,
		ser_irdy   => udplenrx_irdy,
		ser_data   => miirx_data,
		des_data   => udprx_len);

	udprx_sp_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => udprx_frm,
		ser_irdy   => udpsprx_irdy,
		ser_data   => miirx_data,
		des_data   => udprx_sp);

	udprx_dp_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => udprx_frm,
		ser_irdy   => udpdprx_irdy,
		ser_data   => miirx_data,
		des_data   => udprx_dp);

	udptx_e : entity hdl4fpga.udp_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm    => udppltx_frm,
		pl_irdy   => udppltx_irdy,
		pl_trdy   => udppltx_trdy,
		pl_data   => udppltx_data,

		udp_cksm => udptx_cksm,
		udp_id   => udprx_id,
		udp_seq  => udprx_seq,
		udp_frm  => udptx_frm,
		udp_irdy => udptx_irdy,
		udp_trdy => udptx_trdy,
		udp_end  => udptx_end,
		udp_data => miitx_data);

end;
