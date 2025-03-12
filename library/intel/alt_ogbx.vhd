--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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
