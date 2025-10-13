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

entity sio_sin is
	generic (
		debug     : boolean := false);
	port (
		clk  : in  std_logic;
		frm  : in  std_logic;
		irdy : in  std_logic := '1';
		trdy : buffer std_logic;
		data : in  std_logic_vector;

		data_frm  : out std_logic;
		data_irdy : out std_logic;
		sout_irdy : out std_logic;
		data_ptr  : out std_logic_vector(8-1 downto 0);

		rgtr_frm  : out std_logic;
		rgtr_irdy : buffer std_logic;
		rgtr_trdy : in  std_logic := '1';
		rgtr_idv  : out std_logic;
		rgtr_id   : out std_logic_vector(8-1 downto 0);
		rgtr_lv   : out std_logic;
		rgtr_len  : buffer std_logic_vector(8-1 downto 0);
		rgtr_dv   : out std_logic;
		rgtr_data : out std_logic_vector;
		tp        : out std_logic_vector(1 to 32));
end;

architecture beh of sio_sin is
	signal decode_irdy : std_logic;
begin
	decode_irdy <= irdy;
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => compact('{' &
			"   rid:8,"      & 
			"length:8" & '}'),
		size  => icmprx_data'length)
	port map (
		clk    => clk,
		frm    => frm,
		irdy   => decode_irdy,
		act(0) => rid_act,
		act(1) => length_act,
		act(2) => data_act);

	process (clk)
		variable rid    : unsigned(0 to hdo(frame)**".rid"-1);
		variable length : unsigned(0 to hdo(frame)**".length");
		variable data   : unsigned(rgtr_data'range);
		variable ptr    : unsigned(rgtr_id'range);
	begin
		if rising_edge(sin_clk) then
			if (frm or irdy)='1' then
				if (irdy and trdy)='1' then
					if rid_act='1' then
						rid(data'range) := unsigned(data);
						rid := rotate_left(rid, data'length);
					end if;
					if length_act='1' then
						length(data'range) := unsigned(data);
						length := rotate_left(length, data'length);
					end if;
					if data_act='1' then
						length(data'range) := unsigned(data);
						length := rotate_left(length, data'length);
					end if;
					when s_data =>
						ptr := ptr + 1;
						len := len - 1;
						if len(0)='1' then
							state <= s_id;
						else
							idv := '1';
							state <= s_data;
						end if;
						lv  := '0';
						dv  := '1';
					end case;

				end if;
				rgtr_frm  <= to_stdulogic(to_bit(sin_frm));
				data_frm  <= setif(state=s_data);
				rgtr_irdy <= des8_irdy;
				sout_irdy <= sin_irdy;
				data_irdy <= des8_irdy and setif(state=s_data);
				rgtr_dv   <= des8_irdy and len(0);

				rgtr_idv  <= idv;
				rgtr_id   <= rid;
				rgtr_lv   <= lv;
				rgtr_len  <= std_logic_vector(len(1 to des8_data'length));

				if sin_irdy='1' then
					if sin_data'ascending=data'ascending then
						data(sin_data'range) := unsigned(sin_data);
						if sin_data'ascending then
							data := data rol sin_data'length;
						else
							data := data ror sin_data'length;
						end if;
					else
						if sin_data'ascending then
							data := data rol sin_data'length;
						else
							data := data ror sin_data'length;
						end if;
						data(sin_data'reverse_range) := unsigned(sin_data);
					end if;
				end if;

				rgtr_data <= setif(rgtr_data'ascending=sin_data'ascending, std_logic_vector(data), reverse(std_logic_vector(data)));

				data_ptr  <= std_logic_vector(ptr);
			end if;
		end if;
	end process;
	sin_trdy <= not to_stdulogic(to_bit(rgtr_irdy)) or rgtr_trdy;


end;
