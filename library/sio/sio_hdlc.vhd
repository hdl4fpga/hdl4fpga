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

entity sio_hdlc is
	generic (
		mem_size    : natural := 4*(2048*8));
	port (
		uart_clk    : in  std_logic;

		uartrx_irdy : in  std_logic;
		uartrx_data : in  std_logic_vector;

		uarttx_frm  : out std_logic;
		uarttx_irdy : out std_logic;
		uarttx_trdy : in  std_logic;
		uarttx_data : out std_logic_vector;

		sio_clk     : in  std_logic;
		si_frm      : in  std_logic;
		si_irdy     : in  std_logic;
		si_trdy     : buffer std_logic;
		si_end      : in  std_logic;
		si_data     : in  std_logic_vector;

		so_frm      : buffer std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic;
		so_data     : out std_logic_vector;
		tp          : out std_logic_vector(1 to 32));
end;

architecture def of sio_hdlc is

	signal rx_frm  : std_logic := '0';
	signal rx_irdy : std_logic;
	signal rx_trdy : std_logic;
	signal rx_end  : std_logic;
	signal rx_data : std_logic_vector(si_data'range);

	signal tx_frm  : std_logic;
	signal tx_irdy : std_logic;
	signal tx_trdy : std_logic;
	signal tx_end  : std_logic;
	signal tx_data : std_logic_vector(si_data'range);

	signal tagtx_irdy : std_logic;
	signal tagtx_trdy : std_logic;

begin

	hdlc_b : block

		signal hdlcrx_frm    : std_logic;
		signal hdlcrx_irdy   : std_logic;
		signal hdlcrx_end    : std_logic;
		signal hdlcrx_data   : std_logic_vector(so_data'range);

		signal hdlcfcsrx_sb  : std_logic;
		signal hdlcfcsrx_vld : std_logic;

		signal fifo_cmmt     : std_logic;
		signal fifo_avail    : std_logic;
		signal fifo_rllbk    : std_logic;
		signal fifoo_trdy    : std_logic;

	begin

		hdlcdll_rx_e : entity hdl4fpga.hdlcdll_rx
		port map (
			uart_clk    => uart_clk,
			uartrx_irdy => uartrx_irdy,
			uartrx_data => uartrx_data,

			hdlcrx_frm  => hdlcrx_frm,
			hdlcrx_irdy => hdlcrx_irdy,
			hdlcrx_data => hdlcrx_data,
			hdlcrx_end  => hdlcrx_end,
			fcs_sb      => hdlcfcsrx_sb,
			fcs_vld     => hdlcfcsrx_vld);

		tp(1) <= hdlcfcsrx_sb;
		tp(2) <= hdlcfcsrx_vld;

		fifo_cmmt  <= hdlcfcsrx_sb and     hdlcfcsrx_vld;
		fifo_rllbk <= (hdlcfcsrx_sb and not hdlcfcsrx_vld) or not hdlcrx_frm;

		fifo_e : entity hdl4fpga.txn_buffer
		generic map (
			m => unsigned_num_bits(mem_size/hdlcrx_data'length-1))
		port map (
			src_clk  => uart_clk,
			src_frm  => hdlcrx_frm,
			src_irdy => hdlcrx_irdy,
			src_trdy => open,
			src_data => hdlcrx_data,

			rollback => fifo_rllbk,
			commit   => fifo_cmmt,
			avail    => fifo_avail,

			dst_clk  => uart_clk,
			dst_frm  => rx_frm,
			dst_irdy => rx_trdy,
			dst_trdy => fifoo_trdy,
			dst_end  => rx_end,
			dst_data => rx_data);

		rx_frm_p : process (sio_clk)
		begin
			if rising_edge(sio_clk) then
				if to_bit(rx_frm)='0' then
					if fifo_avail='1' then
						rx_frm <= '1';
					end if;
				elsif rx_end='1' and rx_trdy='1' then
					rx_frm <= '0';
				end if;
			end if;
		end process;

		rx_irdy <=
			'0'        when rx_frm='0' else
			fifoo_trdy when rx_end='0' else
			'0';

		hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
		port map (
			uart_clk    => uart_clk,
			uart_frm    => uarttx_frm,
			uart_irdy   => uarttx_irdy,
			uart_trdy   => uarttx_trdy,
			uart_data   => uarttx_data,

			hdlctx_frm  => tx_frm,
			hdlctx_irdy => tagtx_irdy,
			hdlctx_trdy => tagtx_trdy,
			hdlctx_end  => tx_end,
			hdlctx_data => tx_data);

	end block;

	process (tx_frm, tx_irdy, tagtx_trdy, sio_clk)
		variable cntr : unsigned(0 to 4);
	begin
		if rising_edge(sio_clk) then
			if tx_frm='0' then
				cntr := (others => '0');
			elsif cntr(0)='0' then
				if tx_irdy='1' then
					cntr := cntr + tx_data'length;
				end if;
			end if;
		end if;

		if tx_frm='0' then
			tagtx_irdy <= '0';
			tx_trdy    <= '0';
		elsif cntr(0)='1' then
			tagtx_irdy <= tx_irdy;
			tx_trdy    <= tagtx_trdy;
		else
			tagtx_irdy <= '0';
			tx_trdy    <= '1';
		end if;
	end process;

	flow_e : entity hdl4fpga.sio_flow
	port map (

		rx_clk  => uart_clk,
		rx_frm  => rx_frm,
		rx_irdy => rx_irdy,
		rx_trdy => rx_trdy,
		rx_end  => rx_end,
		rx_data => rx_data,

		so_clk  => uart_clk,
		so_frm  => so_frm,
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_data => so_data,

		si_frm  => si_frm,
		si_irdy => si_irdy,
		si_trdy => si_trdy,
		si_end  => si_end,
		si_data => si_data,

		tx_clk  => uart_clk,
		tx_frm  => tx_frm,
		tx_irdy => tx_irdy,
		tx_trdy => tx_trdy,
		tx_end  => tx_end ,
		tx_data => tx_data);

end;
