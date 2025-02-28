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

entity hdlcdll_rx is
	port (
		uart_clk    : in  std_logic;
		uartrx_irdy : in  std_logic;
		uartrx_data : in  std_logic_vector;

		hdlcrx_frm  : buffer std_logic;
		hdlcrx_irdy : buffer  std_logic;
		hdlcrx_end  : buffer std_logic;
		hdlcrx_data : buffer std_logic_vector;
		fcs_sb      : out std_logic;
		fcs_vld     : out std_logic);
end;

architecture def of hdlcdll_rx is
	signal hdlcsyncrx_irdy : std_logic;
	signal hdlcsyncrx_trdy : std_logic;
	signal hdlcsyncrx_data : std_logic_vector(hdlcrx_data'range);
	constant dly : natural := 3;
begin

	syncrx_e : entity hdl4fpga.hdlcsync_rx
	port map (
		uart_clk  => uart_clk,

		uartrx_irdy => uartrx_irdy,
		uartrx_data => uartrx_data,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcsyncrx_irdy,
		hdlcrx_trdy => hdlcsyncrx_trdy,
		hdlcrx_end  => hdlcrx_end,
		hdlcrx_data => hdlcsyncrx_data);

	fcsrx_e : entity hdl4fpga.hdlcfcs_rx
	port map (
		uart_clk  => uart_clk,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcsyncrx_irdy,
		hdlcrx_trdy => hdlcsyncrx_trdy,
		hdlcrx_end  => hdlcrx_end ,
		hdlcrx_data => hdlcsyncrx_data,
		fcs_sb      => fcs_sb,
		fcs_vld     => fcs_vld);

	process (hdlcsyncrx_irdy, uart_clk)
		variable q : unsigned(0 to dly-1);
	begin
		if rising_edge(uart_clk) then
			if hdlcrx_frm='0' then
				q := (others => '0');
			elsif hdlcsyncrx_irdy='1' then
				q(0) := '1';
				q := q rol 1;
			end if;
		end if;
		hdlcrx_irdy <= hdlcsyncrx_irdy and to_stdulogic(to_bit(q(0)));
	end process;

	data_e : entity hdl4fpga.latency
	generic map (
		n => hdlcrx_data'length,
		d => (hdlcrx_data'range => dly))
	port map (
		clk => uart_clk,
		ena => hdlcsyncrx_irdy,
		di  => hdlcsyncrx_data,
		do  => hdlcrx_data);

end;



