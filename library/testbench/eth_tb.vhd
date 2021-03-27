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

architecture eth_tb of testbench is
	signal mii_rxc  : std_logic;
	signal mii_txc  : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_req1 : std_logic;
	signal mii_req2 : std_logic;
	signal mii_data : std_logic_vector(0 to 8-1);

begin
	
	mii_txc  <= not to_stdulogic(to_bit(mii_txc)) after 20 ns;
	mii_rxc  <= mii_txc;
	mii_req1 <= '0', '1' after 70 ns;
	mii_req2 <= '0';
	du_e : entity hdl4fpga.eth_tb
	port map (
		mii_frm1 => mii_req1,
		mii_frm2 => mii_req2,
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_data,
                         
		mii_txc  => mii_txc,
		mii_txd  => mii_data);

end;
