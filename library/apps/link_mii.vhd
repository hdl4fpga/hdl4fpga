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
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

entity link_mii is
	generic (
		rmii          : boolean := false;
		default_mac   : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03";
		default_ipv4a : std_logic_vector(0 to 32-1) := aton("192.168.1.1");
		n             : natural);
	port (
		tp       : out std_logic_vector(1 to 32);
		si_frm   : in  std_logic;
		si_irdy  : in  std_logic;
		si_trdy  : out std_logic;
		si_end   : in  std_logic;
		si_data  : in  std_logic_vector(0 to 8-1);

		so_frm   : out std_logic;
		so_irdy  : out std_logic;
		so_trdy  : in  std_logic;
		so_data  : out std_logic_vector(0 to 8-1);

		dhcp_btn : in  std_logic;
		hdplx    : in  std_logic := '0';
		mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector(0 to n-1);

		mii_txc  : in  std_logic;
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector(0 to n-1));
end;

architecture graphics of link_mii is
	signal dhcpcd_req : std_logic;
	signal dhcpcd_rdy : std_logic;

	signal miitx_frm  : std_logic;
	signal miitx_irdy : std_logic;
	signal miitx_trdy : std_logic;
	signal miitx_end  : std_logic;
	signal miitx_data : std_logic_vector(si_data'range);

	signal rxdv       : std_logic;
begin

   	process (mii_rxdv, mii_rxc)
   		variable last_rxd : std_logic;
   	begin
   		if rising_edge(mii_rxc) then
   			last_rxd := mii_rxdv;
   		end if;
		if rmii then
       		rmii : if mii_rxdv='1' then
       			rxdv <= '1';
       		elsif last_rxd='1' then
       			rxdv <= '1';
       		else 
       			rxdv <= '0';
       		end if;
		else
			non_rmii : rxdv <= mii_rxdv;
		end if;
   	end process;

	dhcp_p : process(mii_txc)
		type states is (s_request, s_wait);
		variable state : states;
	begin
		if rising_edge(mii_txc) then
			case state is
			when s_request =>
				if dhcp_btn='1' then
					dhcpcd_req <= not dhcpcd_rdy;
					state := s_wait;
				end if;
			when s_wait =>
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					if dhcp_btn='0' then
						state := s_request;
					end if;
				end if;
			end case;
		end if;
	end process;

	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		my_mac        => default_mac,
		default_ipv4a => default_ipv4a)
	port map (
		tp         => tp,
		hdplx      => hdplx,
		mii_clk    => mii_txc,
		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,
		miirx_frm  => rxdv,
		miirx_data => mii_rxd,
	
		miitx_frm  => miitx_frm,
		miitx_irdy => miitx_irdy,
		miitx_trdy => miitx_trdy,
		miitx_end  => miitx_end,
		miitx_data => miitx_data,
	
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_end     => si_end,
		si_data    => si_data,
	
		so_clk     => mii_txc,
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data);
	
	desser_e: entity hdl4fpga.desser
	port map (
		desser_clk => mii_txc,
	
		des_frm  => miitx_frm,
		des_irdy => miitx_irdy,
		des_trdy => miitx_trdy,
		des_data => miitx_data,
	
		ser_irdy => open,
		ser_data => mii_txd);
	
	mii_txen <= miitx_frm and not miitx_end;
end;