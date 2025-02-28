-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

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

		uart_frm    : buffer std_logic := '1';
		uart_irdy   : out std_logic;
		uart_trdy   : in  std_logic;
		uart_data   : out std_logic_vector);

end;

architecture def of hdlcsync_tx is

	constant flag   : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_flag), hdlc_flag);
	constant esc    : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_esc),  hdlc_esc);
	constant invb   : std_logic_vector(hdlctx_data'range) := setif(hdlctx_data'ascending, reverse(hdlc_invb), hdlc_invb);

	signal data     : std_logic_vector(hdlctx_data'range);
	signal esc_on   : std_logic;

	signal debug_tx : std_logic_vector(8-1 downto 0);
begin

	process (uart_clk)
	begin
		if rising_edge(uart_clk) then
			if hdlctx_frm='1' then
				if hdlctx_irdy='1' then
					debug_tx <= setif(hdlctx_data'ascending, reverse(hdlctx_data), hdlctx_data);
					if uart_trdy='1' then
						if esc_on='1' then
							esc_on <= '0';
						elsif hdlctx_data=flag then
							esc_on <= '1';
						elsif hdlctx_data=esc then
							esc_on <= '1';
						end if;
					end if;
				end if;
			else
				esc_on <= '0';
			end if;
		end if;
	end process;

	process (hdlctx_frm, hdlctx_irdy, uart_clk)
		variable q : std_logic;
	begin
		if rising_edge(uart_clk) then
			if hdlctx_frm='1' then
				if (hdlctx_irdy and hdlctx_trdy)='1' then
					q := hdlctx_end;
				end if;
			else
				q := '0';
			end if;
		end if;
		if hdlctx_frm='1' then
			if hdlctx_end='0' then
				uart_irdy <= hdlctx_irdy;
			elsif q='1' then
				uart_irdy <= '0';
			else
				uart_irdy <= hdlctx_irdy;
			end if;
		else
			uart_irdy <= '0';
		end if;

	end process;

	hdlctx_trdy <=
		'0'       when hdlctx_frm='0'   else
		uart_trdy when esc_on='1'       else
		'0'       when hdlctx_data=flag else
		'0'       when hdlctx_data=esc  else
		uart_trdy;

	data <= hdlctx_data when data'ascending=uart_data'ascending else reverse(hdlctx_data);
	uart_frm  <=hdlctx_frm;
	uart_data <=
		(flag'range => '-') when hdlctx_frm='0'   else
		flag            when hdlctx_end='1'   else
		data xor invb   when esc_on='1'       else
		esc             when hdlctx_data=flag else
		esc             when hdlctx_data=esc  else
		data;

end;





