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

entity miitx_dll is
	port (
		mii_txc   : in  std_logic;
		mii_rxdv  : in  std_logic_vector;
		mii_rxd   : in  std_logic_vector;
		mii_txdv  : out std_logic;
		mii_txd   : out std_logic_vector);
end;

architecture mix of miitx_dll is
	constant mii_pre1   : std_logic_vector := reverse(x"5555_5555", 8);

	signal miipre1_txd  : std_logic_vector(mii_txd'range);
	signal miipre1_txdv : std_logic;
	signal miipre1_trdy : std_logic;

	signal rxdv         : std_logic;
	signal rxd          : std_logic_vector(mii_txd'range);

	signal miibuf1_rxdv : std_logic;
	signal miibuf1_rxd  : std_logic_vector(mii_txd'range);

begin
	crc32_b : block
		constant mii_pre2   : std_logic_vector := reverse(x"5555_55d5", 8);

		signal miipre2_txd  : std_logic_vector(mii_txd'range);
		signal miipre2_txdv : std_logic;
		signal miipre2_trdy : std_logic;

		signal miibuf2_rxdv : std_logic;
		signal miibuf2_rxd  : std_logic_vector(mii_txd'range);

		signal crc32_txd    : std_logic_vector(mii_txd'range);
		signal crc32_txdv   : std_logic;
		signal crc32_trdy   : std_logic;

	begin
		rxd  <= word2byte(mii_rxd, encoder(mii_rxdv), mii_txd'length);
		rxdv <= not setif(mii_rxdv /= (mii_rxdv'range => '0'));

		miitx_pre2_e  : entity hdl4fpga.mii_rom
		generic map (
			mem_data => mii_pre2)
		port map (
			mii_txc  => mii_txc,
			mii_treq => rxdv,
			mii_trdy => miipre2_trdy,
			mii_txdv => miipre2_txdv,
			mii_txd  => miipre2_txd);

		miishr_txd_e : entity hdl4fpga.align
		generic map (
			n   => mii_txd'length,
			d   => (1 to mii_txd'length => mii_pre2'length/mii_txd'length))
		port map (
			clk => mii_txc,
			ena => rxdv,
			di  => rxd,
			do  => miibuf2_rxd);

		mii_txdv_e : entity hdl4fpga.align
		generic map (
			n     => 1,
			d     => (1 to 1 => mii_pre2'length/mii_txd'length))
		port map (
			clk   => mii_txc,
			di(0) => rxdv,
			do(0) => miibuf2_rxdv);

		crc32_e : entity hdl4fpga.miitx_crc32
		port map (
			mii_txc  => mii_txc,
			mii_rxd  => miibuf2_rxd,
			mii_rxdv => miibuf2_rxdv,
			mii_txdv => crc32_txdv,
			mii_txd  => crc32_txd);

		miibuf1_rxdv <= miibuf2_rxdv or crc32_txdv;
		miibuf1_rxd  <= word2byte(miibuf2_rxd & crc32_txd, not miibuf2_rxdv);
	end block;

	miitx_pre1_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mii_pre1)
	port map (
		mii_txc  => mii_txc,
		mii_treq => rxdv,
		mii_trdy => miipre1_trdy,
		mii_txdv => miipre1_txdv,
		mii_txd  => miipre1_txd);

	miishr_txd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (1 to mii_txd'length => mii_pre1'length/mii_txd'length))
	port map (
		clk => mii_txc,
		ena => rxdv,
		di  => rxd,
		do  => miibuf1_rxd);

	mii_txdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (1 to 1 => mii_pre1'length/mii_txd'length))
	port map (
		clk   => mii_txc,
		di(0) => rxdv,
		do(0) => miibuf1_rxdv);

	mii_txd  <= word2byte(miipre1_txd & miibuf1_rxd , miipre1_trdy);
	mii_txdv <= miipre1_txdv or miibuf1_rxdv;

end;
