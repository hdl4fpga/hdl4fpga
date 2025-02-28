-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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





