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

entity miitx_rnd is
    port (
        mii_txc  : in  std_logic;
		mii_txi  : in  std_logic_vector;
		mii_txiv : in  std_logic;
		mii_txd  : out std_logic_vector;
		mii_txdv : out std_logic);
end;

architecture def of miitx_rnd is
	constant mii_pre : std_logic_vector := reverse(x"5555_5555_5555_55d5", 8);

	signal miipre_trdy : std_logic;
	signal miipre_txdv : std_logic;
	signal miipre_txd  : std_logic_vector(mii_txd'range);
	signal miicrc_txen : std_logic;
	signal miicrc_txd  : std_logic_vector(mii_txd'range);
	signal miibuf_txiv : std_logic;
	signal miibuf_txi  : std_logic_vector(mii_txd'range);
	signal miibuf_txd  : std_logic_vector(mii_txd'range);
	signal miibuf_txdv : std_logic;
begin

	mii_fcs_e : entity hdl4fpga.miitx_crc32
    port map (
        mii_txc   => mii_txc,
		mii_txiv  => mii_txiv,
		mii_txi   => mii_txi,
		mii_txen  => miicrc_txen,
		mii_txd   => miicrc_txd);

	miibuf_txiv <= mii_txiv or miicrc_txen;
	miibuf_txi  <= word2byte(mii_txi & miicrc_txd, mii_txiv);

	miitx_pre_e  : entity hdl4fpga.mii_mem
	generic map (
		mem_data => mii_pre)
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_txiv,
		mii_trdy => miipre_trdy,
		mii_txen => miipre_txdv,
		mii_txd  => miipre_txd);

	miibuf_txd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (1 to mii_txd'length => mii_pre'length/mii_txd'length))
	port map (
		clk => mii_txc,
		ena => miibuf_txiv,
		di  => miibuf_txi,
		do  => miibuf_txd);

	mii_txdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (1 to 1 => mii_pre'length/mii_txd'length))
	port map (
		clk   => mii_txc,
		di(0) => miibuf_txiv,
		do(0) => miibuf_txdv);

	mii_txd  <= word2byte(miipre_txd  & miibuf_txd,  not miipre_trdy);
	mii_txdv <= word2byte(miipre_txdv & miibuf_txdv, not miipre_trdy)(0);
end;

