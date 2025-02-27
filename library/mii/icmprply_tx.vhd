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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmprply_tx is
	port (
		mii_clk   : in  std_logic;

		pl_frm    : in  std_logic;
		pl_irdy   : in  std_logic;
		pl_trdy   : out std_logic;
		pl_end    : in  std_logic;
		pl_data   : in  std_logic_vector;
		metatx_end  : in std_logic;

		icmpcksm_frm : out std_logic;

		icmp_frm  : out std_logic;
		icmp_irdy : out std_logic := '0';
		icmp_trdy : in  std_logic := '1';
		icmp_end  : out std_logic;
		icmp_data : out std_logic_vector);
end;

architecture def of icmprply_tx is

	signal frm_ptr : std_logic_vector(0 to unsigned_num_bits(summation(icmphdr_frame)/icmp_data'length-1));

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := to_unsigned(summation(icmphdr_frame)/icmp_data'length-1, cntr'length);
			elsif cntr(0)='0' and metatx_end='1' and(pl_irdy and icmp_trdy)='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	icmpcksm_frm <= pl_frm and frame_decode(frm_ptr, reverse(icmphdr_frame), icmp_data'length, icmp_cksm);
	pl_trdy      <= icmp_trdy;

	icmp_frm  <= pl_frm;
	icmp_data <= pl_data;
	icmp_irdy <= pl_irdy;
	icmp_end  <= pl_end;

end;

