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

entity scopeio_miitx is
	generic (
		mac_daddr : std_logic_vector(0 to 48-1) := x"ffffffffffff");
	port (
		mii_treq  : in  std_logic;
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
	signal crc        : std_logic_vector(0 to 32-1);
	signal crc_dv     : std_logic;
	signal crc_req    : std_logic;
	signal crc_rst    : std_logic;
	signal crc_dat    : std_logic_vector(mii_txd'range);
	signal pkt_dv     : std_logic;
	signal pkt_rdy    : std_logic;
	signal pkt_dat    : std_logic_vector(mii_txd'range);
	signal pktmem_dat : std_logic_vector(mii_txd'range);
	signal pktmem_dv  : std_logic;
	signal pktmem_rdy : std_logic;
	signal dlycrc_dat : std_logic_vector(mii_txd'range);
begin

	miitx_pkt_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => x"10")
--		mem_data => 
--			x"5555_5555_5555_55d5" &
--			mac_daddr              &
--			x"000000010203"	       &    -- MAC Source Address
--			x"0800"                &    -- MAC Protocol ID
--			ipheader_checksumed(
--				x"4500"            &    -- IP  Version, header length, TOS
--				std_logic_vector(to_unsigned(payload_size+28,16)) &	-- IP  Length
--				x"0000"            &    -- IP  Identification
--				x"0000"            &    -- IP  Fragmentation
--				x"0511"            &    -- IP  TTL, protocol
--				x"0000"            &    -- IP  Checksum
--				x"c0a802c8"        &    -- IP  Source address
--				x"ffffffff")       &    -- IP  Destination address
--			x"04000400"            &    -- UDP Source port, Destination port
--			std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
--			x"1234")	   	            -- UPD Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_trdy => pkt_rdy,
		mii_txen => pkt_dv,
		mii_txd  => pkt_dat);

	mem_req <= pkt_rdy;
	pktmem_b : block 
		signal dlypkt_dat : std_logic_vector(pkt_dat'range);
		signal dlypkt_dv  : std_logic;
		signal pktmem_mux : std_logic_vector(pkt_dat'range); 
		signal rst_n      : std_logic;
	begin
		dlypktdat_e: entity hdl4fpga.align
		generic map (
			n => pkt_dat'length,
			d => (pkt_dat'range => 2))
		port map (
			clk => mii_txc,
			di  => pkt_dat,
			do  => dlypkt_dat);

		dlypktdv_e: entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => mii_txc,
			di(0) => pkt_dv,
			do(0) => dlypkt_dv);

		pktmem_mux <= word2byte (
			word => dlypkt_dat & mem_dat,
			addr => (0 => not dlypkt_dv));

		pktmem_dv  <= dlypkt_dv or mem_ena;
		pktmem_dat <=
			pktmem_mux when pktmem_dv='1' else
			(others => '0');

		dlypmdat_e : entity hdl4fpga.align
		generic map (
			n => pktmem_dat'length,
			d => (pktmem_dat'range => 1))
		port map (
			clk => mii_txc,
			di  => pktmem_dat,
			do  => crc_dat);

		pktmem_rdy <= pkt_rdy and mem_rdy;
		dlypmdv_e : entity hdl4fpga.align
		generic map (
			n => 2,
			d => (0 to 1 => 1))
		port map (
			clk   => mii_txc,
			di(0) => pktmem_dv,
			di(1) => rst_n,
			do(0) => rst_n,
			do(1) => crc_req);
		crc_rst <= not rst_n;
	end block;

	miitx_crc_e : entity hdl4fpga.crc
	generic map (
		p    => crc32)
	port map (
		clk  => mii_txc,
		rst  => crc_rst,
		data => crc_dat,
		crc  => crc);

	dlycrcdat_e : entity hdl4fpga.align
	generic map (
		n => crc_dat'length,
		d => (crc_dat'range => 1))
	port map (
		clk => mii_txc,
		di  => crc_dat,
		do  => dlycrc_dat);

	process (mii_txc)
		variable cntr : unsigned(0 to unsigned_num_bits(crc'length/pkt_dat'length-1));
		variable aux  : unsigned(crc'range);
		variable msg  : line;
	begin
		if rising_edge(mii_txc) then
			if crc_req='1' then
				mii_txd  <= dlycrc_dat;
				mii_txdv <= '1';
				cntr     := (others => '0');
				aux      := unsigned(crc);
			elsif cntr(0)='0' then
				mii_txd  <= std_logic_vector(aux(dlycrc_dat'range));
				mii_txdv <= '1';
				cntr     := cntr + 1;
				aux      := aux  sll dlycrc_dat'length;
			else
				mii_txd  <= (mii_txd'range => '0');
				mii_txdv <= '0';
			end if;
		end if;
	end process;

end;
