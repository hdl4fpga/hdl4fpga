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

entity hdlcsync_rx is
	generic (
		hdlc_flag : std_logic_vector := x"7e";
		hdlc_esc  : std_logic_vector := x"7d");
	port (
		uart_clk  : in  std_logic;
		uart_rxdv : in  std_logic;
		uart_rxd  : in  std_logic_vector(8-1 downto 0);

		hdlcrx_frm  : buffer std_logic;
		hdlcrx_irdy : buffer std_logic;
		hdlcrx_data : buffer std_logic_vector(8-1 downto 0));
end;

architecture def of hdlcsync_rx is
	signal debug : std_logic_vector(8-1 downto 0);
begin

	process (uart_rxd, uart_rxdv, uart_clk)
		variable frm : std_logic;
		variable esc : std_logic;
	begin
		if rising_edge(uart_clk) then
			if uart_rxdv='1' then
				if uart_rxd=hdlc_flag then
					frm := '0';
					esc := '0';
				elsif uart_rxd=hdlc_esc then
					frm := '1';
					esc := '1';
				else
					frm := '1';
					esc := '0';
				end if;
				if hdlcrx_irdy='1' then
					debug <= hdlcrx_data;
				end if;
			end if;
		end if;
		hdlcrx_frm  <= (setif(uart_rxd/=hdlc_flag) and uart_rxdv) or (frm and not uart_rxdv);
		hdlcrx_data <= setif(esc='1', uart_rxd xor x"20", uart_rxd);
	end process;

	hdlcrx_irdy <= hdlcrx_frm and uart_rxdv and setif(uart_rxd/=hdlc_esc);

end;
