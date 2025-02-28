-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pgm_delay is
	generic (
		n : natural := 1);
	port (
		xi  : in  std_logic;
--		ena : in  std_logic_vector(n-1 downto 0) := (others => '1');
		x_p : out std_logic;
		x_n : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture mix of pgm_delay is
	constant ena             : std_logic_vector(n-1 downto 0) := (others => '1');

	attribute keep           : string;

	signal d : std_logic_vector(0 to n-1);

	attribute keep of x_p  : signal is "true";
	attribute keep of x_n  : signal is "true";
	attribute keep of lutp : label is "true";
	attribute keep of lutn : label is "true";


begin
	d(n-1) <= '-';
	chain_g: for i in n-1 downto 1 generate
		attribute keep of lut : label is "true";
	begin
		lut : lut4
		generic map (
			init => x"00ca")
		port map (
			i0 => d(i),
			i1 => xi,
			i2 => ena(i),
			i3 => '0',
			o  => d(i-1));
	end generate;

	lutp : lut4
	generic map (
		init => x"00ca")
	port map (
		i0 => d(0),
		i1 => xi,
		i2 => ena(0),
		i3 => '0',
		o  => x_p);

	lutn : lut4
	generic map (
		init => x"0035")
	port map (
		i0 => d(0),
		i1 => xi,
		i2 => ena(0),
		i3 => '0',
		o  => x_n);
end;

