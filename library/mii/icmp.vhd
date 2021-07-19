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
use hdl4fpga.ipoepkg.all;

entity icmp is
	port (
		mii_clk     : in  std_logic;

		dll_frm     : in  std_logic;
		dll_irdy    : in  std_logic;
		net_frm     : in  std_logic;
		net_irdy    : in  std_logic;

		icmprx_frm  : in  std_logic;
		icmprx_irdy : in  std_logic;
		icmprx_data : in  std_logic_vector;
		icmptx_frm  : buffer std_logic;
		dlltx_end   : in  std_logic;
		icmptx_irdy : buffer std_logic;
		icmptx_trdy : in  std_logic := '1';
		icmptx_end  : buffer std_logic;
		icmptx_data : out std_logic_vector);
end;

architecture def of icmp is

	signal icmpdata_irdy   : std_logic;

	signal icmpd_rdy       : bit := '0';
	signal icmpd_req       : bit := '0';

	signal icmpcoderx_irdy : std_logic;
	signal icmptyperx_irdy : std_logic;
	signal icmpidrx_irdy   : std_logic;
	signal icmpseqrx_irdy  : std_logic;
	signal icmpcksmrx_frm  : std_logic;
	signal icmpcksmrx_irdy : std_logic;
	signal icmpplrx_irdy   : std_logic;

	signal icmprx_id       : std_logic_vector(0 to 16-1);
	signal icmprx_seq      : std_logic_vector(0 to 16-1);
	signal icmprx_cksm     : std_logic_vector(0 to 16-1);
	signal icmptx_cksm     : std_logic_vector(0 to 16-1);

	signal icmppl_irdy     : std_logic;
	signal icmpcksmtx_irdy : std_logic;
	signal icmppltx_frm    : std_logic;
	signal icmppltx_irdy   : std_logic;
	signal icmppltx_trdy   : std_logic;
	signal icmppltx_end    : std_logic;
	signal icmppltx_data   : std_logic_vector(icmptx_data'range);

	signal cksm_end : std_logic;
	signal cksm_data : std_logic_vector(icmprx_data'range);

	signal memrx_data : std_logic_vector(icmprx_data'range);
	signal memtx_data : std_logic_vector(icmptx_data'range);
begin

	icmprqst_rx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_clk       => mii_clk,
		icmp_frm      => dll_frm,
		icmp_data     => icmprx_data,
		icmp_irdy     => icmprx_irdy,

		icmpcode_irdy => icmpcoderx_irdy,
		icmptype_irdy => icmptyperx_irdy,
		icmpid_irdy   => icmpidrx_irdy,
		icmpseq_irdy  => icmpseqrx_irdy,
		icmpcksm_frm  => icmpcksmrx_frm,
		icmpcksm_irdy => icmpcksmrx_irdy,
		icmppl_irdy   => icmpplrx_irdy);

	cksm_end <= not icmpcksmrx_frm;
	cksmrx_e : entity hdl4fpga.mii_1cksm
	generic map (
		n    => 16,
		init => icmptype_rply & icmptype_rqst)
	port map (
		mii_clk   => mii_clk,
		mii_frm   => dll_frm,
		mii_irdy  => icmpcksmrx_irdy,
		mii_end   => cksm_end,
		mii_data  => icmprx_data,
		mii_cksm  => cksm_data);

	memrx_data <= primux(
		(icmptx_data'range => '0') & (icmptx_data'range => '0') & cksm_data, 
		icmpcoderx_irdy & icmptyperx_irdy & icmpcksmrx_irdy,
		icmprx_data);

	icmpdata_irdy <= dll_irdy or net_irdy or icmprx_irdy;
	icmpdata_e : entity hdl4fpga.sio_ram
	generic map (
		mem_size => 128*octect_size)
    port map (
		si_clk   => mii_clk,
        si_frm   => dll_frm,
		si_irdy  => icmpdata_irdy,
        si_data  => memrx_data,

		so_clk   => mii_clk,
        so_frm   => icmppltx_frm,
        so_irdy  => icmppltx_trdy,
        so_trdy  => icmppltx_irdy,
		so_end   => icmppltx_end,
        so_data  => memtx_data);

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

	cksmtx_e : entity hdl4fpga.mii_1cksm
	generic map (
		n    => 16)
	port map (
		mii_clk   => mii_clk,
		mii_frm   => icmppltx_frm,
		mii_ci    => '-',
		mii_irdy  => icmpcksmtx_irdy,
		mii_end   => '-', --cksm_end,
		mii_data  => (icmptx_data'range => '0'),
		mii_cksm  => icmppltx_data);

	icmprply_e : entity hdl4fpga.icmprply_tx
	port map (
		mii_clk   => mii_clk,

		pl_frm    => icmppltx_frm,
		pl_irdy   => icmppltx_irdy,
		pl_trdy   => icmppltx_trdy,
		pl_end    => icmppltx_end,
		pl_data   => icmppltx_data,

		icmp_frm  => icmptx_frm,
		icmp_irdy => icmptx_irdy,
		icmp_trdy => icmptx_trdy,
		icmp_end  => icmptx_end,
		icmp_data => icmptx_data);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (icmpd_req xor icmpd_rdy)='1' then
				if (dlltx_end and icmptx_end)='1' then
					icmpd_rdy <= icmpd_req;
				end if;
			end if;
		end if;
	end process;

end;
