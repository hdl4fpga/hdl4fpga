--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

architecture miitx_udp of testbench is
	signal mii_req  : std_logic;

	signal mii_txc  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(4-1 downto 0);
		
begin

	mii_txc <= not mii_txc after 5 ns;
	mii_req <= '0', '1' after 111 ns, '0' after 4000 ns, '1' after 4045 ns;

	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		mii_req  => mii_req,
		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_txd  => mii_txd);

end;
