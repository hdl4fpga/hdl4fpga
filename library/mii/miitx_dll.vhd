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

	signal miibuf1_rxdv : std_logic;
	signal miibuf1_rxd  : std_logic_vector(mii_txd'range);

	signal rxdv2        : std_logic;
	signal rxd2         : std_logic_vector(mii_txd'range);

	function encoder (
		constant arg : std_logic_vector)
		return   std_logic_vector is
--		variable val : std_logic_vector(0 to unsigned_num_bits(arg'length-1)-1) := (others => '0');
		variable val : std_logic_vector(0 to 2-1) := (others => '0');
		variable aux : unsigned(0 to arg'length-1) := (0 => '1', others => '0');
	begin
		for i in aux'range loop
			if arg=std_logic_vector(aux) then
				val := std_logic_vector(to_unsigned(i, val'length));
			end if;
			aux := aux ror 1;
		end loop;
		return val;
	end;

begin
	crc32_b : block
		constant mii_pre2   : std_logic_vector := reverse(x"5555_55d5", 8);

		signal rxdv         : std_logic;
		signal rxd          : std_logic_vector(mii_txd'range);

		signal miipre2_txd  : std_logic_vector(mii_txd'range);
		signal miipre2_txdv : std_logic;

		signal miibuf2_rxdv : std_logic;
		signal miibuf2_rxd  : std_logic_vector(mii_txd'range);

		signal crc32_txd    : std_logic_vector(mii_txd'range);
		signal crc32_txdv   : std_logic;

	begin
		rxd  <= word2byte(mii_rxd, encoder(mii_rxdv), mii_txd'length);
--		process (mii_rxd, mii_rxdv)
--			variable arxdv : unsigned(0 to mii_rxdv'length-1);
--			variable arxd  : unsigned(0 to mii_rxd'length-1);
--			variable atxd  : unsigned(0 to mii_txd'length-1);
--		begin
--			arxd  := unsigned(mii_rxd);
--			arxdv := unsigned(mii_rxdv);
--			atxd  := (others => '0');
--			for i in arxdv'range loop
--				if arxdv(0)='1' then
--					atxd := atxd or arxd(atxd'range);
--				end if;
--				arxd  := arxd  rol atxd'length;
--				arxdv := arxdv rol 1;
--			end loop;
--			rxd <= std_logic_vector(atxd);
--		end process;
--		rxd  <= word2byte(x"6699", encoder(mii_rxdv), mii_txd'length);

		process (mii_rxdv)
		begin
			rxdv <= '0';
			for i in mii_rxdv'range loop
				if mii_rxdv(i)='1'  then
					rxdv <= '1';
					exit;
				end if;
			end loop;
		end process;
--		rxdv <= setif(mii_rxdv /= (mii_rxdv'range => '0'));

		miitx_pre2_e  : entity hdl4fpga.mii_rom
		generic map (
			mem_data => mii_pre2)
		port map (
			mii_txc  => mii_txc,
			mii_treq => rxdv,
			mii_txdv => miipre2_txdv,
			mii_txd  => miipre2_txd);

		miishr_txd_e : entity hdl4fpga.align
		generic map (
			n   => mii_txd'length,
			d   => (1 to mii_txd'length => mii_pre2'length/mii_txd'length))
		port map (
			clk => mii_txc,
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

		crc32_e : entity hdl4fpga.mii_crc32
		port map (
			mii_txc  => mii_txc,
			mii_rxd  => miibuf2_rxd,
			mii_rxdv => miibuf2_rxdv,
			mii_txdv => crc32_txdv,
			mii_txd  => crc32_txd);

		rxdv2 <= word2byte(miipre2_txdv & (miibuf2_rxdv or crc32_txdv), not miipre2_txdv)(0);
		rxd2  <= word2byte(miipre2_txd  & word2byte(miibuf2_rxd  & crc32_txd , not miibuf2_rxdv), not miipre2_txdv);
	end block;

	miitx_pre1_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mii_pre1)
	port map (
		mii_txc  => mii_txc,
		mii_treq => rxdv2,
		mii_txdv => miipre1_txdv,
		mii_txd  => miipre1_txd);

	miishr_txd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (1 to mii_txd'length => mii_pre1'length/mii_txd'length))
	port map (
		clk => mii_txc,
		di  => rxd2,
		do  => miibuf1_rxd);

	mii_txdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (1 to 1 => mii_pre1'length/mii_txd'length))
	port map (
		clk   => mii_txc,
		di(0) => rxdv2,
		do(0) => miibuf1_rxdv);

	mii_txd  <= word2byte(miipre1_txd  & miibuf1_rxd,   not miipre1_txdv);
	mii_txdv <= word2byte(miipre1_txdv & miibuf1_rxdv,  not miipre1_txdv)(0);

end;
