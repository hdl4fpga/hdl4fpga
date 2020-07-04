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
	generic (
		hwsa     : in  std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_txc  : in  std_logic;
		pl_txen  : in  std_logic;
		pl_txd   : in  std_logic_vector;
		eth_txen : out std_logic;
		eth_txd  : out std_logic_vector);

end;

architecture def of eth_tx is

	signal hwda_trdy : std_logic;
	signal hwda_txen : std_logic;
	signal hwda_txd  : std_logic_vector(eth_txd'range);

	signal hwsa_trdy : std_logic;
	signal hwsa_txen : std_logic;
	signal hwsa_txd  : std_logic_vector(eth_txd'range);

	constant lat_length : natural := (eth_frame(eth_hwda)+eth_frame(eth_hwsa))/eth_txd'length;
	signal lat_txen  : std_logic;
	signal lat_txd   : std_logic_vector(eth_txd'range);

	signal padd_txen  : std_logic;
	signal padd_txd   : std_logic_vector(eth_txd'range);

	signal dll_txen  : std_logic;
	signal dll_txd   : std_logic_vector(eth_txd'range);

begin

	padding_p : process (mii_txc, pl_txen)
		variable cntr : unsigned(0 to unsigned_num_bits(64*8/eth_txd'length-1));
	begin
		if rising_edge(mii_txc) then
			if cntr(0)='0' then
				cntr := cntr + 1;
			elsif pl_txen='1' then
				cntr := to_unsigned((2*6+4)*8/eth_txd'length+1, cntr'length); 
			end if;
		end if;
		padd_txen <= not cntr(0) or pl_txen;
	end process;
	padd_txd  <= pl_txd when pl_txen='1' else (padd_txd'range => '0');

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

	hwda_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => padd_txen,
		mii_trdy => hwda_trdy,
		mii_txen => hwda_txen,
		mii_txd  => hwda_txd);

	hwsa_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(hwsa, 8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => hwda_trdy,
		mii_trdy => hwsa_trdy,
		mii_txen => hwsa_txen,
		mii_txd  => hwsa_txd);

	dll_txd  <= primux (hwda_txd & hwsa_txd & lat_txd, hwda_txen & hwsa_txen & lat_txen);
	dll_txen <= hwda_txen or hwsa_txen or lat_txen;

	dll_e : entity hdl4fpga.eth_dll
	port map (
		mii_txc  => mii_txc,
		dll_txen => dll_txen,
		dll_txd  => dll_txd,
		mii_txen => eth_txen,
		mii_txd  => eth_txd);

end;

