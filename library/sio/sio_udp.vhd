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

entity sio_udp is
	generic (
		preamble_disable : boolean := false;
		crc_disable : boolean := false;
		mac      : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		dchp_req  : in  std_logic;
		dchp_rcvd : in  std_logic;
		myip4a    : buffer std_logic_vector(0 to 32-1);

		sio_clk   : out std_logic;

		si_dv     : in  std_logic;
		si_data   : in  std_logic_vector);

		so_dv     : out std_logic;
		so_data   : out std_logic_vector);
end;

architecture struct of sio_udp is

	signal txc_rxdv     : std_logic;
	signal txc_rxd      : std_logic_vector(mii_rxd'range);

	signal ethhwda_rxdv : std_logic;
	signal ethhwsa_rxdv : std_logic;

	signal ip4da_rxdv   : std_logic;
	signal ip4sa_rxdv   : std_logic;

	signal udpsp_rxdv   : std_logic;
	signal udpdp_rxdv   : std_logic;
	signal udplen_rxdv  : std_logic;
	signal udpcksm_rxdv : std_logic;
	signal udppl_rxdv   : std_logic;

begin
	
	so_clk  <= mii_txc;

	ipoe_e : entity hdl4fpga.mii_ipoe
	generic map (
		mymac : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03")
	port map (
		mii_rxc      => mii_rxc,
		mii_rxd      => mii_rxd,
		mii_rxdv     => mii_rxdv,

		mii_txc      => mii_txc,
		mii_txd      => mii_txd,
		mii_txen     => mii_txen,

		txc_rxdv     => txc_rxdv,
		txc_rxd      => txc_rxd,

		dhcp_req     => dhcp_req,
		dhcp_rcvd    => dhcp_rcvd,

		ethhwda_rxdv => ethhwda_rxdv,
		ethhwsa_rxdv => ethhwsa_rxdv,

		ip4da_rxdv   => ip4da_rxdv,
		ip4sa_rxdv   => ip4sa_rxdv,

		udpsp_rxdv   => udpsp_rxdv,
		udpdp_rxdv   => udpdp_rxdv,
		udplen_rxdv  => udplen_rxdv,
		udpcksm_rxdv => udpcksm_rxdv,
		udppl_rxdv   => udppl_rxdv);

	srvp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(std_logic_vector(to_unsigned(57001,16)),8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => txc_rxdv,
		mii_ena  => udpdp_rxdv,
		mii_rxd  => txc_rxd,
		mii_equ  => srvp_chk);

	clip_crc_b : block
		constant lat    : natural := 32/mii_rxd'length;

		signal dv : std_logic;
		signal data : std_logic_vector(mii_rxd'range);
	begin

		dvlat_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => lat))
		port map (
			clk   => mii_txc,
			di(0) => udppl_rxdv,
			do(0) => dv);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if not crc_disable then
					so_dv <= udpdports_vld(0) and dv;
				else	
					so_dv <= udpdports_vld(0) and udppl_rxdv;
				end if;
			end if;
		end process;

		datalat_e : entity hdl4fpga.align
		generic map (
			n => mii_rxd'length,
			d => (1 to mii_rxd'length => lat))
		port map (
			clk => mii_txc,
			di  => txc_rxd,
			do  => data);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if not crc_disable then
					so_data <= data;
				else	
					so_data <= txc_rxd;
				end if;
			end if;
		end process;

	end block;


end;
