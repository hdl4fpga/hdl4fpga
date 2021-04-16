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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity mii_ipoe is
	generic (
		default_ipv4a : std_logic_vector(0 to 32-1) := x"c0_a8_00_0e";
		my_mac        : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk       : in  std_logic;
		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic;
		miirx_trdy    : out std_logic;
		miirx_data    : in  std_logic_vector;

		miitx_frm     : out std_logic;
		miitx_irdy    : out std_logic;
		miitx_trdy    : in  std_logic;
		miitx_end     : buffer std_logic;
		miitx_data    : out std_logic_vector;

		tp            : out std_logic_vector(1 to 32));

end;

architecture def of mii_ipoe is


	signal frmrx_ptr    : std_logic_vector(0 to unsigned_num_bits((128*octect_size)/miirx_data'length-1));

	signal hwdarx_irdy  : std_logic;
	signal hwdarx_trdy  : std_logic;
	signal hwdarx_last  : std_logic;
	signal hwdarx_equ   : std_logic;
	signal hwdarx_vld   : std_logic;
	signal hwsarx_irdy  : std_logic;
	signal hwsarx_trdy  : std_logic;
	signal hwtyprx_irdy : std_logic;
	signal hwtyprx_trdy : std_logic;
	signal plrx_irdy    : std_logic;
	signal plrx_trdy    : std_logic;
	signal llc_last     : std_logic;
	signal arprx_equ    : std_logic;
	signal arprx_vld    : std_logic;
	signal iprx_equ     : std_logic;
	signal iprx_vld     : std_logic;
	signal fcs_sb       : std_logic;
	signal fcs_vld      : std_logic;

	signal arprx_frm    : std_logic;
	signal iprx_frm     : std_logic;

	signal arptx_frm    : std_logic;
	signal arptx_irdy   : std_logic;
	signal arptx_trdy   : std_logic;
	signal arptx_end    : std_logic;
	signal arptx_data   : std_logic_vector(miitx_data'range);

	signal hwsa_rx      : std_logic_vector(my_mac'range);
	signal ipv4arx_frm  : std_logic;
	signal ipv4arx_trdy : std_logic;
	signal ipv4arx_equ  : std_logic;
	signal ipv4arx_last : std_logic;
	signal ipv4arx_vld  : std_logic;

	signal arpdtx_req : std_logic;
	signal arpdtx_rdy : std_logic;
begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk    => mii_clk,
		mii_frm    => miirx_frm,
		mii_irdy   => miirx_irdy,
		mii_trdy   => miirx_trdy,
		mii_data   => miirx_data,

		eth_ptr    => frmrx_ptr,
		hwda_irdy  => hwdarx_irdy,
		hwsa_irdy  => hwsarx_irdy,
		hwtyp_irdy => hwtyprx_irdy,
		pl_irdy    => plrx_irdy,
		crc_sb     => fcs_sb,
		crc_equ    => fcs_vld);

	hwdacmp_e : entity hdl4fpga.sio_cmp
    port map (
		mux_data  => reverse(my_mac,8),
        sio_clk   => mii_clk,
        sio_frm   => miirx_frm,
        sio_irdy  => hwdarx_irdy,
        sio_trdy  => hwdarx_trdy,
        si_data   => miirx_data,
		so_last   => hwdarx_last,
		so_equ(0) => hwdarx_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if miirx_frm='0' then
				hwdarx_vld <= '0';
			elsif hwdarx_last='1' then
				hwdarx_vld <= hwdarx_equ;
			end if;
		end if;
	end process;

	hwsa_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => miirx_frm,
		ser_irdy   => hwdarx_irdy,
		ser_trdy   => hwdarx_trdy,
		ser_data   => miirx_data,
		des_irdy   => open,
		des_data   => hwsa_rx);

	llc_e : entity hdl4fpga.sio_cmp
	generic map (
		n => 2)
	port map (
		mux_data  => reverse(llc_arp & llc_ip,8),
        sio_clk   => mii_clk,
        sio_frm   => miirx_frm,
		sio_irdy  => hwtyprx_irdy,
		sio_trdy  => hwtyprx_trdy,
        si_data   => miirx_data,
		so_last   => llc_last,
		so_equ(0) => arprx_equ,
		so_equ(1) => iprx_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if miirx_frm='0' then
				arprx_vld <= '0';
			elsif llc_last='1' then
				arprx_vld <= arprx_equ;
			end if;
		end if;
	end process;
	arprx_frm <= miirx_frm and arprx_vld;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if miirx_frm='0' then
				iprx_vld <= '0';
			elsif llc_last='1' then
				iprx_vld <= iprx_equ;
			end if;
		end if;
	end process;
	iprx_frm <= miirx_frm and iprx_vld;

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_clk  => mii_clk,

		pl_frm   => arptx_frm,
		pl_irdy  => arptx_irdy,
		pl_trdy  => arptx_trdy,
		pl_end   => arptx_end,
		pl_data  => arptx_data,

		hwsa     => my_mac,
		hwda     => reverse(x"ffffffffffff",8),
		hwtyp    => reverse(x"0806",8),

		mii_frm  => miitx_frm,
		mii_irdy => miitx_irdy,
		mii_trdy => miitx_trdy,
		mii_end  => miitx_end,
		mii_data => miitx_data);

	ip4arx_e : entity hdl4fpga.sio_cmp
	port map (
		mux_data  => reverse(default_ipv4a,8),
        sio_clk   => mii_clk,
        sio_frm   => ipv4arx_frm,
		sio_irdy  => miirx_irdy,
		sio_trdy  => ipv4arx_trdy,
        si_data   => miirx_data,
        so_last   => ipv4arx_last,
		so_equ(0) => ipv4arx_equ);
	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if ipv4arx_frm='0' then
				ipv4arx_vld <= '0';
			elsif ipv4arx_last='1' then
				ipv4arx_vld <= ipv4arx_equ;
			end if;
		end if;
	end process;

	arpd_e : entity hdl4fpga.arpd
	port map (
		my_ipv4a   => default_ipv4a,
		my_mac     => my_mac,

		mii_clk    => mii_clk,
		miirx_data => miirx_data,
		frmrx_ptr  => frmrx_ptr,

		arpdtx_req => arpdtx_rdy,
		arpdtx_rdy => arpdtx_rdy,
		arprx_frm  => arprx_frm,

		tparx_frm  => ipv4arx_frm,
		tparx_vld  => ipv4arx_vld,

		arptx_frm  => arptx_frm,
		arptx_irdy => arptx_irdy,
		arptx_trdy => arptx_trdy,
		arptx_end  => arptx_end,
		arptx_data => arptx_data,
		miitx_end  => miitx_end);

	ipv4_e : entity hdl4fpga.ipv4
	port map (
		mii_clk        => mii_clk,
		miirx_data    => miirx_data,
		frmrx_ptr  => frmrx_ptr,

		ipv4rx_frm     => iprx_frm,
		ipv4rx_irdy    => miirx_irdy,

		ipv4lenrx_irdy => open,
		ipv4protorx_irdy => open,
		ipv4sarx_irdy  => open,
		ipv4darx_frm   => open,
		ipv4darx_irdy  =>  open,
		ipv4plrx_irdy  => open,

--		ipv4tx_frm     : buffer std_logic := '0';
--		ipv4tx_irdy    : out std_logic;
--		ipv4tx_trdy    : in  std_logic;
--		ipv4tx_end     : out std_logic;
		ipv4tx_data    => miitx_data,
		miitx_end      => '1'

		);

end;
