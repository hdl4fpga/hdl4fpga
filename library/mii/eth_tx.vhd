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

entity eth_tx is
	port (
		mii_clk  : in  std_logic;

		pl_frm   : in std_logic;
		pl_irdy  : in std_logic := '1';
		pl_trdy  : buffer std_logic;
		pl_end   : in std_logic;
		pl_data  : in std_logic_vector;

		hwllc_irdy : buffer std_logic;
		hwllc_trdy : in std_logic := '1';
		hwllc_end  : in std_logic;
		hwllc_data : in std_logic_vector;

		mii_frm  : buffer std_logic;
		mii_irdy : buffer std_logic;
		mii_trdy : in  std_logic := '1';
		mii_end  : buffer std_logic;
		mii_data : out std_logic_vector);

end;

architecture def of eth_tx is

	signal pre_trdy : std_logic;
	signal pre_end  : std_logic;
	signal pre_data : std_logic_vector(mii_data'range);

	signal minpkt   : std_logic;

	signal fcs_irdy : std_logic;
	signal fcs_mode : std_logic;
	signal fcs_data : std_logic_vector(mii_data'range);
	signal fcs_end  : std_logic;
	signal fcs_crc  : std_logic_vector(0 to 32-1);

		signal cntr1 : unsigned(0 to unsigned_num_bits(64*8/mii_data'length-1));
begin

	mii_frm <= pl_frm;
	pre_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(x"5555_5555_5555_55d5", 8),
		sio_clk  => mii_clk,
		sio_frm  => mii_frm,
		sio_irdy => mii_trdy,
		sio_trdy => pre_trdy,
		so_end   => pre_end,
		so_data  => pre_data);

	process(mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(64*8/mii_data'length-1));
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := to_unsigned((64*8-32)/mii_data'length-1, cntr'length);
			elsif mii_trdy='1' and pre_end='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			cntr1  <= cntr;
			minpkt <= '1'; --cntr(0);
		end if;
	end process;

	hwllc_irdy <= mii_trdy and pre_end;

	pl_trdy  <= hwllc_end and mii_trdy;
	fcs_irdy <= primux(hwllc_irdy & (pl_irdy and mii_trdy), not hwllc_end & not pl_end, (0 to 0 => mii_trdy))(0);
	fcs_data <= primux(hwllc_data & pl_data, not hwllc_end & not pl_end, (pl_data'range => '0'));

	process (mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(fcs_crc'length/mii_data'length-1));
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := (others => '0');
			elsif pl_end='1' and minpkt='1' and cntr(0)='0' then
				if fcs_irdy='1' then
					cntr := cntr + 1; 
				end if;
			end if;
			fcs_end <= cntr(0);
		end if;
	end process;

	fcs_mode <= pl_end and minpkt;
	fcs_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => mii_frm,
		irdy => fcs_irdy,
		mode => fcs_mode,
		data => fcs_data,
		crc  => fcs_crc);

	mii_irdy <= primux(pre_trdy & hwllc_trdy & pl_irdy,
		not pre_end   & 
		not hwllc_end & 
		not pl_end , "1")(0);
	mii_data <= primux(
		pre_data     & hwllc_data    & pl_data    & (pl_data'range => '0'),
		not  pre_end & not hwllc_end & not pl_end & not minpkt,
		fcs_crc(mii_data'range));
	mii_end <= fcs_end;

end;

