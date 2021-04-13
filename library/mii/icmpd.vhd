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

entity icmpd is
	port (
		mii_clk  : std_logic;
		pmii_data : std_logic_vector;
		miirx_data : std_logic_vector;
		miitx_data : std_logic_vector);

end;

architecture def of icmpd is

	signal icmpidrx_irdy   : std_logic;
	signal icmpseqrx_irdy  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpidrx_data   : std_logic_vector(0 to 16-1);
	signal icmpseq_data    : std_logic_vector(0 to 16-1);
	signal icmpcksm_data   : std_logic_vector(0 to 16-1);
	signal icmprply_cksm   : std_logic_vector(0 to 16-1);

	signal icmppl_irdy   : std_logic;

	signal pltx_irdy   : std_logic;
	signal pltx_data    : std_logic_vector(miitx_data'range);


begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_irdy      => 
		mii_data      => 
		mii_ptr       => 

		icmprqst_frm  =>
		icmpid_irdy   => icmpidrx_irdy,
		icmpseq_irdy  => icmpseqrx_irdy,
		icmpcksm_irdy => icmpcksmrx_irdy,
		icmppl_irdy   => icmpplrx_irdy  

	icmpcksm_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpcksmrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmpcksm_data);

	icmpseq_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpseqrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmpseq_data);

	icmpid_e : entity hdl4fpga.mii_des
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmp_frm,
		ser_irdy   => icmpidrx_irdy,
		ser_data   => miirx_data,
		des_data   => icmpid_data);

	icmpdata_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 64*octect_size)
    port map (
		si_clk   => mii_clk,
        si_frm   => icmprx_frm,
        si_irdy  => icmpplrx_irdy,
        si_data  => miirx_data,

		so_clk   => mii_clk,
        so_frm   => 
        so_irdy  =>
        so_data  => );

	icmprply_cksm <= oneschecksum(icmpcksm_data & icmptype_rqst & x"00", icmprply_cksm'length);
	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_txc   => mii_txc,

		pl_txen   => icmppl_txen,
		pl_txd    => icmppl_txd,

		icmp_ptr  => txfrm_ptr,
		icmp_cksm => icmprply_cksm,
		icmp_id   => icmpid_data,
		icmp_seq  => icmpseq_data,
		icmp_txen => icmp_txen,
		icmp_txd  => icmp_txd);

end;
