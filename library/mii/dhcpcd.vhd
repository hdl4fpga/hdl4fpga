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
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;

entity dhcpcd is
	port (
		mii_clk       : in  std_logic;
		dhcpcdrx_frm  : in  std_logic;
		dhcpcdrx_irdy : in  std_logic;
		dhcpcdrx_data : in  std_logic_vector;

		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		ipv4sawr_frm  : out std_logic := '0';
		ipv4sawr_irdy : out std_logic := '0';

		dhcpcdtx_frm  : buffer std_logic;
		ipdatx_full   : in  std_logic := '1';
		ipdatx_irdy   : in  std_logic := '1';
		udplentx_full : in  std_logic := '1';
		udplentx_irdy : in  std_logic := '1';

		dhcpcdtx_irdy : buffer std_logic;
		dhcpcdtx_trdy : in  std_logic;
		dhcpcdtx_end  : buffer std_logic;
		dhcpcdtx_data : out std_logic_vector);
end;

architecture def of dhcpcd is

	signal dhcpop_irdy  : std_logic;
	signal dhcpchaddr6_irdy: std_logic;
	signal dhcpyia_irdy : std_logic;

	signal dhcpctx_irdy : std_logic;

begin

	dhcpoffer_e : entity hdl4fpga.dhcpc_offer
	port map (
		mii_clk      => mii_clk,
		dhcp_frm     => dhcpcdrx_frm,
		dhcp_irdy    => dhcpcdrx_irdy,
		dhcp_data    => dhcpcdrx_data,

		dhcpop_irdy  => dhcpop_irdy,
		dhcpchaddr6_irdy => dhcpchaddr6_irdy,
		dhcpyia_irdy => dhcpyia_irdy);

	process (mii_clk)
		variable q : std_logic;
	begin
		if rising_edge(mii_clk) then
			if (dhcpcd_req xor dhcpcd_rdy)='1' then
				if dhcpcdtx_trdy='1' then
					dhcpcd_rdy <= dhcpcdtx_end xnor dhcpcd_req;
				end if;
			end if;
		end if;
	end process;

	dhcpcdtx_frm <= dhcpcd_req xor dhcpcd_rdy;
	dhcpdscb_e : entity hdl4fpga.dhcpc_dscb
	port map (
		mii_clk       => mii_clk,
		dhcpdscb_frm  => dhcpcdtx_frm,
		ipdatx_full   => ipdatx_full,
		udplentx_full => udplentx_full,
		udplentx_irdy => udplentx_irdy,
		dhcpdscb_irdy => dhcpcdtx_trdy,
		dhcpdscb_trdy => dhcpcdtx_irdy,
		dhcpdscb_end  => dhcpcdtx_end,
		dhcpdscb_data => dhcpcdtx_data);

end;
