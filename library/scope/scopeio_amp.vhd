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

entity scopeio_amp is
	generic (
		gains : natural_vector);
	port (
		input_clk     : in  std_logic;
		input_dv      : in  std_logic;
		input_sample  : in  std_logic_vector;
		gain_id       : in  std_logic_vector;
		output_dv     : out std_logic;
		output_sample : out std_logic_vector);
end;

architecture beh of scopeio_amp is

	signal g : signed(0 to 18-1);
	signal p : signed(0 to input_sample'length+g'length-1);
	signal b : signed(input_sample'range);

begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				b <= signed(input_sample);
				p <= b*g;
				g <= to_signed(-gains(to_integer(unsigned(gain_id))),g'length);
			end if;
		end if;
	end process;
	output_sample <= std_logic_vector(resize(p(0 to input_sample'length), input_sample'length));
	output_dv <= input_dv;

end;



