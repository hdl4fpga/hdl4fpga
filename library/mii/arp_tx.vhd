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
	generic (
		hwsa     : std_logic_vector(0 to 48-1));
	port (
		mii_clk  : in  std_logic;
		arp_frm  : in  std_logic;
		
		pa_frm   : buffer std_logic;
		pa_irdy  : out std_logic;
		pa_trdy  : in  std_logic;
		pa_end   : in  std_logic;
		pa_data  : in  std_logic_vector;

		arp_irdy : in  std_logic;
		arp_trdy : out std_logic;
		arp_end  : out std_logic;

		arp_data : out std_logic_vector);

end;

architecture def of arp_tx is
	constant sha : std_logic_vector := hwsa;
	constant tha : std_logic_vector := x"ff_ff_ff_ff_ff_ff";

	signal mux_data    : std_logic_vector(0 to summation(arp4_frame)-(arp4_frame(arp_spa)+arp4_frame(arp_tpa))-1);
	signal frm_ptr     : std_logic_vector(0 to unsigned_num_bits(summation(arp4_frame)/arp_data'length-1));
	signal arpmux_irdy : std_logic;
	signal arpmux_data : std_logic_vector(arp_data'range);

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if arp_frm='0' then
				cntr := to_unsigned(summation(arp4_frame)/arp_data'length-1, cntr'length);
			elsif cntr(0)='0' and arp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	pa_frm  <= arp_frm and (
		frame_decode(frm_ptr, reverse(arp4_frame), arp_data'length, arp_spa) or
		frame_decode(frm_ptr, reverse(arp4_frame), arp_data'length, arp_tpa));
	pa_irdy <= pa_frm and arp_irdy;
	
	mux_data <= reverse(
		x"0001"          & -- htype 
		x"0800"          & -- ptype 
		x"06"            & -- hlen  
		x"04"            & -- plen  
		x"0002"          & -- oper  
	    sha              & -- Sender Hardware Address
		tha,             8);    -- Target Hardware Address

	arpmux_irdy <= '0' when pa_frm='1' else arp_irdy;
	arpmux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => mii_clk,
		sio_frm  => arp_frm,
		sio_irdy => arpmux_irdy,
        sio_trdy => arp_trdy,
        so_data  => arpmux_data);
	arp_data <= arpmux_data when pa_frm='0' else pa_data;
	arp_end  <= frm_ptr(0);

end;
