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

entity ahdlc_tx is
	port (
		clk        : in  std_logic;

		uart_irdy  : out std_logic;
		uart_trdy  : in  std_logic;
		uart_txd   : out std_logic_vector(8-1 downto 0);

		ahdlc_frm  : in  std_logic;
		ahdlc_irdy : in  std_logic;
		ahdlc_trdy : buffer std_logic;
		ahdlc_data : in  std_logic_vector(8-1 downto 0));

	constant ahdlc_flag : std_logic_vector := x"7e";
	constant ahdlc_esc  : std_logic_vector := x"7d";

end;

architecture def of ahdlc_tx is

begin

	process (uart_trdy, ahdlc_frm, ahdlc_data, ahdlc_irdy, clk)
		variable frm : std_logic;
		variable esc : std_logic;
	begin
		if rising_edge(clk) then
			if uart_trdy='1' then
				if ahdlc_frm='1' then
					if ahdlc_irdy='1' then
						if esc='1' then
							esc := '0';
						elsif ahdlc_data=ahdlc_flag then
							esc := frm;
						elsif ahdlc_data=ahdlc_esc then
							esc := frm;
						end if;
					else 
						esc := '0';
					end if;
				else
					esc := '0';
				end if;
				frm := ahdlc_frm;
			end if;
		end if;

		if ahdlc_frm='1' then
			if frm='0' then
				uart_txd   <= ahdlc_flag;
				uart_irdy  <= ahdlc_irdy;
				ahdlc_trdy <= '0';
			elsif esc='1' then
				uart_txd   <= ahdlc_data xor x"20";
				uart_irdy  <= ahdlc_irdy;
				ahdlc_trdy <= uart_trdy;
			elsif ahdlc_data=ahdlc_flag then
				uart_txd   <= ahdlc_esc;
				uart_irdy  <= ahdlc_irdy;
				ahdlc_trdy <= '0';
			elsif ahdlc_data=ahdlc_esc then
				uart_txd   <= ahdlc_esc;
				uart_irdy  <= ahdlc_irdy;
				ahdlc_trdy <= '0';
			else
				uart_txd   <= ahdlc_data;
				uart_irdy  <= ahdlc_irdy;
				ahdlc_trdy <= uart_trdy;
			end if;
		else 
			ahdlc_trdy <= '0';
			uart_irdy  <= frm;
			uart_txd   <= ahdlc_flag;
		end if;
	end process;


end;
