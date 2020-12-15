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

	signal flow_frm     : std_logic;
	signal flow_trdy    : std_logic;
	signal flow_irdy    : std_logic;
	signal flow_data    : std_logic_vector(si_data'range);

	signal ahdlctx_frm  : std_logic;
	signal ahdlctx_irdy : std_logic;
	signal ahdlctx_trdy : std_logic;
	signal ahdlctx_data : std_logic_vector(si_data'range);

begin

	ahdlcfcs_b : block

		constant ccitt_residue : std_logic_vector := x"1d0f";

		signal buffer_data : std_logic_vector(so_data'range);
		signal buffer_cmmt : std_logic;
		signal buffer_rlk  : std_logic;
		signal buffer_ovfl : std_logic;
		signal buffer_irdy : std_logic;

		signal ahdlcrx_frm  : std_logic;
		signal ahdlcrx_irdy : std_logic;
		signal ahdlcrx_data : std_logic_vector(so_data'range);

		signal fcs_sb   : std_logic;
		signal fcs_vld  : std_logic;
		signal pkt_dup  : std_logic;
		signal ack_rxdv : std_logic;
		signal ack_rxd  : std_logic_vector(8-1 downto 0);

	begin

		ahdlcrx_e : entity hdl4fpga.ahdlc_rx
		port map (
			clk        => uart_clk,

			uart_rxdv  => uart_rxdv,
			uart_rxd   => uart_rxd,

			ahdlc_frm  => ahdlcrx_frm,
			ahdlc_irdy => ahdlcrx_irdy,
			ahdlc_data => ahdlcrx_data);

		fcs_b : block

			signal crc_init : std_logic;
			signal crc_ena  : std_logic;
			signal crc      : std_logic_vector(ccitt_residue'range);
			signal irdy_ini : std_logic;
			signal irdy_ena : std_logic;
		begin
			crc_init <= setif(ahdlcrx_frm/='1');
			crc_ena  <= (ahdlcrx_frm and ahdlcrx_irdy) or not ahdlcrx_frm;
			crc_ccitt_e : entity hdl4fpga.crc
			port map (
				g    => x"1021",
				clk  => uart_clk,
				init => crc_init,
				ena  => crc_ena,
				data => ahdlcrx_data,
				crc  => crc);

			process(ahdlcrx_frm, uart_clk)
				variable q : std_logic;
			begin
				if rising_edge(uart_clk) then
					q := ahdlcrx_frm;
				end if;
				fcs_sb <= not ahdlcrx_frm and q;
			end process;
			fcs_vld <= setif(crc=not ccitt_residue);

			irdy_ini <= not ahdlcrx_frm;
			rdy_ena_e : entity hdl4fpga.align 
			generic map (
				n => 1,
				i => (0 to 0 => '0'),
				d => (0 to 0 => 2))
			port map (
				clk => uart_clk,
				ini => irdy_ini,
				ena => ahdlcrx_irdy,
				di(0) => '1',
				do(0) => irdy_ena);
			buffer_irdy <= irdy_ena and ahdlcrx_irdy;

			data_e : entity hdl4fpga.align 
			generic map (
				n => ahdlcrx_data'length,
				d => (ahdlcrx_data'range => 2))
			port map (
				clk => uart_clk,
				ena => ahdlcrx_irdy,
				di  => ahdlcrx_data,
				do  => buffer_data);

		end block;

	flow_b : block

		signal ack_txd  : std_logic_vector(ack_rxd'range);
		signal flow_end : std_logic;

	begin

		flowrx_e : entity hdl4fpga.sio_flowrx
		port map (
			si_clk   => sio_clk,
			si_frm   => ahdlcrx_frm,
			si_irdy  => buffer_irdy,
			si_data  => buffer_data,

			fcs_sb   => fcs_sb,
			fcs_vld  => fcs_vld,
			pkt_dup  => pkt_dup,
			ack_rxdv => ack_rxdv,
			ack_rxd  => ack_rxd);

		process (fcs_sb, fcs_vld, ack_rxd, sio_clk)
			variable q : std_logic := '0';
		begin
			if rising_edge(sio_clk) then
				if q='1' then
					if flow_end='1' then
						if flow_irdy='1' then
							q := '0';
						end if;
					end if;
				elsif fcs_vld='1' then
					if fcs_sb='1' then
						q := ack_rxd(ack_rxd'left);
					end if;
				end if;
			end if;
			flow_frm <= (fcs_vld and fcs_sb and ack_rxd(ack_rxd'left)) or q;
		end process;

		ack_txd <= ack_rxd;
		flowtx_e : entity hdl4fpga.sio_flowtx
		port map(
			ack_data => ack_txd,
			so_clk   => sio_clk,
			so_frm   => flow_frm,
			so_irdy  => flow_irdy,
			so_trdy  => flow_trdy,
			so_data  => flow_data,
			so_end   => flow_end);

	end block;

	buffer_cmmt <= (    fcs_vld and not pkt_dup) and fcs_sb;
	buffer_rlk  <= (not fcs_vld  or     pkt_dup) and fcs_sb;

	buffer_e : entity hdl4fpga.sio_buffer
	port map (
		si_clk    => uart_clk,
		si_frm    => ahdlcrx_frm,
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

	artibiter_b : block

		constant gnt_flow  : natural := 0;
		constant gnt_si    : natural := 1;

		signal ahdlctx_req : std_logic_vector(0 to 2-1);
		signal ahdlctx_gnt : std_logic_vector(0 to 2-1);
		signal ahdlctx_swp : std_logic;

	begin

		ahdlctx_req(gnt_flow) <= flow_frm;
		ahdlctx_req(gnt_si)   <= si_frm;

		gnt_e : entity hdl4fpga.arbiter
		port map (
			clk  => sio_clk,
			ena  => uart_idle,
			req  => ahdlctx_req,
			gswp => ahdlctx_swp,
			gnt  => ahdlctx_gnt);

		ahdlctx_frm  <= not ahdlctx_swp and setif(ahdlctx_gnt/=(ahdlctx_gnt'range => '0'));
		ahdlctx_irdy <= not ahdlctx_swp and wirebus(flow_trdy & si_irdy, ahdlctx_gnt)(0);
		ahdlctx_data <= wirebus(flow_data & si_data, ahdlctx_gnt);

		si_trdy      <= ahdlctx_gnt(gnt_si)   and ahdlctx_trdy;
		flow_irdy    <= ahdlctx_gnt(gnt_flow) and ahdlctx_trdy;

	end block;

	ahdlcfcs_tx_b : block

		signal fcs_frm  : std_logic;
		signal fcs_data : std_logic_vector(ahdlctx_data'range);
		signal fcs_irdy : std_logic;
		signal fcs_trdy : std_logic;

		signal crc_init : std_logic;
		signal crc_sero : std_logic;
		signal crc_ena  : std_logic;
		signal crc      : std_logic_vector(0 to 16-1);
		signal cy       : std_logic;

	begin

		fcs_p : process (ahdlctx_frm, cy, uart_clk)
			variable q : std_logic;
		begin
			if rising_edge(uart_clk) then
				if uart_idle='1' then
					if ahdlctx_frm='1' then
						if cy='1' then
							q := '0';
						end if;
					else
						q := '1';
					end if;
				end if;
			end if;
			crc_init <= cy and q;
			crc_sero <= setif(ahdlctx_frm='1', q and not cy, not cy);
		end process;

		cntr_p : process (uart_clk)
			variable cntr : unsigned(0 to unsigned_num_bits(crc'length/fcs_data'length-1));
		begin
			if rising_edge(uart_clk) then
				if fcs_trdy='1' then
					if crc_sero='0' then
						if ahdlctx_frm='1' then
							cntr := to_unsigned(crc'length/ahdlctx_data'length-1, cntr'length);
						end if;
					elsif cy='0' then
						cntr := cntr - 1;
					end if;
				end if;
				cy <= setif(cntr(0)/='0');
			end if;
		end process;

		crc_ena <= (ahdlctx_frm and ahdlctx_irdy and ahdlctx_trdy) or (fcs_trdy and crc_sero);
		crc_ccitt_e : entity hdl4fpga.crc
		port map (
			g    => x"1021",
			clk  => uart_clk,
			init => crc_init,
			ena  => crc_ena,
			sero => crc_sero,
			data => ahdlctx_data,
			crc  => crc);

		fcs_frm  <= (ahdlctx_frm or crc_sero) and not crc_init;
		fcs_data <= wirebus(ahdlctx_data & crc(0 to fcs_data'length-1), not crc_sero & crc_sero);
		fcs_irdy <= setif(crc_sero='0', ahdlctx_irdy, '1');

		ahdlctx_e : entity hdl4fpga.ahdlc_tx
		port map (
			clk        => uart_clk,
			uart_irdy  => uart_txen,
			uart_trdy  => uart_idle,
			uart_txd   => uart_txd,

			ahdlc_frm  => fcs_frm,
			ahdlc_irdy => fcs_irdy, 
			ahdlc_trdy => fcs_trdy,
			ahdlc_data => fcs_data);

		ahdlctx_trdy <= ahdlctx_frm and fcs_trdy and not crc_init and not crc_sero;

	end block;

end;
