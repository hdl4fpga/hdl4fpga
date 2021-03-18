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

entity arpd is
	port (
		my_ipv4a   : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		my_mac     : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");

		mii_clk    : in  std_logic;

		arprx_frm  : in  std_logic;
		arprx_irdy : in  std_logic;
		arprx_trdy : out std_logic;
		arprx_data : in  std_logic;

		arptx_frm  : out std_logic;
		arptx_irdy : out std_logic;
		arptx_trdy : in  std_logic;
		arptx_data : out std_logic;

		dllfcs_sb  : out std_logic;
		dllfcs_vld : buffer std_logic;

		tp         : out std_logic_vector(1 to 32));

end;

architecture def of arpd is
begin

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_clk  => mii_clk,
		mii_ptr  => rxfrm_ptr,
		arp_frm  => arprx_frm,
		arp_irdy => arprx_irdy,
		arp_data => arprx_data,
		tpa_irdy => tpa_irdy);

	arptx_e : entity hdl4fpga.arp_tx
	port map (
		mii_clk  => mii_clk,
		arp_frm  => arptx_frm,
		sha      => my_mac,
		spa      => cfgipv4a,
		tha      => x"ff_ff_ff_ff_ff_ff",
		tpa      => cfgipv4a,
		arp_irdy => arptx_irdy,
		arp_data => arptx_data);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dev_gnt(arp_gnt)='1' then
				if arp_irdy='0' then
					arp_req	<= '0';
				end if;
			elsif arp_rcvd='1' then
				arp_req <= '1';
			elsif dhcp_rcvd='1' then
				arp_req <= '1';
			end if;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if dll_rxdv='0' then
				if txc_eor='1' then
					arp_rcvd <= typearp_rcvd and myip4a_rcvd;
				elsif arp_req='1' then
					arp_rcvd <= '0';
				end if;
			end if;
		end if;
	end process;

end;
