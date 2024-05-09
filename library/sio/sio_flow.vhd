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
use hdl4fpga.base.all;

entity sio_flow is
	generic (
		debug   : boolean := false);
	port (
		rx_clk  : in std_logic;
		rx_frm  : in std_logic;
		rx_irdy : in std_logic;
		rx_trdy : out std_logic;
		rx_end  : in std_logic := '0';
		rx_data : in std_logic_vector;

		so_clk  : in std_logic;
		so_frm  : out std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : out std_logic_vector;

		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_end  : in  std_logic := '0';
		si_data : in  std_logic_vector;

		tx_clk  : in std_logic;
		tx_frm  : buffer std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_end  : out std_logic;
		tx_data : buffer std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	constant rgtrmeta_id : std_logic_vector(8-1 downto 0) := x"00";

	signal metarx_irdy  : std_logic;
	signal metarx_data  : std_logic_vector(rx_data'range);

	signal buffer_cmmt  : std_logic;
	signal buffer_rllbk : std_logic;
	signal buffer_ovfl  : std_logic;

	signal meta_cmmt    : std_logic;
	signal meta_rllbk   : std_logic;
	signal meta_ovfl    : std_logic;

	signal sin_trdy     : std_logic;
	signal rgtr_frm     : std_logic;
	signal rgtr_irdy    : std_logic;
	signal rgtr_id      : std_logic_vector(8-1 downto 0);
	signal rgtr_idv     : std_logic;
	signal rgtr_dv      : std_logic;
	signal rgtr_data    : std_logic_vector(0 to 8-1);
	signal data_frm     : std_logic;
	signal data_irdy    : std_logic;

	signal ackrply_req  : bit;
	signal ackrply_rdy  : bit;

	signal ackrx_dv     : std_logic;
	signal ackrx_data   : std_logic_vector(0 to 8-1);

	signal ackrply_data : std_logic_vector(0 to 5*8-1);
	signal acktx_frm    : std_logic;
	signal acktx_irdy   : std_logic;
	signal acktx_trdy   : std_logic;
	signal meta_end     : std_logic;
	signal acktx_end    : std_logic;
	signal acktx_data   : std_logic_vector(tx_data'range);

	signal ackrx_dup    : std_logic;
begin

	rx_trdy <= sin_trdy when rx_end='0' else not so_irdy;
	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => rx_clk,
		sin_frm   => rx_frm,
		sin_irdy  => rx_irdy,
		sin_trdy  => sin_trdy,
		sin_data  => rx_data,
		rgtr_frm  => rgtr_frm,
		rgtr_id   => rgtr_id,
		rgtr_idv  => rgtr_idv,
		rgtr_dv   => rgtr_dv,
		rgtr_irdy => rgtr_irdy,
		data_frm  => data_frm,
		data_irdy => data_irdy,
		rgtr_data => rgtr_data);

	metarx_irdy <= rgtr_irdy and setif(rgtr_id=rgtrmeta_id);
	metarx_data <= std_logic_vector(resize(unsigned(rgtr_data), metarx_data'length));

	meta_e : entity hdl4fpga.fifo
	generic map (
		max_depth => 64,
		latency   => 1,
		check_sov => true,
		check_dov => true)
	port map(
		src_clk   => rx_clk,
		src_irdy  => rx_irdy,
		src_trdy  => open,
		src_data  => rx_data,

		rollback  => buffer_rllbk,
		commit    => buffer_cmmt,
		overflow  => buffer_ovfl,

		dst_clk   => so_clk,
		dst_irdy  => so_irdy,
		dst_trdy  => so_trdy,
		dst_data  => so_data);

	so_frm <= so_irdy;

	sigseq_e : entity hdl4fpga.sio_rgtr
	generic map (
		rid  => std_logic_vector'(x"01"))
	port map (
		rgtr_clk  => rx_clk,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_data,
		dv        => ackrx_dv,
		data      => ackrx_data);

	process (rx_clk)
		variable last : unsigned(ackrx_data'range) := (others => '0');
	begin
		if rising_edge(rx_clk) then
			if ackrx_dv='1' then
				if to_bit(ackrx_data(ackrx_data'right))='1' then
					buffer_rllbk <= '1';
					meta_cmmt   <= '1';
					ackrply_req <= not ackrply_rdy;
				elsif shift_right(unsigned(ackrx_data),2)/=last or debug then
					buffer_cmmt  <= '1';
				else
					buffer_rllbk <= '1';
					meta_cmmt    <= '1';
					ackrply_req  <= not ackrply_rdy;
				end if;
				last := shift_right(unsigned(ackrx_data),2);
			elsif rx_frm='0' then
				buffer_cmmt  <= '0';
				meta_cmmt    <= '0';
				buffer_rllbk <= '0';
			end if;
		end if;
	end process;

	process (tx_clk)
	begin
		if rising_edge(tx_clk) then
			if acktx_end='1' then
				if tx_trdy='1' then
					ackrply_rdy <= ackrply_req;
				end if;
			end if;
		end if;
	end process;

	ackrply_data <= reverse(reverse(x"0003") & x"01" & x"00", 8) & (x"01" or ackrx_data);

	acktx_frm  <= to_stdulogic(ackrply_req xor ackrply_rdy);
	acktx_b : block

		signal meta_irdy  : std_logic;
		signal meta_data  : std_logic_vector(rx_data'range);

		signal ack_irdy   : std_logic;
		signal ack_trdy   : std_logic;
		signal ack_data   : std_logic_vector(tx_data'range);

		signal rx_dfrm    : std_logic;
		signal tx_frm    : std_logic;

	begin

		dly_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 0 => 2))
		port map (
			clk => rx_clk,
			di(0) => rx_frm,
			do(0) => rx_dfrm);

		meta_rllbk <= not (rx_frm or rx_dfrm);
		meta_ovfl  <= buffer_ovfl;

		meta_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 64,
			latency   => 1,
			check_dov => true)
		port map(
			src_clk   => rx_clk,
			src_irdy  => metarx_irdy,
			src_trdy  => open,
			src_data  => metarx_data,

			rollback  => meta_rllbk,
			commit    => meta_cmmt,
			overflow  => meta_ovfl,

			dst_clk   => tx_clk,
			dst_irdy  => meta_irdy,
			dst_trdy  => acktx_trdy,
			dst_data  => meta_data);

		wait_fifo_latency : process (acktx_frm, tx_clk)
			variable q : unsigned(0 to 2-1);
		begin
			if rising_edge(tx_clk) then
				if acktx_frm='0' then
					q := (others => '0');
				else
					q(0) := acktx_frm;
					q := q rol 1;
				end if;
			end if;
			tx_frm <= acktx_frm and q(0);
		end process;

		acktx_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ackrply_data,
			sio_clk  => tx_clk,
			sio_frm  => tx_frm,
			sio_irdy => ack_irdy,
			sio_trdy => ack_trdy,
			so_end   => acktx_end,
			so_data  => ack_data);

		ack_irdy   <= acktx_trdy when meta_irdy='0' else '0';
		acktx_irdy <= ack_trdy   when meta_irdy='0' else meta_irdy;
		acktx_data <= ack_data   when meta_irdy='0' else meta_data;


	end block;

	artibiter_b : block

		signal req  : std_logic_vector(0 to 2-1);
		signal gnt  : std_logic_vector(0 to 2-1);

	begin

		req <= acktx_frm & si_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => tx_clk,
			req => req,
			gnt => gnt);

		tp(5 to 6) <= gnt;
		tx_frm  <= wirebus(acktx_frm  & si_frm,  gnt);
		tx_irdy <= wirebus(acktx_irdy & si_irdy, gnt);
		tx_end  <= wirebus(acktx_end  & si_end,  gnt);
		tx_data <= wirebus(acktx_data & si_data, gnt);
		(0 => acktx_trdy, 1 => si_trdy) <= gnt and (gnt'range => tx_trdy);

	end block;

end;
