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

entity udp is
	port (
		mii_clk       : in  std_logic;
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : out std_logic := '0';

		arp_req       : buffer std_logic := '0';
		arp_rdy       : in  std_logic := '0';

		udprx_frm     : in  std_logic;
		udprx_irdy    : in  std_logic;
		udprx_data    : in  std_logic_vector;

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
		pltx_data     : in  std_logic_vector;
		pltx_end      : in  std_logic;

		ipv4sawr_frm  : out std_logic := '0';
		ipv4sawr_irdy : out std_logic := '0';
		ipv4sawr_end  : in  std_logic;
		ipv4sawr_data : out std_logic_vector;

		dlltx_irdy    : out std_logic := '1';
		dlltx_end     : in  std_logic := '1';
		dlltx_data    : out  std_logic_vector;

		netdatx_end   : in  std_logic;
		netdatx_irdy  : out std_logic;
		netlentx_end  : in  std_logic;
		netlentx_irdy : out std_logic;
		netlentx_data : buffer std_logic_vector;
		nettx_end     : in  std_logic;

		udptx_frm     : out std_logic;
		udptx_irdy    : out std_logic;
		udptx_trdy    : in  std_logic;
		udptx_end     : out std_logic;
		udptx_data    : out std_logic_vector;

		tp : out std_logic_vector(1 to 32));
end;

architecture def of udp is

	signal udpsprx_irdy    : std_logic;
	signal udpdprx_irdy    : std_logic;
	signal udplenrx_irdy   : std_logic;
	signal udpcksmrx_irdy  : std_logic;
	signal udpplrx_frm     : std_logic;
	signal udpplrx_irdy    : std_logic;

	signal dhcprx_frm      : std_logic;

	signal dhcptx_frm      : std_logic;
	signal dhcptx_irdy     : std_logic;
	signal dhcptx_trdy     : std_logic;
	signal dhcptx_end      : std_logic;
	signal dhcptx_data     : std_logic_vector(udptx_data'range);

	signal udppltx_frm     : std_logic;
	signal udppltx_irdy    : std_logic;
	signal udppltx_trdy    : std_logic;
	signal udppltx_end     : std_logic;
	signal udppltx_data    : std_logic_vector(udptx_data'range);

	signal udpdlltx_irdy   : std_logic;
	signal udpdlltx_end    : std_logic;
	signal udpdlltx_data   : std_logic_vector(udptx_data'range);

	signal udpdatx_irdy    : std_logic;
	signal udpdatx_end     : std_logic;
	signal udplentx_irdy   : std_logic;
	signal udplentx_end    : std_logic;
	signal udplentx_data   : std_logic_vector(udptx_data'range);

	signal udpnettx_end    : std_logic;

	signal dhcpdlltx_irdy  : std_logic;
	signal dhcpdlltx_data  : std_logic_vector(udptx_data'range);
	signal dhcpdlltx_end   : std_logic;
	signal dhcpdatx_irdy   : std_logic;
	signal dhcpdatx_end    : std_logic;
	signal dhcplentx_irdy  : std_logic;
	signal dhcplentx_data  : std_logic_vector(udptx_data'range);
	signal dhcplentx_end   : std_logic;
	signal dhcpnettx_end   : std_logic;

	signal dhcpipdatx_irdy : std_logic;
	signal udpmactx_irdy   : std_logic;
	signal udpipdatx_irdy  : std_logic;
	signal udpiplentx_irdy : std_logic;
	signal dhcpcd_vld      : std_logic;

begin

	udp_rx_e : entity hdl4fpga.udp_rx
	port map (
		mii_clk      => mii_clk,
		udp_frm      => udprx_frm,
		udp_irdy     => udprx_irdy,
		udp_data     => udprx_data,

		udpsp_irdy   => udpsprx_irdy,
		udpdp_irdy   => udpdprx_irdy,
		udplen_irdy  => udplenrx_irdy,
		udpcksm_irdy => udpcksmrx_irdy,
		udppl_frm    => udpplrx_frm,
		udppl_irdy   => udpplrx_irdy);

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
		signal gnt     : std_logic_vector(0 to 2-1);
	begin

		dev_req <= (dhcptx_frm, pltx_frm);
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

		udptx_frm  <= wirebus(dhcptx_frm  & pltx_frm,     dev_gnt);
		udptx_irdy <= wirebus(dhcptx_irdy & pltx_irdy,    dev_gnt);
		udptx_end  <= wirebus(dhcptx_end  & udppltx_end,  dev_gnt);
		udptx_data <= wirebus(dhcptx_data & udppltx_data, dev_gnt);
		(dhcptx_trdy, udppltx_trdy) <= dev_gnt and (dev_gnt'range => udptx_trdy);

		dlltx_irdy <= wirebus(dhcpdlltx_irdy & udpdlltx_irdy, dev_gnt);
		dlltx_data <= wirebus(dhcpdlltx_data & udpdlltx_data, dev_gnt);
		(dhcpdlltx_end, udpdlltx_end) <= dev_gnt and (dev_gnt'range => dlltx_end);

		netlentx_irdy <= wirebus(dhcplentx_irdy & udplentx_irdy, dev_gnt);
		netlentx_data <= wirebus(dhcplentx_data & udplentx_data, dev_gnt);
		(dhcplentx_end, udplentx_end) <= dev_gnt and (dev_gnt'range => netlentx_end);

		netdatx_irdy  <= wirebus(dhcpdatx_irdy & udpdatx_irdy, dev_gnt);
		(dhcpdatx_end,  udpdatx_end)   <= dev_gnt and (dev_gnt'range => netdatx_end);

		(dhcpnettx_end, udpnettx_end) <= dev_gnt and (dev_gnt'range => nettx_end);
	end block;

	udptx_b : block

   		signal udpsp_irdy  : std_logic;
   		signal udpsp_end   : std_logic;
   		signal udpsp_data  : std_logic_vector(pltx_data'range);

   		signal udpdp_irdy  : std_logic;
   		signal udpdp_end   : std_logic;
   		signal udpdp_data  : std_logic_vector(pltx_data'range);

   		signal udplen_irdy : std_logic;
   		signal udplen_end  : std_logic;
   		signal udplen_data : std_logic_vector(pltx_data'range);

		signal tptsp_irdy  : std_logic;
		signal tptsp_end   : std_logic;
		signal tptdp_irdy  : std_logic;
		signal tptdp_end   : std_logic;
		signal tptlen_irdy : std_logic;
		signal tptlen_end  : std_logic;
		signal tpttx_end   : std_logic;

	begin

    	meta_b : block
			signal rev_udpdata : std_logic_vector(udppltx_data'range);
    	begin

    		udpsp_e : entity hdl4fpga.sio_ram
    		generic map (
    			mem_length => 16)
    		port map (
    			si_clk   => mii_clk,
    			si_frm   => pltx_frm,
    			si_irdy  => tptsp_irdy,
    			si_trdy  => open,
    			si_full  => tptsp_end,
    			si_data  => udppltx_data,

    			so_clk   => mii_clk,
    			so_frm   => udppltx_frm,
    			so_irdy  => udpsp_irdy,
    			so_trdy  => open,
    			so_end   => udpsp_end,
    			so_data  => udpsp_data);

    		udpdp_e : entity hdl4fpga.sio_ram
    		generic map (
    			mem_length => 16)
    		port map (
    			si_clk  => mii_clk,
    			si_frm  => pltx_frm,
    			si_irdy => tptdp_irdy,
    			si_trdy => open,
    			si_full => tptdp_end,
    			si_data => udppltx_data,

    			so_clk  => mii_clk,
    			so_frm  => udppltx_frm,
    			so_irdy => udpdp_irdy,
    			so_trdy => open,
    			so_end  => udpdp_end,
    			so_data => udpdp_data);

			-- rev_udpdata <= reverse(udppltx_data);
			rev_udpdata <= reverse(netlentx_data);
           	udllen_e : entity hdl4fpga.sio_ram
           	generic map (
           		mode_fifo => false,
           		mem_length => 16)
           	port map (
           		si_clk  => mii_clk,
           		si_frm  => pltx_frm,
           		si_irdy => tptlen_irdy,
           		si_trdy => open,
           		si_full => tptlen_end,
           		si_data => rev_udpdata,

           		so_clk  => mii_clk,
           		so_frm  => udppltx_frm,
           		so_irdy => udplen_irdy,
           		so_trdy => open,
           		so_end  => udplen_end,
           		so_data => udplen_data);

			tpttx_end <= tptsp_end and tptdp_end and tptlen_end;

    	end block;

    	udptx_e : entity hdl4fpga.udp_tx
    	port map (
			mii_clk       => mii_clk,

			pl_frm        => pltx_frm,
			pl_irdy       => pltx_irdy,
			pl_trdy       => pltx_trdy,
			pl_end        => pltx_end,
			pl_data       => pltx_data,

			dlltx_irdy    => udpdlltx_irdy,
			dlltx_end     => udpdlltx_end,
			dlltx_data    => udpdlltx_data,
			netdatx_irdy  => udpdatx_irdy,
			netdatx_end   => udpdatx_end,
			netlentx_irdy => udplentx_irdy,
			netlentx_data => udplentx_data,
			netlentx_end  => udplentx_end,

			tptsp_irdy    => tptsp_irdy,
			tptsp_end     => tptsp_end,
			tptdp_irdy    => tptdp_irdy,
			tptdp_end     => tptdp_end,
			tptlen_irdy   => tptlen_irdy,
			tptlen_end    => tptlen_end,
			tpttx_end     => tpttx_end,

			udpsp_irdy    => udpsp_irdy,
			udpsp_end     => udpsp_end,
			udpsp_data    => udpsp_data,

			udpdp_irdy    => udpdp_irdy,
			udpdp_end     => udpdp_end,
			udpdp_data    => udpdp_data,

			udplen_irdy   => udplen_irdy,
			udplen_end    => udplen_end,
			udplen_data   => udplen_data,

			udp_frm       => udppltx_frm,
			udp_irdy      => udppltx_irdy,
			udp_trdy      => udppltx_trdy,
			udp_end       => udppltx_end,
			udp_data      => udppltx_data);

	end block;

   	plrx_cmmt  <= plrx_frm;
	plrx_rllbk <= udpplrx_frm when dhcpcd_vld='1' else '0';
	plrx_frm   <= udpplrx_frm when dhcpcd_vld='0' else '0';
   	plrx_irdy  <= 
		(udprx_frm   and (udpdprx_irdy or udpsprx_irdy)) or
		(udpplrx_frm and udprx_irdy);

   	plrx_data  <= udprx_data;

	dhcpcd_b : block
		signal dp_last : std_logic;
		signal dp_equ  : std_logic;
	begin

    	dhcp_dp_e : entity hdl4fpga.sio_muxcmp
        port map (
    		mux_data  => reverse(x"0044",8),
            sio_clk   => mii_clk,
            sio_frm   => udprx_frm,
            sio_irdy  => udpdprx_irdy,
            sio_trdy  => open,
            si_data   => udprx_data,
    		so_last   => dp_last,
    		so_equ(0) => dp_equ);

    	process (mii_clk)
    	begin
    		if rising_edge(mii_clk) then
    			if udprx_frm='0' then
    				dhcpcd_vld <= '0';
    			elsif dp_last='1' and udprx_irdy='1' then
    				dhcpcd_vld <= dp_equ;
    			end if;
    		end if;
    	end process;

		dhcprx_frm <= udpplrx_frm when dhcpcd_vld='1' else '0';
		dhcpcd_e: entity hdl4fpga.dhcpcd
		port map (
			tp            => tp,
			mii_clk       => mii_clk,
			dhcpcdrx_frm  => dhcprx_frm,
			dhcpcdrx_irdy => udprx_irdy,
			dhcpcdrx_data => udprx_data,
			dhcpcd_req    => dhcpcd_req,
			dhcpcd_rdy    => dhcpcd_rdy,
			arp_req       => arp_req,
			arp_rdy       => arp_rdy,
			
			hwda_frm      => hwda_frm,
			hwda_irdy     => hwda_irdy,
			hwda_trdy     => hwda_trdy,
			hwda_last     => hwda_last,
			hwda_equ      => hwda_equ,
			hwdarx_vld    => hwdarx_vld,
			
			ipv4sawr_frm  => ipv4sawr_frm,
			ipv4sawr_irdy => ipv4sawr_irdy,
			ipv4sawr_end  => ipv4sawr_end,
			ipv4sawr_data => ipv4sawr_data,
			
			dhcpcdtx_frm  => dhcptx_frm,
			dlltx_irdy    => dhcpdlltx_irdy,
			dlltx_data    => dhcpdlltx_data,
			dlltx_end     => dhcpdlltx_end,
			netdatx_irdy  => dhcpdatx_irdy,
			netdatx_end   => dhcpdatx_end,
			netlentx_irdy => dhcplentx_irdy,
			netlentx_data => dhcplentx_data,
			netlentx_end  => dhcplentx_end,
			nettx_end     => dhcpnettx_end,
			dhcpcdtx_irdy => dhcptx_irdy,
			dhcpcdtx_trdy => dhcptx_trdy,
			dhcpcdtx_end  => dhcptx_end,
			dhcpcdtx_data => dhcptx_data);

	end block;

end;
