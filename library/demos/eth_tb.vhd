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

entity eth_tb is 
	port (
		mii_req1  : in  std_logic;
		mii_req2  : in  std_logic;
		mii_rxc   : in  std_logic;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector(0 to 2-1);

		mii_txc   : in  std_logic;
		mii_txen  : buffer std_logic;
		mii_txd   : out std_logic_vector(0 to 2-1));
end;

architecture def of eth_tb is

	constant arppkt : std_logic_vector :=
		x"0000"                 & -- arp_htype
		x"0000"                 & -- arp_ptype
		x"00"                   & -- arp_hlen 
		x"00"                   & -- arp_plen 
		x"0000"                 & -- arp_oper 
		x"00_00_00_00_00_00"    & -- arp_sha  
		x"00_00_00_00"          & -- arp_spa  
		x"00_00_00_00_00_00"    & -- arp_tha  
		x"c0_a8_00_0e";           -- arp_tpa  

	constant icmppkt : std_logic_vector :=
		x"4500"                 &    -- IP Version, TOS
		x"0000"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0501"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"ffffffff"             &    -- IP Source IP address
		x"c0a8000e"             &    -- IP Destiantion IP Address
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"12345678",8) &
		reverse(x"aaaaaaaa",8) &
		reverse(x"ffffffff",8) ;

--	constant packet : std_logic_vector := 
--		x"4500"                 &    -- IP Version, TOS
--		x"0000"                 &    -- IP Length
--		x"0000"                 &    -- IP Identification
--		x"0000"                 &    -- IP Fragmentation
--		x"0511"                 &    -- IP TTL, protocol
--		x"0000"                 &    -- IP Header Checksum
--		x"ffffffff"             &    -- IP Source IP address
--		x"c0a8000e"             &    -- IP Destiantion IP Address
--
--		udp_checksummed (
--			x"00000000",
--			x"ffffffff",
--			x"0044dea9"         & -- UDP Source port, Destination port
--			std_logic_vector(to_unsigned(payload'length/8+8,16))    & -- UDP Length,
--			x"0000" &              -- UPD checksum
--			payload);
--
	signal eth1_llc   : std_logic_vector(0 to 16-1);
	signal eth1_txen  : std_logic;
	signal eth1_txd   : std_logic_vector(mii_txd'range);
	signal eth2_llc   : std_logic_vector(0 to 16-1);
	signal eth2_txen  : std_logic;
	signal eth2_txd   : std_logic_vector(mii_txd'range);
	signal eth_llc   : std_logic_vector(0 to 16-1);
	signal eth_txen  : std_logic;
	signal eth_txd   : std_logic_vector(mii_txd'range);

	signal txfrm_ptr : std_logic_vector(0 to 20);

begin

	eth1_e: entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(arppkt,8))
	port map (
		mii_txc  => mii_txc,
		mii_txen => mii_req1,
		mii_txdv => eth1_txen,
		mii_txd  => eth1_txd);

	eth2_e: entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(icmppkt,8))
	port map (
		mii_txc  => mii_txc,
		mii_txen => mii_req2,
		mii_txdv => eth2_txen,
		mii_txd  => eth2_txd);

	eth_txen <= eth1_txen or eth2_txen;
	eth_txd  <= wirebus(eth1_txd & eth2_txd, eth1_txen & eth2_txen);
	eth_llc  <= wirebus(x"0806" & x"0800",   eth1_txen & eth2_txen);
	process (mii_txc)
	begin

		if rising_edge(mii_txc) then
			if eth_txen='0' and mii_txen='0' then
				txfrm_ptr <= (others => '0');
			else
				txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
			end if;
		end if;
	end process;

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		eth_ptr  => txfrm_ptr,
		hwsa     => x"ff_ff_ff_ff_ff_ff",
		hwda     => x"00_40_00_01_02_03",
		llc      => eth_llc,
		pl_txen  => eth_txen,
		eth_rxd  => eth_txd,
		eth_txen => mii_txen,
		eth_txd  => mii_txd);

end;
