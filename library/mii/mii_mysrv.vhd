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

entity mii_mysrv is
	generic (
		my_udpport    : std_logic_vector(0 to 16-1));
	port (
		mii_txc       : in  std_logic;
		mii_txd       : buffer std_logic_vector;
		mii_txen      : buffer std_logic;

		txc_rxd       : buffer std_logic_vector;
		txc_rxdv      : buffer std_logic;

		ethhwda_rxdv  : in  std_logic;
		ethhwsa_rxdv  : in  std_logic;
		ethtype_rxdv  : in  std_logic;

		ip4da_rxdv    : in  std_logic;
		ip4sa_rxdv    : in  std_logic;
		ip4sa_rx      : in  std_logic_vector(0 to 32-1);

		udpsp_rxdv    : in  std_logic;
		udpdp_rxdv    : in  std_logic;
		udplen_rxdv   : in  std_logic;
		udpcksm_rxdv  : in  std_logic;
		udppl_rxdv    : in  std_logic;

		my_req        : in std_logic := '0';
		my_rdy        : buffer std_logic;
		my_gnt        : buffer std_logic;
		my_hwsa       : in  std_logic_vector(0 to 48-1);
		my_hwda       : buffer std_logic_vector(0 to 48-1) := (others => '-');
		my_ip4da      : buffer std_logic_vector(0 to 32-1) := (others => '-');
		my_udplen     : buffer std_logic_vector(0 to 16-1) := (others => '-');

		myipv4a       : out std_logic_vector(0 to 32-1);
		dhcp_rcvd     : buffer std_logic;

		tp            : buffer std_logic_vector(1 to 4));

end;

architecture def of mii_mysrv is
	signal myport_rcvd : std_logic;
begin

	myport_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(my_port,8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => txc_rxdv,
		mii_rxd  => txc_rxd,
		mii_ena  => udpdp_rxdv,
		mii_equ  => myport_rcvd);

	mydstport_e : entity hdl4fpga.mii_des
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => udpdp_rxdv,
		mii_rxd  => txc_rxd,
		des_data => mydstport);

	icmprqst_ena <= ip4icmp_rcvd and dll_rxdv;
	icmprqstrx_e : entity hdl4fpga.icmprqst_rx
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dll_rxdv,
		mii_rxd  => txc_rxd,
		mii_ptr  => rxfrm_ptr,

		icmprqst_ena  => icmprqst_ena,
		icmpid_rxdv   => icmpid_rxdv,
		icmpcksm_rxdv => icmpcksm_rxdv,
		icmpseq_rxdv  => icmpseq_rxdv,
		icmppl_rxdv   => icmppl_rxdv);

	icmpcksm_e : entity hdl4fpga.mii_des
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => icmpcksm_rxdv,
		mii_rxd  => txc_rxd,
		des_data => icmpcksm_data);

	icmpseq_e : entity hdl4fpga.mii_des
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => icmpseq_rxdv,
		mii_rxd  => txc_rxd,
		des_data => icmpseq_data);

	icmpid_e : entity hdl4fpga.mii_des
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => icmpid_rxdv,
		mii_rxd  => txc_rxd,
		des_data => icmpid_data);

	icmpdata_e : entity hdl4fpga.mii_ram
	generic map (
		mem_size => 64*octect_size)
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => icmppl_rxdv,
		mii_rxd  => txc_rxd,

		mii_txc  => mii_txc,
		mii_txen => icmp_gnt,
		mii_txdv => icmppl_txen,
		mii_txd  => icmppl_txd);

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

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if icmp_rdy='1' then
				icmp_req <= '0';
			elsif icmp_rcvd='1' then
				icmp_req     <= '1';
				ethhwda_icmp <= ethhwsa_rx;
				icmp_ip4da   <= ip4sa_rx;
				ipicmp_len   <= ip4len_rx;
			end if;
		end if;
	end process;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if dll_rxdv='0' then
				if txc_eor='1' then
					icmp_rcvd <= ip4icmp_rcvd and myip4a_rcvd;
				elsif icmp_req='1' then
					icmp_rcvd <= '0';
				end if;
			end if;
		end if;
	end process;

end;
