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
use hdl4fpga.ipoepkg.all;

entity icmpd is
	port (
		miirx_clk   : in  std_logic;
		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_trdy : out std_logic;
		icmprx_data : in  std_logic_vector);
end;

architecture def of icmpd is

	signal typerx_frm   : std_logic;
	signal coderx_frm   : std_logic;
	signal chksumrx_frm : std_logic;
	signal idrx_frm     : std_logic;
	signal seqrx_frm    : std_logic;
	signal pylrx_frm    : std_logic;

	signal cyrx         : std_logic;
begin

	icmprx_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.icmp",
		size  => icmp_data'length)
	port map (
		clk     => miirx_clk,
		frm     => icmprx_frm,
		irdy    => icmprx_irdy,
		act(0)  => typerx_frm,
		act(1)  => coderx_frm,
		act(2)  => chksumrx_frm,
		act(3)  => idrx_frm,
		act(4)  => seqrx_frm,
		act(5)  => pylrx_frm);

	cksmrx_b : block
		alias  chksumrx_irdy is chksum_frm;
		signal adj_data : std_logic_vector(icmprx_data'range);
	begin

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(
				std_logic_vector'(hdo(frames)**".data.icmp.rqst.type") &
				std_logic_vector'(hdo(frames)**".data.icmp.rqst.code"), 8))
		port map (
			so_clk  => mii_clk,
			so_frm  => chksum_frm,
			so_irdy => chksum_irdy,
			so_trdy => open,
			so_data => adj_data);

		process (mii_clk)
			variable sum : unsigned(0 to miirx_data'length+1);
			variable op1 : unsigned(sum'range);
			variable op2 : unsigned(sum'range);
		begin
			if rising_edge(mii_clk) then
				op1 := unsigned'('0' & reverse(icmprx_data) & '1');
				op2 := unsigned'('0' & ajd_data             & cyrx);
				sum := op1 + op2;
				if icmprx_frm='0' then
					cyrx := '0';
				elsif chksumrx_frm='1' then
					cyrx := sum(0);
				end if;
			end if;
		end process;
	end block;

	cksmtx_b : block
		signal ci   : std_logic;
		signal co   : std_logic;
		signal data : std_logic_vector(icmptx_data'range);
		constant kk : std_logic_vector := (0 to icmptx_data'length-1 => '0');
	begin
		process (icmpcksmtx_frm, mii_clk)
			variable cy : std_logic;
		begin
			if rising_edge(mii_clk) then
				if icmpcksmtx_frm='0' then
					cy := tx_cy;
				elsif icmpcksmtx_frm='1' then
					if (icmppltx_irdy and icmptx_trdy)='1' then
						cy := co;
					end if;
				end if;
			end if;
			ci <= setif(icmpcksmtx_frm='1', cy, '0');
		end process;

		tx_sum_e : entity hdl4fpga.adder
		port map (
			ci  => ci,
			a   => memtx_data,
			b   => kk,
			s   => data,
			co  => co);
		icmppltx_data <= data when icmpcksmtx_frm='0' else reverse(data);
	end block;

	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm    => icmppltx_frm,
		pl_irdy   => icmppltx_irdy,
		pl_trdy   => icmppltx_trdy,
		pl_end    => icmppltx_end,
		pl_data   => icmppltx_data,

		icmpcksm_frm => icmpcksmtx_frm,
		metatx_end => tx_meta,
		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => icmptx_data);

end;
