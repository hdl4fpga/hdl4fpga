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
