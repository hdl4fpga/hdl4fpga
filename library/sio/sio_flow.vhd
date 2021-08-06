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
	generic (
		mem_size    : natural := 2048*8);
	port (
		phyi_clk    : in  std_logic;
		phyi_frm    : in  std_logic;
		phyi_fcssb  : in std_logic;
		phyi_fcsvld : in std_logic;

		buffer_frm  : in std_logic;
		buffer_irdy : in std_logic;
		buffer_trdy : out std_logic;
		buffer_data : in std_logic_vector;

		so_clk      : in  std_logic;
		so_frm      : out std_logic;
		so_irdy     : buffer std_logic;
		so_trdy     : in  std_logic;
		so_data     : out std_logic_vector;

		si_clk      : in  std_logic;
		si_frm      : in  std_logic;
		si_irdy     : in  std_logic;
		si_trdy     : out std_logic;
		si_data     : in  std_logic_vector;

        phyo_idle   : in  std_logic := '1';
		
		phyo_clk    : in  std_logic;
		phyo_frm    : buffer std_logic;
		phyo_irdy   : buffer std_logic;
		phyo_trdy   : in  std_logic := '1';
		phyo_data   : buffer std_logic_vector;

		tp          : out std_logic_vector(1 to 32));
end;

architecture struct of sio_flow is

	constant rgtrmeta_id : std_logic_vector(8-1 downto 0) := x"00";

	signal metaram_frm  : std_logic;
	signal metaram_irdy : std_logic;
	signal metaram_data : std_logic_vector(si_data'range);

	signal buffer_cmmt  : std_logic;
	signal buffer_rllk  : std_logic;
	signal buffer_ovfl  : std_logic;
	signal flow_frm     : std_logic;
	signal flow_trdy    : std_logic;
	signal flow_irdy    : std_logic_vector(0 to 0); -- Xilinx's ISE core-dump bug
	signal flow_data    : std_logic_vector(si_data'range);

	signal ack_rxd      : std_logic_vector(8-1 downto 0);
	signal ack_txd      : std_logic_vector(ack_rxd'range);

	signal pkt_dup      : std_logic;
	signal ack_rxdv     : std_logic;

	signal meta_data    : std_logic_vector(si_data'range);
	signal meta_trdy    : std_logic;
	signal meta_end     : std_logic;

	signal sioack_data  : std_logic_vector(0 to 9*8-1);
	signal ack_irdy     : std_logic;
	signal ack_trdy     : std_logic;
	signal ack_data     : std_logic_vector(si_data'range);
	signal ack_end      : std_logic;

	signal des_irdy     : std_logic_vector(0 to 0); -- Xilinx's ISE core-dump bug
	signal des_trdy     : std_logic;
	signal des_data     : std_logic_vector(si_data'range);

begin

	rx_b : block

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
		signal rxd          : std_logic_vector(0 to 8-1);

		signal ena  : std_logic;


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

		sigseq_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => std_logic_vector'(x"01"))
		port map (
			rgtr_clk  => phyi_clk,
			rgtr_id   => rgtr_id,
			rgtr_dv   => rgtr_dv,
			rgtr_data => rgtr_data,
			dv        => ack_rxdv,
			data      => rxd);

		process (phyi_fcssb, phyi_fcsvld, pkt_dup, rxd, phyi_clk)
			variable last  : bit_vector(ack_rxd'range);
			variable dup   : bit;
			variable latch : bit;
		begin
			if rising_edge(phyi_clk) then
				if phyi_fcssb='1' and phyi_fcsvld='1' then
					dup   := to_bit(pkt_dup);
					last  := to_bitvector(reverse(rxd));
					latch := '0';
				elsif ack_rxdv='1' then
					latch := '1';
				end if;
			end if;

			if phyi_fcssb='1' and phyi_fcsvld='1' then
				pkt_dup <= setif(shift_left(unsigned(reverse(rxd)),2)=shift_left(unsigned(to_stdlogicvector(last)),2));
			else
				pkt_dup <= to_stdulogic(dup);
			end if;
			ack_rxd <= reverse(rxd) or (pkt_dup & (0 to 7-1 => '0'));

		end process;

	end block;

	meta_b : block

		constant xxx  : natural := rgtrmeta_id'length/metaram_data'length;
		constant xxx1 : natural := metaram_data'length;

		signal lat_frm : std_logic;
		signal lat_data : std_logic_vector(metaram_data'range);

	begin

		latfrm_e : entity hdl4fpga.align 
		generic map (
			n => 1,
			d => (0 to 0 => xxx-1))
		port map (
			clk   => phyi_clk,
			di(0) => metaram_frm,
			do(0) => lat_frm);

		latdat_e : entity hdl4fpga.align 
		generic map (
			n => xxx1,
			d => (0 to xxx1-1 => xxx-1))
		port map (
			clk => phyi_clk,
			di  => metaram_data,
			do  => lat_data);

		metaram_e : entity hdl4fpga.sio_ram 
		generic map (
			mem_size => 64*8)
		port map (
			si_clk   => phyi_clk,
			si_frm   => lat_frm,
			si_irdy  => metaram_irdy,
			si_data  => lat_data,

			so_clk   => so_clk,
			so_frm   => flow_frm,
			so_irdy  => flow_trdy,
			so_trdy  => meta_trdy,
			so_end   => meta_end,
			so_data  => meta_data);

	end block;

	buffer_cmmt <= (    phyi_fcsvld and not pkt_dup and not buffer_ovfl) and phyi_fcssb;
	buffer_rllk <= (not phyi_fcsvld  or     pkt_dup or      buffer_ovfl) and phyi_fcssb;
	tp(1) <=buffer_cmmt;

--	serdes_e : entity hdl4fpga.serdes
--	port map (
--		serdes_clk => so_clk,
--		serdes_frm => buffer_frm,
--		ser_irdy   => buffer_irdy,
--		ser_data   => buffer_data,
--
--		des_irdy   => des_irdy,
--		des_data   => des_data);

	buffer_e : entity hdl4fpga.fifo
	generic map (
		max_depth  => 128)
	port map(
		src_clk   => so_clk,
		src_irdy  => buffer_irdy,
		src_data  => buffer_data,

		commit    => buffer_cmmt,
		rollback  => buffer_rllk,
		overflow  => buffer_ovfl,

		dst_clk   => so_clk,
		dst_irdy  => so_irdy,
		dst_trdy  => so_trdy,
		dst_data  => so_data);
	so_frm <= so_irdy;

	ack_p : process (phyi_fcssb, phyi_fcsvld, ack_rxd, phyi_clk)
		variable q : std_logic := '0';
	begin
		if rising_edge(phyi_clk) then
			if q='1' then
				if ack_end='1' then
					if des_trdy='1' then
						q := '0';
					end if;
				end if;
			elsif phyi_fcsvld='1' then
				if phyi_fcssb='1' then
					q := (ack_rxd(ack_rxd'left) or buffer_ovfl);
				end if;
			end if;
		end if;
		flow_frm <= (phyi_fcsvld and phyi_fcssb and (ack_rxd(ack_rxd'left) or buffer_ovfl)) or q;
		ack_txd  <= ack_rxd or ('0' & q & (0 to 6-1 => '0'));
	end process;

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

	desser_e : entity hdl4fpga.desser
	port map (
		desser_clk => phyo_clk,

		des_frm    => phyo_frm,
		des_irdy   => des_irdy(0),
		des_trdy   => des_trdy,
		des_data   => des_data,

		ser_irdy   => phyo_irdy,
		ser_trdy   => phyo_trdy,
		ser_data   => phyo_data);

end;
