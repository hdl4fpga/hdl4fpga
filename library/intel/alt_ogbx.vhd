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

entity alt_ogbx is
	generic (
		device    : fpga_devices := cyclonev;
		size      : natural;
		gear      : natural;
		data_edge : string := "SAME_EDGE");
	port (
		rst   : in  std_logic := '0';
		clk   : in  std_logic;
		clkx2 : in std_logic := '0';
		t     : in  std_logic_vector(0 to gear*size-1) := (others => '0');
		tq    : out std_logic_vector(0 to size-1) := (others => 'Z');
		d     : in  std_logic_vector(0 to gear*size-1);
		q     : out std_logic_vector(0 to size-1));
end;

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture beh of alt_ogbx is
begin

	bus_g : for i in q'range generate 
		signal oe : std_logic_vector(t'range);
	begin
		oe <= not t;
    	gear1_g : if gear = 1 generate
    		ffd_i : altddio_out
    		generic map (
    			width	=> 1)
    		port map (
    			outclock    => clk,
    			oe          => oe(gear*i+0),
    			datain_h(0) => d(gear*i+0),
    			datain_l(0) => d(gear*i+0),
    			dataout(0)	=> q(i));
    	end generate;

    	gear2_g : if gear = 2 generate
    		ffd_i : altddio_out
    		generic map (
    			width	=> 1)
    		port map (
    			outclock    => clk,
    			oe          => oe(gear*i+0),
    			datain_h(0) => d(gear*i+0),
    			datain_l(0) => d(gear*i+1),
    			dataout(0)	=> q(i));
    	end generate;
	end generate;

end;



