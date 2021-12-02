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
		mii_frm1  : in  std_logic := '0';
		mii_frm2  : in  std_logic := '0';
		mii_frm3  : in  std_logic := '0';
		mii_frm4  : in  std_logic := '0';

		mii_txc   : in  std_logic;
		mii_txen  : buffer std_logic;
		mii_txd   : out std_logic_vector);
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
		x"1234"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0501"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"d0a10004"             &    -- IP Source IP address
		x"c0a8000e"             &    -- IP Destiantion IP Address
		x"5555edcb" &
		x"abcdefaf" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"00000000" &
		x"ffffffaa" ;

	constant payload : std_logic_vector :=
			x"01010600"  &    -- OP, HTYPE, HLEN,  HOPS
			x"3903f326"  &    -- XID
			x"00000000"  &
			x"00000000"  &    -- CIADDR
			x"c0a80002"  &    -- YIADDR
			x"00000000"  &    -- SIADDR
			x"00000000"  &    -- GIADDR
			x"00400001"  &    -- CHADDR
			x"02030000"  &    -- CHADDR
			x"00000000"  &    -- CHADDR
			x"00000000"  &    -- CHADDR
			(0 to 192*8-1 => '0') ;
	constant packet : std_logic_vector :=
		x"4500"                 &    -- IP Version, TOS
		x"0000"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0511"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"c0a80001"             &    -- IP Source IP address
		x"ffffffff"             &    -- IP Destiantion IP Address

		udp_checksummed (
			x"ffffffff",             -- IP Source IP address
			x"c0a8000e",             -- IP Destiantion IP Address
			x"00430044"         &    -- UDP Source port, Destination port
			std_logic_vector(to_unsigned(payload'length/8+8,16))    & -- UDP Length,
			x"0000" &              -- UPD checksum
			payload);

	constant pyld1 : std_logic_vector := x"ff00ff";
	constant pkt1 : std_logic_vector :=
		x"4500"                 &    -- IP Version, TOS
		x"0000"                 &    -- IP Length
		x"0000"                 &    -- IP Identification
		x"0000"                 &    -- IP Fragmentation
		x"0511"                 &    -- IP TTL, protocol
		x"0000"                 &    -- IP Header Checksum
		x"ffffffff"             &    -- IP Source IP address
		x"c0a8000e"             &    -- IP Destiantion IP Address

		udp_checksummed (
			x"ffffffff",             -- IP Source IP address
			x"c0a8000e",             -- IP Destiantion IP Address
			x"5ff5affa"         &    -- UDP Source port, Destination port
			std_logic_vector(to_unsigned(pyld1'length/8+8,16))    & -- UDP Length,
			x"0000" &              -- UPD checksum
			pyld1);

	signal eth1_txd   : std_logic_vector(mii_txd'range);
	signal eth1_end   : std_logic;

	signal eth2_end   : std_logic;
	signal eth2_txd   : std_logic_vector(mii_txd'range);

	signal eth3_end   : std_logic;
	signal eth3_txd   : std_logic_vector(mii_txd'range);

	signal eth4_end   : std_logic;
	signal eth4_txd   : std_logic_vector(mii_txd'range);

	signal eth_llc    : std_logic_vector(0 to 16-1);

	signal pl_frm     : std_logic;
	signal pl_trdy    : std_logic;
	signal pl_end     : std_logic_vector(0 to 0);
	signal pl_data    : std_logic_vector(mii_txd'range);

	signal miirx_frm  : std_logic;
	signal miirx_end  : std_logic;
	signal miirx_irdy : std_logic;
	signal miirx_trdy : std_logic;
	signal miirx_data : std_logic_vector(pl_data'range);

	signal miitx_frm  : std_logic;
	signal miitx_irdy : std_logic;
	signal miitx_trdy : std_logic;
	signal miitx_end  : std_logic;
	signal miitx_data : std_logic_vector(pl_data'range);

	signal llc_data   : std_logic_vector(0 to 2*48+16-1);
	signal hwllc_irdy : std_logic;
	signal hwllc_trdy : std_logic;
	signal hwllc_end  : std_logic;
	signal hwllc_data : std_logic_vector(pl_data'range);

begin

	eth1_e: entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(arppkt,8),
		sio_clk  => mii_txc,
		sio_frm  => mii_frm1,
		sio_irdy => pl_trdy,
		so_end   => eth1_end,
		so_data  => eth1_txd);

	eth2_e: entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(icmppkt,8),
        sio_clk  => mii_txc,
        sio_frm  => mii_frm2,
		sio_irdy => pl_trdy,
		so_end   => eth2_end,
        so_data  => eth2_txd);

	eth3_e: entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(packet,8),
        sio_clk  => mii_txc,
        sio_frm  => mii_frm3,
		sio_irdy => pl_trdy,
		so_end   => eth3_end,
        so_data  => eth3_txd);

	eth4_e: entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(pkt1,8),
        sio_clk  => mii_txc,
        sio_frm  => mii_frm4,
		sio_irdy => pl_trdy,
		so_end   => eth4_end,
        so_data  => eth4_txd);

	pl_end  <= wirebus(eth1_end & eth2_end & eth3_end & eth4_end, mii_frm1 & mii_frm2 & mii_frm3 & mii_frm4);
	pl_data <= wirebus(eth1_txd & eth2_txd & eth3_txd & eth4_txd, mii_frm1 & mii_frm2 & mii_frm3 & mii_frm4);
	eth_llc <= wirebus(std_logic_vector'(x"0806" & x"0800" & x"0800" & x"0800"), mii_frm1 & mii_frm2 & mii_frm3 & mii_frm4); -- Qualified expression required by Latticesemi Diamond

	process (miitx_end, mii_txc)
		variable frm : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if frm='1' then
				if miirx_end='1' then
					if pl_trdy='1' then
						frm := '0';
					end if;
				end if;
			elsif ((mii_frm1 and not eth1_end) or (mii_frm2 and not eth2_end) or (mii_frm3 and not eth3_end) or (mii_frm4 and not eth4_end))='1' then
				frm := '1';
			end if;
		end if;
		pl_frm <= frm;
	end process;

	llc_data <= reverse(x"00_40_00_01_02_03" & x"00_27_0e_0f_f5_95" & eth_llc,8);
	hwsa_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => llc_data,
		sio_clk  => mii_txc,
		sio_frm  => pl_frm,
		sio_irdy => hwllc_irdy,
		sio_trdy => hwllc_trdy,
		so_end   => hwllc_end,
		so_data  => hwllc_data);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_clk  => mii_txc,

		pl_frm   => pl_frm,
		pl_trdy  => pl_trdy,
		pl_end   => pl_end(0),
		pl_data  => pl_data,

		hwllc_irdy => hwllc_irdy,
		hwllc_trdy => open,
		hwllc_end  => hwllc_end,
		hwllc_data => hwllc_data,

		mii_frm  => miirx_frm,
		mii_irdy => miirx_irdy,
		mii_trdy => '1', --miirx_trdy,
		mii_end  => miirx_end,
		mii_data => miirx_data);

	mii_txen <= miirx_frm and not miirx_end;
	mii_txd  <= miirx_data;

end;
