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
		half_duplex   : boolean := false;
		default_ipv4a : std_logic_vector(0 to 32-1);
		my_mac        : std_logic_vector(0 to 48-1));
	port (
		hdplx         : in  std_logic := '0';

		mii_clk       : in  std_logic;
		myhwa_vld     : out std_logic;
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : out std_logic := '0';

		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic := '1';
		miirx_trdy    : out std_logic := '1';
		miirx_data    : in  std_logic_vector;

		plrx_frm       : buffer std_logic;
		plrx_irdy      : buffer std_logic;
		plrx_trdy      : in  std_logic := '1';
		plrx_end       : out std_logic;
		plrx_data      : out std_logic_vector;

		pltx_frm       : in  std_logic;
		pltx_irdy      : in  std_logic;
		pltx_trdy      : out std_logic;
		pltx_end       : in  std_logic;
		pltx_data      : in  std_logic_vector;

		miitx_frm     : buffer std_logic;
		miitx_irdy    : buffer std_logic;
		miitx_trdy    : in  std_logic;
		miitx_end     : buffer std_logic;
		miitx_data    : out std_logic_vector;

		tp            : buffer std_logic_vector(1 to 32));

end;

architecture def of mii_ipoe is

	signal pream_vld     : std_logic;
	signal dllrx_frm     : std_logic;
	signal dllrx_irdy    : std_logic;
	signal dllrx_data    : std_logic_vector(plrx_data'range);
	signal metarx_frm    : std_logic;
	signal metarx_irdy   : std_logic;

	signal bcstrx_equ    : std_logic;

	signal hwda_frm      : std_logic;
	signal hwda_irdy     : std_logic;
	signal hwda_trdy     : std_logic;
	signal hwda_last     : std_logic;
	signal hwda_end      : std_logic;
	signal hwda_equ      : std_logic;
	signal hwda_vld      : std_logic;

	signal hwdarx_irdy   : std_logic;
	signal hwdarx_vld    : std_logic;
	signal hwsarx_irdy   : std_logic;
	signal hwsarx_trdy   : std_logic;
	signal hwtyprx_irdy  : std_logic;
	signal hwtyprx_trdy  : std_logic;
	signal ethplrx_trdy  : std_logic;
	signal llc_last      : std_logic;
	signal arprx_equ     : std_logic;
	signal arprx_vld     : std_logic;
	signal iprx_equ      : std_logic;
	signal iprx_vld      : std_logic;
	signal fcs_sb        : std_logic;
	signal fcs_vld       : std_logic;

	signal arprx_frm     : std_logic;
	signal tparx_frm     : std_logic;
	signal iprx_frm      : std_logic;

	signal ethtx_frm     : std_logic;
	signal ethtx_irdy    : std_logic;
	signal ethpltx_irdy  : std_logic;
	signal ethpltx_trdy  : std_logic;
	signal ethpltx_end   : std_logic;
	signal ethpltx_data  : std_logic_vector(miitx_data'range);

	signal arptx_frm     : std_logic;
	signal arptx_irdy    : std_logic;
	signal arptx_trdy    : std_logic;
	signal arptx_end     : std_logic;
	signal arptx_data    : std_logic_vector(miitx_data'range);

	signal ipv4tx_frm    : std_logic;
	signal ipv4tx_irdy   : std_logic;
	signal ipv4tx_trdy   : std_logic;
	signal ipv4tx_end    : std_logic;
	signal ipv4tx_data   : std_logic_vector(miitx_data'range);

	signal ipv4plrx_frm  : std_logic;
	signal ipv4plrx_cmmt : std_logic;
	signal ipv4plrx_rllbk : std_logic;
	signal ipv4plrx_irdy : std_logic;
	signal ipv4plrx_trdy : std_logic;
	signal ipv4plrx_data : std_logic_vector(miitx_data'range);

	signal hwtyp_tx      : std_logic_vector(0 to 16-1);

	signal hwllctx_irdy  : std_logic;
	signal hwllctx_trdy  : std_logic;
	signal hwllctx_end   : std_logic;
	signal hwllctx_data  : std_logic_vector(pltx_data'range);

	signal ipv4hwda_frm  : std_logic;
	signal ipv4hwda_irdy : std_logic;

	signal ipv4arx_trdy  : std_logic;
	signal ipv4arx_equ   : std_logic;
	signal ipv4arx_last  : std_logic;
	signal ipv4darx_frm  : std_logic;
	signal ipv4darx_irdy : std_logic;

	signal ipv4sarx_frm  : std_logic;
	signal ipv4sarx_irdy : std_logic;
	signal ipv4sarx_trdy : std_logic;
	signal ipv4sarx_end  : std_logic;
	signal ipv4sarx_equ  : std_logic;

	signal ipv4satx_frm  : std_logic :='0';
	signal ipv4satx_trdy : std_logic :='0';
	signal ipv4satx_irdy : std_logic :='0';
	signal ipv4satx_end  : std_logic :='1';
	signal ipv4satx_data : std_logic_vector(miitx_data'range);

	signal metatx_irdy   : std_logic;
	signal metatx_end    : std_logic;

	signal arptxmac_full  : std_logic;
	signal arptxmac_trdy  : std_logic;
	signal ipv4txmac_full : std_logic;
	signal ipv4txmac_trdy : std_logic;
	signal mactx_full    : std_logic;

	signal fifo_frm      : std_logic;
	signal fifo_irdy     : std_logic;
	signal fifo_trdy     : std_logic;
	signal fifoo_end     : std_logic;
	signal fifoo_irdy    : std_logic;
	signal fifoo_trdy    : std_logic;
	signal fifo_data     : std_logic_vector(miitx_data'range);

	signal fifo_cmmt     : std_logic;
	signal fifo_avail    : std_logic;
	signal fifo_rllbk    : std_logic;

	signal tagtx_irdy      : std_logic;
	signal tagtx_trdy    : std_logic;

	signal tag_frm       : std_logic;
	signal tag_irdy      : std_logic;
	signal tag_end       : std_logic;
	signal tag_trdy      : std_logic;
	signal tag_data      : std_logic_vector(miitx_data'range);

	signal arp_req       : std_logic;
	signal arp_rdy       : std_logic;

	signal ipv4_tp : std_logic_vector(1 to 32);
begin

	process (pltx_frm, pltx_irdy, tagtx_trdy, mii_clk)
		variable cntr : unsigned(0 to 4);
	begin
		if rising_edge(mii_clk) then
			if pltx_frm='0' then
				cntr := (others => '0');
			elsif cntr(0)='0' then
				if pltx_irdy='1' then
					cntr := cntr + pltx_data'length;
				end if;
			end if;
		end if;

		if pltx_frm='0' then
			tagtx_irdy <= '0';
			pltx_trdy  <= '0';
		elsif cntr(0)='1' then
			tagtx_irdy <= pltx_irdy;
			pltx_trdy  <= tagtx_trdy;
		else
			tagtx_irdy <= '0';
			pltx_trdy  <= '1';
		end if;
	end process;

	ethrrx_b : block
		signal dll_frm    : std_logic;
		signal hwtyp_irdy : std_logic;
		signal hwda_irdy  : std_logic;
		signal hwsa_irdy  : std_logic;
		signal dll_irdy   : std_logic;
		signal dll_data   : std_logic_vector(dllrx_data'range);
		signal dll_sb     : std_logic;
		signal dll_vld    : std_logic;
	begin
		ethrx_e : entity hdl4fpga.eth_rx
		port map (
			mii_clk    => mii_clk,
			mii_frm    => miirx_frm,
			mii_irdy   => miirx_irdy,
			mii_data   => miirx_data,
	
			dll_frm    => dll_frm,
			dll_irdy   => dll_irdy,
			dll_trdy   => open,
			dll_data   => dll_data,
	
			hwda_irdy  => hwda_irdy,
			hwda_end   => hwda_end,
			hwsa_irdy  => hwsa_irdy,
			hwtyp_irdy => hwtyp_irdy,
			pl_irdy    => open,
			pl_trdy    => open,
			fcs_sb     => dll_sb,
			fcs_vld    => dll_vld);


		buffer_p : process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				dllrx_frm    <= dll_frm;
				dllrx_irdy   <= dll_irdy;
				dllrx_data   <= dll_data;
				hwtyprx_irdy <= hwtyp_irdy;
				hwdarx_irdy  <= hwda_irdy;
				hwsarx_irdy  <= hwsa_irdy;
				fcs_sb       <= dll_sb;
				fcs_vld      <= dll_vld;
			end if;
		end process;

	end block;


	bcstcmp_b : block
		constant all1s : std_logic_vector := (0 to dllrx_data'length-1 => '1');
	begin
		bcstcmp_e : entity hdl4fpga.sio_cmp
		port map (
			si_clk    => mii_clk,
			si_frm    => dllrx_frm,
			si1_irdy  => hwdarx_irdy,
			si1_trdy  => open,
			si1_data  => all1s,
			si2_irdy  => hwdarx_irdy,
			si2_trdy  => open,
			si2_data  => dllrx_data,
			si_equ    => bcstrx_equ);
	end block;

	hwda_frm <=
		dllrx_frm when hwdarx_vld='0' else
		ipv4hwda_frm;

	hwda_irdy <=
		hwdarx_irdy when hwdarx_vld='0' else
		ipv4hwda_irdy;

	hwdacmp_e : entity hdl4fpga.sio_muxcmp
    port map (
		mux_data  => reverse(my_mac,8),
        sio_clk   => mii_clk,
        sio_frm   => hwda_frm,
        sio_irdy  => hwdarx_irdy,
        sio_trdy  => hwda_trdy,
        si_data   => dllrx_data,
		so_last   => hwda_last,
		so_end    => hwda_end,
		so_equ(0) => hwda_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dllrx_frm='0' then
				hwdarx_vld <= '0';
			elsif hwda_last='1' and dllrx_irdy='1' then
				hwdarx_vld <= hwda_equ or bcstrx_equ;
			end if;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dllrx_frm='0' then
				hwda_vld <= '0';
			elsif hwda_last='1' and dllrx_irdy='1' then
				hwda_vld <= hwda_equ;
			end if;
		end if;
	end process;
	myhwa_vld <= hwda_vld;


	llc_e : entity hdl4fpga.sio_muxcmp
	generic map (
		n => 2)
	port map (
		mux_data  => reverse(llc_arp & llc_ip,8),
        sio_clk   => mii_clk,
        sio_frm   => dllrx_frm,
		sio_irdy  => hwtyprx_irdy,
		sio_trdy  => hwtyprx_trdy,
        si_data   => dllrx_data,
		so_last   => llc_last,
		so_equ(0) => arprx_equ,
		so_equ(1) => iprx_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dllrx_frm='0' then
				arprx_vld <= '0';
			elsif llc_last='1' and dllrx_irdy='1' then
				arprx_vld <= arprx_equ;
			end if;
		end if;
	end process;
	arprx_frm <= dllrx_frm and arprx_vld and hwdarx_vld;
	tp(1) <= arprx_frm;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dllrx_frm='0' then
				iprx_vld <= '0';
			elsif llc_last='1' and dllrx_irdy='1' then
				iprx_vld <= iprx_equ;
			end if;
		end if;
	end process;
	iprx_frm <= dllrx_frm and iprx_vld and hwda_vld; -- hwdarx_vld;

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
		signal dev_csc : std_logic;
		signal gnt     : std_logic_vector(dev_gnt'range);
	begin

		dev_csc <= not miirx_frm when hdplx='1' else '1';
		dev_req <= arptx_frm & ipv4tx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			csc => dev_csc,
			req => dev_req,
			gnt => gnt);

		tp(2 to 3) <= dev_gnt;
		dev_gnt <= gnt;
		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
			end if;
		end process;

		ethtx_frm    <= wirebus(arptx_frm  & ipv4tx_frm,  dev_gnt);
		ethtx_irdy   <= wirebus(arptx_irdy & ipv4tx_irdy, dev_gnt);
		ethpltx_end  <= wirebus(arptx_end  & ipv4tx_end,  dev_gnt);
		ethpltx_data <= wirebus(arptx_data & ipv4tx_data, dev_gnt);
		(0 => arptx_trdy,    1 => ipv4tx_trdy)    <= dev_gnt and (dev_gnt'range => ethpltx_trdy);
		(0 => arptxmac_full, 1 => ipv4txmac_full) <= dev_gnt and (dev_gnt'range => mactx_full);
		(0 => arptxmac_trdy, 1 => ipv4txmac_trdy) <= dev_gnt;

		hwtyp_tx     <= wirebus(reverse(x"0806",8) & reverse(x"0800",8), dev_gnt);

	end block;

	meta_b : block

		signal hwsatx_irdy  : std_logic;
		signal hwsatx_trdy  : std_logic;
		signal hwsatx_end   : std_logic;
		signal hwsatx_data  : std_logic_vector(pltx_data'range);

		signal hwdatx_irdy  : std_logic;
		signal hwdatx_trdy  : std_logic;
		signal hwdatx_end   : std_logic;
		signal hwdatx_full  : std_logic;
		signal hwdatx_data  : std_logic_vector(pltx_data'range);

		signal hwtyptx_irdy : std_logic;
		signal hwtyptx_trdy : std_logic;
		signal hwtyptx_end  : std_logic;
		signal hwtyptx_data : std_logic_vector(pltx_data'range);

	begin

		hwdatx_irdy <= hwllctx_irdy;
		hwda_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => my_mac'length)
		port map (
			si_clk   => mii_clk,
			si_frm   => ethtx_frm,
			si_irdy  => ethtx_irdy,
			si_trdy  => open,
			si_full  => mactx_full,
			si_data  => ethpltx_data,

			so_clk   => mii_clk,
			so_frm   => ethtx_frm,
			so_irdy  => hwdatx_irdy,
			so_trdy  => hwdatx_trdy,
			so_end   => hwdatx_end,
			so_data  => hwdatx_data);

		hwsatx_irdy <= '0' when hwdatx_end='0' else hwllctx_irdy;
		hwsa_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => reverse(my_mac,8),
			sio_clk  => mii_clk,
			sio_frm  => ethtx_frm,
			sio_irdy => hwsatx_irdy,
			sio_trdy => hwsatx_trdy,
			so_end   => hwsatx_end,
			so_data  => hwsatx_data);

		hwtyptx_irdy <= '0' when hwsatx_end='0' else hwllctx_irdy;
		hwtyp_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => hwtyp_tx,
			sio_clk  => mii_clk,
			sio_frm  => ethtx_frm,
			sio_irdy => hwtyptx_irdy,
			sio_trdy => hwtyptx_trdy,
			so_end   => hwllctx_end,
			so_data  => hwtyptx_data);

		hwllctx_data <= primux(
			hwdatx_data    & hwsatx_data,
			not hwdatx_end & not hwsatx_end,
			hwtyptx_data);

	end block;

	ethpltx_irdy <= ethtx_irdy;
	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_clk     => mii_clk,

		metatx_irdy => '1',
		metatx_end  => mactx_full,
		hwllc_irdy  => hwllctx_irdy,
		hwllc_end   => hwllctx_end,
		hwllc_data  => hwllctx_data,

		pl_frm      => ethtx_frm,
		pl_irdy     => ethpltx_irdy,
		pl_trdy     => ethpltx_trdy,
		pl_end      => ethpltx_end,
		pl_data     => ethpltx_data,

		mii_frm     => miitx_frm,
		mii_irdy    => miitx_irdy,
		mii_trdy    => miitx_trdy,
		mii_end     => miitx_end,
		mii_data    => miitx_data);

	arpd_e : entity hdl4fpga.arpd
	generic map (
		hwsa       => my_mac)
	port map (
		mii_clk    => mii_clk,

		arpdtx_req => arp_req,
		arpdtx_rdy => arp_rdy,
		arprx_frm  => arprx_frm,
		arprx_irdy => dllrx_irdy,
		arprx_data => dllrx_data,

		sparx_irdy => ipv4sarx_irdy,
		sparx_trdy => ipv4sarx_trdy,
		sparx_end  => ipv4sarx_end,
		sparx_equ  => ipv4sarx_equ,

		spatx_frm  => ipv4satx_frm,
		spatx_irdy => ipv4satx_irdy,
		spatx_trdy => ipv4satx_trdy,
		spatx_end  => ipv4satx_end,
		spatx_data => ipv4satx_data,

		arpdtx_frm  => arptx_frm,
		dlltx_full  => arptxmac_full,
		dlltx_trdy  => arptxmac_trdy,
		arpdtx_irdy => arptx_irdy,
		arpdtx_trdy => arptx_trdy,
		arpdtx_end  => arptx_end,
		arpdtx_data => arptx_data);

		tp(4 to 5 ) <= ipv4_tp(1 to 2);
	ipv4_e : entity hdl4fpga.ipv4
	generic map (
		default_ipv4a => default_ipv4a)
	port map (
		tp => ipv4_tp,
		mii_clk       => mii_clk,
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,
		arp_req       => arp_req,
		arp_rdy       => arp_rdy,

		dll_frm       => dllrx_frm,
		dll_irdy      => hwsarx_irdy,
		fcs_sb        => fcs_sb,
		fcs_vld       => fcs_vld,
		ipv4rx_frm    => iprx_frm,
		ipv4rx_irdy   => dllrx_irdy,
		ipv4rx_data   => dllrx_data,

		ipv4sarx_frm  => dllrx_frm,
		ipv4sarx_irdy => ipv4sarx_irdy,
		ipv4sarx_trdy => ipv4sarx_trdy,
		ipv4sarx_end  => ipv4sarx_end,
		ipv4sarx_equ  => ipv4sarx_equ,

		hwda_frm      => ipv4hwda_frm,
		hwda_irdy     => ipv4hwda_irdy,
		hwda_trdy     => hwda_trdy,
		hwda_last     => hwda_last,
		hwda_equ      => hwda_equ,
		hwdarx_vld    => hwdarx_vld,

		ipv4satx_frm  => ipv4satx_frm,
		ipv4satx_irdy => ipv4satx_irdy,
		ipv4satx_trdy => ipv4satx_trdy,
		ipv4satx_end  => ipv4satx_end,
		ipv4satx_data => ipv4satx_data,

		plrx_frm      => ipv4plrx_frm,
		plrx_cmmt     => ipv4plrx_cmmt,
		plrx_rllbk    => ipv4plrx_rllbk,
		plrx_irdy     => ipv4plrx_irdy,
		plrx_trdy     => open, --ipv4plrx_trdy,
		plrx_data     => ipv4plrx_data,

		pltx_frm      => pltx_frm,
		pltx_irdy     => tagtx_irdy,
		pltx_trdy     => tagtx_trdy,
		pltx_end      => pltx_end,
		pltx_data     => pltx_data,

		ipv4tx_frm    => ipv4tx_frm,
		mactx_full    => ipv4txmac_full,
		mactx_trdy    => ipv4txmac_trdy,
		ipv4tx_irdy   => ipv4tx_irdy,
		ipv4tx_trdy   => ipv4tx_trdy,
		ipv4tx_end    => ipv4tx_end,
		ipv4tx_data   => ipv4tx_data);

	cmmt_p : process (fcs_vld, fcs_sb, mii_clk)
		variable q : std_logic;
		variable c : std_logic;
	begin
		if rising_edge(mii_clk) then
			if dllrx_frm='0' then
				q := '0';
				c := '1';
			elsif fifo_irdy='1' and fifo_trdy='0' then
				q := '0';
				c := '0';
			elsif ipv4plrx_cmmt='1' then
				q := c;
			end if;
		end if;
		fifo_cmmt <= fcs_sb and fcs_vld and q;
	end process;
	fifo_rllbk <= (fcs_sb and not fcs_vld) or not fifo_frm;

	fifo_frm  <= dllrx_frm or fcs_sb;
	fifo_irdy <= hwsarx_irdy or ipv4plrx_irdy;
	fifo_e : entity hdl4fpga.txn_buffer
	generic map (
		m => 11)
	port map(
		src_clk   => mii_clk,
		src_frm   => fifo_frm,
		src_irdy  => fifo_irdy,
		src_trdy  => fifo_trdy,
		src_data  => ipv4plrx_data,

		rollback  => fifo_rllbk,
		commit    => fifo_cmmt,
		avail     => fifo_avail,

		dst_frm   => tag_frm,
		dst_irdy  => fifoo_irdy,
		dst_trdy  => fifoo_trdy,
		dst_end   => fifoo_end,
		dst_data  => fifo_data);

	tag_frm_p : process (mii_clk)
		variable frm : bit;
	begin
		if rising_edge(mii_clk) then
			if frm='0' then
				if fifo_avail='1' then
					frm := '1';
				end if;
			elsif fifoo_end='1' and plrx_trdy='1' then
				frm := '0';
			end if;
			tag_frm <= to_stdulogic(frm);
		end if;
	end process;
	plrx_end <= fifoo_end;

	fifoo_irdy  <= '0' when tag_end='0'   else plrx_trdy;
	tag_irdy    <= fifoo_trdy;
	tag_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(x"000d",8),
		sio_clk  => mii_clk,
		sio_frm  => tag_frm,
		sio_irdy => tag_irdy,
		sio_trdy => tag_trdy,
		so_end   => tag_end,
		so_data  => tag_data);

	plrx_frm  <= tag_frm;
	plrx_irdy <=
		'0'      when tag_frm='0' else
		tag_trdy when to_bit(tag_end)='0' else
		not fifoo_end and fifoo_trdy;
	plrx_data <=
		tag_data when to_bit(tag_end)='0' else
		fifo_data;

end;
