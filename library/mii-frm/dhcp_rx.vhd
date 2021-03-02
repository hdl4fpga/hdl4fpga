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

entity dhcp_rx is
	port (
		mii_clk      : in  std_logic;
		mii_frm      : in  std_logic;
		mii_data     : in  std_logic_vector;
		mii_ptr      : in  std_logic_vector;
		dhcp_frm     : in  std_logic;
		dhcpop_frm  : out std_logic;
		dhcpchaddr6_frm : out std_logic;
		dhcpyia_frm : out std_logic);
end;

architecture def of dhcp_rx is

begin
					
	dhcpop_frm  <= dhcp_frm and frame_decode(mii_ptr, eth_frame & ip4hdr_frame & udp4hdr_frame & dhcp4hdr_frame, mii_data'length, dhcp4_op);
	dhcpchaddr6_frm  <= dhcp_frm and frame_decode(mii_ptr, eth_frame & ip4hdr_frame & udp4hdr_frame & dhcp4hdr_frame, mii_data'length, dhcp4_chaddr6);
	dhcpyia_frm <= dhcp_frm and frame_decode(mii_ptr, eth_frame & ip4hdr_frame & udp4hdr_frame & dhcp4hdr_frame, mii_data'length, dhcp4_yiaddr);

end;

