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
		hdlc_esc  : std_logic_vector := x"7d";
		hdlc_invb : std_logic_vector := x"20");
	port (
		uart_clk    : in  std_logic;
		uartrx_irdy : in  std_logic;
		uartrx_data : in  std_logic_vector;

		hdlcrx_frm  : buffer std_logic;
		hdlcrx_irdy : buffer std_logic;
		hdlcrx_data : buffer std_logic_vector);
end;

architecture def of hdlcsync_rx is
	constant flag : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_flag), hdlc_flag);
	constant esc  : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_esc),  hdlc_esc);
	constant invb : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_invb), hdlc_invb);

	signal debug_rx : std_logic_vector(8-1 downto 0);
begin

	process (uartrx_data, uartrx_irdy, uart_clk)
		variable frm : std_logic;
		variable eon : std_logic;
	begin
		if rising_edge(uart_clk) then
			if uartrx_irdy='1' then
				if uartrx_data=flag then
					frm := '0';
					eon := '0';
				elsif uartrx_data=esc then
					frm := '1';
					eon := '1';
				else
					frm := '1';
					eon := '0';
				end if;
				if hdlcrx_irdy='1' then
					debug_rx <= setif(hdlcrx_data'ascending, reverse(hdlcrx_data), hdlcrx_data);
				end if;
			end if;
		end if;
		hdlcrx_frm  <= (setif(uartrx_data/=flag) and uartrx_irdy) or (frm and not uartrx_irdy);
		if hdlcrx_data'ascending=uartrx_data'ascending then
			hdlcrx_data <= setif(eon='1', uartrx_data xor invb, uartrx_data);
		else
			hdlcrx_data <= reverse(setif(eon='1', uartrx_data xor invb, uartrx_data));
		end if;
	end process;

	hdlcrx_irdy <= hdlcrx_frm and uartrx_irdy and setif(uartrx_data/=esc);

end;
