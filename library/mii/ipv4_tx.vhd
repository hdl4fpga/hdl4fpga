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

		ipv4len_irdy   : out std_logic;
		ipv4len_data   : in  std_logic_vector;
		ipv4proto_irdy : out std_logic;
		ipv4proto_data : in  std_logic_vector;

		ipv4a_frm  : out std_logic;
		ipv4a_irdy : out std_logic;
		ipv4a_end  : in  std_logic;
		ipv4a_data : in  std_logic_vector;

		ipv4_frm  : buffer std_logic;
		ipv4_irdy : buffer std_logic;
		ipv4_trdy : in  std_logic;
		ipv4_end  : out std_logic;
		ipv4_data : out std_logic_vector);
end;

architecture def of ipv4_tx is

	function xxx (constant size : natural)
		return std_logic_vector is
		constant proto_base  : natural := summation(ipv4hdr_frame(ipv4hdr_frame'left to hdl4fpga.ipoepkg.ipv4_proto-1))/size;
		constant length_base : natural := summation(ipv4hdr_frame(ipv4hdr_frame'left to hdl4fpga.ipoepkg.ipv4_len-1))/size;
		variable retval : unsigned(0 to 3*summation(ipv4hdr_frame(ipv4hdr_frame'left to hdl4fpga.ipoepkg.ipv4_len-1))/size-1);
	begin
		retval := (others => '0');
		for i in ipv4hdr_frame'left to hdl4fpga.ipoepkg.ipv4_len-1 loop
			if length_base <= i and i < length_base+ipv4hdr_frame(hdl4fpga.ipoepkg.ipv4_len) then
				retval(0 to 3-1) := "001";
			elsif proto_base <= i and i < proto_base+ipv4hdr_frame(hdl4fpga.ipoepkg.ipv4_proto) then
				retval(0 to 3-1) := "010";
			else
				retval(0 to 3-1) := "100";
			end if;
			retval := retval rol 3;
		end loop;
		return std_logic_vector(retval);
	end;

	signal cksm_frm      : std_logic;
	signal cksm_irdy     : std_logic;
	signal cksm_data     : std_logic_vector(ipv4_data'range);
	signal chksum        : std_logic_vector(16-1 downto 0);

	signal ipv4hdr_irdy  : std_logic;
	signal ipv4hdr_trdy  : std_logic;
	signal ipv4hdr_end   : std_logic;
	signal ipv4hdr_mux   : std_logic_vector(0 to summation(
		ipv4hdr_frame(hdl4fpga.ipoepkg.ipv4_verihl to hdl4fpga.ipoepkg.ipv4_proto))-1);
	signal ipv4hdr_data  : std_logic_vector(ipv4_data'range);
	signal ipv4hdr1_data  : std_logic_vector(ipv4_data'range);

	signal ipv4sel_irdy  : std_logic;
	signal ipv4sel_trdy  : std_logic;
	signal ipv4sel_end   : std_logic;
	signal ipv4sel_data  : std_logic_vector(0 to 3-1);

	signal ipv4a_trdy    : std_logic;
	signal ipv4a_last    : std_logic;

	signal ipv4chsm_frm  : std_logic;
	signal ipv4chsm_irdy : std_logic;
	signal ipv4chsm_trdy : std_logic;
	signal ipv4chsm_end  : std_logic;
	signal ipv4chsm_data : std_logic_vector(ipv4_data'range);

	signal post : std_logic;
begin

	ipv4_frm <= pl_frm;
	post <= pl_frm and ipv4a_end;
	
	ipv4hdr_mux <=
		x"4500"            &   -- Version, TOS
		(0 to 16-1 => '-') &   -- Length
		x"0000"            &   -- Identification
		x"0000"            &   -- Fragmentation
		x"05"              &   -- Time To Live
		(0 to 8-1  => '-');

	ipv4hdr_irdy <= post and ipv4_trdy;
	ipv4hdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ipv4hdr_mux,
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => ipv4hdr_irdy,
		sio_trdy => ipv4hdr_trdy,
		so_end   => ipv4hdr_end,
		so_data  => ipv4hdr1_data);

	ipv4sel_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => xxx(pl_data'length),
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => ipv4hdr_irdy,
		sio_trdy => open,
		so_end   => open,
		so_data  => ipv4sel_data);

--	ipv4hdr1_data <= wirebus(ipv4hdr1_data & ipv4proto_data & ipv4len_data, ipv4

	ipv4a_frm  <= pl_frm when post='0' else pl_frm and ipv4hdr_end;
	ipv4a_irdy <= '1' when post='0' else ipv4_trdy;

	cksm_data <= primux(ipv4a_data & ipv4hdr1_data, not post & post);
	cksm_irdy <= primux(ipv4a_trdy & (ipv4hdr_trdy and not ipv4hdr_end), not post & post)(0);
	mii_1cksm_e : entity hdl4fpga.mii_1cksm
	generic map (
		cksm_init => x"0000")
	port map (
		mii_clk  => mii_clk,
		mii_frm  => pl_frm,
		mii_irdy => cksm_irdy,
		mii_data => cksm_data,
		mii_cksm => chksum);

	ipv4chsm_frm <= pl_frm and ipv4hdr_end;
	ipv4cksm_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => chksum,
        sio_clk  => mii_clk,
        sio_frm  => ipv4chsm_frm,
        sio_irdy => ipv4_trdy,
        sio_trdy => ipv4chsm_trdy,
        so_end   => ipv4chsm_end,
        so_data  => ipv4chsm_data);

	pl_trdy <= ipv4chsm_end and ipv4a_end and ipv4_trdy; 

	ipv4_irdy <= primux(
		'0'      & ipv4hdr_trdy     &     ipv4chsm_trdy & ipv4a_trdy     & pl_irdy,
		not post & not ipv4hdr_end  & not ipv4chsm_end  & not ipv4a_end  & '1')(0);
	ipv4_data <= primux(
		ipv4hdr_data    & ipv4chsm_data    &     ipv4a_data & pl_data,
		not ipv4hdr_end & not ipv4chsm_end & not ipv4a_end  & '1');
	ipv4_end  <= post and ipv4a_end and pl_end;
end;
