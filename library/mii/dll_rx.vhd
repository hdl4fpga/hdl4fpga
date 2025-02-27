-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;

entity dll_rx is
	port (
		mii_clk    : in  std_logic;
		dll_frm    : in  std_logic;
		dll_irdy   : in  std_logic;
		dll_trdy   : buffer std_logic;
		dll_data   : in  std_logic_vector;

		hwda_irdy  : buffer std_logic;
		hwda_trdy  : in  std_logic := '1';
		hwda_end   : in  std_logic := '1';
		hwsa_irdy  : buffer std_logic;
		hwsa_trdy  : in  std_logic := '1';
		hwsa_end   : in  std_logic := '1';
		hwtyp_irdy : buffer std_logic;
		hwtyp_trdy : in  std_logic := '1';
		hwtyp_end  : in  std_logic := '1';
		pl_irdy    : out std_logic;
		pl_trdy    : in  std_logic := '1';

		crc_sb     : out std_logic;
		crc_equ    : out std_logic;
		crc_rem    : buffer std_logic_vector(0 to 32-1));

end;

architecture def of dll_rx is

	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(eth_frame)/dll_data'length-1));
	signal hwda_frm  : std_logic;
	signal hwsa_frm  : std_logic;
	signal hwtyp_frm : std_logic;
	signal pl_frm    : std_logic;
	signal crc_frm   : std_logic;
	signal crc_irdy  : std_logic;

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if dll_frm='0' then
				cntr := to_unsigned(summation(eth_frame)/dll_data'length-1, cntr'length);
			elsif cntr(0)='0' and dll_irdy='1' and dll_trdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	hwda_frm   <= dll_frm  and frame_decode(frm_ptr, reverse(eth_frame), dll_data'length, eth_hwda);
	hwsa_frm   <= dll_frm  and frame_decode(frm_ptr, reverse(eth_frame), dll_data'length, eth_hwsa);
	hwtyp_frm  <= dll_frm  and frame_decode(frm_ptr, reverse(eth_frame), dll_data'length, eth_type);
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

