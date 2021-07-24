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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmp is
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
		dlltx_full  : in  std_logic;
		nettx_full  : in  std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '1';
		icmptx_end  : buffer std_logic;
		icmptx_data : out std_logic_vector;
		tp : out std_logic_vector(1 to 32));
end;

architecture def of icmp is

	signal icmpdata_irdy   : std_logic;
	signal icmpdatatx_irdy : std_logic;

	signal icmpd_rdy       : bit := '0';
	signal icmpd_req       : bit := '0';

	signal icmpcoderx_irdy : std_logic;
	signal icmptyperx_irdy : std_logic;
	signal icmpcksmrx_frm  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_id       : std_logic_vector(0 to 16-1);
	signal icmprx_seq      : std_logic_vector(0 to 16-1);
	signal icmprx_cksm     : std_logic_vector(0 to 16-1);
	signal icmptx_cksm     : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;
	signal icmpcksmtx_irdy : std_logic;
	signal icmppltx_frm    : std_logic := '0';
	signal icmppltx_irdy   : std_logic;
	signal icmppltx_trdy   : std_logic;
	signal icmppltx_end    : std_logic;
	signal icmppltx_data   : std_logic_vector(icmptx_data'range);

	signal cksmrx_data : std_logic_vector(icmprx_data'range);
	signal rx2tx_cy : std_logic;

	signal memrx_frm  : std_logic;
	signal memrx_data : std_logic_vector(icmprx_data'range);
	signal memtx_data : std_logic_vector(icmptx_data'range);
begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_clk       => mii_clk,
		icmp_frm      => dll_frm,
		icmp_data     => icmprx_data,
		icmp_irdy     => icmprx_irdy,

		icmpcode_irdy => icmpcoderx_irdy,
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
					rx2tx_cy <= co;
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

	memrx_data <= primux(
		(icmptx_data'range => '0') & (icmptx_data'range => '0') & cksmrx_data, 
		icmpcoderx_irdy & icmptyperx_irdy & icmpcksmrx_irdy,
		icmprx_data);

	icmpdata_irdy   <= dll_irdy or net_irdy or net1_irdy or icmprx_irdy;
	icmpdatatx_irdy <= 
		  '1' when dlltx_full='0' else
		  '1' when nettx_full='0' else
		  icmppltx_trdy;

	memrx_frm <= dll_frm and not icmppltx_frm;
	icmpdata_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 128*octect_size)
    port map (
		si_clk   => mii_clk,
        si_frm   => memrx_frm, 
		si_irdy  => icmpdata_irdy,
        si_data  => memrx_data,

		so_clk   => mii_clk,
        so_frm   => icmppltx_frm,
        so_irdy  => icmpdatatx_irdy,
        so_trdy  => icmppltx_irdy,
		so_end   => icmppltx_end,
        so_data  => memtx_data);

	cksmtx_b : block
		signal ci : std_logic;
		signal co : std_logic;
		signal data : std_logic_vector(icmptx_data'range);
	begin
		process (icmppltx_frm, mii_clk)
			variable cy : std_logic;
		begin
			if rising_edge(mii_clk) then
				if icmppltx_frm='0' then
					cy := rx2tx_cy;
				elsif icmpcksmtx_irdy='1' then
					cy := co;
				end if;
			end if;
			ci <= setif(icmpcksmtx_irdy='1', cy, '0');
		end process;

		tx_sum_e : entity hdl4fpga.adder
		port map (
			ci  => ci,
			a   => memtx_data,
			b   => (icmptx_data'range => '0'),
			s   => data,
			co  => co);
		icmppltx_data <= data when icmpcksmtx_irdy='0' else reverse(data);
	end block;

	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm    => icmppltx_frm,
		pl_irdy   => icmppltx_irdy,
		pl_trdy   => icmppltx_trdy,
		pl_end    => icmppltx_end,
		pl_data   => icmppltx_data,

		icmpcksm_irdy => icmpcksmtx_irdy,
		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => icmptx_data);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (icmpd_req xor icmpd_rdy)='0' then
				if to_bit(icmppltx_frm)='0' then
					if icmprx_frm='1' then
						icmpd_req <= not icmpd_rdy;
					end if;
				elsif dlltx_end='1' then
					icmppltx_frm <= not dlltx_end;
				end if;
			elsif icmprx_frm='0' then
				icmpd_rdy <= icmpd_req;
				icmppltx_frm <= '1';
			end if;
		end if;
	end process;

	tp(1) <= to_stdulogic(icmpd_req);
	tp(2) <= to_stdulogic(icmpd_rdy);
	tp(3) <= icmppltx_frm;
	tp(4) <= icmptx_end; --icmprx_frm;

end;
