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

entity icmprqst_rx is
	port (
		mii_clk      : in  std_logic;
		icmp_frm     : in  std_logic;
		icmp_data    : in  std_logic_vector;
		icmp_irdy    : in  std_logic;

		icmptype_frm : buffer std_logic;
		icmptype_irdy : out std_logic;
		icmpcode_frm : buffer std_logic;
		icmpcode_irdy : out std_logic;
		icmpcksm_frm : buffer std_logic;
		icmpcksm_irdy : out std_logic;
		icmppl_frm   : buffer std_logic;
		icmppl_irdy  : out std_logic);
end;

architecture def of icmprqst_rx is

	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(icmphdr_frame)/icmp_data'length-1));

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if icmp_frm='0' then
				cntr := to_unsigned(summation(icmphdr_frame)/icmp_data'length-1, cntr'length);
			elsif cntr(0)='0' and icmp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	icmptype_frm <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame), icmp_data'length, icmp_type);
	icmpcode_frm <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame), icmp_data'length, icmp_code);
	icmpcksm_frm <= icmp_frm and frame_decode(frm_ptr, reverse(icmphdr_frame), icmp_data'length, icmp_cksm);
	icmppl_frm   <= icmp_frm and frm_ptr(0);

	icmptype_irdy <= icmp_irdy and icmptype_frm;
	icmpcode_irdy <= icmp_irdy and icmpcode_frm;
	icmpcksm_irdy <= icmp_irdy and icmpcksm_frm;
	icmppl_irdy   <= icmp_irdy and icmppl_frm;

end;

