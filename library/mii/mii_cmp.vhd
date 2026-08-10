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

entity mii_cmp is
	generic (
		bitdata : std_logic_vector);
    port (
		mii_clk : in  std_logic;
		frm     : in  std_logic := '0';
		irdy    : in  std_logic := '0';
		trdy    : out std_logic := '1';
		data    : in  std_logic_vector;
		equ     : buffer std_logic := '0');
end;

architecture def of mii_cmp is
	signal si_data : std_logic_vector(data'range);
	signal so_data : std_logic_vector(data'range);
begin

	mem_i : entity hdl4fpga.sio_ram
   	generic map (
		bitdata => bitdata)
	port map (
		si_clk  => mii_clk,
		si_data => si_data,
		so_clk  => mii_clk,
		so_frm  => frm,
		so_irdy => irdy,
		so_trdy => trdy,
		so_data => so_data);

	cmp_i : entity hdl4fpga.sio_cmp
	port map (
		clk     => mii_clk,
		mr_frm  => frm,
		mr_irdy => irdy,
		mr_data => data,
		sl_data => so_data,
		equ     => equ);

end;
