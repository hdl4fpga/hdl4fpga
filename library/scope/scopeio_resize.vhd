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
use hdl4fpga.scopeiopkg.all;

entity scopeio_resize is
	generic (
		inputs      : natural);
	port (
		input_data  : in  std_logic_vector;
		output_data : out std_logic_vector);

end;

architecture beh of scopeio_resize is
	subtype storage_word is std_logic_vector(output_data'length/inputs-1 downto 0);
begin
	resize_p : process (input_data)
		variable aux1   : signed(output_data'length-1 downto 0);
		variable aux2   : signed(input_data'length-1 downto 0);
		variable sample : signed(0 to input_data'length/inputs-1); 
	begin
		aux1 := (others => '-');
		aux2 := signed(input_data);
		if sample'length > storage_word'length then
			for i in 0 to inputs-1 loop
				-- sample := aux2(sample'reverse_range);
				sample := aux2(sample'length-1 downto 0);
				sample := shift_right(sample,(storage_word'length-1));
				if sample=(sample'range => sample(0)) then
					aux1(storage_word'length-1 downto 0) := aux2(storage_word'length-1 downto 0);
				else
					aux1(storage_word'length-1 downto 0) := sample(0) & (1 to storage_word'length-1 => not sample(0));
				end if;
				aux1 := aux1 rol storage_word'length;
				aux2 := aux2 rol input_data'length/inputs;
			end loop;
		elsif sample'length < storage_word'length then
			for i in 0 to inputs-1 loop
				-- aux1(storage_word'range) := resize(aux2(sample'reverse_range), storage_word'length);
				aux1(storage_word'range) := resize(aux2(sample'length-1 downto 0), storage_word'length);
				aux1 := aux1 rol storage_word'length;
				aux2 := aux2 rol sample'length;
			end loop;
		else
			aux1 := aux2;
		end if;
		output_data <= std_logic_vector(aux1);
	end process;

end;





