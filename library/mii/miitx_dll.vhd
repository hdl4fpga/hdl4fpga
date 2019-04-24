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
		mii_txc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_txdv : out std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture mix of miitx_dll is
	constant crc32_size   : natural := 32;

	constant mii_pre : std_logic_vector := reverse(x"5555_5555_5555_55d5", 8);
	signal miipre_txd  : std_logic_vector(mii_txd'range);
	signal miipre_txdv : std_logic;

	signal minpkt_txdv : std_logic;
	signal minpkt_txd  : std_logic_vector(mii_rxd'range);

	signal miibuf_txdv : std_logic;
	signal miibuf_txd  : std_logic_vector(mii_txd'range);

	signal crc32_txd   : std_logic_vector(mii_txd'range);
	signal crc32_txdv  : std_logic;
	signal mii_ptr     : unsigned(0 to unsigned_num_bits(64*8/mii_txd'length)-1); -- := (others => '0');

	constant pre_bysiz : natural :=  mii_pre'length/mii_txd'length;
begin

	process (mii_txc)
		variable last_value : std_logic;
	begin
		if rising_edge(mii_txc) then
			if mii_rxdv='1' and last_value='0' then
				mii_ptr <= to_unsigned(crc32_size/mii_txd'length+1, mii_ptr'length);
			elsif mii_ptr(0)/='1' then
				mii_ptr <= mii_ptr + 1;
			end if;
			last_value := mii_rxdv;
		end if;
	end process;

	miitx_pre_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mii_pre)
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_rxdv,
		mii_txdv => miipre_txdv,
		mii_txd  => miipre_txd);

	minpkt_txd <= mii_rxd when mii_rxdv='1' else (minpkt_txd'range => '0');
	miishr_txd_e : entity hdl4fpga.align
	generic map (
		n  => mii_txd'length,
		d  => (1 to mii_txd'length => pre_bysiz))
	port map (
		clk => mii_txc,
		di  => minpkt_txd, --mii_rxd,
		do  => miibuf_txd);

	minpkt_txdv <= mii_rxdv or not mii_ptr(0);
	miishr_txdv_e : entity hdl4fpga.align
	generic map (
		n  => 1,
		d  => (1 to 1 => pre_bysiz))
	port map (
		clk   => mii_txc,
		di(0) => minpkt_txdv, --mii_rxdv,
		do(0) => miibuf_txdv);

	crc32_e : entity hdl4fpga.mii_crc32
	port map (
		mii_txc  => mii_txc,
		mii_rxd  => miibuf_txd,
		mii_rxdv => miibuf_txdv,
		mii_txdv => crc32_txdv,
		mii_txd  => crc32_txd);

	mii_txdv <= miipre_txdv or miibuf_txdv or crc32_txdv;
	mii_txd  <= wirebus (
		miipre_txd  & miibuf_txd & crc32_txd,
		miipre_txdv & miibuf_txdv & crc32_txdv);

end;
