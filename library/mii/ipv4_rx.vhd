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

entity ipv4_rx is
	port (
		mii_clk        : in  std_logic;

		ipv4_frm       : in  std_logic;
		ipv4_irdy      : in  std_logic;
		ipv4_data      : in  std_logic_vector;

		ipv4len_irdy   : out std_logic;
		ipv4da_frm     : buffer std_logic;
		ipv4da_irdy    : out std_logic;
		ipv4sa_irdy    : out std_logic;
		ipv4proto_irdy : out std_logic;

		pl_frm         : buffer std_logic;
		pl_irdy        : out std_logic);

end;

architecture def of ipv4_rx is

	signal frm_ptr       : std_logic_vector(0 to unsigned_num_bits(summation(ipv4hdr_frame)/ipv4_data'length-1));
	signal ipv4len_frm   : std_logic;
	signal ipv4sa_frm    : std_logic;
	signal ipv4proto_frm : std_logic;

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if ipv4_frm='0' then
				cntr := to_unsigned(summation(ipv4hdr_frame)/ipv4_data'length-1, cntr'length);
			elsif cntr(0)='0' and ipv4_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	ipv4len_frm   <= ipv4_frm and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_len);
	ipv4sa_frm    <= ipv4_frm and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_sa);
	ipv4da_frm    <= ipv4_frm and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_da);
	ipv4proto_frm <= ipv4_frm and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_proto);
	pl_frm        <= ipv4_frm and frm_ptr(0);

	ipv4len_irdy   <= ipv4_irdy and ipv4len_frm;
	ipv4sa_irdy    <= ipv4_irdy and ipv4sa_frm;
	ipv4da_irdy    <= ipv4_irdy and ipv4da_frm;
	ipv4proto_irdy <= ipv4_irdy and ipv4proto_frm;
	pl_irdy        <= ipv4_irdy and pl_frm;

end;




