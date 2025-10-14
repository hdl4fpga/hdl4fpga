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
use hdl4fpga.hdo.all;
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
	constant frame : string := "{rid:8,length:8}";

	signal decode_frm  : std_logic;
	signal decode_irdy : std_logic;
	signal decode_last : std_logic;
	signal rid_act     : std_logic;
	signal length_act  : std_logic;
	signal act2        : std_logic;

begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => frame,
		size  => data'length)
	port map (
		clk    => clk,
		frm    => decode_frm,
		irdy   => decode_irdy,
		last   => decode_last,
		act(0) => rid_act,
		act(1) => length_act,
		act(2) => act2);

	process (frm, irdy, clk)
		type states is (s_header, s_data);
		variable state : states;

		variable shr_rid    : unsigned(0 to 8-1);
		variable shr_length : unsigned(0 to hdo(frame)**".length");
		variable shr_data   : unsigned(pyl_data'range);
	begin
		if rising_edge(clk) then
			if (frm or irdy)='1' then
				if (irdy and trdy)='1' then
					case state is 
					when s_header =>
						if rid_act='1' then
							shr_rid(data'range) := unsigned(data);
							shr_rid := rotate_left(shr_rid, data'length);
						end if;
						if length_act='1' then
							shr_length(data'range) := unsigned(data);
							shr_length := rotate_left(shr_length, data'length);
						end if;
						if decode_last='1' then
							state := s_data;
						end if;
					when s_data   =>
						shr_data(data'range) := unsigned(shr_data);
						shr_data := rotate_left(shr_data, data'length);
					end case;
				end if;
			else
				state := s_header;
			end if;
		end if;
		case state is
		when s_header =>
			decode_frm  <= frm;
			decode_irdy <= irdy;
		when s_data =>
			decode_frm  <= '0';
			decode_irdy <= '0';
		end case;
		rid    <= std_logic_vector(shr_rid);
		length <= std_logic_vector(shr_length(1 to shr_length'right));
	end process;


end;
