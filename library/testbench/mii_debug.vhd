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
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mii_debug of testbench is
	constant n : natural := 8;
	signal rst   : std_logic := '1';
	signal clk   : std_logic := '1';
	signal rrxd  : std_logic_vector(0 to n-1);
	signal rxd   : std_logic_vector(0 to n-1);
	signal rxd1  : std_logic_vector(0 to n-1);
	signal rxd2  : std_logic_vector(0 to n-1);
	signal rxdv  : std_logic;
	signal rxdv1 : std_logic;
	signal rxdv2 : std_logic;

	signal txdv  : std_logic;
	signal treq1 : std_logic;
	signal treq2 : std_logic;
	signal txd   : std_logic_vector(0 to n-1);
	signal trdy1 : std_logic;
	signal rtxd  : std_logic_vector(txd'range);

begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 20 ns;

	process (clk)
		variable edge  : std_logic;
	begin
		if rising_edge(clk) then
			treq1 <= '1';
			if rst='1' then
				treq1 <= '0';
			elsif txdv='0'  then
				if edge='1' then
				--	treq1 <= '0';
				end if;
			end if;
			edge := txdv;
			treq2 <=  trdy1;
		end if;
	end process;

	
	miidhcp_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(
			x"5555_5555_5555_55d5" &
			x"00_40_00_01_02_03"   & 
			x"00_25_00_00_00_ff"   &
			x"08_00"               & 
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"00_11_00_00"         &
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"00_43_00_44"         &
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"00_00_00_00"         &
			x"c0_a8_00_49"         &
			x"0b_00_00_00_00_ff",
			8))
	port map (
		mii_txc  => clk,
		mii_treq => treq1,
		mii_trdy => trdy1,
		mii_txdv => rxdv1,
		mii_txd  => rxd1);

	miipkt_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(
			x"5555_5555_5555_55d5" &
--            x"004000010203"        &
            x"ffffffffffff"        &
			x"16987d31a4c6"        &
			x"0806"                &
			x"00010800"            &
			x"06040001"            &
			x"16987d31a4c6"        &
			x"c0a80001"            &
			x"000000000000"        &
			x"c0a80049"            &
			x"000000000000000000000000000000000000" &
			x"00000000000000000000", 8))
	port map (
		mii_txc  => clk,
		mii_treq => treq2,
		mii_trdy => open,
		mii_txdv => rxdv2,
		mii_txd  => rxd2);

	rxd  <= rxd2  when trdy1='1' else rxd1;
	rxdv <= rxdv2 when trdy1='1' else rxdv1;

	rrxd <= reverse(rxd);
--	du : entity hdl4fpga.mii_debug
	du : entity hdl4fpga.mii_debug
	port map (
        mii_rxc  => clk,
		mii_rxdv => rxdv,
		mii_rxd  => rxd,

        mii_txc  => clk,
		mii_txd  => txd,
		mii_txdv => txdv,
		mii_req  => '0', --treq1,
	
		video_clk => '0');
	rtxd <= reverse(txd);
end;
