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

entity udp_rx is
	port (
		mii_clk      : in  std_logic;
		udp_frm      : in  std_logic;
		udp_irdy     : in  std_logic;
		udp_data     : in  std_logic_vector;

		udpsp_irdy   : out std_logic;
		udpdp_irdy   : out std_logic;
		udplen_irdy  : buffer std_logic;
		udpcksm_irdy : out std_logic;
		udppl_frm    : buffer std_logic;
		udppl_irdy   : out std_logic);
end;

architecture def of udp_rx is

	signal frm_ptr     : std_logic_vector(0 to unsigned_num_bits(summation(udp4hdr_frame)/udp_data'length-1));

	signal udpsp_frm   : std_logic;
	signal udpdp_frm   : std_logic;
	signal udplen_frm  : std_logic;
	signal udpcksm_frm : std_logic;

	signal pl_frm      : std_logic;

begin
					
	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if udp_frm='0' then
				cntr := to_unsigned(summation(udp4hdr_frame)/udp_data'length-1, cntr'length);
			elsif cntr(0)='0' and udp_irdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	process (mii_clk)
		variable cntr : unsigned(0 to 16-1);
		variable len  : unsigned(0 to 16-1);
	begin
		if rising_edge(mii_clk) then
			if frm_ptr(0)='0' then
				cntr := shift_left(len-summation(udp4hdr_frame)/octect_size, unsigned_num_bits(octect_size/udp_data'length)-1)-1;
				if udplen_irdy='1' then
					len := reverse(len, 8);
					len(udp_data'range) := unsigned(udp_data);
					len := len rol udp_data'length;
					len := reverse(len, 8);
				end if;
			elsif udp_irdy='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			pl_frm <= not cntr(0);
		end if;
	end process;

	udpsp_frm    <= udp_frm and frame_decode(frm_ptr, reverse(udp4hdr_frame), udp_data'length, udp4_sp);
	udpdp_frm    <= udp_frm and frame_decode(frm_ptr, reverse(udp4hdr_frame), udp_data'length, udp4_dp);
	udplen_frm   <= udp_frm and frame_decode(frm_ptr, reverse(udp4hdr_frame), udp_data'length, udp4_len);
	udpcksm_frm  <= udp_frm and frame_decode(frm_ptr, reverse(udp4hdr_frame), udp_data'length, udp4_cksm);
	udppl_frm    <= udp_frm and frm_ptr(0) and pl_frm;

	udpsp_irdy   <= udp_irdy and udpsp_frm;
	udpdp_irdy   <= udp_irdy and udpdp_frm;
	udplen_irdy  <= udp_irdy and udplen_frm;
	udpcksm_irdy <= udp_irdy and udpcksm_frm;
	udppl_irdy   <= udp_irdy and udppl_frm;
end;
