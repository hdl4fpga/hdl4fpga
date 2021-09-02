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
		si_end  : in  std_logic := '0';
		si_data : in  std_logic_vector;

		tx_frm  : buffer std_logic;
		tx_irdy : buffer std_logic;
		tx_trdy : in  std_logic := '1';
		tx_end  : buffer std_logic;
		tx_data : buffer std_logic_vector);

end;

architecture struct of sio_flow is

	constant rgtrmeta_id : std_logic_vector(8-1 downto 0) := x"00";

	signal metarx_frm   : std_logic;
	signal metarx_irdy  : std_logic;
	signal metarx_data  : std_logic_vector(rx_data'range);

	signal buffer_cmmt  : std_logic;
	signal buffer_rllbk : std_logic;
	signal buffer_ovfl  : std_logic;

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

	signal ackrply_data : std_logic_vector(0 to 8*9-1);
	signal acktx_frm    : std_logic;
	signal acktx_irdy   : std_logic;
	signal acktx_trdy   : std_logic;
	signal meta_end     : std_logic;
	signal acktx_end    : std_logic;
	signal acktx_data   : std_logic_vector(tx_data'range);

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => sio_clk,
		sin_frm   => rx_frm,
		sin_irdy  => rx_irdy,
		sin_trdy  => rx_trdy,
		sin_data  => rx_data,
		rgtr_frm  => rgtr_frm,
		rgtr_id   => rgtr_id,
		rgtr_idv  => rgtr_idv,
		rgtr_dv   => rgtr_dv,
		rgtr_irdy => rgtr_irdy,
		sout_irdy => open,
		data_frm  => data_frm,
		data_irdy => data_irdy,
		rgtr_data => rgtr_data);

	metarx_frm  <= rgtr_frm;
	metarx_irdy <= rgtr_irdy and setif(rgtr_id=rgtrmeta_id);
	metarx_data <= std_logic_vector(resize(unsigned(rgtr_data), metarx_data'length));

	meta_e : entity hdl4fpga.fifo
	generic map (
		max_depth => 64,
		latency   => 1,
		check_dov => true)
	port map(
		src_clk   => sio_clk,
		src_irdy  => metarx_irdy,
		src_trdy  => open,
		src_data  => metarx_data,

		rollback  => buffer_rllbk,
		commit    => buffer_cmmt,
		overflow  => buffer_ovfl,

		dst_clk   => sio_clk,
		dst_irdy  => so_irdy,
		dst_trdy  => so_trdy,
		dst_data  => so_data);

	so_frm <= '1' when buffer_cmmt='1' else so_irdy;

	sigseq_e : entity hdl4fpga.sio_rgtr
	generic map (
		rid  => std_logic_vector'(x"01"))
	port map (
		rgtr_clk  => sio_clk,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_data,
		dv        => ackrx_dv,
		data      => ackrx_data);

	process (sio_clk)
		variable last : unsigned(ackrx_data'range);
	begin
		if rising_edge(sio_clk) then
			if ackrx_dv='1' then
				if shift_left(unsigned(ackrx_data),2)/=last then
					buffer_cmmt  <= '1';
				elsif to_bit(ackrx_data(ackrx_data'left))='1' then
					buffer_cmmt  <= '1';
				else
					buffer_rllbk <= '1';
				end if;
				ackrply_req <= to_bit(ackrx_data(ackrx_data'left)) xor ackrply_rdy;
				last := shift_left(unsigned(ackrx_data),2);
			elsif rx_frm='0' then
				buffer_cmmt  <= '0';
				buffer_rllbk <= '0';
			end if;
		end if;
	end process;

	process (sio_clk)
	begin
		if rising_edge(sio_clk) then
			if acktx_end='1' then
				if acktx_trdy='1' then
					ackrply_rdy <= ackrply_req;
				end if;
			end if;
		end if;
	end process;

	ackrply_data <= reverse(
		rgtrmeta_id & x"03" & x"04" & x"01" & x"00" & x"03" &
		x"01" & x"00" & ackrx_data, 8);

	acktx_frm  <= to_stdulogic(ackrply_req xor ackrply_rdy);
	acktx_b : block

		signal meta_irdy : std_logic;
		signal meta_data : std_logic_vector(rx_data'range);

		signal ack_irdy  : std_logic;
		signal ack_trdy  : std_logic;
		signal ack_data  : std_logic_vector(tx_data'range);

	begin

		meta_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 64,
			latency   => 1,
			check_dov => true)
		port map(
			src_clk   => sio_clk,
			src_irdy  => metarx_irdy,
			src_trdy  => open,
			src_data  => metarx_data,

			rollback  => buffer_rllbk,
			commit    => buffer_cmmt,
			overflow  => buffer_ovfl,

			dst_clk   => sio_clk,
			dst_irdy  => meta_irdy,
			dst_trdy  => acktx_trdy,
			dst_data  => meta_data);

		ack_irdy   <= '0' when meta_irdy='1' else acktx_trdy;
		acktx_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ackrply_data,
			sio_clk  => sio_clk,
			sio_frm  => acktx_frm,
			sio_irdy => ack_irdy,
			sio_trdy => ack_trdy,
			so_end   => acktx_end,
			so_data  => ack_data);

		acktx_irdy <= '1'       when meta_irdy='1' else ack_trdy;
		acktx_data <= meta_data when meta_irdy='1' else ack_data;
	end block;

	artibiter_b : block

		signal req  : std_logic_vector(0 to 2-1);
		signal gnt  : std_logic_vector(0 to 2-1);

	begin

		req <= acktx_frm & si_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => sio_clk,
			req => req,
			gnt => gnt);

		tx_frm  <= wirebus(acktx_frm  & si_frm,  gnt)(0);
		tx_irdy <= wirebus(acktx_irdy & si_irdy, gnt)(0);
		tx_end  <= wirebus(acktx_end  & si_end,  gnt)(0);
		tx_data <= wirebus(acktx_data & si_data, gnt);
		(0 => acktx_trdy, 1 => si_trdy) <= gnt and (gnt'range => tx_trdy); 

		gnt_e : entity hdl4fpga.arbiter
		port map (
			clk  => sio_clk,
			req  => req,
			gnt  => gnt);


	end block;

end;
