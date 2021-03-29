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

entity eth_rx is
	port (
		mii_clk    : in  std_logic;
		mii_frm    : in  std_logic;
		mii_irdy   : in  std_logic;
		mii_trdy   : buffer std_logic;
		mii_data   : in  std_logic_vector;

		eth_ptr    : buffer std_logic_vector;
		eth_pre    : buffer std_logic;
		hwda_irdy  : buffer std_logic;
		hwda_trdy  : in  std_logic;
		hwsa_irdy  : buffer std_logic;
		hwsa_trdy  : in  std_logic;
		hwtyp_irdy : buffer std_logic;
		hwtyp_trdy : in  std_logic;
		pl_irdy    : out std_logic;
		pl_trdy    : in  std_logic;

		crc_sb     : out std_logic;
		crc_equ    : out std_logic;
		crc_rem    : buffer std_logic_vector(0 to 32-1));
		
end;

architecture def of eth_rx is

	signal hwda_frm  : std_logic;
	signal hwsa_frm  : std_logic;
	signal hwtyp_frm : std_logic;
	signal pl_frm    : std_logic;
	signal crc_frm   : std_logic;
	signal crc_irdy  : std_logic;

begin

	mii_pre_e : entity hdl4fpga.mii_rxpre 
	port map (
		mii_clk  => mii_clk,
		mii_frm  => mii_frm,
		mii_irdy => mii_irdy,
		mii_data => mii_data,
		mii_pre  => eth_pre);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if eth_pre='0' then
				eth_ptr <= (eth_ptr'range => '0');
			elsif eth_ptr(eth_ptr'left)='0' and mii_irdy='1' and mii_trdy='1' then
				eth_ptr <= std_logic_vector(unsigned(eth_ptr) + 1);
			end if;
		end if;
	end process;

	hwda_frm   <= eth_pre  and frame_decode(eth_ptr, eth_frame, mii_data'length, eth_hwda);
	hwsa_frm   <= eth_pre  and frame_decode(eth_ptr, eth_frame, mii_data'length, eth_hwsa);
	hwtyp_frm  <= eth_pre  and frame_decode(eth_ptr, eth_frame, mii_data'length, eth_type);
	pl_frm     <= eth_pre  and frame_decode(eth_ptr, eth_frame, mii_data'length, eth_type, gt);
	hwda_irdy  <= mii_irdy and hwda_frm;
	hwsa_irdy  <= mii_irdy and hwsa_frm;
	hwtyp_irdy <= mii_irdy and hwtyp_frm;
	pl_irdy    <= mii_irdy and pl_frm;

	crc_frm  <= mii_frm and eth_pre;
	crc_irdy <= mii_irdy;
	crc_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => crc_frm,
		irdy => crc_irdy,
		data => mii_data,
		crc  => crc_rem);

	process (mii_frm, mii_clk)
		variable q : bit;
	begin
		if rising_edge(mii_clk) then
			q := to_bit(mii_frm);
		end if;
		crc_sb <= to_stdulogic(q) and not to_stdulogic(to_bit(mii_frm));
	end process;
	crc_equ <= setif(crc_rem=x"38fb2284");

	mii_trdy <= wirebus(hwda_trdy & hwsa_trdy & hwtyp_trdy & pl_trdy, hwda_frm & hwsa_frm & hwtyp_frm & pl_frm)(0);
end;

