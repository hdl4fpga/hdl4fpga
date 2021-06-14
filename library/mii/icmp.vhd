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

entity icmp is
	port (
		mii_clk     : in  std_logic;
		metarx_frm  : in  std_logic := '0';
		metarx_irdy : in  std_logic := '0';

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_data : in  std_logic_vector;
		icmptx_frm  : buffer std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '1';
		icmptx_end  : buffer std_logic;
		miitx_data  : out std_logic_vector);
end;

architecture def of icmp is

	signal icmpd_rdy       : bit := '0';
	signal icmpd_req       : bit := '0';

	signal icmpidrx_irdy   : std_logic;
	signal icmpseqrx_irdy  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_id       : std_logic_vector(0 to 16-1);
	signal icmprx_seq      : std_logic_vector(0 to 16-1);
	signal icmprx_cksm     : std_logic_vector(0 to 16-1);
	signal icmptx_cksm     : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;
	signal icmppltx_frm    : std_logic;
	signal icmppltx_irdy   : std_logic;
	signal icmppltx_trdy   : std_logic;
	signal icmppltx_end    : std_logic;
	signal icmppltx_data   : std_logic_vector(miitx_data'range);

begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_clk     => mii_clk,
		icmp_frm    => icmprx_frm,
		icmp_data   => icmprx_data,
		icmp_irdy   => icmprx_irdy,

		icmpid_irdy   => icmpidrx_irdy,
		icmpseq_irdy  => icmpseqrx_irdy,
		icmpcksm_irdy => icmpcksmrx_irdy,
		icmppl_irdy   => icmpplrx_irdy);

	icmpcksm_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => icmprx_frm,
		ser_irdy   => icmpcksmrx_irdy,
		ser_data   => icmprx_data,
		des_data   => icmprx_cksm);

	icmpseqridx_irdy <= icmpseqrx_irdy and icmpidrx_irdy;
	icmpseqid_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 16+16)
    port map (
		si_clk   => mii_clk,
        si_frm   => icmprx_frm,
		si_irdy  => icmpseqidrx_irdy,
        si_data  => icmprx_data,

		so_clk   => mii_clk,
        so_frm   => icmppltx_frm,
        so_irdy  => icmppltx_trdy,
        so_trdy  => icmppltx_irdy,
		so_end   => icmppltx_end,
        so_data  => icmppltx_data);

	icmpdata_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 64*octect_size)
    port map (
		si_clk   => mii_clk,
        si_frm   => icmprx_frm,
        si_irdy  => icmpplrx_irdy,
        si_data  => icmprx_data,

		so_clk   => mii_clk,
        so_frm   => icmppltx_frm,
        so_irdy  => icmppltx_trdy,
        so_trdy  => icmppltx_irdy,
		so_end   => icmppltx_end,
        so_data  => icmppltx_data);

	process (mii_clk)
		variable q : std_logic;
	begin
		if rising_edge(mii_clk) then
			if (icmpd_req xor icmpd_rdy)='0' then
				if q='1' and icmprx_frm='0' then
					icmpd_req <= not icmpd_rdy;
				end if;
			end if;
			q := icmprx_frm;
		end if;
	end process;

	icmppltx_frm <= to_stdulogic(icmpd_req xor icmpd_rdy);
	icmptx_cksm  <= oneschecksum(icmprx_cksm & x"00" & x"00", icmptx_cksm'length);
	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm    => icmppltx_frm,
		pl_irdy   => icmppltx_irdy,
		pl_trdy   => icmppltx_trdy,
		pl_end    => icmppltx_end,
		pl_data   => icmppltx_data,

		icmp_cksm => icmptx_cksm,
		icmp_id   => icmprx_id,
		icmp_seq  => icmprx_seq,
		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => miitx_data);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (icmpd_req xor icmpd_rdy)='1' then
				if icmptx_end='1' then
					icmpd_rdy <= icmpd_req;
				end if;
			end if;
		end if;
	end process;

end;
