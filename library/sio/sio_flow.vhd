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

entity sio_flow is
	port (
		sio_clk : in std_logic;

		rx_frm  : in std_logic;
		rx_irdy : in std_logic;
		rx_trdy : out std_logic;
		rx_data : in std_logic_vector;

		so_frm  : out std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic;
		so_data : out std_logic_vector;

		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_frm  : buffer std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : buffer std_logic_vector);

end;

architecture struct of sio_flow is

	constant rgtrmeta_id : std_logic_vector(8-1 downto 0) := x"00";

	signal metaram_frm  : std_logic;
	signal metaram_irdy : std_logic;
	signal metaram_data : std_logic_vector(si_data'range);

	signal buffer_cmmt  : std_logic;
	signal buffer_rllbk : std_logic;
	signal buffer_ovfl  : std_logic;
	signal flow_frm     : std_logic;
	signal flow_trdy    : std_logic;
	signal flow_irdy    : std_logic_vector(0 to 0); -- Xilinx's ISE core-dump bug
	signal flow_data    : std_logic_vector(si_data'range);


	signal rgtr_frm     : std_logic;
	signal rgtr_irdy    : std_logic;
	signal rgtr_id      : std_logic_vector(8-1 downto 0);
	signal rgtr_idv     : std_logic;
	signal rgtr_dv      : std_logic;
	signal rgtr_data    : std_logic_vector(0 to 8-1);
	signal data_frm     : std_logic;
	signal data_irdy    : std_logic;
	signal sigsin_frm   : std_logic;
	signal meta_frm     : std_logic;
	signal meta_irdy    : std_logic;
	signal sout_irdy    : std_logic;

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => phyi_clk,
		sin_frm   => buffer_frm,
		sin_irdy  => buffer_irdy,
		sin_trdy  => buffer_trdy,
		sin_data  => buffer_data,
		rgtr_frm  => rgtr_frm,
		rgtr_id   => rgtr_id,
		rgtr_idv  => rgtr_idv,
		rgtr_dv   => rgtr_dv,
		rgtr_irdy => rgtr_irdy,
		sout_irdy => sout_irdy,
		data_frm  => data_frm,
		data_irdy => data_irdy,
		rgtr_data => rgtr_data);

	metaram_frm  <= rgtr_frm;
	metaram_irdy <= rgtr_irdy and setif(rgtr_id=rgtrmeta_id);
	metaram_data <= std_logic_vector(resize(unsigned(rgtr_data), metaram_data'length));

	cflow_b : block
		signal flow_req : bit;
		signal flow_rdy : bit;

		signal ack_dv   : std_logic;
		signal ack_data : std_logic_vector(0 to 8-1);
	begin

		sigseq_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => std_logic_vector'(x"01"))
		port map (
			rgtr_clk  => sio_clk,
			rgtr_id   => rgtr_id,
			rgtr_dv   => rgtr_dv,
			rgtr_data => rgtr_data,
			dv        => ack_dv,
			data      => ack_data);

		process (sio_clk)
			variable last : std_logic_vector(ack_data'range);
		begin
			if rising_edge(sio_clk) then
				if rx_frm='1' then
					if ack_dv='1' then
						if shift_left(unsigned(reverse(ack_data)),2)/=last then
							buffer_cmmt  <= '1';
						else
							buffer_rllbk <= '1';
						end if;
						flow_req <= to_bit(ack_data(ack_data'left)) xor flow_rdy;
						last := shift_left(unsigned(ack_data),2);
					end if;
				else
					buffer_cmmt  <= '0';
					buffer_rllbk <= '0';
				end if;
			end if;
		end process;

	end block;


	sioack_data <= reverse(
		rgtrmeta_id & x"03" & x"04" & x"01" & x"00" & x"03" &
		x"01" & x"00" & ack_txd, 8);

	ack_irdy <= meta_end and flow_trdy;
	ack_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => sioack_data,
		sio_clk  => phyo_clk,
		sio_frm  => flow_frm,
		sio_irdy => ack_irdy,
		sio_trdy => ack_trdy,
		so_end   => ack_end,
		so_data  => ack_data);

	artibiter_b : block

		constant gnt_flow : natural := 0;
		constant gnt_si   : natural := 1;

		signal req  : std_logic_vector(0 to 2-1);
		signal gnt  : std_logic_vector(0 to 2-1);

	begin

		gnt_e : entity hdl4fpga.arbiter
		port map (
			clk  => phyo_clk,
			ena  => phyo_idle,
			req  => req,
			gnt  => gnt);

		req       <= (gnt_flow => flow_frm, gnt_si => si_frm);
		phyo_frm  <= setif(to_bitvector(req)/=(req'range => '0'));
		flow_trdy <= des_trdy and gnt(gnt_flow);
		si_trdy   <= des_trdy and gnt(gnt_si);

		flow_irdy <= wirebus(meta_trdy & ack_trdy, not meta_end & meta_end) and gnt(gnt_flow to gnt_flow);
		flow_data <= wirebus(meta_data & ack_data, not meta_end & meta_end);

		des_data <= wirebus(flow_data & si_data, gnt);
		des_irdy <= wirebus(flow_irdy(0) & si_irdy, gnt); -- Xilinx's ISE core-dump bug

	end block;

end;
