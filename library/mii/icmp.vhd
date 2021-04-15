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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;

entity icmpd is
	port (
		mii_clk     : std_logic;
		miirx_irdy  : std_logic;
		frmrx_ptr   : std_logic_vector;
		miirx_data  : std_logic_vector;
		icmprx_frm  : std_logic;
		icmptx_frm  : std_logic;
		icmptx_irdy : std_logic;
		icmptx_trdy : std_logic;
		miitx_data : out std_logic_vector);

end;

architecture def of icmpd is

	signal icmpidrx_irdy   : std_logic;
	signal icmpseqrx_irdy  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_type   : std_logic_vector(0 to 8-1);
	signal icmprx_id: std_logic_vector(0 to 16-1);
	signal icmprx_seq: std_logic_vector(0 to 16-1);
	signal icmprx_cksm : std_logic_vector(0 to 16-1);
	signal icmptx_cksm   : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;

	signal pltx_irdy       : std_logic;
	signal pltx_data       : std_logic_vector(miitx_data'range);

begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_irdy      => miirx_irdy,
		mii_ptr       => frmrx_ptr,
		mii_data      => miirx_data,

		icmprqst_frm  => icmprx_frm,
		icmpid_irdy   => icmpidrx_irdy,
		icmpseq_irdy  => icmpseqrx_irdy,
		icmpcksm_irdy => icmpcksmrx_irdy,
		icmppl_irdy   => icmpplrx_irdy);

	icmpcksm_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpcksmrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmptx_cksm);

	icmpseq_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpseqrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmprx_seq);

	icmpid_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpidrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmprx_id);

	icmpdata_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 64*octect_size)
    port map (
		si_clk   => mii_clk,
        si_frm   => icmprx_frm,
        si_irdy  => icmpplrx_irdy,
        si_data  => miirx_data,

		so_clk   => mii_clk,
        so_frm   => icmptx_frm,
        so_irdy  => icmptx_irdy,
        so_data  => miitx_data);

	icmptx_cksm <= oneschecksum(icmprx_cksm & icmprx_type & x"00", icmptx_cksm'length);
	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm   => '1',
		pl_irdy   => '1',
		pl_data    => miirx_data,

		icmp_cksm => icmptx_cksm,
		icmp_id   => icmprx_id,
		icmp_seq  => icmprx_seq,
		icmp_irdy => open,
		icmp_data  => miitx_data);

end;
