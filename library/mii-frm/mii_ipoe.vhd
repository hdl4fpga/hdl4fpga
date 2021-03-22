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
		default_ipv4a : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		my_mac        : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc       : in  std_logic;
		mii_rxd       : in  std_logic_vector;
		mii_rxdv      : in  std_logic;

		mii_txc       : in  std_logic;
		mii_col       : in  std_logic := '0';
		mii_crs       : in  std_logic := '0';
		mii_txd       : buffer std_logic_vector;
		mii_txen      : buffer std_logic;

		txc_rxd       : buffer std_logic_vector;
		txc_rxdv      : buffer std_logic;
		dll_rxdv      : buffer std_logic;

		dllfcs_sb     : out std_logic;
		dllfcs_vld    : buffer std_logic;

		dllhwda_rxdv  : buffer std_logic;
		dllhwsa_rxdv  : buffer std_logic;
		dlltype_rxdv  : buffer std_logic;

		dllhwsa_rx    : buffer std_logic_vector(0 to 48-1);

		tp            : out std_logic_vector(1 to 32));

end;

architecture def of mii_ipoe is


	constant icmp_gnt    : natural := 1;
	constant dhcp_gnt    : natural := 2;
	constant extern_gnt  : natural := 3;

	signal dev_gnt       : std_logic_vector(0 to 4-1);
	signal dev_req       : std_logic_vector(dev_gnt'range);
	signal pto_req       : std_logic_vector(dev_req'range);
	signal pto_gnt       : std_logic_vector(dev_gnt'range);

	alias arp_req        : std_logic is dev_req(arp_gnt);
	alias icmp_req       : std_logic is dev_req(icmp_gnt);
	alias dhcp_req       : std_logic is dev_req(dhcp_gnt);
	alias extern_req     : std_logic is dev_req(extern_gnt);

	signal dllhwda_equ   : std_logic;

	signal frmrx_ptr     : std_logic_vector(0 to unsigned_num_bits((128*octect_size)/mii_rxd'length-1));

	signal eth_txen      : std_logic;
	signal eth_txd       : std_logic_vector(mii_txd'range);

	signal arptpa_rxdv   : std_logic;

	signal typearp_rcvd  : std_logic;
	signal arp_irdy      : std_logic;
	signal arp_data      : std_logic_vector(mii_txd'range);


begin

	sync_b : block
		signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal dst_irdy : std_logic;
		signal dst_trdy : std_logic;
	begin
		rxc_rxbus <=  mii_rxdv & mii_rxd;
		rxc2txc_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 4,
			latency   => 0,
			check_sov => false,
			check_dov => true,
			gray_code => false)
		port map (
			src_clk  => mii_rxc,
			src_data => rxc_rxbus,
			dst_clk  => mii_txc,
			dst_irdy => dst_irdy,
			dst_trdy => dst_trdy,
			dst_data => txc_rxbus);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				dst_trdy <= to_stdulogic(to_bit(dst_irdy));
				txc_rxdv <= txc_rxbus(0);
				txc_rxd  <= txc_rxbus(1 to mii_rxd'length);
			end if;
		end process;

	end block;

	extern_req <= tx_req;
	tx_gnt <= dev_gnt(extern_gnt);

	arbiter_b : block
	begin

		process (dev_req, mii_txen, mii_txc)
			variable q    : std_logic_vector(dev_req'range);
			variable cntr : std_logic_vector(0 to 4);
			variable ena  : std_logic;
			variable txen : std_logic;
		begin
			if rising_edge(mii_txc) then

				if mii_txen='1' then
					cntr := (others => '0');
				elsif to_bit(cntr(0))='0' then
					cntr := std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(cntr))) + 1);
				end if;

				if to_bit(cntr(0))='1' then
					ena := '1';
				elsif to_bitvector(dev_gnt)=(dev_gnt'range => '0') then
					ena := '0';
				end if;

				dev_gnt <= pto_gnt and dev_req;
				pto_req <= (dev_req and (dev_req'range => ena)) or (q and (q'range => mii_txen));

				if to_bit(mii_txen)='0' or txen='0' then
					q := dev_req;
				end if;
				txen := mii_txen;
			end if;

		end process;

		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_txc,
			req => pto_req,
			gnt => pto_gnt);


		eth_txen <= setif(to_bitvector((pto_gnt and (arp_irdy & ip4_txen & ip4_txen & ip4_txen)))/=(dev_gnt'range => '0'));
	end block;

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk    => miirx_clk,
		mii_frm    => miirx_frm
		mii_irdy   => miirx_irdy,
		mii_trdy   => miirx_trdy,
		mii_data   => miirx_data,

		eth_ptr    => frmrx_ptr,
		eth_pre    => dll_rxdv,
		hwda_irdy  => hwdarx_irdy,
		hwda_trdy  => hwdarx_trdy,
		hwsa_irdy  => hwsarx_irdy,
		hwsa_trdy  => hwsarx_trdy,
		hwtyp_irdy => hwtyprx_irdy,
		hwtyp_trdy => hwtyprx_trdy,
		crc_sb     => dllfcs_sb,
		crc_sb     => dllfcs_sb,
		crc_equ    => dllfcs_vld);

	hwdacmp_e : entity hdl4fpga.sio_cmp
    port map (
		mem_data => reverse(my_mac,8),
        sio_clk  => mii_txc,
        sio_frm  => mii_rxfrm,
        sio_irdy => hwdarx_irdy,
        sio_trdy => hwdarx_trdy,
        si_data  => miirx_data,
        so_equ   => dllhwda_rxdv,
		mii_equ  => dllhwda_equ);

	hwsa_e : entity hdl4fpga.desser
	port map (
		serder_clk => mii_txc,
		serder_frm => mii_frm,
		ser_irdy   => hwdarx_irdy,
		ser_trdy   => hwdarx_trdy,
		des_irdy   => ,
		des_data   => dllhwsa_rx);

	llc_b : block
	begin
		arpllc_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(llc_arp,8))
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_ena  => dlltype_rxdv,
			mii_rxd  => txc_rxd,
			mii_equ  => typearp_rcvd);
	end block;

	type_tx <= wirebus(llc_arp         & llc_ip4      & llc_ip4         & llc_ip4,  pto_gnt);
	hwda_tx <= wirebus(x"ffffffffffff" & dllhwda_icmp & x"ffffffffffff" & dll_hwda, pto_gnt);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc   => mii_txc,
		hwsa      => my_mac,
		hwda      => hwda_tx,
		llc       => type_tx,
		pl_txen   => eth_txen,
		eth_rxd   => eth_txd,
		eth_txen  => mii_txen,
		eth_txd   => mii_txd);

	end block;

	arpd_e : entity hdl4fgpa.arpd
	port map (
		my_ipv4a   => default_ipv4a,
		my_mac     => my_mac,

		mii_clk    => mii_txc,
		frmrx_ptr  => frmrx_ptr,

		arpd_req   : in  std_logic;
		arpd_rdy   : buffer  std_logic;
		arprx_frm  : in  std_logic;
		arprx_irdy : in  std_logic;
		arprx_trdy : out std_logic;
		arprx_data : in  std_logic_vector;

		tparx_frm  : out std_logic;
		tparx_vld  : in  std_logic;

		arptx_frm  : buffer std_logic;
		arptx_irdy : out std_logic;
		arptx_trdy : in  std_logic;
		arptx_data : out std_logic_vector);

end;
