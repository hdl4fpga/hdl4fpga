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

entity arp_tx is
	generic (
		hwsa     : std_logic_vector(0 to 48-1));
	port (
		mii_clk  : in  std_logic;
		arp_req  : in  std_logic;
		arp_rdy  : buffer std_logic;
		
		pa_frm   : buffer std_logic;
		pa_irdy  : out std_logic;
		pa_trdy  : in  std_logic;
		pa_end   : in  std_logic;
		pa_data  : in  std_logic_vector;

		dlltx_irdy : out std_logic;
		dlltx_data : buffer std_logic_vector;
		dlltx_end  : in  std_logic;

		arp_frm  : buffer std_logic;
		arp_irdy : buffer std_logic;
		arp_trdy : in  std_logic;
		arp_end  : out std_logic;
		arp_data : out std_logic_vector);

end;

architecture def of arp_tx is

	signal frm_ptr     : std_logic_vector(0 to unsigned_num_bits(summation(arp4_frame)/arp_data'length-1));
	signal arpmux_irdy : std_logic;
	signal arpmux_trdy : std_logic;
	signal arpmux_data : std_logic_vector(arp_data'range);

begin

	arp_frm <= to_stdulogic(to_bit(arp_rdy) xor to_bit(arp_req));
	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if arp_frm='0' then
				cntr := to_unsigned(summation(arp4_frame)/arp_data'length-1, cntr'length);
			elsif cntr(0)='0' then
				if dlltx_end='1' then
					if (arp_irdy and arp_trdy)='1' then
						cntr := cntr - 1;
					end if;
				end if;
			elsif (arp_irdy and arp_trdy)='1' then
				arp_rdy <= to_stdulogic(to_bit(arp_req));
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	process (arp_frm, dlltx_end, frm_ptr)
	begin
		if arp_frm='1' then
			if frame_decode(frm_ptr, reverse(arp4_frame), arp_data'length, arp_spa)='1' then
				pa_frm <= '1';
			elsif frame_decode(frm_ptr, reverse(arp4_frame), arp_data'length, arp_tpa)='1' then
				pa_frm <= '1';
			else
				pa_frm <= '0';
			end if;
		else
			pa_frm <= '0';
		end if;
	end process;
	pa_irdy <= pa_frm and arp_irdy and arp_trdy;
	
	arpmux_irdy <= 
		'0' when dlltx_end='0' else
		'0' when    pa_frm='1' else
		arp_trdy;
	arpmux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(
			x"0001" &                 -- htype 
			x"0800" &                 -- ptype 
			x"06"   &                 -- hlen  
			x"04"   &                 -- plen  
			x"0002" &                 -- oper  
			hwsa    &                 -- Sender Hardware Address
			x"ff_ff_ff_ff_ff_ff", 8), -- Target Hardware Address
        sio_clk  => mii_clk,
		sio_frm  => arp_frm,
		sio_irdy => arpmux_irdy,
        sio_trdy => arpmux_trdy,
        so_data  => arpmux_data);

	dlltx_irdy <= arp_frm and arp_trdy;
	dlltx_data <= (arp_data'range => '1');
	arp_irdy   <= 
		arp_frm     when dlltx_end='0' else
		arpmux_trdy when    pa_frm='0' else 
		pa_trdy;
	arp_data   <= 
		dlltx_data  when dlltx_end='0' else
		arpmux_data when    pa_frm='0' else
		pa_data;
	arp_end    <= frm_ptr(0);

end;
