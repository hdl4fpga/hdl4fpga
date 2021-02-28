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

entity hdlcsync_tx is
	generic (
		hdlc_flag : std_logic_vector := x"7e";
		hdlc_esc  : std_logic_vector := x"7d";
		hdlc_5inv : std_logic_vector := x"20");
	port (
		uart_clk    : in  std_logic;
		uart_irdy   : out std_logic;
		uart_idle   : in  std_logic;
		uart_txd    : out std_logic_vector;

		hdlctx_frm  : in  std_logic;
		hdlctx_irdy : in  std_logic;
		hdlctx_trdy : buffer std_logic;
		hdlctx_data : in  std_logic_vector);


end;

architecture def of hdlcsync_tx is

	constant flag : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_flag), hdlc_flag);
	constant esc  : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_esc),  hdlc_esc);
	constant inv5 : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_5inv), hdlc_5inv);

	signal data : std_logic_vector(hdlctx_data'range);

	signal debug_tx : std_logic_vector(8-1 downto 0);
begin

	process (uart_idle, hdlctx_frm, hdlctx_data, hdlctx_irdy, uart_clk)
		variable frm : std_logic;
		variable eon : std_logic;
	begin
		if rising_edge(uart_clk) then
			if uart_idle='1' then
				if hdlctx_frm='1' then
					if hdlctx_irdy='1' then
						debug_tx <= setif(hdlctx_data'ascending, reverse(hdlctx_data), hdlctx_data);
						if eon='1' then
							eon := '0';
						elsif hdlctx_data=flag then
							eon := frm;
						elsif hdlctx_data=esc then
							eon := frm;
						end if;
					else 
						eon := '0';
					end if;
				else
					eon := '0';
				end if;
				frm := hdlctx_frm;
			end if;
		end if;

		if hdlctx_frm='1' then
			if eon='1' then
				uart_irdy   <= hdlctx_irdy;
				hdlctx_trdy <= uart_idle;
				data        <= hdlctx_data xor inv5;
			elsif hdlctx_data=flag then
				uart_irdy   <= hdlctx_irdy;
				hdlctx_trdy <= '0';
				data        <= esc;
			elsif hdlctx_data=esc then
				uart_irdy   <= hdlctx_irdy;
				hdlctx_trdy <= '0';
				data        <= esc;
			else
				uart_irdy   <= hdlctx_irdy;
				hdlctx_trdy <= uart_idle;
				data        <= hdlctx_data;
			end if;
		else 
			uart_irdy   <= frm;
			hdlctx_trdy <= '0';
			data        <= flag;
		end if;
	end process;

	uart_txd <= setif(data'ascending=uart_txd'ascending, data, reverse(data));

end;
