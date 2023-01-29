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
		ipv4sawr_data : out std_logic_vector;

		dlltx_irdy    : out std_logic := '1';
		dlltx_trdy    : in  std_logic := '1';
		dlltx_end     : in  std_logic := '1';

		nettx_irdy    : out std_logic := '1';
		nettx_trdy    : in  std_logic := '1';
		nettx_end     : in  std_logic := '1';

		metatx_trdy   : in  std_logic := '1';
		ipsatx_full   : in  std_logic;
		ipdatx_full   : in  std_logic;
		iplentx_irdy  : out std_logic;
		iplentx_full  : in  std_logic;

		udptx_frm     : out std_logic;
		udptx_irdy    : out std_logic;
		udptx_trdy    : in  std_logic;
		udptx_end     : out std_logic;
		udptx_data    : out std_logic_vector;

		tp : out std_logic_vector(1 to 32)
	);
end;

architecture def of udp is

	signal udpsprx_last   : std_logic;
	signal udpsprx_equ    : std_logic;
	signal udpsprx_vld    : std_logic;

	signal udpsprx_irdy   : std_logic;
	signal udpdprx_irdy   : std_logic;
	signal udplenrx_irdy  : std_logic;
	signal udpcksmrx_irdy : std_logic;
	signal udpplrx_frm    : std_logic;
	signal udpplrx_irdy   : std_logic;

	signal dhcpcrx_frm    : std_logic;
	signal dhcpctx_frm    : std_logic;
	signal dhcpctx_irdy   : std_logic;
	signal dhcpctx_trdy   : std_logic;
	signal dhcpctx_end    : std_logic;
	signal dhcpctx_data   : std_logic_vector(udptx_data'range);

	signal udppltx_frm    : std_logic;
	signal udppltx_irdy   : std_logic;
	signal udppltx_trdy   : std_logic;
	signal udppltx_end    : std_logic;
	signal udppltx_data   : std_logic_vector(udptx_data'range);

	signal udplentx_trdy  : std_logic;
	signal udplentx_end   : std_logic;
	signal udplentx_data  : std_logic_vector(udptx_data'range);

	signal dhcplentx_end  : std_logic;

	signal udplentx_full     : std_logic;
	signal dhcpcdipdatx_irdy : std_logic;
	signal udpmactx_irdy     : std_logic;
	signal udpipdatx_irdy    : std_logic;
	signal udpiplentx_irdy   : std_logic;
	signal dhcpciplentx_irdy : std_logic;

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
		signal dev_req    : std_logic_vector(0 to 2-1);
		signal dev_gnt    : std_logic_vector(0 to 2-1);
	begin

		dev_req <= dhcpctx_frm & pltx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			req => dev_req,
			gnt => dev_gnt);

		udptx_frm    <= wirebus(dhcpctx_frm       & pltx_frm,     dev_gnt);
		udptx_irdy   <= wirebus(dhcpctx_irdy      & pltx_irdy,    dev_gnt);
		udptx_end    <= wirebus(dhcpctx_end       & udppltx_end,  dev_gnt);
		udptx_data   <= wirebus(dhcpctx_data      & udppltx_data, dev_gnt);
		iplentx_irdy <= wirebus(dhcpciplentx_irdy & udpiplentx_irdy, dev_gnt);
		(dhcpctx_trdy, udppltx_trdy) <= dev_gnt and (dev_gnt'range => udptx_trdy);
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

		signal tpttx_end   : std_logic;
		signal tpttx_irdy  : std_logic;

	begin

    	meta_b : block

    		signal tptsp_irdy  : std_logic;
    		signal tptsp_end   : std_logic;
    		signal tptsp_data  : std_logic_vector(pltx_data'range);

    		signal tptdp_irdy  : std_logic;
    		signal tptdp_end   : std_logic;
    		signal tptdp_data  : std_logic_vector(pltx_data'range);

    		signal tptlen_irdy : std_logic;
    		signal tptlen_end  : std_logic;
    		signal tptlen_data : std_logic_vector(pltx_data'range);

    	begin

    		tptsp_irdy  <= tpttx_irdy;
    		tptdp_irdy  <= tpttx_irdy when tptsp_end='1' else '0';
    		tptlen_irdy <= tpttx_irdy when tptdp_end='1' else '0';

    		udpsp_e : entity hdl4fpga.sio_ram
    		generic map (
    			mem_length => 16)
    		port map (
    			si_clk   => mii_clk,
    			si_frm   => udppltx_frm,
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
    			si_frm  => udppltx_frm,
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

    		udplen_b : block
    			-- port (
    				-- si_clk  : in  std_logic;
    				-- si_frm  : in  std_logic;
    				-- si_irdy : in  std_logic;
    				-- si_trdy : out std_logic;
    				-- si_full : out std_logic;
    				-- si_data : in  std_logic_vector;
    				-- 
    				-- so_clk  : in  std_logic;
    				-- so_frm  : in  std_logic;
    				-- so_irdy : in  std_logic;
    				-- so_trdy : out std_logic;
    				-- so_end  : out std_logic;
    				-- so_data : out std_logic_vector)
    			-- port map (
    				-- si_clk  => mii_clk,
    				-- si_frm  => udppltx_frm,
    				-- si_irdy => tptlen_irdy,
    				-- si_trdy => open,
    				-- si_full => tptlen_end,
    				-- si_data => udppltx_data,
    -- 
    			    -- so_clk  => mii_clk,
    			    -- so_frm  => udpltx_frm,
    			    -- so_irdy => udplen_irdy,
    			    -- so_trdy => open,
    			    -- so_end  => udplen_end,
    			    -- so_data => udplen_data);

    			alias si_frm  is udppltx_frm;
    			alias si_irdy is tptlen_irdy;
    			alias si_end  is tptlen_end;
    			alias si_data is udppltx_data;

    			alias so_frm  is udppltx_frm;
    			alias so_irdy is udplen_irdy;
    			alias so_end  is udplen_end;
    			alias so_data is udplen_data;

    			signal crtn_data : std_logic_vector(si_data'range);
    			signal si_ci     : std_logic;
    			signal si_co     : std_logic;
    			signal si_sum    : std_logic_vector(si_data'range);
    			signal so_ci     : std_logic;
    			signal so_sum    : std_logic_vector(0 to si_data'length);

    		begin

    			crtnmux_e : entity hdl4fpga.sio_mux
    			port map (
    				mux_data => reverse(reverse(std_logic_vector(to_unsigned((summation(udp4hdr_frame)/octect_size),16))), crtn_data'length),
    				sio_clk  => mii_clk,
    				sio_frm  => si_frm,
    				sio_irdy => si_irdy,
    				sio_trdy => open,
    				so_data  => crtn_data);

    			si_adder_e : entity hdl4fpga.adder
    			port map (
    				ci  => si_ci,
    				a   => si_data,
    				b   => crtn_data,
    				s   => si_sum(1 to si_data'length),
    				co  => si_co);
    			si_sum(0) <= si_co;

    			si_cy_p : process (mii_clk)
    			begin
    				if rising_edge(mii_clk) then
    					if si_frm='0' then
    						si_ci <= '0';
    					elsif si_irdy='1' then
    						si_ci <= si_co;
    					end if;
    				end if;
    			end process;

        		ram_e : entity hdl4fpga.sio_ram
        		generic map (
    				mode_fifo  => false,
        			mem_length => 16+1*16/si_data'length)
        		port map (
        			si_clk  => mii_clk,
        			si_frm  => si_frm,
        			si_irdy => si_irdy,
        			si_trdy => open,
        			si_full => si_end,
        			si_data => si_sum,

        			so_clk  => mii_clk,
        			so_frm  => so_frm,
        			so_irdy => so_irdy,
        			so_trdy => open,
        			so_end  => so_end,
        			so_data => so_sum);

    			so_adder_e : entity hdl4fpga.adder
    			port map (
    				ci  => so_ci,
    				a   => so_sum(1 to so_data'length),
    				b   => (so_data'range => '0'),
    				s   => so_data,
    				co  => open);

    		end block;
			tpttx_end <= tptlen_end;

    	end block;

    	udptx_e : entity hdl4fpga.udp_tx
    	port map (
            mii_clk    => mii_clk,

            pl_frm     => udppltx_frm,
            pl_irdy    => pltx_irdy,
            pl_trdy    => pltx_trdy,
            pl_end     => pltx_end,
            pl_data    => pltx_data,

			dlltx_irdy  => dlltx_irdy,
			dlltx_trdy  => dlltx_trdy,
			dlltx_end   => dlltx_end,

			nettx_irdy  => nettx_irdy,
			nettx_trdy  => nettx_trdy,
			nettx_end   => nettx_end,

            tpttx_irdy  => tpttx_irdy,
            tpttx_end   => tpttx_end,

            udpsp_irdy  => udpsp_irdy,
            udpsp_end   => udpsp_end,
            udpsp_data  => udpsp_data,

            udpdp_irdy  => udpdp_irdy,
            udpdp_end   => udpdp_end,
            udpdp_data  => udpdp_data,

            udplen_irdy => udplen_irdy,
            udplen_end  => udplen_end,
            udplen_data => udplen_data,

            udp_irdy    => udppltx_irdy,
            udp_trdy    => udppltx_trdy,
            udp_end     => udppltx_end,
            udp_data    => udppltx_data);

	end block;

	dhcpcd_b : block
	begin
    	udpc_e : entity hdl4fpga.sio_muxcmp
        port map (
    		mux_data  => reverse(x"0044",8),
            sio_clk   => mii_clk,
            sio_frm   => udprx_frm,
            sio_irdy  => udpdprx_irdy,
            sio_trdy  => open,
            si_data   => udprx_data,
    		so_last   => udpsprx_last,
    		so_equ(0) => udpsprx_equ);

    	process (mii_clk)
    	begin
    		if rising_edge(mii_clk) then
    			if udprx_frm='0' then
    				udpsprx_vld <= '0';
    			elsif udpsprx_last='1' and udprx_irdy='1' then
    				udpsprx_vld <= udpsprx_equ;
    			end if;
    		end if;
    	end process;

    	dhcpcrx_frm <= udpplrx_frm and udpsprx_vld;
    	plrx_frm    <= udpplrx_frm and not udpsprx_vld;
    	plrx_rllbk  <= dhcpcrx_frm;
    	plrx_cmmt   <= plrx_frm;
    	plrx_irdy   <= (udprx_frm and (udpsprx_irdy or udpdprx_irdy)) or (udpplrx_frm and udprx_irdy);
    	plrx_data   <= udprx_data;

    	dhcpcd_e: entity hdl4fpga.dhcpcd
    	port map (
    		tp            => tp,
    		mii_clk       => mii_clk,
    		dhcpcdrx_frm  => dhcpcrx_frm,
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

    		dhcpcdtx_frm  => dhcpctx_frm,
    		mactx_full    => dlltx_end,
    		ipdatx_full   => ipdatx_full,
    		ipsatx_full   => ipsatx_full,
    		udplentx_full => iplentx_full,
    		ipv4sawr_frm  => ipv4sawr_frm,
    		ipv4sawr_irdy => ipv4sawr_irdy,
    		ipv4sawr_data => ipv4sawr_data,

    		dhcpcdtx_irdy => dhcpctx_irdy,
    		dhcpcdtx_trdy => dhcpctx_trdy,
    		dhcpcdtx_end  => dhcpctx_end,
    		dhcpcdtx_data => dhcpctx_data);

    	dhcpciplentx_irdy <= '0' when ipdatx_full='0' else dhcpctx_irdy;

	end block;

end;
