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

architecture manchester of testbench is
    constant oversampling : natural := 4;

	constant data : std_logic_vector(0 to 64-1) := x"aaaa_aaab" & x"0000_ffff";

	signal txc  : std_logic := '0';
	signal txen : std_logic;
	signal txd  : std_logic;
	signal rxc  : std_logic := '0';
	signal rxdv : std_logic;
	signal rxd  : std_logic;
	signal txr  : std_logic;

begin

	txc <= not txc after (10 ns*oversampling)*0.9;
	rxc <= not rxc after 10 ns;
	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				txd  <= data(cntr);
				txen <= '1';
				cntr := cntr + 1;
			else
				txen <= '0';
			end if;
		end if;
	end process;

	tx_d : entity hdl4fpga.tx_manchester
	port map (
		txc  => txc,
		txen => txen,
		txd  => txd,
		tx   => txr);

	rx_d : entity hdl4fpga.rx_manchester
    generic map (
        oversampling => (3*oversampling)/4)
	port map (
		rxc  => rxc,
		rxdv => rxdv,
		rxd  => rxd,
		rx   => txr);
end;