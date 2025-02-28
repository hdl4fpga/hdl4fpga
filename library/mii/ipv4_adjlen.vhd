-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ipv4_adjlen is
	generic (
		adjust  : std_logic_vector);
	port (
		sio_clk  : in  std_logic;
		sio_frm  : in  std_logic;
		sio_irdy : in  std_logic;
		sio_trdy : out std_logic;
		si_data  : in  std_logic_vector;
		so_data  : out std_logic_vector);
end;

architecture def of ipv4_adjlen is
	signal si_b   : std_logic_vector(si_data'range);
	signal si_ci  : std_logic;
	signal si_co  : std_logic;
	signal so_sum : std_logic_vector(so_data'range);

	constant crtn_data : std_logic_vector := reverse(reverse(adjust), si_b'length);
begin

	crtnmux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => crtn_data,
		sio_clk  => sio_clk,
		sio_frm  => sio_frm,
		sio_irdy => sio_irdy,
		sio_trdy => open,
		so_data  => si_b);

	si_adder_e : entity hdl4fpga.adder
	port map (
		ci  => si_ci,
		a   => si_data,
		b   => si_b,
		s   => so_sum,
		co  => si_co);

	si_cy_p : process (sio_clk)
	begin
		if rising_edge(sio_clk) then
			if sio_frm='0' then
				si_ci <= '0';
			elsif sio_irdy='1' then
				si_ci <= si_co;
			end if;
		end if;
	end process;

	so_data <= so_sum;
end;
