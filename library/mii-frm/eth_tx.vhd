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
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : buffer std_logic;
		pl_end   : in  std_logic;
		pl_data  : in  std_logic_vector;

		hwsa     : in  std_logic_vector;
		hwda     : in  std_logic_vector;
		hwtyp    : in  std_logic_vector;

		eth_frm  : buffer std_logic;
		eth_irdy : buffer std_logic;
		eth_trdy : in  std_logic;
		eth_end  : out std_logic;
		eth_data : out std_logic_vector);

end;

architecture def of eth_tx is

	signal pre_trdy : std_logic;
	signal pre_end  : std_logic;
	signal pre_data : std_logic_vector(eth_data'range);

	signal llc_mux  : std_logic_vector(0 to hwsa'length+hwda'length+hwtyp'length-1);
	signal llc_irdy : std_logic;
	signal llc_trdy : std_logic;
	signal llc_end  : std_logic;
	signal llc_data : std_logic_vector(eth_data'range);

	signal fcs_irdy : std_logic;
	signal fcs_trdy : std_logic;
	signal fcs_mode : std_logic;
	signal fcs_data : std_logic_vector(eth_data'range);
	signal fcs_end  : std_logic;
	signal fcs_crc  : std_logic_vector(0 to 32-1);

begin

	eth_frm <= pl_frm;
	pre_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(x"5555_5555_5555_55d5", 8),
		sio_clk  => mii_clk,
		sio_frm  => eth_frm,
		sio_irdy => eth_trdy,
		sio_trdy => pre_trdy,
		so_end   => pre_end,
		so_data  => pre_data);

	llc_mux  <= hwda & hwsa & hwtyp;
	llc_irdy <= eth_trdy and pre_end;
	llc_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => llc_mux,
		sio_clk  => mii_clk,
		sio_frm  => eth_frm,
		sio_irdy => llc_irdy,
		so_end   => llc_end,
		so_data  => llc_data);

	fcs_data <= wirebus(llc_data & pl_data, not llc_end & llc_end);
	fcs_irdy <= wirebus(llc_irdy & pl_irdy & eth_trdy, 
		not llc_end              &
		(not pl_end and llc_end) & 
		pl_end)(0);

	process (mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(fcs_crc'length/eth_data'length-1));
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				if cntr(0)='0' then
					cntr := (others => '1');
				end if;
			elsif pl_end='1' and cntr(0)='1' then
				if fcs_irdy='1' then
					cntr := cntr - 1; 
				end if;
			end if;
			fcs_end <= cntr(0);
		end if;
	end process;

	fcs_mode <= llc_end;
	fcs_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => eth_frm,
		irdy => fcs_irdy,
		mode => fcs_mode,
		data => fcs_data,
		crc  => fcs_crc);

	eth_irdy <= wirebus(pre_trdy & llc_trdy & pl_irdy & '1',
		not  pre_end              & 
		(not llc_end and pre_end) & 
		(not pl_end  and llc_end) & 
		(not fcs_end and pl_end))(0);
	eth_data <= wirebus(pre_data & llc_data & pl_data & fcs_crc(eth_data'range), 
		not  pre_end              & 
		(not llc_end and pre_end) & 
		(not pl_end  and llc_end) & 
		(not fcs_end and pl_end));
	eth_end <= fcs_end;
end;

