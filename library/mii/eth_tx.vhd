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

entity eth_tx is
	port (
		mii_txc  : in  std_logic;
		eth_ptr  : in  std_logic_vector;

		pl_txen  : in  std_logic;
		pl_txd   : in  std_logic_vector;

		hwsa     : in  std_logic_vector;
		hwda     : in  std_logic_vector;
		llc      : in  std_logic_vector;

		eth_txen : buffer std_logic;
		eth_txd  : out std_logic_vector);

end;

architecture def of eth_tx is

	signal llc_txen : std_logic;
	signal llc_txd  : std_logic_vector(eth_txd'range);

	signal hwda_txen : std_logic;
	signal hwda_txd  : std_logic_vector(eth_txd'range);

	signal hwsa_txen : std_logic;
	signal hwsa_txd  : std_logic_vector(eth_txd'range);

	constant lat_length : natural := summation(eth_frame)/eth_txd'length;
	signal lat_txen  : std_logic;
	signal lat_txd   : std_logic_vector(eth_txd'range);

	signal padd_txen  : std_logic;
	signal padd_txd   : std_logic_vector(eth_txd'range);

	signal dll_txen  : std_logic;
	signal dll_txd   : std_logic_vector(eth_txd'range);


begin

	hwda_txen <= frame_decode(eth_ptr, eth_frame, eth_txd'length, eth_hwda) and pl_txen;
	hwsa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => hwsa,
		mii_txc  => mii_txc,
		mii_txdv => hwsa_txen,
		mii_txd  => hwsa_txd);

	hwsa_txen <= frame_decode(eth_ptr, eth_frame, eth_txd'length, eth_hwsa) and pl_txen;
	hwda_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => hwda,
		mii_txc  => mii_txc,
		mii_txdv => hwda_txen,
		mii_txd  => hwda_txd);

	llc_txen <= frame_decode(eth_ptr, eth_frame, eth_txd'length, eth_type) and pl_txen;
	llc_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => llc,
		mii_txc  => mii_txc,
		mii_txdv => llc_txen,
		mii_txd  => llc_txd);

	padding_p : process (mii_txc, pl_txen, lat_txen)
		variable txen : std_logic;
		variable cntr : unsigned(0 to unsigned_num_bits(64*octect_size/eth_txd'length-1)) := (others => '1');
	begin
		if rising_edge(mii_txc) then
			if pl_txen='1' then
				if txen='0' then
					cntr := to_unsigned((2*6+4)*8/eth_txd'length+1, cntr'length); 
				elsif cntr(0)='0' then
					cntr := cntr + 1;
				end if;
				txen := '1';
			elsif cntr(0)='0' then
				cntr := cntr + 1;
				txen := '1';
			elsif lat_txen='1' then
				txen := '0';
			end if;

		end if;
		padd_txen <= (pl_txen or not cntr(0)) or txen or lat_txen;
	end process;
	padd_txd <= pl_txd when pl_txen='1' else (padd_txd'range => '0');

	lattxd_e : entity hdl4fpga.align
	generic map (
		n => eth_txd'length,
		d => (0 to eth_txd'length-1 => lat_length))
	port map (
		clk => mii_txc,
		di  => padd_txd, 
		do  => lat_txd);

	lattxdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to eth_txd'length-1 => lat_length),
		i => (0 to eth_txd'length-1 => '0'))
	port map (
		clk   => mii_txc,
		di(0) => padd_txen,
		do(0) => lat_txen);

	dll_txd  <= wirebus (hwda_txd & hwsa_txd & llc_txd & lat_txd, hwda_txen & hwsa_txen & llc_txen & lat_txen);
	dll_txen <= hwda_txen or hwsa_txen or llc_txen or lat_txen;

	dll_e : entity hdl4fpga.eth_dll
	port map (
		mii_txc  => mii_txc,
		dll_txen => dll_txen,
		dll_txd  => dll_txd,
		mii_txen => eth_txen,
		mii_txd  => eth_txd);

end;

