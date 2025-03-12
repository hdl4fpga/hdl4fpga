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

entity dhcpc_offer is
	port (
		mii_clk          : in  std_logic;
		dhcp_frm         : in  std_logic;
		dhcp_irdy        : in  std_logic;
		dhcp_data        : in  std_logic_vector;
		dhcpop_irdy      : out std_logic;
		dhcpchaddr6_frm  : buffer std_logic;
		dhcpchaddr6_irdy : out std_logic;
		dhcpyia_frm      : buffer std_logic;
		dhcpyia_irdy     : out std_logic);
end;

architecture def of dhcpc_offer is
	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(dhcp4hdr_frame)/dhcp_data'length-1));

	signal dhcpop_frm      : std_logic;

begin
					
	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if dhcp_frm='0' then
				cntr := to_unsigned(summation(dhcp4hdr_frame)/dhcp_data'length-1, cntr'length);
			elsif cntr(0)='0' and dhcp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	dhcpop_frm      <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_op);
	dhcpchaddr6_frm <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_chaddr6);
	dhcpyia_frm     <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_yiaddr);

	dhcpop_irdy  <= dhcp_irdy and dhcpop_frm;
	dhcpchaddr6_irdy <= dhcp_irdy and dhcpchaddr6_frm;
	dhcpyia_irdy <= dhcp_irdy and dhcpyia_frm;

end;

