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

entity so_data is
	port (
		sio_clk   : in  std_logic;
		si_frm    : in  std_logic;
		si_irdy   : in  std_logic;
		si_trdy   : out std_logic;
		si_length : in  std_logic_vector;
		si_end    : buffer std_logic;
		si_data   : in  std_logic_vector;

		so_rid    : in  std_logic_vector(0 to 8-1) := x"18";
		so_frm    : buffer std_logic;
		so_irdy   : buffer std_logic;
		so_trdy   : in  std_logic;
		so_end    : buffer std_logic;
		so_data   : out std_logic_vector);
end;

architecture def of so_data is

	signal low_cntr  : unsigned(0 to 8);
	signal high_cntr : unsigned(0 to setif(si_length'length > 8, si_length'length - 8, 0));

	type states is (st_idle, st_rid, st_len, st_data);
	signal state : states;

	signal deso_trdy : std_logic;

begin

	process(sio_clk)
	begin
		if rising_edge(sio_clk) then
			case state is
			when st_idle =>
				so_end    <= si_end;
				low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
				high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
				if si_frm='1' then
					state <= st_rid;
				else
					state <= st_idle;
				end if;
			when st_rid  =>
				if si_frm='1' then
					if so_trdy='1' then
						so_end <= si_end;
						state  <= st_len;
					end if;
				else
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state     <= st_idle;
				end if;
			when st_len =>
				if si_frm='1' then
					if so_trdy='1' then
						so_end    <= si_end;
						high_cntr <= high_cntr - 1;
						low_cntr  <= low_cntr  - 1;
						state     <= st_data;
					end if;
				else
					so_end    <= si_end;
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state     <= st_idle;
				end if;
			when st_data =>
				if si_frm='1' then
					if (si_irdy and so_trdy)='1' then
						so_end <= si_end;
						if low_cntr(0)='0' then
							low_cntr <= low_cntr - 1;
							state  <= st_data;
						elsif high_cntr(0)='0' then
							low_cntr <= '0' & (1 to 8 => '1');
							state  <= st_rid;
						end if;
					end if;
				else
					low_cntr  <= '0' & resize(unsigned(si_length) srl 0, low_cntr'length-1);
					high_cntr <= '0' & resize(unsigned(si_length) srl 8, high_cntr'length-1);
					state     <= st_idle;
				end if;
			end case;
		end if;
	end process;

	si_end   <= '0' when state=st_idle else si_frm and high_cntr(0) and low_cntr(0);

	si_trdy <= so_trdy when state=st_data else '0';

	so_frm  <= to_stdulogic(to_bit(si_frm));
	so_irdy  <=
		'1'      when so_end='1' else
		'0'      when state=st_idle else
		si_irdy when state=st_data else
		'1';

	with state select
	so_data <=
		so_rid   when st_idle | st_rid,
		std_logic_vector(resize(low_cntr, so_data'length)) when st_len,
		si_data when st_data;


end;
