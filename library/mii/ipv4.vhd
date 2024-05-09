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
use hdl4fpga.base.all;
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
		fcs_sb        : in  std_logic;
		fcs_vld       : in  std_logic;
		ipv4rx_frm    : in  std_logic;
		ipv4rx_irdy   : in  std_logic;
		ipv4rx_data   : in  std_logic_vector;

		ipv4hwda_frm  : out std_logic;
		ipv4sarx_frm  : in  std_logic;
		ipv4sarx_irdy : in  std_logic;
		ipv4sarx_trdy : buffer std_logic;
		ipv4sarx_end  : buffer std_logic;
		ipv4sarx_equ  : buffer std_logic;

	    ipv4sawr_frm  : buffer std_logic;
	    ipv4sawr_irdy : buffer std_logic;
	    ipv4sawr_trdy : in std_logic := '-';
	    ipv4sawr_end  : buffer std_logic;
	    ipv4sawr_data : buffer std_logic_vector;

		hwda_frm      : out std_logic;
		hwda_irdy     : out std_logic;
		hwda_trdy     : in  std_logic;
		hwda_last     : in  std_logic;
		hwda_equ      : in  std_logic;
		hwdarx_vld    : in  std_logic;

		plrx_frm      : buffer std_logic;
		plrx_irdy     : out std_logic;
		plrx_trdy     : in  std_logic := '1';
		plrx_cmmt     : out std_logic;
		plrx_rllbk    : out std_logic;
		plrx_data     : out std_logic_vector;

		pltx_frm      : in  std_logic;
		pltx_irdy     : in  std_logic;
		pltx_trdy     : out std_logic;
		pltx_end      : in  std_logic;
		pltx_data     : in  std_logic_vector;

		dlltx_irdy    : out  std_logic;
		dlltx_data    : out  std_logic_vector;
		dlltx_end     : in   std_logic;

		ipv4tx_frm    : out std_logic := '0';
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

	signal ipv4pltx_frm     : std_logic;
	signal ipv4pltx_irdy    : std_logic;
	signal ipv4pltx_trdy    : std_logic;
	signal ipv4pltx_end     : std_logic;
	signal ipv4pltx_data    : std_logic_vector(ipv4tx_data'range);
	signal ppltx_data       : std_logic_vector(ipv4tx_data'range);

	signal icmprx_frm       : std_logic;
	signal icmprx_irdy      : std_logic;
	signal icmprx_equ       : std_logic;
	signal icmprx_vld       : std_logic;
	signal icmptx_frm       : std_logic := '0';
	signal icmptx_irdy      : std_logic := '0';
	signal icmptx_trdy      : std_logic;
	signal icmptx_end       : std_logic := '0';
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

	signal nettx_irdy       : std_logic;
	signal nettx_end        : std_logic;
	signal netdatx_end      : std_logic;
	signal netdatx_irdy     : std_logic;
	signal netlentx_irdy    : std_logic;
	signal netlentx_data    : std_logic_vector(ipv4tx_data'range);
	signal netlentx_end     : std_logic;

	signal icmpdlltx_irdy   : std_logic;
	signal icmpdlltx_data   : std_logic_vector(ipv4tx_data'range);
	signal icmpdlltx_end    : std_logic;
	signal icmplentx_irdy   : std_logic;
	signal icmplentx_end    : std_logic;
	signal icmplentx_data   : std_logic_vector(ipv4tx_data'range);
	signal icmpdatx_irdy    : std_logic;
	signal icmpdatx_end     : std_logic;

	signal udpdlltx_irdy    : std_logic;
	signal udpdlltx_end     : std_logic;
	signal udpdlltx_data    : std_logic_vector(ipv4tx_data'range);
	signal udplentx_irdy    : std_logic;
	signal udplentx_end     : std_logic;
	signal udplentx_data    : std_logic_vector(ipv4tx_data'range);
	signal udpdatx_irdy     : std_logic;
	signal udpdatx_end      : std_logic;

	signal ipv4len_irdy     : std_logic;
	signal ipv4len_end      : std_logic;
	signal ipv4len_data     : std_logic_vector(ipv4rx_data'range);

	signal udpipv4len_end   : std_logic;
	signal udpipv4len_data  : std_logic_vector(ipv4rx_data'range);

	signal icmpipv4len_end  : std_logic;
	signal icmpipv4len_data : std_logic_vector(ipv4rx_data'range);

	signal ipv4proto_irdy   : std_logic;
	signal ipv4proto_trdy   : std_logic;
	signal ipv4proto_end    : std_logic;
	signal ipv4proto_data   : std_logic_vector(ipv4rx_data'range);

	signal udpmactx_irdy    : std_logic;
	signal icmpnetrx_irdy   : std_logic;


	signal ipv4sanll_vld    : std_logic := '0';

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
					if ipv4sawr_end='0' then
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

	end block;

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
		signal gnt     : std_logic_vector(0 to 2-1);

	begin

		dev_req <= icmptx_frm & udptx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			req => dev_req,
			gnt => gnt);

		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				dev_gnt <= gnt;
			end if;
		end process;

		ipv4pltx_frm  <= wirebus(icmptx_frm  & udptx_frm,  dev_gnt);
		ipv4pltx_irdy <= wirebus(icmptx_irdy & udptx_irdy, dev_gnt);
		ipv4pltx_end  <= wirebus(icmptx_end  & udptx_end,  dev_gnt);
		ipv4pltx_data <= wirebus(icmptx_data & udptx_data, dev_gnt);

		ipv4proto_tx  <= wirebus(reverse(ipv4proto_icmp & ipv4proto_udp,8), dev_gnt);
		ipv4len_data  <= wirebus(icmpipv4len_data & udpipv4len_data, dev_gnt);
		ipv4len_end   <= wirebus(icmpipv4len_end  & udpipv4len_end,  dev_gnt);

		dlltx_irdy    <= wirebus(icmpdlltx_irdy & udpdlltx_irdy, dev_gnt);
		dlltx_data    <= wirebus(icmpdlltx_data & udpdlltx_data, dev_gnt);
		(icmpdlltx_end, udpdlltx_end) <= dev_gnt and (dev_gnt'range => dlltx_end);
		netlentx_irdy <= wirebus(icmplentx_irdy & udplentx_irdy, dev_gnt);
		netlentx_data <= wirebus(icmplentx_data & udplentx_data, dev_gnt);
		netlentx_end  <= wirebus(icmplentx_end  & udplentx_end,  dev_gnt);
		netdatx_irdy  <= wirebus(icmpdatx_irdy  & udpdatx_irdy,  dev_gnt);

		(icmptx_trdy,  udptx_trdy)  <= dev_gnt and (dev_gnt'range => ipv4pltx_trdy);
		(icmpdatx_end, udpdatx_end) <= dev_gnt and (dev_gnt'range => netdatx_end);

	end block;

	meta_b : block

		signal ipv4da_irdy  : std_logic;
		signal ipv4da_trdy  : std_logic;
		signal ipv4da_data  : std_logic_vector(ipv4rx_data'range);

		signal ipv4sa_trdy : std_logic;
		signal ipv4sa_end  : std_logic;
		signal ipv4sa_data : std_logic_vector(ipv4tx_data'range);

	begin
		ipv4udplen_b : block
			signal si_data : std_logic_vector(ipv4pltx_data'range);
			signal so_sum  : std_logic_vector(ipv4pltx_data'range);
		begin
    		adjlen_e : entity hdl4fpga.ipv4_adjlen
    		generic map (
    			adjust => std_logic_vector(to_unsigned((summation(ipv4hdr_frame)/octect_size),16)))
    		port map (
    			sio_clk  => mii_clk,
    			sio_frm  => ipv4pltx_frm,
    			sio_irdy => udplentx_irdy,
    			sio_trdy => open,
				-- si_data  => ipv4pltx_data,
				si_data  => udplentx_data,
    			so_data  => so_sum);
    	
			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
				end if;
			end process;
			si_data <= reverse(so_sum);

    		ipv4len_e : entity hdl4fpga.sio_ram
    		generic map (
    			mode_fifo => false,
    			mem_length => 16)
    		port map (
    			si_clk  => mii_clk,
    			si_frm  => ipv4pltx_frm,
    			si_irdy => udplentx_irdy,
    			si_trdy => open,
    			si_full => udplentx_end,
    			si_data => si_data,
    		
    			so_clk  => mii_clk,
    			so_frm  => ipv4pltx_frm,
    			so_irdy => ipv4len_irdy,
    			so_trdy => open,
    			so_end  => udpipv4len_end,
    			so_data => udpipv4len_data);
		end block;

		ipv4proto_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ipv4proto_tx,
			sio_clk  => mii_clk,
			sio_frm  => ipv4pltx_frm,
			sio_irdy => ipv4proto_irdy,
			sio_trdy => ipv4proto_trdy,
			so_end   => ipv4proto_end,
			so_data  => ipv4proto_data);

		ipv4len_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => 16)
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4pltx_frm,
			si_irdy  => icmplentx_irdy,
			si_trdy  => open,
			si_full  => icmplentx_end,
			-- si_data  => ipv4pltx_data,
			si_data  => icmplentx_data,

			so_clk   => mii_clk,
			so_frm   => ipv4pltx_frm,
			so_irdy  => ipv4len_irdy,
			so_trdy  => open,
			so_end   => icmpipv4len_end,
			so_data  => icmpipv4len_data);

		ipv4da_irdy <= '0' when ipv4sa_end='0' else ipv4atx_irdy;
		ipv4sa_b : block
			signal ipv4sard_frm  : std_logic;
			signal ipv4sard_irdy : std_logic;
		begin
			ipv4sard_frm  <= 
				'1' when  ipv4atx_frm='1' else
				'0';
			ipv4sard_irdy  <= 
				'1' when  ipv4atx_irdy='1' else
				'0';

			ipv4sa_e : entity hdl4fpga.sio_ram
			generic map (
				mem_data => reverse(default_ipv4a,8),
				mem_length => 32)
			port map (
				si_clk  => mii_clk,
				si_frm  => ipv4sawr_frm,
				si_irdy => ipv4sawr_irdy,
				si_trdy => open,
				si_full => ipv4sawr_end,
				si_data => ipv4sawr_data,
	
				so_clk  => mii_clk,
				so_frm  => ipv4atx_frm,
				so_irdy => ipv4sard_irdy,
				so_trdy => ipv4sa_trdy,
				so_end  => ipv4sa_end,
				so_data => ipv4sa_data);
		end block;

		ipv4da_e : entity hdl4fpga.sio_ram
		generic map (
			mem_length => 32)
		port map (
			si_clk   => mii_clk,
			si_frm   => ipv4pltx_frm,
			si_irdy  => netdatx_irdy,
			si_trdy  => open,
			si_full  => netdatx_end,
			si_data  => ipv4pltx_data,

			so_clk   => mii_clk,
			so_frm   => ipv4atx_frm,
			so_irdy  => ipv4da_irdy,
			so_trdy  => ipv4da_trdy,
			so_end   => ipv4atx_end,
			so_data  => ipv4da_data);

		nettx_end    <= netdatx_end and netlentx_end;
		ipv4atx_trdy <= ipv4sa_trdy when ipv4sa_end='0' else ipv4da_trdy;
		ipv4atx_data <= ipv4sa_data when ipv4sa_end='0' else ipv4da_data;

	end block;

	ipv4tx_e : entity hdl4fpga.ipv4_tx
	port map (
		mii_clk        => mii_clk,

		pl_frm         => ipv4pltx_frm,
		pl_irdy        => ipv4pltx_irdy,
		pl_trdy        => ipv4pltx_trdy,
		pl_end         => ipv4pltx_end,
		pl_data        => ipv4pltx_data,

		ipv4_frm       => ipv4tx_frm,

		dlltx_end      => dlltx_end,

		nettx_irdy     => nettx_irdy,
		nettx_end      => nettx_end,

		ipv4a_frm      => ipv4atx_frm,
		ipv4a_irdy     => ipv4atx_irdy,
		ipv4a_end      => ipv4atx_end,
		ipv4a_data     => ipv4atx_data,

		ipv4len_irdy   => ipv4len_irdy,
		ipv4len_data   => ipv4len_data,

		ipv4proto_irdy => ipv4proto_irdy,
		ipv4proto_trdy => ipv4proto_trdy,
		ipv4proto_end  => ipv4proto_end,
		ipv4proto_data => ipv4proto_data,

		ipv4_irdy      => ipv4tx_irdy,
		ipv4_trdy      => ipv4tx_trdy,
		ipv4_end       => ipv4tx_end,
		ipv4_data      => ipv4tx_data);

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

	icmpnetrx_irdy <= ipv4lenrx_irdy or ipv4rxsa_irdy;
	icmpd_b : block
		signal tx_frm  : std_logic;
		signal tx_irdy : std_logic;
		signal tx_trdy : std_logic;
		signal tx_end  : std_logic;
		signal tx_data : std_logic_vector(icmptx_data'range);
	begin
		icmpd_e : entity hdl4fpga.icmpd
		port map (
			mii_clk     => mii_clk,
			dll_frm     => dll_frm,
			dll_irdy    => dll_irdy,
			fcs_sb      => fcs_sb,
			fcs_vld     => fcs_vld,
			net_irdy    => icmpnetrx_irdy,
	
			icmprx_frm  => icmprx_frm,
			icmprx_irdy => icmprx_irdy,
			icmprx_data => ipv4rx_data,
	
			icmptx_frm  => tx_frm,
			icmptx_irdy => tx_irdy,
			icmptx_trdy => tx_trdy,
			icmptx_end  => tx_end,
			icmptx_data => tx_data);

		miibuffer_e : entity hdl4fpga.mii_buffer
		port map (
			io_clk => mii_clk,
			i_frm  => tx_frm,
			i_irdy => tx_irdy,
			i_trdy => tx_trdy,
			i_data => tx_data,
			i_end  => tx_end,
			o_frm  => icmptx_frm,
			o_irdy => icmptx_irdy,
			o_trdy => icmptx_trdy,
			o_data => icmptx_data,
			o_end  => icmptx_end);

		icmpdlltx_irdy <= icmptx_irdy and icmptx_trdy;
		icmpdlltx_data <= icmptx_data;
		icmplentx_data <= icmptx_data;
		icmplentx_irdy <= icmptx_irdy when dlltx_end='1' else '0';
		icmpdatx_irdy  <= icmptx_irdy when icmplentx_end='1' else '0';
	end block;

	udp_e : entity hdl4fpga.udp
	port map (
		mii_clk      => mii_clk,
		dhcpcd_req   => dhcpcd_req,
		dhcpcd_rdy   => dhcpcd_rdy,
		arp_req      => arp_req,
		arp_rdy      => arp_rdy,
		udprx_frm    => udprx_frm,
		udprx_irdy   => ipv4rx_irdy,
		udprx_data   => ipv4rx_data,

		hwda_frm     => hwda_frm,
		hwda_irdy    => hwda_irdy,
		hwda_trdy    => hwda_trdy,
		hwda_last    => hwda_last,
		hwda_equ     => hwda_equ,
		hwdarx_vld   => hwdarx_vld,

		plrx_frm     => udpplrx_frm,
		plrx_irdy    => udpplrx_irdy,
		plrx_trdy    => open, --udpplrx_trdy,
		plrx_cmmt    => plrx_cmmt,
		plrx_rllbk   => plrx_rllbk,
		plrx_data    => udpplrx_data,

		pltx_frm     => pltx_frm,
		pltx_irdy    => pltx_irdy,
		pltx_trdy    => pltx_trdy,
		pltx_data    => pltx_data,
		pltx_end     => pltx_end,

		ipv4sawr_frm  => ipv4sawr_frm,
		ipv4sawr_irdy => ipv4sawr_irdy,
		ipv4sawr_data => ipv4sawr_data,
		ipv4sawr_end  => ipv4sawr_end,

		dlltx_irdy    => udpdlltx_irdy,
		dlltx_data    => udpdlltx_data,
		dlltx_end     => udpdlltx_end,
		netdatx_irdy  => udpdatx_irdy,
		netdatx_end   => udpdatx_end,
		netlentx_irdy => udplentx_irdy,
		netlentx_end  => udplentx_end,
		netlentx_data => udplentx_data,
		nettx_end     => nettx_end,

		udptx_frm     => udptx_frm,
		udptx_irdy    => udptx_irdy,
		udptx_trdy    => udptx_trdy,
		udptx_end     => udptx_end ,
		udptx_data    => udptx_data);

	plrx_data <= udpplrx_data;
end;
