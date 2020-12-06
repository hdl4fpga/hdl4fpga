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

library hdl4fpga;
use hdl4fpga.std.all;

entity ahdlc_rx is
	port (
		clk        : in  std_logic;

		uart_rxdv  : in  std_logic;
		uart_rxd   : in  std_logic_vector(8-1 downto 0);

		ahdlc_frm  : buffer std_logic;
		ahdlc_irdy : out std_logic;
		ahdlc_data : out std_logic_vector(8-1 downto 0));

	constant ahdlc_flag : std_logic_vector := x"7e";
	constant ahdlc_esc  : std_logic_vector := x"7d";

end;

architecture def of ahdlc_rx is
begin

	process (uart_rxd, uart_rxdv, clk)
		variable frm : std_logic;
		variable esc : std_logic;
	begin
		if rising_edge(clk) then
			if uart_rxdv='1' then
				case uart_rxd is
				when ahdlc_flag =>
					frm := '0';
					esc := '0';
				when ahdlc_esc =>
					frm := '1';
					esc := '1';
				when others =>
					frm := '1';
					esc := '0';
				end case;
			end if;
		end if;
		ahdlc_frm  <= (setif(uart_rxd/=ahdlc_flag) and uart_rxdv) or (frm and not uart_rxdv);
		ahdlc_data <= setif(esc='0', uart_rxd, uart_rxd xor x"10");
	end process;

	ahdlc_irdy <= ahdlc_frm and uart_rxdv and setif(uart_rxd/=ahdlc_esc);

end;
