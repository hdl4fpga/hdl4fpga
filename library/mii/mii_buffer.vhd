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
	signal rollback  : std_logic;
	signal fifoi_irdy : std_logic;
	signal fifo_frm  : std_logic;
	signal fifo_irdy : std_logic;
	signal fifo_trdy : std_logic;
	signal fifo_data : std_logic_vector(dst_data'range);
begin

	process (clk)
		type states is (s_commit, s_queue);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_commit =>
				if (dst_frm or dst_irdy)='0' then
					rollback <= '0';
					if (src_frm or src_irdy)='1' then
						state := s_queue;
					end if;
				end if;
			when s_queue =>
				if (src_frm or src_irdy)='0' then
					rollback <= '1';
					if (dst_frm or dst_irdy)='1' then
						state := s_commit;
					end if;
				end if;
			end case;
		end if;
	end process;

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

		mode(0)  => '1',
		mode(1)  => rollback,

		dst_clk  => clk,
		dst_irdy => fifo_irdy,
		dst_trdy => fifo_trdy,
		dst_data => fifo_data);

	fifo_frm  <= fifo_irdy;
	fifo_trdy <= not dst_irdy or dst_trdy;
	process (fifo_irdy, clk)
		variable frm  : std_logic;
	begin
		if rising_edge(clk) then
			if fifo_trdy='1' then
				dst_data <= fifo_data;
				dst_irdy <= fifo_irdy;
			end if;
			frm := fifo_frm;
		end if;
		dst_frm <= frm and fifo_irdy;
	end process;

end;
