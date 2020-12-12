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

entity sio_ahdlc is
	port (
		uart_clk  : in  std_logic;
		uart_rxdv : in  std_logic;
		uart_rxd  : in  std_logic_vector;

		uart_idle : in  std_logic;
		uart_txen : out std_logic;
		uart_txd  : out std_logic_vector;

		sio_clk   : in  std_logic;
		si_frm    : in  std_logic;
		si_irdy   : in  std_logic;
		si_trdy   : buffer std_logic;
		si_data   : in  std_logic_vector;

		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector);

end;

architecture def of sio_ahdlc is

begin

	ahdlcfcs_b : block

		constant ccitt_residue : std_logic_vector := x"1d0f";

		signal buffer_data : std_logic_vector(so_data'range);
		signal buffer_cmmt : std_logic;
		signal buffer_rlk  : std_logic;
		signal buffer_ovfl : std_logic;
		signal buffer_irdy : std_logic;

		signal ahdlc_frm  : std_logic;
		signal ahdlc_irdy : std_logic;
		signal ahdlc_data : std_logic_vector(so_data'range);

	begin

		ahdlcrx_e : entity hdl4fpga.ahdlc_rx
		port map (
			clk        => uart_clk,

			uart_rxdv  => uart_rxdv,
			uart_rxd   => uart_rxd,

			ahdlc_frm  => ahdlc_frm,
			ahdlc_irdy => ahdlc_irdy,
			ahdlc_data => ahdlc_data);

		fcs_b : block
			signal crc_init : std_logic;
			signal crc_ena  : std_logic;
			signal crc      : std_logic_vector(ccitt_residue'range);
			signal irdy_ini : std_logic;
			signal irdy_ena : std_logic;
		begin
			crc_init <= setif(ahdlc_frm/='1');
			crc_ena  <= (ahdlc_frm and ahdlc_irdy) or not ahdlc_frm;
			crc_ccitt_e : entity hdl4fpga.crc
			generic map (
				g => x"1021")
			port map (
				clk  => uart_clk,
				init => crc_init,
				ena  => crc_ena,
				data => ahdlc_data,
				crc  => crc);

			process(uart_clk)
				variable frm : std_logic;
			begin
				if rising_edge(uart_clk) then
					frm := ahdl
				end if;
			end process;

			fcs_vld <= '1' when ahdlc_frm='0' and crc =not ccitt_residue else '0';
			fcs_rlk <= '1' when ahdlc_frm='0' and crc/=not ccitt_residue else '0';

			irdy_ini <= not ahdlc_frm;
			rdy_ena_e : entity hdl4fpga.align 
			generic map (
				n => 1,
				i => (0 to 0 => '0'),
				d => (0 to 0 => 2))
			port map (
				clk => uart_clk,
				ini => irdy_ini,
				ena => ahdlc_irdy,
				di(0) => '1',
				do(0) => irdy_ena);
			buffer_irdy <= irdy_ena and ahdlc_irdy;

			data_e : entity hdl4fpga.align 
			generic map (
				n => ahdlc_data'length,
				d => (ahdlc_data'range => 2))
			port map (
				clk => uart_clk,
				ena => ahdlc_irdy,
				di  => ahdlc_data,
				do  => buffer_data);

		end block;

	flowrx_e : entity hdl4fpga.sio_flowrx
	port map (
		si_clk   => uart_clk,
		si_frm   => ahdlc_frm,
		si_irdy  => buffer_irdy
		si_data  => buffer_data,

		pkt_vld  => pkt_vld,
		pkt_dup  => pkt_dup,
		ack_rxdv => ack_rxdv,
		acki_rxd => ack_rxd);

	buffer_rlk  <= pkt_dup;
	buffer_cmmt <= not pkt_dup;


	buffer_e : entity hdl4fpga.sio_buffer
	port map (
		si_clk    => uart_clk,
		si_frm    => ahdlc_frm,
		si_irdy   => buffer_irdy,
		si_data   => buffer_data,

		rollback  => buffer_rlk,
		commit    => buffer_cmmt,
		overflow  => buffer_ovfl,

		so_clk    => sio_clk,
		so_frm    => so_frm,
		so_irdy   => so_irdy,
		so_trdy   => so_trdy,
		so_data   => so_data);
	end block;

	ahdlcfcs_tx_b : block

		signal fcs_frm  : std_logic;
		signal fcs_data : std_logic_vector(si_data'range);
		signal fcs_trdy : std_logic;

		signal crc_init : std_logic;
		signal crc_sero : std_logic;
		signal crc_ena  : std_logic;
		signal crc      : std_logic_vector(0 to 16-1);
		signal cy       : std_logic;

	begin

		fcs_p : process (si_frm, cy, uart_clk)
			variable q : std_logic;
		begin
			if rising_edge(uart_clk) then
				if uart_idle='1' then
					if si_frm='1' then
						if cy='1' then
							q := '0';
						end if;
					else
						q := '1';
					end if;
				end if;
			end if;
			crc_init <= cy and q;
			crc_sero <= setif(si_frm='1', q and not cy, not cy);
		end process;

		cntr_p : process (uart_clk)
			variable cntr : unsigned(0 to unsigned_num_bits(crc'length/fcs_data'length-1));
		begin
			if rising_edge(uart_clk) then
				if fcs_trdy='1' then
					if crc_sero='0' then
						if si_frm='1' then
							cntr := to_unsigned(crc'length/si_data'length-1, cntr'length);
						end if;
					elsif cy='0' then
						cntr := cntr - 1;
					end if;
				end if;
				cy <= setif(cntr(0)/='0');
			end if;
		end process;

		crc_ena <= (si_frm and si_irdy and si_trdy) or (fcs_trdy and crc_sero);
		crc_ccitt_e : entity hdl4fpga.crc
		generic map (
			g => x"1021")
		port map (
			clk  => uart_clk,
			init => crc_init,
			ena  => crc_ena,
			sero => crc_sero,
			data => si_data,
			crc  => crc);

		fcs_frm  <= (si_frm or crc_sero) and not crc_init;
		fcs_data <= wirebus(si_data & crc(0 to fcs_data'length-1), not crc_sero & crc_sero);

		ahdlctx_e : entity hdl4fpga.ahdlc_tx
		port map (
			clk        => uart_clk,
			uart_irdy  => uart_txen,
			uart_trdy  => uart_idle,
			uart_txd   => uart_txd,

			ahdlc_frm  => fcs_frm,
			ahdlc_irdy => si_irdy,
			ahdlc_trdy => fcs_trdy,
			ahdlc_data => fcs_data);

		si_trdy <= si_frm and fcs_trdy and not crc_init and not crc_sero;

	end block;

end;
