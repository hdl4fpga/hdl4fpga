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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity miitx_dhcp is
	generic (
		mac_src   : std_logic_vector(0 to 48-1) := x"000000010203");
	port (
		mii_treq  : in  std_logic;
		mii_trdy  : out std_logic;
		mii_txc   : in  std_logic;
		mii_txdv  : out std_logic;
		mii_txd   : out std_logic_vector;

		mem_req   : out std_logic;
		mem_rdy   : in  std_logic;
		mem_ena   : in  std_logic;
		mem_dat   : in  std_logic_vector);

	constant payload_size : natural := 512;
end;

architecture mix of scopeio_miitx is
	constant crc32 : std_logic_vector(1 to 32) := X"04C11DB7";
	signal align_rst  : std_logic;
	signal pre_dv     : std_logic;
	signal pre_rdy    : std_logic;
	signal pre_dat    : std_logic_vector(mii_txd'range);

	signal hdr_dv     : std_logic;
	signal hdr_rdy    : std_logic;
	signal hdr_dat    : std_logic_vector(mii_txd'range);

	signal hdrmem_dat : std_logic_vector(mii_txd'range);
	signal hdrmem_dv  : std_logic;

	signal crc        : std_logic_vector(0 to 32-1);
	signal crc_rst    : std_logic;
	signal crc_req    : std_logic;
	signal crc_rdy    : std_logic;
	signal crc_dat    : std_logic_vector(mii_txd'range);
	signal pkt_dv     : std_logic;
	signal pkt_txd    : std_logic_vector(mii_txd'range);
begin

	align_rst <= not mii_treq;
	miitx_pre_e  : entity hdl4fpga.mii_mem
	generic map (
		mem_data => x"5555_5555_5555_55d5")
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_trdy => pre_rdy,
		mii_txen => pre_dv,
		mii_txd  => pre_dat);

	miitx_hdr_e  : entity hdl4fpga.mii_mem
	generic map (
		x"ffffffffffff"	       &    
		mac_src                &    -- MAC Source Address
		x"0800"                &    -- MAC Protocol ID
		ipheader_checksumed(
			x"4500"            &    -- IP  Version, header length, TOS
			std_logic_vector(to_unsigned(payload_size+28,16)) &	-- IP  Length
			x"0000"            &    -- IP  Identification
			x"0000"            &    -- IP  Fragmentation
			x"0511"            &    -- IP  TTL, protocol
			x"0000"            &    -- IP  Checksum
			x"00000000"        &    -- IP  Source address
			x"ffffffff")       &    -- IP  Destination address
		x"00680067"            &    -- UDP Source port, Destination port
		std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
		x"0000"                &
		x"01010600"            &    -- OP, HTYPE, HLEN,  HOPS
		x"3903f326"            &    -- XID
		x"00000100"            &    -- SECS, FLAGS
		x"00000000"            &    -- CIADDR
		x"00000000"            &    -- YIADDR
		x"00000000"            &    -- SIADDR
		x"00000000"            &    -- GIADDR
		x"00000001"            &    -- CHADDR
		x"02030000"            &    -- CHADDR
		x"00000000"            &    -- CHADDR
		x"00000000"            &    -- CHADDR
	)	   	            -- UPD Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => pre_rdy,
		mii_trdy => hdr_rdy,
		mii_txen => hdr_dv,
		mii_txd  => hdr_dat);

	mem_req <= hdr_rdy;
	hdrmem_b : block 
		signal prehdr_dat   : std_logic_vector(hdr_dat'range);
		signal dlyhdr_dat   : std_logic_vector(hdr_dat'range);
		signal dlypre_dv    : std_logic;
		signal dlyhdr_dv    : std_logic;
		signal dlyhdrmem_dv : std_logic;
		signal dv           : std_logic;
	begin
		prehdr_dat <= word2byte (
			word => pre_dat & hdr_dat,
			addr => (0 => hdr_dv));

		dlyhdrdat_e: entity hdl4fpga.align
		generic map (
			n => hdr_dat'length,
			i => (mii_txd'range => '-'),
			d => (hdr_dat'range => 2))
		port map (
			clk => mii_txc,
			di  => prehdr_dat,
			do  => dlyhdr_dat);

		dlyhdrdv_e: entity hdl4fpga.align
		generic map (
			n => 2,
			d => (0 => 2, 1 => 3),
			i => (0 to 1 => '0'))
		port map (
			clk   => mii_txc,
			rst   => align_rst,
			di(0) => hdr_dv,
			di(1) => pre_dv,
			do(0) => dlyhdr_dv,
			do(1) => dlypre_dv);
		hdrmem_dv <= dlyhdr_dv or mem_ena;

		hdrmem_dat <= word2byte (
			word =>  dlyhdr_dat & reverse(mem_dat),
			addr => (0 => mem_ena));

		dlypmdat_e : entity hdl4fpga.align
		generic map (
			n => hdrmem_dat'length,
			i => (mii_txd'range => '-'),
			d => (hdrmem_dat'range => 1))
		port map (
			clk => mii_txc,
			di  => hdrmem_dat,
			do  => crc_dat);

		dv <= dlyhdrmem_dv or dlypre_dv;
		dlypmdv_e : entity hdl4fpga.align
		generic map (
			n => 2,
			d => (0 => 1, 1 => 1),
			i => (0 to 1 => '0'))
		port map (
			clk   => mii_txc,
			rst   => align_rst,
			di(0) => hdrmem_dv,
			di(1) => dv,
			do(0) => dlyhdrmem_dv,
			do(1) => pkt_dv);

		crc_rst <= not dlyhdrmem_dv;
	end block;

	miitx_crc_e : entity hdl4fpga.crc
	generic map (
		p    => crc32)
	port map (
		clk  => mii_txc,
		rst  => crc_rst,
		data => crc_dat,
		crc  => crc);

	crcreq_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => 2),
		i => (0 to 1 => '0'))
	port map (
		clk   => mii_txc,
		rst   => align_rst,
		di(0) => mem_rdy,
		do(0) => crc_req);

	crcdat_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		i => (mii_txd'range => '-'),
		d => (mii_txd'range => 1))
	port map (
		clk => mii_txc,
		di  => crc_dat,
		do  => pkt_txd);

	process (mii_txc)
		variable cntr : unsigned(0 to unsigned_num_bits(crc'length/hdr_dat'length-1));
		variable aux  : unsigned(crc'range);
	begin
		if rising_edge(mii_txc) then
			if crc_req='0' then
				mii_txdv <= pkt_dv;
				mii_txd  <= pkt_txd;
				mii_trdy <= '0';
				cntr     := (others => '0');
				aux      := unsigned(crc);
			elsif crc_rdy='0' then
				mii_txd  <= (std_logic_vector(aux(crc_dat'range)));
				mii_txdv <= '1';
				mii_trdy <= '0';
				cntr     := cntr + 1;
				aux      := aux  sll crc_dat'length;
			else
				mii_txd  <= (mii_txd'range => '0');
				mii_txdv <= '0';
				mii_trdy <= '1';
			end if;
			crc_rdy <= cntr(0);
		end if;
	end process;

end;
