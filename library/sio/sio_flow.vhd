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

entity sio_flow is
	port (
		phyio_clk : in  std_logic;
		phyi_frm  : buffer std_logic;
		phyi_data : buffer std_logic_vector;
		fcs_vld   : in std_logic;

		buffer_frm : in std_logic;
		buffer_irdy : in std_logic;
		buffer_data : in std_logic_vector;

		phyo_req  : out std_logic;
		phyo_rdy  : in  std_logic;
		phyo_gnt  : in  std_logic;
		phyo_idle : in  std_logic;

		phyo_frm  : buffer std_logic;
		phyo_irdy : out std_logic;
		phyo_data : buffer std_logic_vector;

		mii_txd   : out std_logic_vector;
		mii_txen  : out std_logic;

		sio_clk   : in  std_logic;

		si_frm    : in  std_logic := '0';
		si_irdy   : in  std_logic := '0';
		si_trdy   : out std_logic;
		si_data   : in  std_logic_vector;

		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector);
end;

architecture struct of sio_flow is

	signal buffer_cmmt  : std_logic;
	signal buffer_rllk  : std_logic;
	signal buffer_ovfl  : std_logic;
	signal flow_frm     : std_logic;
	signal flow_trdy    : std_logic;
	signal flow_irdy    : std_logic;
	signal flow_data    : std_logic_vector(phyi_data'range);

	signal ack_rxd      : std_logic_vector(8-1 downto 0);
	signal ack_txd      : std_logic_vector(ack_rxd'range);
	signal fcs_end      : std_logic;
	signal flow_end     : std_logic;

	signal pkt_dup      : std_logic;
	signal fcs_sb       : std_logic;
	signal ack_rxdv     : std_logic;

begin

	process(phyi_frm, phyio_clk)
		variable q : std_logic;
	begin
		if rising_edge(phyio_clk) then
			q := phyi_frm;
		end if;
		fcs_sb <= not phyi_frm and q;
	end process;

	flowrx_e : entity hdl4fpga.sio_flowrx
	port map (
		si_clk   => phyio_clk,
		si_frm   => phyi_frm,
		si_data  => phyi_data,

		fcs_sb   => fcs_sb,
		fcs_vld  => fcs_vld,
		pkt_dup  => pkt_dup,
		ack_rxdv => ack_rxdv,
		ack_rxd  => ack_rxd);

	process (fcs_sb, fcs_vld, ack_rxd, phyio_clk)
		variable q : std_logic := '0';
	begin
		if rising_edge(phyio_clk) then
			if q='1' then
				if flow_end='1' then
					q := '0';
				end if;
			elsif fcs_vld='1' then
				if fcs_sb='1' then
					q := (ack_rxd(ack_rxd'left) or buffer_ovfl);
				end if;
			end if;
		end if;
		flow_frm <= (fcs_vld and fcs_sb and (ack_rxd(ack_rxd'left) or buffer_ovfl)) or q;
		ack_txd  <= ack_rxd or ('0' & q & (0 to 6-1 => '0'));
	end process;

	flowtx_e : entity hdl4fpga.sio_flowtx
	port map(
		ack_data => ack_txd,
		so_clk   => phyio_clk,
		so_frm   => flow_frm,
		so_irdy  => flow_irdy,
		so_trdy  => flow_trdy,
		so_data  => flow_data,
		so_end   => flow_end);

	buffer_cmmt <= (    fcs_vld and not pkt_dup and not buffer_ovfl) and fcs_sb;
	buffer_rllk <= (not fcs_vld  or     pkt_dup or      buffer_ovfl) and fcs_sb;

	buffer_e : entity hdl4fpga.sio_buffer
	port map (
		si_clk    => phyio_clk,
		si_frm    => buffer_frm,
		si_irdy   => buffer_irdy,
		si_data   => buffer_data,
		commit    => buffer_cmmt,
		rollback  => buffer_rllk,
		overflow  => buffer_ovfl,

		so_clk    => sio_clk,
		so_frm    => so_frm,
		so_irdy   => so_irdy,
		so_trdy   => so_trdy,
		so_data   => so_data);

	artibiter_b : block

		constant gnt_flow  : natural := 0;
		constant gnt_si    : natural := 1;

		signal tx_req : std_logic_vector(0 to 2-1);
		signal tx_gnt : std_logic_vector(0 to 2-1);
		signal tx_swp : std_logic;

	begin

		tx_req(gnt_flow) <= flow_frm;
		tx_req(gnt_si)   <= si_frm;

		gnt_e : entity hdl4fpga.arbiter
		port map (
			clk  => sio_clk,
			csc  => phyo_gnt,
			ena  => phyo_idle,
			req  => tx_req,
			gnt  => tx_gnt);

		phyo_frm  <= setif(tx_gnt/=(tx_gnt'range => '0'));
		phyo_req  <= setif(tx_req/=(tx_req'range => '0'));
		phyo_irdy <= wirebus(flow_trdy & si_irdy, tx_gnt)(0);
		phyo_data <= wirebus(flow_data & si_data, tx_gnt);

		si_trdy    <= tx_gnt(gnt_si)   and phyo_rdy;
		flow_irdy  <= tx_gnt(gnt_flow) and phyo_rdy;

	end block;

end;
