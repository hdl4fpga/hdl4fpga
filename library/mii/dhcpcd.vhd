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
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;

entity dhcpcd is
	port (
		mii_clk       : in  std_logic;
		dhcpcdrx_frm  : in  std_logic;
		dhcpcdrx_irdy : in  std_logic;
		dhcpcdrx_data : in  std_logic_vector;

		arp_req       : buffer std_logic := '0';
		arp_rdy       : in  std_logic := '0';

		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		ipv4sawr_frm  : out std_logic := '0';
		ipv4sawr_irdy : out std_logic := '0';
		ipv4sawr_end  : in  std_logic := '1';
		ipv4sawr_data : out std_logic_vector;

		hwda_frm      : out std_logic;
		hwda_irdy     : out std_logic;
		hwda_trdy     : in  std_logic;
		hwda_last     : in  std_logic;
		hwda_equ      : in  std_logic;
		hwdarx_vld    : in  std_logic;

		dhcpcdtx_frm  : buffer std_logic;
		dlltx_irdy    : out std_logic;
		dlltx_end     : in  std_logic;
		dlltx_data    : out std_logic_vector;
		netdatx_end   : in  std_logic;
		netdatx_irdy  : out std_logic;
		netlentx_end  : in  std_logic;
		netlentx_irdy : out std_logic;
		netlentx_data : out std_logic_vector;
		nettx_end     : in  std_logic;

		dhcpcdtx_irdy : buffer std_logic;
		dhcpcdtx_trdy : in  std_logic;
		dhcpcdtx_end  : buffer std_logic;
		dhcpcdtx_data : out std_logic_vector;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of dhcpcd is

	signal dhcpop_irdy       : std_logic;
	signal dhcpchaddr6_frm   : std_logic;
	signal dhcpchaddr6_irdy  : std_logic;
	signal dhcpyia_frm       : std_logic;
	signal dhcpyia_irdy      : std_logic;

	signal dhcpctx_irdy      : std_logic;

	signal dscbipv4sawr_frm  : std_logic;
	signal dscbipv4sawr_irdy : std_logic;

begin

	dhcpoffer_e : entity hdl4fpga.dhcpc_offer
	port map (
		mii_clk          => mii_clk,
		dhcp_frm         => dhcpcdrx_frm,
		dhcp_irdy        => dhcpcdrx_irdy,
		dhcp_data        => dhcpcdrx_data,

		dhcpop_irdy      => dhcpop_irdy,
		dhcpchaddr6_frm  => dhcpchaddr6_frm,
		dhcpchaddr6_irdy => dhcpchaddr6_irdy,
		dhcpyia_frm      => dhcpyia_frm,
		dhcpyia_irdy     => dhcpyia_irdy);

	process (mii_clk)
		type states is (s_idle, s_offer, s_arp);
		variable state : states;
	begin
		if rising_edge(mii_clk) then
			case state is
			when s_idle =>
				if (dhcpyia_frm and hwdarx_vld)='1' then
					state := s_offer;
				else
				end if;
			when s_offer =>
				if (dhcpyia_frm and hwdarx_vld)='0' then
					if (to_bit(arp_req) xor to_bit(arp_rdy))='0' then
						arp_req <= not to_stdulogic(to_bit(arp_rdy));
						state := s_arp;
					end if;
				end if;
			when s_arp =>
				if (to_bit(arp_req) xor to_bit(arp_rdy))='0' then
					state := s_idle;
				end if;
			end case;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (dhcpcd_req xor dhcpcd_rdy)='1' then
				if dhcpcdtx_trdy='1' then
					dhcpcd_rdy <= dhcpcdtx_end xnor dhcpcd_req;
				end if;
			end if;
		end if;
	end process;

	dhcpcdtx_frm <= to_stdulogic(to_bit(dhcpcd_req)) xor dhcpcd_rdy;
	dhcpdscb_e : entity hdl4fpga.dhcpc_dscb
	port map (
		mii_clk       => mii_clk,
		dhcpdscb_frm  => dhcpcdtx_frm,
		dlltx_irdy    => dlltx_irdy,
		dlltx_end     => dlltx_end,
		dlltx_data    => dlltx_data,
		netdatx_irdy  => netdatx_irdy,
		netdatx_end   => netdatx_end,
		netlentx_irdy => netlentx_irdy,
		netlentx_data => netlentx_data,
		netlentx_end  => netlentx_end,
		nettx_end     => nettx_end,
		dhcpdscb_irdy => dhcpcdtx_irdy,
		dhcpdscb_trdy => dhcpcdtx_trdy,
		dhcpdscb_end  => dhcpcdtx_end,
		dhcpdscb_data => dhcpcdtx_data);

	ipv4sawr_frm  <= dhcpcdtx_frm or (dhcpyia_frm and hwdarx_vld);
	ipv4sawr_irdy <=
		'1'          when dhcpcdtx_frm='1' else
		dhcpyia_irdy when (dhcpyia_frm and hwdarx_vld)='1'  else
		'0';
	ipv4sawr_data <=
		(ipv4sawr_data'range => '0') when dhcpcdtx_frm='1' else
		dhcpcdrx_data                when  dhcpyia_frm='1' else
		(ipv4sawr_data'range => '-');

end;
