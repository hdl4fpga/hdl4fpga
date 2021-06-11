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

entity dhcpc is
	port (
		mii_clk     : in  std_logic;
		dhcprx_frm  : in  std_logic;
		dhcprx_irdy  : in  std_logic;
		dhcprx_data  : in  std_logic_vector;

		dhcpc_req   : in  std_logic;
		dhcpc_rdy   : buffer std_logic;

		dhcptx_frm  : buffer std_logic;
		dhcptx_irdy : buffer std_logic;
		dhcptx_trdy : in  std_logic := '1';
		dhcptx_end  : buffer std_logic;
		dhcptx_len  : out std_logic_vector(0 to 16-1);
		dhcptx_data : out std_logic_vector);
end;

architecture def of dhcpc is

	signal dhcpop_irdy  : std_logic;
	signal dhcpchaddr6_irdy: std_logic;
	signal dhcpyia_irdy : std_logic;

begin

	dhcpoffer_e : entity hdl4fpga.dhcpc_offer
	port map (
		mii_clk       => mii_clk,
		dhcp_frm     => dhcprx_frm,
		dhcp_irdy    => dhcprx_irdy,
		dhcp_data    => dhcprx_data,

		dhcpop_irdy  => dhcpop_irdy,
		dhcpchaddr6_irdy => dhcpchaddr6_irdy,
		dhcpyia_irdy => dhcpyia_irdy);

	process (mii_clk)
		variable q : std_logic;
	begin
		if rising_edge(mii_clk) then
			if (dhcpc_req xor dhcpc_rdy)='1' then
				if dhcprx_frm='0' then
					dhcpc_rdy <= dhcpc_req;
				end if;
			end if;
		end if;
	end process;

	dhcpdscb_e : entity hdl4fpga.dhcpc_dscb
	port map (
		mii_clk       => mii_clk,
		dhcpdscb_frm  => dhcptx_frm,
		dhcpdscb_irdy => dhcptx_trdy,
		dhcpdscb_trdy => dhcptx_irdy,
		dhcpdscb_end  => dhcptx_end,
		dhcpdscb_len  => dhcptx_len,
		dhcpdscb_data => dhcptx_data);

end;
