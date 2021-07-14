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
		mii_clk : in  std_logic;

		pl_frm  : in  std_logic;
		pl_irdy : in  std_logic;
		pl_trdy : out std_logic;
		pl_end  : in  std_logic;
		pl_data : in  std_logic_vector;

		ipv4len_irdy   : buffer std_logic;
		ipv4len_data   : in  std_logic_vector;
		ipv4proto_irdy : buffer std_logic;
		ipv4proto_trdy : in  std_logic;
		ipv4proto_end  : in  std_logic;
		ipv4proto_data : in  std_logic_vector;

		ipv4a_frm  : out std_logic;
		ipv4a_irdy : buffer std_logic;
		ipv4a_end  : in  std_logic;
		ipv4a_data : in  std_logic_vector;

		ipv4_frm  : buffer std_logic;
		nettx_full : in std_logic;
		ipv4_irdy : buffer std_logic;
		ipv4_trdy : in  std_logic;
		ipv4_end  : out std_logic;
		ipv4_data : out std_logic_vector);
end;

architecture def of ipv4_tx is
	signal ipv4shdr_frm  : std_logic;
	signal ipv4proto_frm : std_logic;
	signal ipv4len_frm   : std_logic;

	signal cksm_irdy     : std_logic;
	signal cksm_data     : std_logic_vector(ipv4_data'range);
	signal chksum        : std_logic_vector(0 to 16-1);
	signal chksum_rev    : std_logic_vector(16-1 downto 0);

	signal ipv4shdr_irdy : std_logic;
	signal ipv4shdr_trdy : std_logic;
	signal ipv4shdr_end  : std_logic;
	signal ipv4shdr_mux  : std_logic_vector(0 to summation(
		ipv4hdr_frame(ipv4_verihl to ipv4_ttl))-ipv4hdr_frame(ipv4_len)-1);
	signal ipv4shdr_data : std_logic_vector(ipv4_data'range);
	signal ipv4hdr_data  : std_logic_vector(ipv4_data'range);

	signal ipv4sel_irdy  : std_logic;
	signal ipv4sel_trdy  : std_logic;
	signal ipv4sel_end   : std_logic;
	signal ipv4sel_data  : std_logic_vector(0 to 3-1);

	signal ipv4a_trdy    : std_logic := '1';
	signal ipv4a_last    : std_logic;

	signal ipv4chsm_frm  : std_logic;
	signal ipv4chsm_irdy : std_logic;
	signal ipv4chsm_trdy : std_logic;
	signal ipv4chsm_end  : std_logic;
	signal ipv4chsm_data : std_logic_vector(ipv4_data'range);

	signal post : std_logic;

	signal frm_ptr : std_logic_vector(0 to unsigned_num_bits(summation(ipv4hdr_frame)/ipv4_data'length-1));
begin

	ipv4_frm <= pl_frm;
	process(pl_frm, ipv4a_end, mii_clk)
		variable q : std_logic;
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				q := '0';
			elsif ipv4a_end='1' then
				q := '1';
			end if;
		end if;
		post <= q or (pl_frm and ipv4a_end);
	end process;
	
	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := to_unsigned(summation(ipv4hdr_frame)/ipv4_data'length-1, cntr'length);
			elsif cntr(0)='0' and post='1' and pl_irdy='1' and ipv4_trdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	ipv4shdr_frm  <= post and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, (ipv4_verihl, ipv4_tos, ipv4_ident, ipv4_flgsfrg, ipv4_ttl));
	ipv4proto_frm <= post and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_proto);
	ipv4len_frm   <= post and frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_len);

	ipv4shdr_irdy  <= ipv4shdr_frm  and ipv4_trdy;
	ipv4proto_irdy <= ipv4proto_frm and ipv4_trdy;
	ipv4len_irdy   <= ipv4len_frm   and ipv4_trdy;

	ipv4shdr_mux <= reverse(
		x"4500"            &   -- Version, TOS
		x"0000"            &   -- Identification
		x"0000"            &   -- Fragmentation
		x"05",                 -- Time To Live
		8);

	ipv4shdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ipv4shdr_mux,
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => ipv4shdr_irdy,
		sio_trdy => ipv4shdr_trdy,
		so_end   => ipv4shdr_end,
		so_data  => ipv4shdr_data);

	ipv4hdr_data <= wirebus(ipv4shdr_data & ipv4proto_data & reverse(ipv4len_data), ipv4shdr_frm & ipv4proto_frm & ipv4len_frm);

	ipv4a_frm  <= pl_frm when post='0' else pl_frm and ipv4chsm_end;
	ipv4a_irdy <= 
		'0' when nettx_full='0' else 
		'1' when post='0' else 
		ipv4_trdy;

	cksm_data <= primux(ipv4a_data & ipv4hdr_data, not post & post);
	cksm_irdy <= primux((ipv4a_trdy and ipv4a_irdy) & (ipv4_trdy and not ipv4proto_end), not post & post)(0);
	mii_1cksm_e : entity hdl4fpga.mii_1cksm
	port map (
		mii_clk  => mii_clk,
		mii_frm  => pl_frm,
		mii_irdy => cksm_irdy,
		mii_data => cksm_data,
		mii_cksm => chksum);

	ipv4chsm_frm <= pl_frm and ipv4proto_end;
	chksum_rev <= not reverse(chksum, 8);
	ipv4cksm_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => chksum_rev,
        sio_clk  => mii_clk,
        sio_frm  => ipv4chsm_frm,
        sio_irdy => ipv4_trdy,
        sio_trdy => ipv4chsm_trdy,
        so_end   => ipv4chsm_end,
        so_data  => ipv4chsm_data);

	pl_trdy <= ipv4chsm_end and ipv4a_end and ipv4_trdy; 

	ipv4_irdy <= 
		'1' when nettx_full='0' else 
		primux(
		'0'      & ipv4shdr_trdy     &     ipv4proto_trdy &     ipv4chsm_trdy & ipv4a_trdy     & pl_irdy,
		not post & not ipv4shdr_end  & not ipv4proto_end  & not ipv4chsm_end  & not ipv4a_end  & '1')(0);
	ipv4_data <=  
		pl_data when nettx_full='0' else 
		primux(
		ipv4hdr_data     &     ipv4proto_data & ipv4chsm_data    &     ipv4a_data,
		not ipv4shdr_end & not ipv4proto_end  & not ipv4chsm_end & not ipv4a_end,
		pl_data);
	ipv4_end  <= 
		'0' when nettx_full='0' else 
		post and ipv4a_end and pl_end;
end;
