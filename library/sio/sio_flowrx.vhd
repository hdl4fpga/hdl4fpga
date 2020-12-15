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

entity sio_flowrx is
	port (
		si_clk  : in  std_logic;
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		fcs_sb   : in  std_logic;
		fcs_vld  : in  std_logic;
		pkt_dup  : buffer std_logic;

		ack_rxdv : out std_logic;
		ack_rxd  : buffer std_logic_vector(8-1 downto 0);

		tp       : buffer std_logic_vector(1 to 4));

end;

architecture def of sio_flowrx is

	signal rgtr_id      : std_logic_vector(8-1 downto 0);
	signal data_frm     : std_logic;
	signal data_irdy    : std_logic;
	signal data_rgtr    : std_logic_vector(8-1 downto 0);
	signal sigsin_frm   : std_logic;
	signal sigrgtr_data : std_logic_vector(8-1 downto 0);
	signal sig_frm      : std_logic;
	signal sig_irdy     : std_logic;
	signal sigrgtr_id   : std_logic_vector(8-1 downto 0);
	signal sigrgtr_dv   : std_logic;
	signal rxd          : std_logic_vector(8-1 downto 0);

begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => si_clk,
		sin_frm   => si_frm,
		sin_irdy  => si_irdy,
		sin_trdy  => si_trdy,
		sin_data  => si_data,
		rgtr_id   => rgtr_id,
		data_frm  => data_frm,
		data_irdy => data_irdy,
		rgtr_data => data_rgtr);

	sigsin_frm <= data_frm and setif(rgtr_id=x"00");
	sigsin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => si_clk,
		sin_frm   => sigsin_frm,
		sin_irdy  => data_irdy,
		sin_data  => data_rgtr,
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

	process (pkt_dup, ack_rxd, si_clk)
		variable last : std_logic_vector(ack_rxd'range);
	begin
		if rising_edge(si_clk) then
			if fcs_sb='1' then
				if fcs_vld='1' then
					last    := rxd;
					ack_rxd <= rxd or (pkt_dup & (0 to 7-1 => '0'));
				end if;
			end if;
		end if;
		pkt_dup <= setif(shift_left(unsigned(rxd),2)=shift_left(unsigned(last),2));
	end process;

end;
