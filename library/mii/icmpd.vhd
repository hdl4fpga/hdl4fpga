--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmpd is
	port (
		mii_clk     : in  std_logic;

		dll_frm     : in  std_logic;
		dll_irdy    : in  std_logic;
		net_irdy    : in  std_logic;

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_data : in  std_logic_vector;
		icmptx_frm  : buffer std_logic;
		metatx_trdy : in  std_logic := '1';
		metatx_end  : in  std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '1';
		icmptx_end  : buffer std_logic;
		icmptx_data : out std_logic_vector;
		tp : out std_logic_vector(1 to 32));
end;

architecture def of icmpd is

	signal icmpdata_irdy   : std_logic;
	signal icmpdatatx_trdy : std_logic;

	signal icmpcoderx_frm  : std_logic;
	signal icmpcoderx_irdy : std_logic;
	signal icmptyperx_frm  : std_logic;
	signal icmptyperx_irdy : std_logic;
	signal icmpcksmrx_frm  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_id       : std_logic_vector(0 to 16-1);
	signal icmprx_seq      : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;
	signal icmpcksmtx_frm  : std_logic;
	signal icmppltx_frm    : std_logic := '0';
	signal icmppltx_irdy   : std_logic;
	signal icmppltx_trdy   : std_logic;
	signal icmppltx_end    : std_logic;
	signal icmppltx_data   : std_logic_vector(icmptx_data'range);

	signal cksmrx_data     : std_logic_vector(icmprx_data'range);
	signal rx_cy           : std_logic_vector(0 to 0);
	signal tx_cy           : std_logic_vector(0 to 0);

	signal miirx_frm       : std_logic;

	signal memrx_frm       : std_logic;
	signal memrx_data      : std_logic_vector(icmprx_data'range);
	signal memtx_data      : std_logic_vector(icmptx_data'range);
	signal tp1             : std_logic_vector(1 to 32);
	signal tx_irdy         : std_logic;
begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_clk       => mii_clk,
		icmp_frm      => icmprx_frm,
		icmp_data     => icmprx_data,
		icmp_irdy     => icmprx_irdy,

		icmpcode_frm  => icmpcoderx_frm,
		icmpcode_irdy => icmpcoderx_irdy,
		icmptype_frm  => icmptyperx_frm,
		icmptype_irdy => icmptyperx_irdy,
		icmpcksm_frm  => icmpcksmrx_frm,
		icmpcksm_irdy => icmpcksmrx_irdy,
		icmppl_irdy   => icmpplrx_irdy);

	cksmrx_b : block
		signal ci : std_logic;
		signal co : std_logic;
		signal data : std_logic_vector(icmprx_data'range);
		signal adj_data : std_logic_vector(icmprx_data'range);
	begin

		mux_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => icmptype_rqst & icmpcode_rqst,
			sio_clk  => mii_clk,
			sio_frm  => dll_frm,
			sio_irdy => icmpcksmrx_irdy,
			sio_trdy => open,
			so_data  => adj_data);

		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				if dll_frm='0' then
					ci <= '0';
				elsif icmpcksmrx_irdy='1' then
					ci <= co;
					rx_cy(0) <= co;
				end if;
			end if;
		end process;
		data <= reverse(icmprx_data);
		rx_sum_e : entity hdl4fpga.adder
		port map (
			ci  => ci,
			a   => data,
			b   => adj_data,
			s   => cksmrx_data,
			co  => co);
	end block;

	memrx_data <=
--		x"f1" when icmpcoderx_frm='1' else
--		x"f2" when icmptyperx_frm='1' else
		(icmptx_data'range => '0') when icmpcoderx_frm='1' else
		(icmptx_data'range => '0') when icmptyperx_frm='1' else
		cksmrx_data                when icmpcksmrx_frm='1' else
		icmprx_data;

	icmpdata_irdy   <= dll_irdy or net_irdy or icmprx_irdy;
	icmpdatatx_trdy <=
		metatx_trdy when metatx_end='0' else
		icmppltx_trdy;

	buffer_e : block
		signal miirx_end : std_logic;
		signal rollback  : std_logic;
		signal icmp_req  : std_logic;
		signal icmp_rdy  : std_logic;
		signal delay_req : std_logic;
	begin

		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				if (icmp_req xor icmp_rdy)='0' then
					if icmprx_frm='1' then
						icmp_req <= not icmp_rdy;
					elsif tx_irdy='1' then
						icmp_req <= not icmp_rdy;
					end if;
				elsif (icmppltx_end and icmppltx_trdy)='1' then
					icmp_rdy <= icmp_req;
				end if;
			end if;
		end process;

		frm_delay_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk => mii_clk,
			di(0) => icmp_req,
			do(0) => delay_req);


		rollback <= not dll_frm;

		icmppltx_frm <= to_stdulogic(to_bit(icmp_rdy) xor to_bit(delay_req));
		buffer_e : entity hdl4fpga.txn_buffer
		generic map (
			m => 8)
		port map (
		tp => tp1,
			src_clk  => mii_clk,
			src_frm  => dll_frm, --miirx_frm,
			src_irdy => icmpdata_irdy,
			src_trdy => open,
			src_end  => '0', --miirx_end,
			src_tag  => rx_cy,
			src_data => memrx_data,

			rollback => rollback,
			commit   => icmprx_frm,
			avail  => tx_irdy,

			dst_frm  => icmppltx_frm,
			dst_irdy => icmpdatatx_trdy,
			dst_trdy => icmppltx_irdy,
			dst_end  => icmppltx_end,
			dst_tag  => tx_cy,
			dst_data => memtx_data);

	end block;

	cksmtx_b : block
		signal ci : std_logic;
		signal co : std_logic;
		signal data : std_logic_vector(icmptx_data'range);
		constant kk : std_logic_vector := (0 to icmptx_data'length-1 => '0');
	begin
		process (icmpcksmtx_frm, mii_clk)
			variable cy : std_logic;
		begin
			if rising_edge(mii_clk) then
				if icmpcksmtx_frm='0' then
					cy := tx_cy(0);
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
		metatx_end => metatx_end,
		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => icmptx_data);

	tp(2) <= icmppltx_frm;
	tp(3) <= icmppltx_irdy;
	tp(4) <= icmppltx_trdy;
	tp(5) <= icmppltx_end;
	tp(6) <= metatx_end;
	tp(7) <=tp1(1);
	tp(8) <=tp1(2);
	tp(9) <=tp1(3);

end;
