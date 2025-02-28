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
use hdl4fpga.profiles.all;

entity igbx is
	generic (
		device    : fpga_devices := xc7a;
		size      : natural := 1;
		gear      : natural := 2;
		data_edge : string := "SAME_EDGE");
	port (
		rst       : in  std_logic := '0';
		sclk      : in std_logic := '0';
		clkx2     : in std_logic := '0';
		clk       : in std_logic;
		d         : in  std_logic_vector(0 to size-1);
		q         : out std_logic_vector(0 to size*gear-1));
end;

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture beh of igbx is
begin

	reg_g : for i in d'range generate
		signal po : std_logic_vector(0 to 4-1);
	begin

		gear1_g : if gear=1 generate
			ffd_i : altddio_in
			generic map (
				width	=> 1)
			port map (
				inclock      => clk,
				datain(0)    => d(i),
				dataout_h(0) => po(0));

		end generate;

		gear2_g : if gear=2 generate
			ffd_i : altddio_in
			generic map (
				width	=> 1)
			port map (
				inclock      => clk,
				datain(0)    => d(i),
				dataout_h(0) => po(0),
				dataout_l(0) => po(1));
		end generate;

		process (po)
		begin
			for j in 0 to gear-1 loop
				q(gear*i+j) <= po(j);
			end loop;
		end process;

	end generate;

end;



