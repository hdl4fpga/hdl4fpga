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

		eth_pre    : buffer std_logic;
		hwda_irdy  : buffer std_logic;
		hwda_trdy  : in  std_logic := '1';
		hwda_end   : in  std_logic := '1';
		hwsa_irdy  : buffer std_logic;
		hwsa_trdy  : in  std_logic := '1';
		hwsa_end   : in  std_logic := '1';
		hwtyp_irdy : buffer std_logic;
		hwtyp_trdy : in  std_logic := '1';
		hwtyp_end  : in  std_logic := '1';
		pl_irdy    : out std_logic;
		pl_trdy    : in  std_logic := '1';

		crc_sb     : out std_logic;
		crc_equ    : out std_logic;
		crc_rem    : buffer std_logic_vector(0 to 32-1));
		
end;

architecture def of eth_rx is

	signal frm_ptr   : std_logic_vector(0 to unsigned_num_bits(summation(eth_frame)/mii_data'length-1));
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
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if eth_pre='0' then
				cntr := to_unsigned(summation(eth_frame)/mii_data'length-1, cntr'length);
			elsif cntr(0)='0' and mii_irdy='1' and mii_trdy='1' then
				cntr := cntr - 1;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	hwda_frm   <= eth_pre  and frame_decode(frm_ptr, reverse(eth_frame), mii_data'length, eth_hwda);
	hwsa_frm   <= eth_pre  and frame_decode(frm_ptr, reverse(eth_frame), mii_data'length, eth_hwsa);
	hwtyp_frm  <= eth_pre  and frame_decode(frm_ptr, reverse(eth_frame), mii_data'length, eth_type);
	pl_frm     <= eth_pre  and frm_ptr(0);
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

	mii_trdy <= 
	   hwda_trdy  when hwda_frm='1'  else
	   hwsa_trdy  when hwsa_frm='1'  else
	   hwtyp_trdy when hwtyp_frm='1' else
	   pl_trdy    when pl_frm='1'    else
	   '1';
end;

