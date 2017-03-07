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
	signal pre_dv     : std_logic;
	signal pre_rdy    : std_logic;
	signal pre_dat    : std_logic_vector(mii_txd'range);

	signal frm_dv     : std_logic;
	signal frm_rdy    : std_logic;
	signal frm_dat    : std_logic_vector(mii_txd'range);

	signal frmmem_dat : std_logic_vector(mii_txd'range);
	signal frmmem_dv  : std_logic;

	signal crc        : std_logic_vector(0 to 32-1);
	signal crc_dv     : std_logic;
	signal crc_req    : std_logic;
	signal crc_rst    : std_logic;
	signal crc_dat    : std_logic_vector(mii_txd'range);
	signal dlycrc_dat : std_logic_vector(mii_txd'range);
	signal pktmux_dat : std_logic_vector(mii_txd'range);
begin

	miitx_pre_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => x"5555_5555_5555_55d5")
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_trdy => pre_rdy,
		mii_txen => pre_dv,
		mii_txd  => pre_dat);

	miitx_frm_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => x"14")
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
--			x"0000")	   	            -- UPD Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => pre_rdy,
		mii_trdy => frm_rdy,
		mii_txen => frm_dv,
		mii_txd  => frm_dat);

	mem_req <= frm_rdy;
	frmmem_b : block 
		signal prefrm_dat : std_logic_vector(frm_dat'range);
		signal prefrm_dv  : std_logic;
		signal dlyfrm_dat : std_logic_vector(frm_dat'range);
		signal frmcrc_rst : std_logic;
		signal frmmem_rst : std_logic;
		signal frm_dv_n   : std_logic;
	begin
		prefrm_dat <= word2byte (
			word => pre_dat & frm_dat,
			addr => (0 => frm_dv));

		dlyfrmdat_e: entity hdl4fpga.align
		generic map (
			n => frm_dat'length,
			d => (frm_dat'range => 2))
		port map (
			clk => mii_txc,
			di  => prefrm_dat,
			do  => dlyfrm_dat);

		prefrm_dv <= pre_dv or frm_dv;
		frm_dv_n  <= not frm_dv;
		dlyfrmdv_e: entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => mii_txc,
			di(0) => frm_dv_n,
			do(0) => frmcrc_rst);

		frmmem_dat <= word2byte (
			word => dlyfrm_dat & mem_dat,
			addr => (0 => mem_ena));

		frmmem_rst <= frmcrc_rst and not mem_ena;

		dlypmdat_e : entity hdl4fpga.align
		generic map (
			n => frmmem_dat'length,
			d => (frmmem_dat'range => 1))
		port map (
			clk => mii_txc,
			di  => frmmem_dat,
			do  => crc_dat);

		dlypmdv_e : entity hdl4fpga.align
		generic map (
			n => 2,
			d => (0 to 1 => 1))
		port map (
			clk   => mii_txc,
			di(0) => frmcrc_rst,
			di(1) => crc_rst,
			do(0) => crc_rst,
			do(1) => crc_req);
	end block;

	miitx_crc_e : entity hdl4fpga.crc
	generic map (
		p    => crc32)
	port map (
		clk  => mii_txc,
		rst  => crc_rst,
		data => crc_dat,
		crc  => crc);

	pktmux_dat <= word2byte(
		data => 
	dlycrcdat_e : entity hdl4fpga.align
	generic map (
		n => crc_dat'length,
		d => (crc_dat'range => 1))
	port map (
		clk => mii_txc,
		di  => crc_dat,
		do  => dlycrc_dat);

--		mii_txd <= crc_dat;
--		mii_txdv <= frmmem_rst;
	process (mii_txc)
		variable cntr : unsigned(0 to unsigned_num_bits(crc'length/frm_dat'length-1));
		variable aux  : unsigned(crc'range);
		variable msg  : line;
	begin
		if rising_edge(mii_txc) then
			if crc_req='0' then
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
