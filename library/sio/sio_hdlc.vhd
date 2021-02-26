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

entity sio_hdlc is
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

architecture def of sio_hdlc is

	signal hdlcfcsrx_vld : std_logic;

	signal hdlcrx_frm    : std_logic;
	signal hdlcrx_irdy   : std_logic;
	signal hdlcrx_data   : std_logic_vector(so_data'range);

	signal hdlctx_frm    : std_logic;
	signal hdlctx_irdy   : std_logic;
	signal hdlctx_trdy   : std_logic;
	signal hdlctx_data   : std_logic_vector(si_data'range);

begin

	hdlcdll_rx_e : entity hdl4fpga.hdlcdll_rx
	port map (
		uart_clk    => uart_clk,
		uart_rxdv   => uart_rxdv,
		uart_rxd    => uart_rxd,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcrx_irdy,
		hdlcrx_data => hdlcrx_data,
		fcs_vld     => hdlcfcsrx_vld);

	flow_e : entity hdl4fpga.sio_flow
	port map (
		phyi_clk    => uart_clk,
		phyi_frm    => hdlcrx_frm,
		phyi_fcsvld => hdlcfcsrx_vld,

		buffer_frm  => hdlcrx_frm,
		buffer_irdy => hdlcrx_irdy,
		buffer_data => hdlcrx_data,

		so_clk      => sio_clk,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_data     => so_data,

		si_clk      => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_trdy     => si_trdy,
		si_data     => si_data,

		phyo_clk    => uart_clk,
		phyo_frm    => hdlctx_frm,
		phyo_irdy   => hdlctx_irdy,
		phyo_trdy   => hdlctx_trdy,
		phyo_data   => hdlctx_data);

	hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
	port map (
		uart_clk    => uart_clk,
		uart_idle   => uart_idle,
		uart_txen   => uart_txen,
		uart_txd    => uart_txd,

		hdlctx_frm  => hdlctx_frm,
		hdlctx_irdy => hdlctx_irdy,
		hdlctx_trdy => hdlctx_trdy,
		hdlctx_data => hdlctx_data);

end;
