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
		hdlc_invb : std_logic_vector := x"20");
	port (
		uart_clk    : in  std_logic;

		hdlctx_frm  : in  std_logic;
		hdlctx_irdy : in  std_logic;
		hdlctx_trdy : buffer std_logic;
		hdlctx_end  : in  std_logic := '0';
		hdlctx_data : in  std_logic_vector;

		uart_irdy   : out std_logic;
		uart_trdy   : in  std_logic;
		uart_data   : out std_logic_vector);



end;

architecture def of hdlcsync_tx is

	constant flag : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_flag), hdlc_flag);
	constant esc  : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_esc),  hdlc_esc);
	constant invb : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_invb), hdlc_invb);

	signal data : std_logic_vector(hdlctx_data'range);

	signal debug_tx : std_logic_vector(8-1 downto 0);
	signal eon : std_logic;
begin

	process (hdlctx_frm, hdlctx_data, hdlctx_irdy, uart_clk)
	begin
		if rising_edge(uart_clk) then
			if hdlctx_frm='1' then
				if (hdlctx_irdy and hdlctx_irdy)='1' then
					debug_tx <= setif(hdlctx_data'ascending, reverse(hdlctx_data), hdlctx_data);
					if eon='1' then
						eon <= '0';
					elsif hdlctx_data=flag then
						eon <= '1';
					elsif hdlctx_data=esc then
						eon <= '1';
					end if;
				else
					eon <= '0';
				end if;
			else
				eon <= '0';
			end if;
		end if;
	end process;

	uart_irdy <=
		when hdlctx_frm='0' else
		hdlctx_irdy;

	hdlctx_trdy <=
		'0'       when hdlctx_frm='0'   else
		uart_trdy when eon='1'          else
		'0'       when hdlctx_data=flag else
		'0'       when hdlctx_data=esc  else
		uart_trdy;

	data <= hdlctx_data when data'ascending=uart_data'ascending else reverse(hdlctx_data);
	uart_data <=
		flag          when hdlctx_frm='0'   else
		data xor invb when eon='1'          else
		esc           when hdlctx_data=flag else
		esc           when hdlctx_data=esc  else
		data;

end;
