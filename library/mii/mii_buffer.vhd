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

entity mii_buffer is -- skid buffer
	generic (
		flush   : boolean := false;
		latency : natural := 1);
	port (
		clk : in std_logic;
		src_frm  : in  std_logic := '1';
		src_irdy : in  std_logic;
		src_trdy : out std_logic;
		src_data : in  std_logic_vector;
		dst_frm  : buffer std_logic := '0';
		dst_irdy : buffer std_logic := '0';
		dst_trdy : in  std_logic;
		dst_data : out std_logic_vector);
end;

architecture def of mii_buffer is
	signal fifo_irdy : std_logic;
	signal fifo_trdy : std_logic;
	signal fifo_data : std_logic_vector(dst_data'range);

	signal mode      : std_logic_vector(0 to 2-1);
	alias commit   is mode(0);
	alias rollback is mode(1);
begin

	commit   <=     (src_frm or src_irdy) or  (dst_frm or dst_irdy);
	rollback <= not (src_frm or src_irdy) and (dst_frm or dst_irdy);
	fifo_i : entity hdl4fpga.fifo
	generic map (
		latency   => 0,
		check_sov => true,
		check_dov => true,
		max_depth => (32*8)/src_data'length)
	port map (
		src_clk  => clk,
		src_irdy => src_irdy,
		src_trdy => src_trdy,
		src_data => src_data,

		mode     => mode,

		dst_clk  => clk,
		dst_irdy => fifo_irdy,
		dst_trdy => fifo_trdy,
		dst_data => fifo_data);

	fifo_trdy <= dst_trdy or not dst_irdy;
	process(clk)
		variable shr_irdy : std_logic := '0';
		variable shr_data : std_logic_vector(0 to dst_data'length-1);
	begin
		if rising_edge(clk) then
			if dst_irdy='0' then
				dst_frm  <= shr_irdy;
				dst_irdy <= shr_irdy;
				dst_data <= shr_data;
				shr_irdy := fifo_irdy;
				shr_data := fifo_data;
			elsif dst_trdy='1' then
				dst_frm  <= fifo_irdy;
				dst_irdy <= shr_irdy;
				dst_data <= shr_data;
				shr_irdy := fifo_irdy;
				shr_data := fifo_data;
			end if;
		end if;
	end process;

end;
