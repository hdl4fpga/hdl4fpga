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

entity ipv4 is
	generic (
		default_ipv4a : std_logic_vector);
	port (

		mii_clk       : in  std_logic;
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : out std_logic := '0';
		arp_req       : out std_logic;
		arp_rdy       : in  std_logic;

		dll_frm       : in  std_logic := '1';
		dll_irdy      : in  std_logic := '1';
		ipv4rx_frm    : in  std_logic;
		ipv4rx_irdy   : in  std_logic;
		ipv4rx_data   : in  std_logic_vector;

		ipv4hwda_frm  : out std_logic;
		ipv4sarx_frm  : in  std_logic;
		ipv4sarx_irdy : in  std_logic;
		ipv4sarx_trdy : buffer std_logic;
		ipv4sarx_end  : buffer std_logic;
		ipv4sarx_equ  : buffer std_logic;

		ipv4satx_frm  : in  std_logic;
		ipv4satx_irdy : in  std_logic;
		ipv4satx_trdy : buffer std_logic;
		ipv4satx_end  : buffer std_logic;
		ipv4satx_data : buffer std_logic_vector;

		hwda_frm      : out std_logic;
		hwda_irdy     : out std_logic;
		hwda_trdy     : in  std_logic;
		hwda_last     : in  std_logic;
		hwda_equ      : in  std_logic;
		hwdarx_vld    : in  std_logic;

		plrx_frm      : buffer std_logic;
		plrx_irdy     : out std_logic;
		plrx_trdy     : in  std_logic;
		plrx_cmmt     : out std_logic;
		plrx_rllbk    : out std_logic;
		plrx_data     : out std_logic_vector;

		pltx_frm      : in  std_logic;
		pltx_irdy     : in  std_logic;
		pltx_trdy     : out std_logic;
		pltx_end      : in  std_logic;
		pltx_data     : in  std_logic_vector;


		mactx_irdy    : out std_logic;
		mactx_full     : in  std_logic;

		ipv4tx_frm    : buffer std_logic := '0';
		ipv4tx_irdy   : buffer std_logic;
		ipv4tx_trdy   : in  std_logic := '1';
		ipv4tx_end    : buffer std_logic := '0';
		ipv4tx_data   : buffer std_logic_vector;

		tp            : out std_logic_vector(1 to 32));

end;

architecture def of ipv4 is


	signal ipv4len_tx       : std_logic_vector(ipv4tx_data'range);
	signal ipv4sa_tx        : std_logic_vector(ipv4tx_data'range);
	signal ipv4proto_tx     : std_logic_vector(0 to 8-1);
	signal ipv4atx_frm      : std_logic;
	signal ipv4atx_irdy     : std_logic;
	signal ipv4atx_trdy     : std_logic;
	signal ipv4atx_data     : std_logic_vector(pltx_data'range);
	signal ipv4atx_end      : std_logic;
	signal ipv4da_vld       : std_logic;
	signal ipv4bcst_vld     : std_logic;
	signal ipv4plrx_frm     : std_logic;
	signal ipv4plrx_irdy    : std_logic;

	signal ipv4pltx_irdy    : std_logic;
	signal ipv4pltx_trdy    : std_logic;
	signal ipv4pltx_end     : std_logic;
	signal ipv4pltx_data    : std_logic_vector(ipv4tx_data'range);
	signal ppltx_data       : std_logic_vector(ipv4tx_data'range);

	signal icmprx_frm       : std_logic;
	signal icmprx_irdy      : std_logic;
	signal icmprx_equ       : std_logic;
	signal icmprx_vld       : std_logic;
	signal icmptx_frm       : std_logic;
	signal icmptx_irdy      : std_logic;
	signal icmptx_trdy      : std_logic;
	signal icmptx_end       : std_logic;
	signal icmptx_data      : std_logic_vector(ipv4tx_data'range);

	signal udpplrx_frm      : std_logic;
	signal udpplrx_irdy     : std_logic;
	signal udpplrx_trdy     : std_logic;
	signal udpplrx_data     : std_logic_vector(ipv4rx_data'range);

	signal udprx_frm        : std_logic;
	signal udprx_equ        : std_logic;
	signal udprx_vld        : std_logic;

	signal udptx_frm        : std_logic;
	signal udptx_irdy       : std_logic;
	signal udptx_trdy       : std_logic;
	signal udptx_end        : std_logic;
	signal udptx_data       : std_logic_vector(ipv4tx_data'range);

	signal protorx_last     : std_logic;

	signal ipv4protorx_irdy : std_logic;
	signal ipv4rxsa_irdy    : std_logic;
	signal ipv4lenrx_irdy   : std_logic;
	signal ipv4arx_last     : std_logic;
	signal ipv4arx_equ      : std_logic;

	signal ipv4darx_frm     : std_logic;
	signal ipv4darx_irdy    : std_logic;
	signal ipv4sawr_frm     : std_logic;
	signal ipv4sawr_irdy    : std_logic;
	signal ipv4sawr_data    : std_logic_vector(ipv4rx_data'range);

	signal ipv4satx_full    : std_logic;
	signal ipv4datx_full    : std_logic;


	signal ipv4len_irdy     : std_logic;
	signal ipv4len_trdy     : std_logic;
	signal ipv4len_end      : std_logic;
	signal ipv4len_data     : std_logic_vector(ipv4rx_data'range);

	signal ipv4proto_irdy   : std_logic;
	signal ipv4proto_trdy   : std_logic;
	signal ipv4proto_end    : std_logic;
	signal ipv4proto_data   : std_logic_vector(ipv4rx_data'range);

	signal icmp_gnt         : std_logic;
	signal udp_gnt          : std_logic;

	signal udpmactx_irdy    : std_logic;
	signal icmpmactx_irdy   : std_logic;
	signal ipdatx_irdy      : std_logic;

	signal iplentx_irdy     : std_logic;
	signal icmpiplentx_irdy : std_logic;
	signal udpiplentx_irdy  : std_logic;

	signal iplentx_full     : std_logic;

	signal metatx_end       : std_logic;
	signal metatx_irdy      : std_logic;

		signal ipv4sanll_vld  :std_logic := '0';

		signal tp1            : std_logic_vector(1 to 32);
begin

	plrx_frm  <= ipv4rx_frm;
	plrx_irdy <= to_stdulogic(to_bit(plrx_frm and (ipv4rxsa_irdy or udpplrx_irdy)));

	ipv4rx_e : entity hdl4fpga.ipv4_rx
	port map (
		mii_clk        => mii_clk,
		ipv4_data      => ipv4rx_data,
		ipv4_frm       => ipv4rx_frm,
		ipv4_irdy      => ipv4rx_irdy,

		ipv4len_irdy   => ipv4lenrx_irdy,
		ipv4proto_irdy => ipv4protorx_irdy,
		ipv4sa_irdy    => ipv4rxsa_irdy,
		ipv4da_frm     => ipv4darx_frm,
		ipv4da_irdy    => ipv4darx_irdy,

		pl_frm         => ipv4plrx_frm,
		pl_irdy        => ipv4plrx_irdy);

	ipv4satx_b : block
		signal ipv4sard_frm  : std_logic;
		signal ipv4sard_irdy : std_logic;

		signal ipv4sa_frm    : std_logic;
		signal ipv4sa_irdy   : std_logic;
		signal ipv4sa_data   : std_logic_vector(ipv4rx_data'range);
		signal ipv4bcstrx_equ : std_logic;
		signal ipv4sanll_equ : std_logic;
	begin

		ipv4sa_frm  <= ipv4sarx_frm;
		ipv4sa_irdy <= ipv4sarx_irdy or ipv4darx_irdy;

		sarx_e : entity hdl4fpga.sio_ram
		generic map (
			mem_data   => reverse(default_ipv4a,8),
			mem_length => 32)
		port map (
			si_clk  => mii_clk,
			si_frm  => ipv4sawr_frm,
			si_irdy => ipv4sawr_irdy,
			si_trdy => open,
			si_full => open,
			si_data => ipv4sawr_data,

			so_clk  => mii_clk,
			so_frm  => ipv4sa_frm,
			so_irdy => ipv4sa_irdy,
			so_trdy => ipv4sarx_trdy,
			so_end  => ipv4sarx_end,
			so_data => ipv4sa_data);

		nll_e : entity hdl4fpga.sio_muxcmp
		port map (
			mux_data  => reverse(x"00_00_00_00",8),
			sio_clk   => mii_clk,
			sio_frm   => ipv4sawr_frm,
			sio_irdy  => ipv4sawr_irdy,
			sio_trdy  => open,
			si_data   => ipv4sawr_data,
			so_last   => open,
			so_equ(0) => ipv4sanll_equ);

		null_p : process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				if ipv4sawr_frm='1' then
					if ipv4satx_full='0' then
						if ipv4sawr_irdy='1' then
							ipv4sanll_vld <= ipv4sanll_equ;
						end if;
					end if;
				end if;
			end if;
		end process;

		bcst_e : entity hdl4fpga.sio_muxcmp
		port map (
			mux_data  => reverse(x"ff_ff_ff_ff",8),
			sio_clk   => mii_clk,
			sio_frm   => ipv4sa_frm,
			sio_irdy  => ipv4sa_irdy,
			sio_trdy  => open,
			si_data   => ipv4rx_data,
			so_last   => open,
			so_equ(0) => ipv4bcstrx_equ);

		sarxcmp_e : entity hdl4fpga.sio_cmp
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4sa_frm,
			si1_irdy => ipv4sa_irdy,
			si1_trdy => open,
			si1_data => ipv4sa_data,
			si2_irdy => ipv4sa_irdy,
			si2_trdy => open,
			si2_data => ipv4rx_data,
			si_equ   => ipv4sarx_equ);

		ipbcst_p : process (ipv4sarx_end, mii_clk)
			variable q : std_logic;
		begin
			if rising_edge(mii_clk) then
				if ipv4rx_frm='0' then
					q  := '0';
				elsif ipv4sarx_end='0' then
					if ipv4sa_irdy='1' then
						q := ipv4bcstrx_equ;
					end if;
				end if;
			end if;
			ipv4bcst_vld <= ipv4sarx_end and q;
		end process;

		ipv4a_p : process (ipv4sarx_end, mii_clk)
			variable q : std_logic;
		begin
			if rising_edge(mii_clk) then
				if ipv4rx_frm='0' then
					q  := '0';
				elsif ipv4sarx_end='0' then
					if ipv4sa_irdy='1' then
						q := ipv4sarx_equ or ipv4bcstrx_equ or ipv4sanll_vld;
					end if;
				end if;
			end if;
			ipv4da_vld <= ipv4sarx_end and q;
		end process;

		ipv4sard_frm  <= to_stdulogic(to_bit(ipv4satx_frm  or ipv4atx_frm));
		ipv4sard_irdy <= to_stdulogic(to_bit(ipv4satx_irdy or ipv4atx_irdy));
		satx_e : entity hdl4fpga.sio_ram
		generic map (
			mem_data => reverse(default_ipv4a,8),
			mem_length => 32)
		port map (
			si_clk  => mii_clk,
			si_frm  => ipv4sawr_frm,
			si_irdy => ipv4sawr_irdy,
			si_trdy => open,
			si_full => ipv4satx_full,
			si_data => ipv4sawr_data,

			so_clk  => mii_clk,
			so_frm  => ipv4sard_frm,
			so_irdy => ipv4sard_irdy,
			so_trdy => ipv4satx_trdy,
			so_end  => ipv4satx_end,
			so_data => ipv4satx_data);

	end block;

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
		signal icmpdatx_irdy   : std_logic;
		signal icmplentx_irdy  : std_logic;
		signal udpipdatx_irdy    : std_logic;
		signal icmpipdatx_irdy  : std_logic;
	begin

		dev_req <= icmptx_frm & udptx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			req => dev_req,
			gnt => dev_gnt);

		(icmp_gnt, udp_gnt) <= dev_gnt;

		ipv4tx_frm    <= wirebus(icmptx_frm  & udptx_frm,  dev_gnt)(0);
		ipv4pltx_irdy <= wirebus(icmptx_irdy & udptx_irdy, dev_gnt)(0);
		ipv4pltx_end  <= wirebus(icmptx_end  & udptx_end,  dev_gnt)(0);
		ipv4pltx_data <= wirebus(icmptx_data & udptx_data, dev_gnt);
		ipv4proto_tx  <= wirebus(reverse(ipv4proto_icmp & ipv4proto_udp,8), dev_gnt);

		(0 => icmptx_trdy, 1 => udptx_trdy) <= dev_gnt and (dev_gnt'range => ipv4pltx_trdy); 

		ipdatx_irdy     <= wirebus(icmpipdatx_irdy & udpipdatx_irdy, dev_gnt)(0);
		udpipdatx_irdy  <= 
			'0' when mactx_full='0'    else
			'1';
		icmpipdatx_irdy <= '0' when iplentx_full='0' else '1';

		iplentx_irdy  <= wirebus(icmpiplentx_irdy & udpiplentx_irdy, dev_gnt)(0);
	end block;

	meta_b : block

		signal ipv4da_irdy  : std_logic;
		signal ipv4da_trdy  : std_logic;
		signal ipv4da_data  : std_logic_vector(ipv4rx_data'range);

		signal len_datai  : std_logic_vector(pltx_data'range);
		signal ldatai  : std_logic_vector(pltx_data'range);
		signal len  : std_logic_vector(0 to 16);
	begin

		len_b : block
			signal crtn_data  : std_logic_vector(pltx_data'range);
			signal datai : std_logic_vector(0 to 16-1);
			signal datao : std_logic_vector(0 to 16-1);
			signal tx_ci : std_logic;
			signal tx_co : std_logic;
		begin

			mux_e : entity hdl4fpga.sio_mux
			port map (
				mux_data => reverse(reverse(std_logic_vector(to_unsigned((summation(ipv4hdr_frame)/octect_size),16))), crtn_data'length),
				sio_clk  => mii_clk,
				sio_frm  => udptx_frm,
				sio_irdy => iplentx_irdy,
				sio_trdy => open,
				so_data  => crtn_data);

			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
					if udptx_frm='0' then
						tx_ci <= '0';
					elsif pltx_irdy='1' then
						tx_ci <= tx_co;
					end if;
				end if;
			end process;

			tx_sum_e : entity hdl4fpga.adder
			port map (
				ci  => tx_ci,
				a   => ipv4pltx_data,
				b   => crtn_data,
				s   => len_datai,
				co  => tx_co);

			ldatai <= ipv4pltx_data when icmp_gnt='1' else len_datai;
			lenrgtr_e : entity hdl4fpga.sio_ff
			port map (
				si_clk  => mii_clk,
				si_frm  => ipv4tx_frm,
				si_irdy => iplentx_irdy,
				si_trdy => open,
				si_full => iplentx_full,
				si_data => ldatai,
				so_data => datai);

			datao <= reverse(datai) when icmp_gnt='1' else datai;
			muxi_e : entity hdl4fpga.sio_mux
			port map (
				mux_data => datao,
				sio_clk  => mii_clk,
				sio_frm  => ipv4tx_frm,
				sio_irdy => ipv4len_irdy,
				sio_trdy => ipv4len_trdy,
				so_end   => ipv4len_end,
				so_data  => ipv4len_data);

			ppltx_data <= 
				ipv4pltx_data when mactx_full='0'   else 
				len_datai     when iplentx_full='0' else
				ipv4pltx_data;

		end block;

		protomux_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ipv4proto_tx,
			sio_clk  => mii_clk,
			sio_frm  => ipv4tx_frm,
			sio_irdy => ipv4proto_irdy,
			sio_trdy => ipv4proto_trdy,
			so_end   => ipv4proto_end,
			so_data  => ipv4proto_data);

		ipv4da_irdy <= '0' when ipv4satx_end='0' else ipv4atx_irdy;
		da_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => 32)
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4tx_frm,
			si_irdy  => ipdatx_irdy,
			si_trdy  => open,
			si_full  => ipv4datx_full,
			si_data  => ipv4pltx_data,

			so_clk   => mii_clk,
			so_frm   => ipv4atx_frm,
			so_irdy  => ipv4da_irdy,
			so_trdy  => ipv4da_trdy,
			so_end   => ipv4atx_end,
			so_data  => ipv4da_data);

		ipv4atx_trdy <= ipv4satx_trdy when ipv4satx_end='0' else ipv4da_trdy;
		ipv4atx_data <= ipv4satx_data when ipv4satx_end='0' else ipv4da_data;

	end block;

	ipv4tx_e : entity hdl4fpga.ipv4_tx
	port map (
		mii_clk    => mii_clk,

		pl_frm     => ipv4tx_frm,
		pl_irdy    => ipv4pltx_irdy,
		pl_trdy    => ipv4pltx_trdy,
		pl_end     => ipv4pltx_end,
		pl_data    => ppltx_data,

		ipv4a_frm  => ipv4atx_frm,
		ipv4a_irdy => ipv4atx_irdy,
		ipv4a_end  => ipv4atx_end,
		ipv4a_data => ipv4atx_data,

		ipv4len_irdy   => ipv4len_irdy,
		ipv4len_data   => ipv4len_data,
		ipv4proto_irdy => ipv4proto_irdy,
		ipv4proto_trdy => ipv4proto_trdy,
		ipv4proto_end  => ipv4proto_end,
		ipv4proto_data => ipv4proto_data,

		ipv4_irdy  => ipv4tx_irdy,
		metatx_end => ipv4datx_full,
		ipv4_trdy  => ipv4tx_trdy,
		ipv4_end   => ipv4tx_end,
		ipv4_data  => ipv4tx_data);

	proto_e : entity hdl4fpga.sio_muxcmp
	generic map (
		n => 2)
	port map (
		mux_data  => reverse(ipv4proto_icmp,8) & reverse(ipv4proto_udp,8),
        sio_clk   => mii_clk,
        sio_frm   => ipv4rx_frm,
		sio_irdy  => ipv4protorx_irdy,
        si_data   => ipv4rx_data,
		so_last   => protorx_last,
		so_equ(0) => icmprx_equ,
		so_equ(1) => udprx_equ);

	icmp_p : process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if ipv4rx_frm='0' then
				icmprx_vld <= '0';
				udprx_vld  <= '0';
			elsif protorx_last='1' and ipv4protorx_irdy='1' then
				icmprx_vld <= icmprx_equ;
				udprx_vld  <= udprx_equ;
			end if;
		end if;
	end process;
	icmprx_frm  <= ipv4plrx_frm and icmprx_vld and ipv4da_vld;
	udprx_frm   <= ipv4plrx_frm and udprx_vld  and ipv4da_vld;
	icmprx_irdy <= icmprx_frm   and ipv4rx_irdy;
	process (tp1)
	begin
		tp <= tp1;
--		tp(2) <= ipv4tx_frm;
--		tp(3) <= ipv4pltx_trdy;
--		tp(4) <= ipv4pltx_end;
	end process;

--	tp(1) <= ipv4plrx_frm; --   and ipv4da_vld;

	icmpiplentx_irdy <= '0' when mactx_full='0' else '1';
	icmpd_e : entity hdl4fpga.icmpd
	port map (
		tp => tp1,
		mii_clk     => mii_clk,
		dll_frm     => dll_frm,
		dll_irdy    => dll_irdy,
		net_frm     => ipv4rx_frm,
		net_irdy    => ipv4rxsa_irdy,
		net1_irdy   => ipv4lenrx_irdy,

		icmprx_frm  => icmprx_frm,
		icmprx_irdy => icmprx_irdy,
		icmprx_data => ipv4rx_data,

		metatx_end  => ipv4datx_full,

		icmptx_frm  => icmptx_frm,
		icmptx_irdy => icmptx_irdy,
		icmptx_trdy => icmptx_trdy,
		icmptx_end  => icmptx_end,
		icmptx_data => icmptx_data);

--	udp_e : entity hdl4fpga.udp
--	port map (
--		tp => tp1,
--		mii_clk      => mii_clk,
--		dhcpcd_req   => dhcpcd_req,
--		dhcpcd_rdy   => dhcpcd_rdy,
--		arp_req      => arp_req,
--		arp_rdy      => arp_rdy,
--		udprx_frm    => udprx_frm,
--		udprx_irdy   => ipv4rx_irdy,
--		udprx_data   => ipv4rx_data,
--
--		hwda_frm     => hwda_frm,
--		hwda_irdy    => hwda_irdy,
--		hwda_trdy    => hwda_trdy,
--		hwda_last    => hwda_last,
--		hwda_equ     => hwda_equ,
--		hwdarx_vld   => hwdarx_vld,
--
--		plrx_frm     => udpplrx_frm,
--		plrx_irdy    => udpplrx_irdy,
--		plrx_trdy    => udpplrx_trdy,
--		plrx_cmmt    => plrx_cmmt,
--		plrx_rllbk   => plrx_rllbk,
--		plrx_data    => udpplrx_data,
--
--		pltx_frm     => pltx_frm,
--		pltx_irdy    => pltx_irdy,
--		pltx_trdy    => pltx_trdy,
--		pltx_data    => pltx_data,
--		pltx_end     => pltx_end,
--
--		ipv4sawr_frm  => ipv4sawr_frm,
--		ipv4sawr_irdy => ipv4sawr_irdy,
--		ipv4sawr_data => ipv4sawr_data,
--
--		udptx_frm    => udptx_frm,
--		mactx_full   => mactx_full,
--		ipsatx_full  => ipv4satx_full,
--		ipdatx_full  => ipv4datx_full,
--		iplentx_full => iplentx_full,
--		iplentx_irdy => udpiplentx_irdy,
--		udptx_irdy   => udptx_irdy,
--		udptx_trdy   => udptx_trdy,
--		udptx_end    => udptx_end ,
--		udptx_data   => udptx_data); 

	plrx_data <= udpplrx_data;
end;
