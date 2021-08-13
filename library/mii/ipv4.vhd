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

		mii_clk        : in  std_logic;
		dhcpcd_req     : in  std_logic := '0';
		dhcpcd_rdy     : out std_logic := '0';

		dll_frm        : in  std_logic := '1';
		dll_irdy       : in  std_logic := '1';
		ipv4rx_frm     : in  std_logic;
		ipv4rx_irdy    : in  std_logic;
		ipv4rx_data    : in  std_logic_vector;

		ipv4sarx_frm   : in  std_logic;
		ipv4sarx_irdy  : in  std_logic;
		ipv4sarx_trdy  : buffer std_logic;
		ipv4sarx_end   : buffer std_logic;
		ipv4sarx_equ   : buffer std_logic;

		ipv4satx_frm   : in  std_logic;
		ipv4satx_irdy  : in  std_logic;
		ipv4satx_trdy  : buffer std_logic;
		ipv4satx_end   : buffer std_logic;
		ipv4satx_data  : buffer std_logic_vector;

		plrx_frm       : out std_logic;
		plrx_irdy      : out std_logic;
		plrx_trdy      : in  std_logic;
		plrx_data      : out std_logic_vector;

		pltx_frm       : in  std_logic;
		pltx_irdy      : in  std_logic;
		pltx_trdy      : out std_logic;
		pltx_end       : in  std_logic;
		pltx_data      : in  std_logic_vector;

		dlltx_irdy     : in  std_logic;
		dlltx_full     : in  std_logic;
		dlltx_end      : in  std_logic;

		ipv4tx_frm     : buffer std_logic := '0';
		ipv4tx_irdy    : buffer std_logic;
		ipv4tx_trdy    : in  std_logic := '1';
		ipv4tx_end     : out std_logic := '0';
		ipv4tx_data    : buffer std_logic_vector;

		tp             : out std_logic_vector(1 to 32));

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
	signal ipv4plrx_frm     : std_logic;
	signal ipv4plrx_irdy    : std_logic;

	signal ipv4pltx_irdy    : std_logic;
	signal ipv4pltx_trdy    : std_logic;
	signal ipv4pltx_end     : std_logic;
	signal ipv4pltx_data    : std_logic_vector(ipv4tx_data'range);

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

	signal udptx_frm        : std_logic;
	signal udptx_irdy       : std_logic;
	signal udptx_trdy       : std_logic;
	signal udptx_end        : std_logic;
	signal udptx_data       : std_logic_vector(ipv4tx_data'range);

	signal protorx_last     : std_logic;
	signal udpmetarx_irdy   : std_logic;

	signal ipv4protorx_irdy : std_logic;
	signal ipv4rxsa_irdy    : std_logic;
	signal ipv4lenrx_irdy   : std_logic;
	signal ipv4arx_last     : std_logic;
	signal ipv4arx_equ      : std_logic;

	signal ipv4sarx_data    : std_logic_vector(ipv4rx_data'range);
	signal ipv4darx_frm     : std_logic;
	signal ipv4darx_irdy    : std_logic;

	signal ipv4sa_frm       : std_logic;
	signal ipv4sa_irdy      : std_logic;

	signal nettx_full       : std_logic;

	signal ipv4sack_frm     : std_logic;
	signal ipv4sack_irdy    : std_logic;

	signal ipv4len_irdy : std_logic;
	signal ipv4len_trdy : std_logic;
	signal ipv4len_end  : std_logic;
	signal ipv4len_data : std_logic_vector(ipv4rx_data'range);

	signal ipv4proto_irdy : std_logic;
	signal ipv4proto_trdy : std_logic;
	signal ipv4proto_end  : std_logic;
	signal ipv4proto_data : std_logic_vector(ipv4rx_data'range);

	signal tp1 : std_logic_vector(tp'range);
begin

	plrx_frm  <= ipv4rx_frm;
	plrx_irdy <= to_stdulogic(to_bit(ipv4rx_frm and (ipv4protorx_irdy or ipv4rxsa_irdy or ipv4lenrx_irdy or udpplrx_irdy)));

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

	ipv4sack_frm  <= ipv4sarx_frm;
	ipv4sack_irdy <= ipv4sarx_irdy or ipv4darx_irdy;

	sarx_e : entity hdl4fpga.sio_ram
	generic map (
		mem_data   => reverse(default_ipv4a,8),
		mem_length => 32)
	port map (
		si_clk  => mii_clk,
		si_frm  => pltx_frm,
		si_irdy => '0',
		si_trdy => open,
		si_full => open,
		si_data => pltx_data,

		so_clk  => mii_clk,
		so_frm  => ipv4sack_frm,
		so_irdy => ipv4sack_irdy,
		so_trdy => ipv4sarx_trdy,
		so_end  => ipv4sarx_end,
		so_data => ipv4sarx_data);

	tp(1) <= ipv4darx_frm;
	tp(2) <= ipv4darx_irdy;
	tp(3 to 10) <= ipv4rx_data;
	tp(11) <= tp1(1);
	tp(12) <= tp1(2);
	tp(13) <= tp1(3);
	tp(14) <= tp1(4);
	sarxcmp_e : entity hdl4fpga.sio_cmp
    port map (
        si_clk    => mii_clk,
        si_frm    => ipv4sack_frm,
        si1_irdy  => ipv4sack_irdy,
        si1_trdy  => open,
        si1_data  => ipv4sarx_data,
        si2_irdy  => ipv4sack_irdy,
        si2_trdy  => open,
        si2_data  => ipv4rx_data,
		si_equ    => ipv4sarx_equ);

	ipv4a_p : process (ipv4sarx_end, mii_clk)
		variable vld : std_logic;
	begin
		if rising_edge(mii_clk) then
			if ipv4rx_frm='0' then
				vld := '0';
			elsif ipv4sarx_end='0' then
				if ipv4sack_irdy='1' then
					vld := ipv4sarx_equ;
				end if;
			end if;
		end if;
		ipv4da_vld <= ipv4sarx_end and vld;
	end process;

	ipv4sa_frm   <= ipv4satx_frm  or ipv4atx_frm;
	ipv4sa_irdy  <= ipv4satx_irdy or ipv4atx_irdy;
	satx_e : entity hdl4fpga.sio_ram
	generic map (
		mem_data => reverse(default_ipv4a,8),
		mem_length => 32)
	port map (
		si_clk  => mii_clk,
		si_frm  => pltx_frm,
		si_irdy => '-',
		si_trdy => open,
		si_full => open,
		si_data => pltx_data,

		so_clk  => mii_clk,
		so_frm  => ipv4sa_frm,
		so_irdy => ipv4sa_irdy,
		so_trdy => ipv4satx_trdy,
		so_end  => ipv4satx_end,
		so_data => ipv4satx_data);

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
	begin

		dev_req <= icmptx_frm & udptx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			req => dev_req,
			gnt => dev_gnt);

		ipv4tx_frm    <= wirebus(icmptx_frm  & udptx_frm,  dev_gnt)(0);
		ipv4pltx_irdy <= wirebus(icmptx_irdy & udptx_irdy, dev_gnt)(0);
		ipv4pltx_end  <= wirebus(icmptx_end  & udptx_end,  dev_gnt)(0);
		ipv4pltx_data <= wirebus(icmptx_data & udptx_data, dev_gnt);
		(0 => icmptx_trdy, 1 => udptx_trdy) <= dev_gnt and (dev_gnt'range => ipv4pltx_trdy); 
		ipv4proto_tx  <= reverse(wirebus(x"01" & x"11", dev_gnt),8);

	end block;

	meta_b : block
		signal lentx_full   : std_logic;
		signal lentx_irdy   : std_logic;
		signal datx_irdy    : std_logic;

		signal ipv4da_irdy  : std_logic;
		signal ipv4da_trdy  : std_logic;
		signal ipv4da_data  : std_logic_vector(ipv4rx_data'range);


	begin

		lentx_irdy <= 
			'0'         when dlltx_full='0' else
			ipv4tx_irdy;

		len_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => 16)
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4tx_frm,
			si_irdy  => lentx_irdy,
			si_trdy  => open,
			si_full  => lentx_full,
			si_data  => ipv4pltx_data,

			so_clk   => mii_clk,
			so_frm   => ipv4tx_frm,
			so_irdy  => ipv4len_irdy,
			so_trdy  => ipv4len_trdy,
			so_end   => ipv4len_end,
			so_data  => ipv4len_data);

		protomux_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ipv4proto_tx,
			sio_clk  => mii_clk,
			sio_frm  => ipv4tx_frm,
			sio_irdy => ipv4proto_irdy,
			sio_trdy => ipv4proto_trdy,
			so_end   => ipv4proto_end,
			so_data  => ipv4proto_data);

		ipv4da_irdy  <= '0' when ipv4satx_end='0' else ipv4atx_irdy;
		datx_irdy    <= '0' when lentx_full='0'   else lentx_full;
		da_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => 32)
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4tx_frm,
			si_irdy  => datx_irdy,
			si_trdy  => open,
			si_full  => nettx_full,
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
		pl_data    => ipv4pltx_data,

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
		nettx_full => nettx_full,
		ipv4_trdy  => ipv4tx_trdy,
		ipv4_end   => ipv4tx_end,
		ipv4_data  => ipv4tx_data);

	proto_e : entity hdl4fpga.sio_muxcmp
	generic map (
		n => 1)
	port map (
		mux_data  => reverse(ipv4proto_icmp,8),
        sio_clk   => mii_clk,
        sio_frm   => ipv4rx_frm,
		sio_irdy  => ipv4protorx_irdy,
        si_data   => ipv4rx_data,
		so_last   => protorx_last,
		so_equ(0) => icmprx_equ);

	icmp_p : process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if ipv4rx_frm='0' then
				icmprx_vld <= '0';
			elsif protorx_last='1' and ipv4protorx_irdy='1' then
				icmprx_vld <= icmprx_equ;
			end if;
		end if;
	end process;
	icmprx_frm  <= ipv4plrx_frm and icmprx_vld and ipv4da_vld;
	icmprx_irdy <= icmprx_frm and ipv4rx_irdy;

	icmpd_e : entity hdl4fpga.icmpd
	port map (
		mii_clk     => mii_clk,
		dll_frm     => dll_frm,
		dll_irdy    => dll_irdy,
		net_frm     => ipv4rx_frm,
		net_irdy    => ipv4rxsa_irdy,
		net1_irdy   => ipv4lenrx_irdy,

		icmprx_frm  => icmprx_frm,
		icmprx_irdy => icmprx_irdy,
		icmprx_data => ipv4rx_data,

		dlltx_irdy  => dlltx_irdy,
		dlltx_full  => dlltx_full,
		dlltx_end   => dlltx_end,
		nettx_full  => nettx_full,

		icmptx_frm  => icmptx_frm,
		icmptx_irdy => icmptx_irdy,
		icmptx_trdy => icmptx_trdy,
		icmptx_end  => icmptx_end,
		icmptx_data => icmptx_data,
		tp => tp1);

	udp_e : entity hdl4fpga.udp
	port map (
		mii_clk     => mii_clk,
		dhcpcd_req  => dhcpcd_req,
		dhcpcd_rdy  => dhcpcd_rdy,

		udprx_irdy  => ipv4rx_irdy,
		udprx_data  => ipv4rx_data,
		udpmetarx_irdy => udpmetarx_irdy,

		plrx_frm    => udpplrx_frm,
		plrx_irdy   => udpplrx_irdy,
		plrx_trdy   => udpplrx_trdy,
		plrx_data   => udpplrx_data,

		pltx_frm    => pltx_frm,
		pltx_irdy   => pltx_irdy,
		pltx_trdy   => pltx_trdy,
		pltx_end    => pltx_end,
		pltx_data   => pltx_data,

		udptx_frm   => udptx_frm,
		dlltx_full  => dlltx_full,
		dlltx_irdy  => dlltx_irdy,
		dlltx_end   => dlltx_end,
		nettx_full  => nettx_full,
		udptx_irdy  => udptx_irdy,
		udptx_trdy  => udptx_trdy,
		udptx_end   => udptx_end ,
		udptx_data  => udptx_data);

end;
