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
use hdl4fpga.base.all;

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
		hdlcrx_trdy : in   std_logic := '1';
		hdlcrx_end  : buffer std_logic;
		hdlcrx_data : buffer std_logic_vector);
end;

architecture def of hdlcsync_rx is
	constant flag : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_flag), hdlc_flag);
	constant esc  : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_esc),  hdlc_esc);
	constant invb : std_logic_vector(uartrx_data'range) := setif(uartrx_data'ascending, reverse(hdlc_invb), hdlc_invb);

	signal debug_rx : std_logic_vector(8-1 downto 0);
begin

	process (uartrx_data, uartrx_irdy, hdlcrx_trdy, uart_clk)
		variable frm_on : std_logic;
		variable end_on : std_logic;
		variable esc_on : std_logic;
	begin
		if rising_edge(uart_clk) then
			if uartrx_irdy='1' then
				if uartrx_data=flag then
					end_on := '1';
					esc_on := '0';
				elsif uartrx_data=esc then
					end_on := '0';
					esc_on := '1';
					frm_on := '1';
				else
					end_on := '0';
					esc_on := '0';
					frm_on := '1';
				end if;
				if hdlcrx_irdy='1' then
					debug_rx <= setif(hdlcrx_data'ascending, reverse(hdlcrx_data), hdlcrx_data);
				end if;
			end if;
			if hdlcrx_trdy='0'then
				if end_on='1' then
					end_on := '0';
				end if;
			end if;
		end if;

		if to_bit(uartrx_irdy)='1' then
			hdlcrx_frm <= '1';
			if uartrx_data/=flag then
				hdlcrx_end <= '0';
			else
				hdlcrx_end <= '1';
			end if;
		elsif (hdlcrx_trdy and end_on)='1' then
			hdlcrx_frm <= '0';
			hdlcrx_end <= '0';
		else
			hdlcrx_frm <= to_stdulogic(to_bit(frm_on));
			hdlcrx_end <= to_stdulogic(to_bit(end_on));
		end if;

		if hdlcrx_data'ascending=uartrx_data'ascending then
			hdlcrx_data <= setif(esc_on='1', uartrx_data xor invb, uartrx_data);
		else
			hdlcrx_data <= reverse(setif(esc_on='1', uartrx_data xor invb, uartrx_data));
		end if;
	end process;

	hdlcrx_irdy <= hdlcrx_frm and uartrx_irdy and setif(uartrx_data/=esc);

end;
