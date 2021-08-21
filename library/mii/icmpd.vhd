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
		net_frm     : in  std_logic;
		net_irdy    : in  std_logic;
		net1_irdy   : in  std_logic;

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_data : in  std_logic_vector;
		icmptx_frm  : buffer std_logic;
		dlltx_end   : in  std_logic;
		dlltx_irdy  : in  std_logic;
		dlltx_full  : in  std_logic;
		nettx_full  : in  std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '1';
		icmptx_end  : buffer std_logic;
		icmptx_data : out std_logic_vector;
		tp : out std_logic_vector(1 to 32));
end;

architecture def of icmpd is

	signal icmpdata_irdy   : std_logic;
	signal icmpdatatx_trdy : std_logic;

	signal icmpcoderx_frm : std_logic;
	signal icmpcoderx_irdy : std_logic;
	signal icmptyperx_frm : std_logic;
	signal icmptyperx_irdy : std_logic;
	signal icmpcksmrx_frm  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_id       : std_logic_vector(0 to 16-1);
	signal icmprx_seq      : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;
	signal icmpcksmtx_frm : std_logic;
	signal icmppltx_frm    : std_logic := '0';
	signal icmppltx_irdy   : std_logic;
	signal icmppltx_trdy   : std_logic;
	signal icmppltx_end    : std_logic;
	signal icmppltx_data   : std_logic_vector(icmptx_data'range);

	signal cksmrx_data : std_logic_vector(icmprx_data'range);
	signal rx_cy       : std_logic_vector(0 to 0);
	signal tx_cy       : std_logic_vector(0 to 0);

	signal memrx_frm  : std_logic;
	signal memrx_data : std_logic_vector(icmprx_data'range);
	signal memtx_data : std_logic_vector(icmptx_data'range);
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
		(icmptx_data'range => '0') when icmpcoderx_frm='1' else
		(icmptx_data'range => '0') when icmptyperx_frm='1' else 
		cksmrx_data                when icmpcksmrx_frm='1' else
		icmprx_data;

	icmpdata_irdy   <= dll_irdy or net_irdy or net1_irdy or icmprx_irdy;
	icmpdatatx_trdy <= 
		  dlltx_irdy when dlltx_full='0' else
		  '1' when nettx_full='0' else
		  icmppltx_trdy and not icmppltx_end ;

	buffer_e : block
		signal miirx_end : std_logic;
		signal rx_len    : std_logic_vector(0 to 6);
		signal tx_len    : std_logic_vector(rx_len'range);
	begin

		process (mii_clk)
			variable cntr : unsigned(rx_len'range);
		begin
			if rising_edge(mii_clk) then
				if dll_frm='0' then
					cntr := (others => '0');
				elsif icmpdata_irdy='1' then
					if icmprx_frm='1' then
						cntr := cntr + 1;
					end if;
				end if;
				rx_len <= std_logic_vector(cntr);
			end if;
		end process;

		buffer_e : block
			signal rollback : std_logic;
		begin
			rollback <= not dll_frm;
			buffer_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 128,
				latency => 1,
				check_dov => true)
			port map(
				src_clk   => mii_clk,
				src_irdy  => icmpdata_irdy,
				src_data  => memrx_data,

				rollback  => rollback,
				commit    => icmprx_frm,
				overflow  => open,

				dst_clk   => mii_clk,
				dst_irdy  => icmppltx_irdy,
				dst_trdy  => icmpdatatx_trdy,
				dst_data  => memtx_data);

		end block;

		process (dll_frm, mii_clk)
			variable q : std_logic;
		begin
			if rising_edge(mii_clk) then
				q := dll_frm;
			end if;
			miirx_end <= not dll_frm and q;
		end process;

		frame_b : block
			signal src_irdy : std_logic;
			signal src_writ : std_logic;
			signal dst_irdy : std_logic;
			signal dst_trdy : std_logic;
		begin

			src_irdy <= miirx_end;
			src_writ <= icmprx_frm and icmpdata_irdy;
			fifo_e : entity hdl4fpga.fifo
				generic map (
					latency    => 0,
					max_depth  => 4)
				port map (
					src_clk    => mii_clk,
					src_frm    => icmppltx_irdy,
					src_irdy   => src_irdy,
					src_auto   => '0',
					src_writ   => src_writ,
					src_trdy   => open,
					src_data   => rx_len,

					dst_clk    => mii_clk,
					dst_irdy   => dst_irdy,
					dst_trdy   => dst_trdy,
					dst_data   => tx_len);

			fifo1_e : entity hdl4fpga.fifo
				generic map (
					latency    => 0,
					max_depth  => 4)
				port map (
					src_clk    => mii_clk,
					src_frm    => icmppltx_irdy,
					src_irdy   => src_irdy,
					src_writ   => icmprx_frm,
					src_trdy   => open,
					src_data   => rx_cy,

					dst_clk    => mii_clk,
					dst_irdy   => open,
					dst_trdy   => dst_trdy,
					dst_data   => tx_cy);

			tp(4) <= dst_irdy;

			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
					if icmppltx_frm='1' then
						if icmppltx_end='1' then
							if dlltx_end='1' then
								icmppltx_frm <= '0';
							end if;
						end if;
					elsif icmprx_frm='1' then
						if icmpdata_irdy='1' then
							icmppltx_frm <= '1';
						end if;
					end if;
				end if;
			end process;

			process (icmppltx_end, mii_clk)
				variable inc  : unsigned(tx_len'range);
				variable cntr : unsigned(tx_len'range) := (others => '0');
				variable q    : std_logic;
			begin
				if rising_edge(mii_clk) then
					if icmppltx_frm='1' then
						if to_bit(icmppltx_end)='1' then
							if dlltx_end='1' then
								icmppltx_end <= '0';
							end if;
						elsif icmppltx_irdy='1' then
							if icmppltx_trdy='1' then
								inc := cntr + 1;
								if cntr < unsigned(tx_len) then
									icmppltx_end <= '0';
								else
									icmppltx_end <= '1';
								end if;
								if cntr < unsigned(tx_len) then
									cntr := inc;
								end if;
							end if;
						end if;
					else
						icmppltx_end <= '0';
						cntr := (others => '0');
					end if;
					q := icmppltx_end;
				end if;
				dst_trdy <= icmppltx_end and not q;
			end process;
		end block;

	end block;

	cksmtx_b : block
		signal ci : std_logic;
		signal co : std_logic;
		signal data : std_logic_vector(icmptx_data'range);
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
			b   => (icmptx_data'range => '0'),
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
		nettx_full => nettx_full,
		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => icmptx_data);

	tp(1) <= icmptx_trdy;
	tp(2) <= icmppltx_end;
	tp(3) <= icmppltx_frm;

end;
