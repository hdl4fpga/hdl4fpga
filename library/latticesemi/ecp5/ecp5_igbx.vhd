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

entity ecp5_igbx is
	generic (
		size : natural := 1;
		gear : natural);
	port (
		rst  : in std_logic := '0';
		sclk : in std_logic := '0';
		d    : in  std_logic_vector(0 to size-1);
		q    : out std_logic_vector(0 to size*gear-1));
end;

library ecp5u;
use ecp5u.components.all;

architecture beh of ecp5_igbx is
begin

	reg_g : for i in d'range generate
		gear1_g : if gear=1 generate
        	ff_i : fd1s3ax
        	port map (
        		ck => sclk,
        		d  => d(0),
        		q  => q(0));
		end generate;

		gear2_g : if gear=2 generate
			assert false
			report "No gear2 core yet"
			severity failure;
		end generate;

		gear4_g : if gear=4 generate
			assert false
			report "No gear4 core yet"
			severity failure;
		end generate;

	end generate;

end;



