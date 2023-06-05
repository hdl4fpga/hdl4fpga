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

architecture usbphy of testbench is
    constant oversampling : natural := 3;

	constant data : std_logic_vector(0 to 64-1) := x"7efd_aaab" & x"5555_fff1";

	signal txc  : std_logic := '0';
	signal txen : std_logic := '0';
	signal txd  : std_logic := '0';
	signal dp   : std_logic;
	signal dn   : std_logic;
	signal rxc  : std_logic := '0';
	signal frm : std_logic := '0';
	signal rxdv : std_logic := '0';
	signal rxd  : std_logic := '0';
	signal busy : std_logic;

	signal datao : std_logic_vector(0 to 64-1) := (others => '0');
begin

	txc <= not txc after 10 ns*oversampling*(25.0/24.0); --*0.975;
	rxc <= not rxc after 10 ns;

	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				if busy='0' then
					txd  <= data(cntr);
					txen <= '1';
					cntr := cntr + 1;
				end if;
			elsif busy='0' then
				if cntr > data'length+7 then
					txen <= '0';
				else
					cntr := cntr + 1;
				end if;
			end if;
		end if;
	end process;

	tx_d : entity hdl4fpga.usbphy_tx
	port map (
		txc  => txc,
		txen => txen,
		busy => busy,
		txd  => txd,
		txdp => dp,
		txdn => dn);

	rx_d : entity hdl4fpga.usbphy_rx
	generic map (
		oversampling => oversampling)
	port map (
		data => rxd,
		dv => rxdv,
		frm => frm,
		rxc  => rxc,
		rxdp => dp,
		rxdn => dn);

	process (rxc)
		variable cntr : natural := 0;
	begin
		if rising_edge(rxc) then
			if (frm and rxdv)='1' then
				datao(cntr) <= rxd;
				cntr := cntr + 1;
			end if;
		end if;
	end process;

end;