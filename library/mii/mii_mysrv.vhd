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
		mysrv_port    : std_logic_vector(0 to 16-1));
	port (
		mii_txc       : in  std_logic;
		mii_txd       : in  std_logic_vector;

		dll_rxdv      : in  std_logic;
		dll_rxd       : in std_logic_vector;

		dllhwsa_rx    : in  std_logic_vector(0 to 48-1);
		dllcrc32_rxdv : in std_logic;
		dllcrc32_equ  : in std_logic;

		ipv4sa_rx      : in  std_logic_vector(0 to 32-1);

		udpdp_rxdv    : in  std_logic;
		udppl_rxdv    : in  std_logic;

		udpsp_rx      : in  std_logic_vector(0 to 16-1);

		tx_req     : out std_logic;
		tx_rdy     : in  std_logic;
		tx_gnt     : in  std_logic;

		dll_hwda    : out std_logic_vector(0 to 48-1) := (others => '-');
		ipv4_da  : out std_logic_vector(0 to 32-1) := (others => '-');
		udp_len  : out std_logic_vector(0 to 16-1) := (others => '-');
		udp_dp   : out std_logic_vector(0 to 16-1) := (others => '-');

		udppl_txen    : out  std_logic;
		udppl_txd     : out  std_logic_vector;
		tp            : buffer std_logic_vector(1 to 4));

end;

architecture def of mii_mysrv is
	signal myport_rcvd  : std_logic;
	signal mysrv_rcvd   : std_logic;
	signal dllcrc32_eor : std_logic;
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			dllcrc32_eor <= dllcrc32_rxdv;
		end if;
	end process;

	myport_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mysrv_port,8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dll_rxdv,
		mii_rxd  => dll_rxd,
		mii_ena  => udpdp_rxdv,
		mii_equ  => myport_rcvd);

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if tx_rdy='0' then
				if myport_rcvd='1' then
					dll_hwda  <= dllhwsa_rx;
					ipv4_da <= ipv4sa_rx;
					udp_dp <= udpsp_rx;
				end if;
			end if;
		end if;
	end process;

	process (mii_txc)
		variable rcvd : std_logic;
	begin
		if rising_edge(mii_txc) then
			if tx_rdy='1' then
				tx_req <= '0';
				rcvd   := '0';
			elsif dllcrc32_rxdv='0' then
				if dllcrc32_eor='1' then
					tx_req <= '1';
					rcvd  := '0';
				end if;
			end if;
			if dll_rxdv='1'then
				rcvd := myport_rcvd;
			end if;
		end if;
	end process;

end;
