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
		payload_size : natural := 512;
		mac_destaddr : std_logic_vector(0 to 48-1) := x"ffffffffffff");
	port (
		mii_treq  : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txdv  : out std_logic;
		mii_txd   : out std_logic_vector;

		mem_txdv  : out std_logic;
		mem_txd   : in  std_logic_vector);

end;

architecture mix of scopeio_miitx is

begin

	miitx_macudp_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => 
			x"5555_5555_5555_55d5" &
			mac_destaddr           &
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
			x"0000")	   	            -- UPD Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => ,
		mii_txen => ,
		mii_txd  => ipudp_dat);

	txena(txpld) <= miidma_rxen;
	txdat(txpld) <= miidma_rxd;
	mem_ena   <= txreq(txpld);

	miitx_crc_e : entity hdl4fpga.miitx_crc
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_ted  => crc_ted,
		mii_txi  => txd,
		mii_txen => crc_txen,
		mii_txd  => crc_dat));

	mii_trdy <= rdy(n);
	mii_txd  <= txdat(n) when rdy(n-1)='1' else txd;
end;
