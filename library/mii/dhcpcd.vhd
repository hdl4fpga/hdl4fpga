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
		ipv4sawr_data : out std_logic_vector;

		hwda_frm      : out std_logic;
		hwda_irdy     : out std_logic;
		hwda_trdy     : in  std_logic;
		hwda_last     : in  std_logic;
		hwda_equ      : in  std_logic;
		hwdarx_vld    : in  std_logic;

		dhcpdscb_frm  : buffer std_logic;
		dlltx_end     : in  std_logic := '1';
		netdatx_end   : in  std_logic := '1';
		netsatx_end   : in  std_logic := '1';
		netlentx_trdy : in  std_logic := '1';
		netlentx_end  : in  std_logic := '1';

		dhcpcdtx_irdy : buffer std_logic;
		dhcpcdtx_trdy : in  std_logic;
		dhcpcdtx_end  : buffer std_logic;
		dhcpcdtx_data : out std_logic_vector;
		tp : out std_logic_vector(1 to 32));
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
		variable req : std_logic;
	begin
		if rising_edge(mii_clk) then
			if to_bit(arp_req xor arp_rdy)='0' then
				if (dhcpyia_frm and hwdarx_vld)='0' then
					arp_req <= req xor arp_rdy;
					req     := '0';
				elsif (dhcpyia_frm and hwdarx_vld)='1' then
					req := '1';
				end if;
			elsif (dhcpyia_frm and hwdarx_vld)='1' then
				req := '1';
			end if;
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

	dhcpdscb_frm <= dhcpcd_req xor dhcpcd_rdy when nettx_end='1' else '0';
	dhcpdscb_e : entity hdl4fpga.dhcpc_dscb
	port map (
		mii_clk       => mii_clk,
		dhcpdscb_frm  => dhcpdscb_frm,
		dlltx_end     => dlltx_end,
		netdatx_end   => netdatx_end,
		netlentx_end  => netlentx_end,
		netlentx_irdy => netlentx_trdy,
		dhcpdscb_irdy => dhcpdscb_irdy,
		dhcpdscb_trdy => dhcpdscb_trdy,
		dhcpdscb_end  => dhcpdscb_end,
		dhcpdscb_data => dhcpdscb_data);

	dhcpdscb_irdy <=
		nettx_irdy    when netlentx_end='0' else
		dhcpdscb_irdy;
	dhcpcdtx_irdy <=
		netdatx_irdy when netdatx_end='0' else
		dhcpdscb_trdy;
	dhcpcdtx_end <=
		'0' when netdatx_end='0' else
		dhcppkt_end;
	dhcpcdtx_data <=
		(dhcpdscb_data'range => '1') when   dlltx_end='0'  else
		(dhcpdscb_data'range => '-') when netlentx_end='0' else
		(dhcpdscb_data'range => '1') when  netdatx_end='0' else
		dhcpdscb_data;

	ipv4sawr_frm  <= 
		'1' when dhcpdscb_frm='1'                 else
		'1' when (dhcpyia_frm and hwdarx_vld)='1' else
		'0';
	ipv4sawr_irdy <=
		'1'          when dhcpdscb_frm='1'                  else
		dhcpyia_irdy when (dhcpyia_frm and hwdarx_vld)='1'  else
		'0';
	ipv4sawr_data <=
		(ipv4sawr_data'range => '0') when dhcpdscb_frm='1' else
		dhcpcdrx_data                when  dhcpyia_frm='1'  else
		(ipv4sawr_data'range => '-');

end;
