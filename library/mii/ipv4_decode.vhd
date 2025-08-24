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
use hdl4fpga.hdo.all;
use hdl4fpga.ipoepkg.all;

entity ipv4_decode is
	port (
		mii_clk     : in  std_logic;
		ipv4_frm    : in  std_logic := '0';
		ipv4_irdy   : in  std_logic := '0';
		ipv4_trdy   : out std_logic := '1';
		ipv4_data   : in  std_logic_vector;

		verihl_frm   : buffer std_logic := '0';
		verihl_irdy  : out std_logic := '0';
		verihl_trdy  : in  std_logic := '1';
		tos_frm      : buffer std_logic := '0';
		tos_irdy     : out std_logic := '0';
		tos_trdy     : in  std_logic := '1';
		length_frm   : buffer std_logic := '0';
		length_irdy  : out std_logic := '0';
		length_trdy  : in  std_logic := '1';
		ident_frm    : buffer std_logic := '0';
		ident_irdy   : out std_logic := '0';
		ident_trdy   : in  std_logic := '1';
		flgsfrg_frm  : buffer std_logic := '0';
		flgsfrg_irdy : out std_logic := '0';
		flgsfrg_trdy : in  std_logic := '1';
		ttl_frm      : buffer std_logic := '0';
		ttl_irdy     : out std_logic := '0';
		ttl_trdy     : in  std_logic := '1';
		proto_frm    : buffer std_logic := '0';
		proto_irdy   : out std_logic := '0';
		proto_trdy   : in  std_logic := '1';
		chksum_frm   : buffer std_logic := '0';
		chksum_irdy  : out std_logic := '0';
		chksum_trdy  : in  std_logic := '1';
		sa_frm       : buffer std_logic := '0';
		sa_irdy      : out std_logic := '0';
		sa_trdy      : in  std_logic := '1';
		da_frm       : buffer std_logic := '0';
		da_irdy      : out std_logic := '0';
		da_trdy      : in  std_logic := '1';

		pyl_frm      : buffer std_logic := '0';
		pyl_irdy     : out std_logic := '0';
		pyl_trdy     : in  std_logic := '1');

end;

architecture def of ipv4_decode is
begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.ipv4",
		size  => ipv4_data'length)
	port map (
		clk     => mii_clk,
		frm     => ipv4_frm,
		irdy    => ipv4_irdy,
		act(0)  => verihl_frm,
		act(1)  => tos_frm,
		act(2)  => length_frm,
		act(3)  => ident_frm,
		act(4)  => flgsfrg_frm,
		act(5)  => ttl_frm,
		act(6)  => proto_frm,
		act(7)  => chksum_frm,
		act(8)  => sa_frm,
		act(9)  => da_frm,
		act(10) => pyl_frm);

    verihl_irdy  <= verihl_frm;  
    tos_irdy     <= tos_frm;
    length_irdy  <= length_frm;
    ident_irdy   <= ident_frm;
    flgsfrg_irdy <= flgsfrg_frm;
    ttl_irdy     <= ttl_frm;
    proto_irdy   <= proto_frm;
    chksum_irdy  <= chksum_frm;
    sa_irdy      <= sa_frm;
    da_irdy      <= da_frm;
    pyl_irdy     <= pyl_frm;

	ipv4_trdy <=
		verihl_trdy  when  verihl_frm='1' else
		tos_trdy     when     tos_frm='1' else
		length_trdy  when  length_frm='1' else
		ident_trdy   when   ident_frm='1' else
		flgsfrg_trdy when flgsfrg_frm='1' else
		ttl_trdy     when     ttl_frm='1' else
		proto_trdy   when   proto_frm='1' else
		chksum_trdy  when  chksum_frm='1' else
		sa_trdy      when      sa_frm='1' else
		da_trdy      when      da_frm='1' else
		pyl_trdy     when     pyl_frm='1' else
		'0';

end;
