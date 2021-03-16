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

entity arp_tx is
	port (
		mii_clk  : in  std_logic;
		arp_frm  : in  std_logic;
		
		sha      : in std_logic_vector;
		tha      : in std_logic_vector;
		tpa      : in std_logic_vector;
		spa      : in std_logic_vector;

		arp_irdy : in  std_logic;
		arp_trdy : out std_logic;
		arp_end  : out std_logic;

		arp_data : out std_logic_vector);

end;

architecture def of arp_tx is
	signal mux_data : std_logic_vector(0 to summation(arp4_frame)*8-1);
begin
	
	mux_data <=
		x"0001" & -- htype 
		x"0800" & -- ptype 
		x"06"   & -- hlen  
		x"04"   & -- plen  
		x"0002" & -- oper  
	    sha     & -- Sender Hardware Address
		spa     & -- Sender Protocol Address
		tha     & -- Target Hardware Address
		tpa;      -- Target Protocol Address

	arpmux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => mii_clk,
		sio_frm  => arp_frm,
		sio_irdy => arp_irdy,
        sio_trdy => arp_trdy,
        so_end   => arp_end,
        so_data  => arp_data);

end;
