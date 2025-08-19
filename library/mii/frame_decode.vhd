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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

entity frame_decode is
    generic (
        frame : string;
        size  : natural)
	port (
		clk  : in  std_logic;
		frm  : in  std_logic;
		irdy : in  std_logic;
		trdy : buffer std_logic;
		vld  : buffer std_logic_vector(0 to length(frame)-1);
end;

architecture def of dll_rx is
begin

	process (clk)
        type states is (s_init, s_run)
        variable state : states;
		variable cntr : unsigned(0 to unsigned_num_bits(summation(frame)/size-1));
	begin
		if rising_edge(mii_clk) then
            case state is
            when s_init =>
			if frm='0' then
				cntr := to_unsigned(summation(mac_frame)/dll_data'length-1, cntr'length);
			elsif cntr(0)='0' and dll_irdy='1' and dll_trdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	hwda_frm   <= dll_frm  and frame_decode(frm_ptr, reverse(mac_frame), dll_data'length, eth_hwda);
	hwsa_frm   <= dll_frm  and frame_decode(frm_ptr, reverse(mac_frame), dll_data'length, eth_hwsa);
	hwtyp_frm  <= dll_frm  and frame_decode(frm_ptr, reverse(mac_frame), dll_data'length, eth_type);
	pl_frm     <= dll_frm  and frm_ptr(0);
	hwda_irdy  <= dll_irdy and hwda_frm;
	hwsa_irdy  <= dll_irdy and hwsa_frm;
	hwtyp_irdy <= dll_irdy and hwtyp_frm;
	pl_irdy    <= dll_irdy and pl_frm;

	crc_frm  <= dll_frm;
	crc_irdy <= dll_irdy;
	crc_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => crc_frm,
		irdy => crc_irdy,
		data => dll_data,
		crc  => crc_rem);

	process (dll_frm, mii_clk)
		variable q : bit;
	begin
		if rising_edge(mii_clk) then
			q := to_bit(dll_frm);
		end if;
		crc_sb <= to_stdulogic(q) and not to_stdulogic(to_bit(dll_frm));
	end process;
	crc_equ <= setif(crc_rem=x"38fb2284");

	dll_trdy <=
	   hwda_trdy  when hwda_frm='1'  else
	   hwsa_trdy  when hwsa_frm='1'  else
	   hwtyp_trdy when hwtyp_frm='1' else
	   pl_trdy    when pl_frm='1'    else
	   '1';
end;
