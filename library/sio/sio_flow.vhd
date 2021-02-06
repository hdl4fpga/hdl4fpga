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
		si_clk  : in  std_logic;
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : buffer std_logic_vector;
		fcs_vld : in std_logic;

		buffer_frm  : in std_logic;
		buffer_irdy : in std_logic;
		buffer_data : in std_logic_vector;

		so_clk    : in  std_logic;
		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector;

		phyo_clk   : in  std_logic;
		phyo_frm   : out std_logic;
		phyo_irdy  : out std_logic;
		phyo_trdy  : in  std_logic;
		phyo_data  : out std_logic_vector);
end;

architecture struct of sio_flow is

	signal buffer_cmmt  : std_logic;
	signal buffer_rllk  : std_logic;
	signal buffer_ovfl  : std_logic;
	signal flow_frm     : std_logic;
	signal flow_trdy    : std_logic;
	signal flow_irdy    : std_logic;
	signal flow_data    : std_logic_vector(si_data'range);

	signal ack_rxd      : std_logic_vector(8-1 downto 0);
	signal ack_txd      : std_logic_vector(ack_rxd'range);
	signal fcs_end      : std_logic;
	signal flow_end     : std_logic;

	signal pkt_dup      : std_logic;
	signal fcs_sb       : std_logic;
	signal ack_rxdv     : std_logic;

begin

	process(si_frm, si_clk)
		variable q : std_logic;
	begin
		if rising_edge(si_clk) then
			q := si_frm;
		end if;
		fcs_sb <= not si_frm and q;
	end process;

	rx_b : block

		signal rgtr_frm     : std_logic;
		signal rgtr_irdy     : std_logic;
		signal rgtr_id      : std_logic_vector(8-1 downto 0);
		signal rgtr_data    : std_logic_vector(8-1 downto 0);
		signal data_frm     : std_logic;
		signal data_irdy    : std_logic;
		signal sigsin_frm   : std_logic;
		signal sigrgtr_data : std_logic_vector(8-1 downto 0);
		signal sig_frm      : std_logic;
		signal sig_irdy     : std_logic;
		signal sigrgtr_id   : std_logic_vector(8-1 downto 0);
		signal sigrgtr_dv   : std_logic;
		signal rxd          : std_logic_vector(8-1 downto 0);

		signal sigram_irdy  : std_logic;

		signal sts_frm       : std_logic;
		signal sts_irdy      : std_logic_vector(0 to 0); -- Xilinx ISE Bug;
		signal sts_trdy      : std_logic;
		signal sts_data      : std_logic_vector(8-1 downto 0);

		signal sig_data      : std_logic_vector(8-1 downto 0);
		signal sig_trdy      : std_logic;
		signal sig_end       : std_logic;

	begin

		siosin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_trdy  => si_trdy,
			sin_data  => si_data,
			rgtr_frm  => rgtr_frm,
			rgtr_id   => rgtr_id,
			rgtr_irdy => rgtr_irdy,
			data_frm  => data_frm,
			data_irdy => data_irdy,
			rgtr_data => rgtr_data);

		sigram_irdy <= rgtr_irdy and setif(rgtr_id=x"00");
		sigram_e : entity hdl4fpga.sio_ram 
		generic map (
			mem_size => 128*si_data'length)
		port map (
			si_clk   => si_clk,
			si_frm   => rgtr_frm,
			si_irdy  => sigram_irdy,
			si_data  => rgtr_data,

			so_clk   => so_clk,
			so_frm   => sts_frm,
			so_irdy  => sts_trdy,
			so_trdy  => sig_trdy,
			so_end   => sig_end,
			so_data  => sig_data);

		sigsin_frm <= data_frm and setif(rgtr_id=x"00");
		sigsin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => sigsin_frm,
			sin_irdy  => data_irdy,
			sin_data  => rgtr_data,
			data_frm  => sig_frm,
			data_irdy => sig_irdy,
			rgtr_id   => sigrgtr_id,
			rgtr_dv   => sigrgtr_dv,
			rgtr_data => sigrgtr_data);

		sigseq_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => x"00")
		port map (
			rgtr_clk  => si_clk,
			rgtr_id   => sigrgtr_id,
			rgtr_dv   => sigrgtr_dv,
			rgtr_data => sigrgtr_data,
			dv        => ack_rxdv,
			data      => rxd);

		process (fcs_sb, fcs_vld, pkt_dup, rxd, si_clk)
			variable last : std_logic_vector(ack_rxd'range);
			variable dup  : std_logic;
		begin
			if rising_edge(si_clk) then
				if fcs_sb='1' then
					if fcs_vld='1' then
						dup  := pkt_dup;
						last := rxd;
						ack_rxd <= rxd or (pkt_dup & (0 to 7-1 => '0'));
					end if;
				end if;
			end if;

			if fcs_sb='1' and fcs_vld='1' then
				pkt_dup <= setif(shift_left(unsigned(rxd),2)=shift_left(unsigned(last),2));
			else
				pkt_dup <= dup;
			end if;
			ack_rxd <= rxd or (pkt_dup & (0 to 7-1 => '0'));

		end process;

	end block;

	process (fcs_sb, fcs_vld, ack_rxd, so_clk)
		variable q : std_logic := '0';
	begin
		if rising_edge(so_clk) then
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

	buffer_cmmt <= (    fcs_vld and not pkt_dup and not buffer_ovfl) and fcs_sb;
	buffer_rllk <= (not fcs_vld  or     pkt_dup or      buffer_ovfl) and fcs_sb;

	buffer_e : entity hdl4fpga.sio_buffer
	port map (
		si_clk    => so_clk,
		si_frm    => buffer_frm,
		si_irdy   => buffer_irdy,
		si_data   => buffer_data,
		commit    => buffer_cmmt,
		rollback  => buffer_rllk,
		overflow  => buffer_ovfl,

		so_clk    => so_clk,
		so_frm    => so_frm,
		so_irdy   => so_irdy,
		so_trdy   => so_trdy,
		so_data   => so_data);

	tx_b : block
		signal sioack_data : std_logic_vector(0 to 40-1);
		signal ack_clk    : std_logic;
		signal ack_frm    : std_logic;
		signal ack_irdy   : std_logic;
		signal ack_trdy   : std_logic;
		signal ack_data   : std_logic_vector(si_data'range);
		signal ack_end    : std_logic;
	begin
		sioack_data <= x"00" & x"02" & x"00" & x"00" & ack_txd;
		ack_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => sioack_data,
			sio_clk  => phyo_clk,
			sio_frm  => ack_frm,
			so_irdy  => ack_irdy,
			so_trdy  => ack_trdy,
			so_end   => ack_end,
			so_data  => ack_data);
	end block;

end;
