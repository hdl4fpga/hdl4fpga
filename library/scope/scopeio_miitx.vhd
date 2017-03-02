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
	signal crc      : std_logic_vector(0 to 32-1);
	signal crc_dv   : std_logic;
	signal crc_req0 : std_logic;
	signal crc_req  : std_logic;
	signal crc_rst  : std_logic;
	signal crc_dat  : std_logic_vector(mii_txd'range);
	signal pkt_dv   : std_logic;
	signal pkt_rdy  : std_logic;
	signal pkt_dat  : std_logic_vector(mii_txd'range);
begin

	miitx_pkt_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => 
			x"5555_5555_5555_55d5" &
			mac_daddr              &
			x"000000010203"	       &    -- MAC Source Address
			x"0800"                &    -- MAC Protocol ID
			ipheader_checksumed(
				x"4500"            &    -- IP  Version, header length, TOS
				std_logic_vector(to_unsigned(payload_size+28,16)) &	-- IP  Length
				x"0000"            &    -- IP  Identification
				x"0000"            &    -- IP  Fragmentation
				x"0511"            &    -- IP  TTL, protocol
				x"0000"            &    -- IP  Checksum
				x"c0a802c8"        &    -- IP  Source address
				x"ffffffff")       &    -- IP  Destination address
			x"04000400"            &    -- UDP Source port, Destination port
			std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
			x"1234")	   	            -- UPD Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_trdy => pkt_rdy,
		mii_txen => pkt_dv,
		mii_txd  => pkt_dat);

	mem_req <= pkt_rdy;
	pktmem_b : block 
		signal dly_dat : std_logic_vector(pkt_dat'range);
		signal dly_dv  : std_logic;
	begin
		dlypktdat_e: entity hdl4fpga.align
		generic map (
			n => pkt_dat'length,
			d => (pkt_dat'range => 2))
		port map (
			clk => mii_txc,
			di  => pkt_dat,
			do  => dly_dat);

		dlypktdly_e: entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => mii_txc,
			di(0) => pkt_dv,
			do(0) => dly_dv);

		crc_req0 <= (dly_dv or mem_ena);
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				crc_dat <= word2byte (
					word => dly_dat & mem_dat,
					addr => (0 => not dly_dv));
				if dly_dv='0' then
					if mem_ena='0' then
						crc_dat <= (others => '0');
					end if;
				end if;
				crc_req <= crc_req0;
			end if;
		end process;
	end block;

	crc_rst <= not crc_req;
	miitx_crc_e : entity hdl4fpga.crc
	generic map (
		p    => crc32)
	port map (
		clk  => mii_txc,
		rst  => crc_rst,
		data => crc_dat,
		crc  => crc);

			mii_txd  <= crc_dat;
			mii_txdv <= crc_req or crc_dv;
	process (mii_treq, mii_txc)
		variable cntr : unsigned(0 to unsigned_num_bits(crc'length/pkt_dat'length-1)) := (others => 'U');
	begin
		if mii_treq='0' then
			cntr := (others => '0');
			crc_dv <= '0';
		elsif rising_edge(mii_txc) then
			if crc_req='0' then
				if cntr(0)='0' then
					cntr := cntr + 1;
				end if;
				crc_dv <= not cntr(0);
			end if;
		end if;
	end process;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
--			mii_txd <= crc(crc_dat'range);
--			if crc_req='1' then
--				mii_txd <= crc_dat;
--			end if;
--			mii_txdv <= crc_req or crc_dv; 
		end if;
	end process;

end;
