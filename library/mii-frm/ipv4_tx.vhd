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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ipv4_tx is
	port (
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : out std_logic;
		pl_data  : in  std_logic_vector;

		ip4len   : in  std_logic_vector(0 to 16-1);
		ip4sa    : in  std_logic_vector(0 to 32-1);
		ip4da    : in  std_logic_vector(0 to 32-1);
		ip4proto : in  std_logic_vector(0 to 8-1);

		ip4_ptr  : in  std_logic_vector;
		ip4_frm  : buffer std_logic;
		ip4_data : out std_logic_vector);
end;

architecture def of ipv4_tx is

	signal pllat_frm     : std_logic;
	signal pllat_irdy    : std_logic;
	signal pllat_trdy    : std_logic;
	signal pllat_data    : std_logic_vector(pl_data'range);

	signal cksm_txd      : std_logic_vector(ip4_txd'range);
	signal latcksm_txd   : std_logic_vector(ip4_txd'range);
	signal cksm_txen     : std_logic;
	signal cksmd_txd     : std_logic_vector(ip4_txd'range);
	signal cksmd_txen    : std_logic;
	signal cksm_init     : std_logic_vector(0 to 16-1);

	signal pllat_txd     : std_logic_vector(ip4_txd'range);
	signal pllat_txen    : std_logic;
	signal lenlat_txd    : std_logic_vector(ip4_txd'range);
	signal lenlat_txen   : std_logic;
	signal protolat_txen : std_logic;
	signal alat_txd      : std_logic_vector(ip4_txd'range);
	signal alat_txen     : std_logic;
	signal lat_txd       : std_logic_vector(ip4_txd'range);

	signal ip4shdr_frm   : std_logic;
	signal ip4shdr_irdy  : std_logic;
	signal ip4shdr_trdy  : std_logic_vector(ip4_txd'range);
	signal ip4shdr_data  : std_logic_vector(0 to ip4_shdr'length+ip4hdr_frame(ip4_proto)-1);

	signal ip4proto_txdv  : std_logic;
	signal ip4proto_txd   : std_logic_vector(ip4_txd'range);
	signal ip4proto_data  : std_logic_vector(0 to ip4hdr_frame(ip4_chksum)-1);

	signal ip4sa_txen    : std_logic;
	signal ip4sa_txd     : std_logic_vector(ip4_txd'range);
	signal ip4da_txen    : std_logic;
	signal ip4da_txd     : std_logic_vector(ip4_txd'range);
	signal ip4len_txen   : std_logic;
	signal ip4len_txd    : std_logic_vector(ip4_txd'range);


	constant myip4_len : natural :=  0;
	constant myip4_sa  : natural :=  1;
	constant myip4_da  : natural :=  2;

	constant myip4hdr_frame : natural_vector := (
		myip4_len => ip4hdr_frame(ip4_len),
		myip4_sa  => ip4hdr_frame(ip4_sa),
		myip4_da  => ip4hdr_frame(ip4_da));

begin

	pl_e : entity hdl4fpga.fifo
	generic map (
		fifo_depth => 
			summation(ip4hdr_frame)-
			ip4hdr_frame(ip4_len)-
			ip4hdr_frame(ip4_sa)-
			ip4hdr_frame(ip4_da)/pl_data'length,
		latency   => 0,
		check_sov => true,
		check_dov => true,
		gray_code => false)
	port map (
		src_clk   => mii_clk,
		src_irdy  => pl_irdy,
		src_trdy  => pl_trdy,
		src_data  => pl_data,
		dst_clk   => mii_clk,
		dst_irdy  => pllat_irdy,
		dst_trdy  => pllat_trdy,
		dst_data  => pllat_data);

	ip4shdr_txen <= not frame_decode(
		ip4_ptr,
	   	ip4hdr_frame, 
		ip4_txd'length,
	   	ip4_proto, gt) and ip4_txen;

	ip4shdr_data <= ip4_shdr & ip4proto;
	ip4shdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ip4shdr_data,
        sio_clk  => mii_clk,
        sio_frm  => ip4shdr_frm,
        sio_irdy => ip4shdr_irdy,
        sio_trdy => ip4shdr_trdy);
        so_end   => ip4shdr_end);
        so_data  => ip4shdr_data);

	ip4proto_data <= x"00" & ip4proto;
	ip4proto_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => ip4proto_data,
        sio_clk  => mii_clk,
        sio_frm  => ip4len_txen,
        sio_irdy => ip4proto_txdv,
        mii_txd  => ip4proto_txd);

	ip4len_txen <= frame_decode(ip4_ptr, myip4hdr_frame, ip4_txd'length, myip4_len) and ip4_txen;
	ip4len_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => ip4len,
        sio_clk  => mii_clk,
        mii_txdv => ip4len_txen,
        mii_txd  => ip4len_txd);

	ip4sa_txen <= frame_decode(ip4_ptr, myip4hdr_frame, ip4_txd'length, myip4_sa) and ip4_txen;
	ip4sa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => ip4sa,
        sio_clk  => mii_clk,
		mii_txdv => ip4sa_txen,
		mii_txd  => ip4sa_txd);

	ip4da_txen <= frame_decode(ip4_ptr, myip4hdr_frame, ip4_txd'length, myip4_da) and ip4_txen;
	ip4da_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ip4da,
		sio_clk  => mii_txc,
		mii_txdv => ip4da_txen,
		mii_txd  => ip4da_txd);

	lat_b : block
		signal pllat1_txen : std_logic;
		signal pllat2_txen : std_logic;
	begin
		
	mux_data  <= icmptype_rply & icmpcode_rply & icmp_cksm & icmp_id & icmp_seq;
	icmphdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => mii_clk,
		sio_frm  => icmp_frm,
		sio_irdy => icmp_trdy,
        sio_trdy => icmphdr_trdy,
        so_end   => icmphdr_end,
        so_data  => icmphdr_data);

		lat_txd  <= wirebus(latcksm_txd & pllat_txd, cksm_txen & pllat1_txen);
		iplenlat_e : entity hdl4fpga.mii_latency
		generic map (
			latency => 
				ip4hdr_frame(ip4_verihl)+
				ip4hdr_frame(ip4_tos))
		port map (
			mii_txc  => mii_txc,
			lat_txen => pllat1_txen,
			lat_txd  => lat_txd,
			mii_txen => pllat2_txen,
			mii_txd  => lenlat_txd);

		ipalat_e : entity hdl4fpga.mii_latency
		generic map (
			latency => 
				ip4hdr_frame(ip4_ident)+
				ip4hdr_frame(ip4_flgsfrg)+
				ip4hdr_frame(ip4_ttl)+
				ip4hdr_frame(ip4_proto)+
				ip4hdr_frame(ip4_chksum))
		port map (
			mii_txc  => mii_txc,
			lat_txen => pllat2_txen,
			lat_txd  => lenlat_txd,
			mii_txen => pllat_txen,
			mii_txd  => alat_txd);
		
	end block;
	
	xxx_b : block
		signal cy  : std_logic;
		signal sum : unsigned(0 to pl_txd'length+1);
		signal op1 : unsigned(pl_txd'range);
		signal op2 : unsigned(pl_txd'range);
	begin
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if pl_txen='0' then
					cy <= '0';
				else
					cy <= sum(0);
				end if;
			end if;
		end process;
		latcksm_txd <= wirebus(ip4len_txd & ip4sa_txd & ip4da_txd, ip4len_txen & ip4sa_txen & ip4da_txen);
		op1 <= unsigned(reverse(latcksm_txd));
		op2 <= unsigned(reverse((ip4proto_txd) and (pl_txd'range => ip4proto_txdv)));
		sum <= ('0' & op2  & '1') + ('0' & op1 & cy);
		cksm_txd <= not reverse(std_logic_vector(sum(1 to pl_txd'length)));
	end block;

	cksm_txen  <= frame_decode(ip4_ptr, myip4hdr_frame, ip4_txd'length, (myip4_len, myip4_sa, myip4_da)) and ip4_txen;
	cksmd_txen <= frame_decode(ip4_ptr, ip4hdr_frame, ip4_txd'length, ip4_chksum) and ip4_txen; 
	cksm_init  <= oneschecksum(not (ip4_shdr & x"00"), cksm_init'length);
	mii1checksum_e : entity hdl4fpga.mii_1chksum
	generic map (
		chksum_size => 16)
	port map (
		mii_txc   => mii_txc,
		mii_txen  => cksm_txen,
		mii_txd   => cksm_txd,

		cksm_init => cksm_init,
		cksm_txd  => cksmd_txd);

	lenlat_txen   <= frame_decode(ip4_ptr, ip4hdr_frame, ip4_txd'length, ip4_len) and to_stdulogic(to_bit(ip4_txen));
	protolat_txen <= frame_decode(ip4_ptr, ip4hdr_frame, ip4_txd'length, ip4_proto) and to_stdulogic(to_bit(ip4_txen));
	alat_txen     <= frame_decode(ip4_ptr, ip4hdr_frame, ip4_txd'length, (ip4_sa, ip4_da)) and to_stdulogic(to_bit(ip4_txen));

	ip4_txd <= wirebus(ip4shdr_txd & lenlat_txd & cksmd_txd & alat_txd, ip4shdr_txen & lenlat_txen & cksmd_txen & (alat_txen or to_stdulogic(to_bit(pllat_txen))));

end;
