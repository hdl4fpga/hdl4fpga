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
	port (
		clk      : in  std_logic;
		frm      : in  std_logic;
		irdy     : in  std_logic := '1';
		trdy     : buffer std_logic;
		data     : in  std_logic_vector;

		rid      : out std_logic_vector(0 to 8-1);
		length   : out std_logic_vector(0 to 8-1);
		pyl_frm  : out std_logic;
		pyl_irdy : out std_logic;
		pyl_trdy : in  std_logic;
		pyl_data : out std_logic_vector(8-1 downto 0));
end;

architecture beh of sio_sin is
	signal decode_irdy : std_logic;
begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => compact('{' &
			"   rid:8,"      & 
			"length:8" & '}'),
		size  => icmprx_data'length)
	port map (
		clk    => clk,
		frm    => decode_frm,
		irdy   => decode_irdy,
		act(0) => rid_act,
		act(1) => length_act,
		act(2) => data_act);

	process (frm, irdy, clk)
		type states (s_rid, s_length, s_data)
		variable state : states;

		variable shr : unsigned(0 to 8-1);
		variable shr_length : unsigned(0 to hdo(frame)**".length");
		variable shr_data   : unsigned(rgtr_data'range);
	begin
		if rising_edge(sin_clk) then
			if (frm or irdy)='1' then
				if (irdy and trdy)='1' then
					case state is 
					when s_rid    =>
					when s_length =>
						shr_length := shr_length - 1;
					when s_data   =>
					end case;
					if data_act='1' then
						shr_data(data'range) := unsigned(shr_data);
						shr_data := rotate_left(shr_data, data'length);
					end if;
					if length_act='1' then
						shr_length(data'range) := unsigned(data);
						shr_length := rotate_left(shr_length, data'length);
					end if;
					if rid_act='1' then
						shr_rid(data'range) := unsigned(data);
						shr_rid := rotate_left(shr_rid, data'shr_length);
					end if;
				end if;
			else
				state := s_rid;
				shr_length := (others => '0');
			end if;
		end if;
		rid    <= std_logic_vector(shr_rid);
		length <= std_logic_vector(shr_length(1 to shr_length'right));
		decode_frm  <= not shr_length(0) and (frm or irdy);
		decode_irdy <= irdy;
	end process;


end;
