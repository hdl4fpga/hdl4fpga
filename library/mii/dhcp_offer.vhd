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

entity dhcpc_offer is
	port (
		mii_clk          : in  std_logic;
		dhcp_frm         : in  std_logic;
		dhcp_irdy        : in  std_logic;
		dhcp_data        : in  std_logic_vector;
		dhcpop_irdy      : out std_logic;
		dhcpchaddr6_frm  : buffer std_logic;
		dhcpchaddr6_irdy : out std_logic;
		dhcpyia_frm      : buffer std_logic;
		dhcpyia_irdy     : out std_logic);
end;

architecture def of dhcpc_offer is
	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(dhcp4hdr_frame)/dhcp_data'length-1));

	signal dhcpop_frm      : std_logic;

begin
					
	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if dhcp_frm='0' then
				cntr := to_unsigned(summation(dhcp4hdr_frame)/dhcp_data'length-1, cntr'length);
			elsif cntr(0)='0' and dhcp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	dhcpop_frm      <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_op);
	dhcpchaddr6_frm <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_chaddr6);
	dhcpyia_frm     <= dhcp_frm and frame_decode(frm_ptr, reverse(dhcp4hdr_frame), dhcp_data'length, dhcp4_yiaddr);

	dhcpop_irdy  <= dhcp_irdy and dhcpop_frm;
	dhcpchaddr6_irdy <= dhcp_irdy and dhcpchaddr6_frm;
	dhcpyia_irdy <= dhcp_irdy and dhcpyia_frm;

end;






