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
	constant  blut           : string(1 to 2) := "FG";

	attribute dont_touch     : string;
	attribute keep           : string;
	attribute keep_hierarchy : string;

	signal d : std_logic_vector(0 to n-1);

	attribute dont_touch of d : signal is "true";
	attribute keep  of d      : signal is "true";

begin
	d(n-1) <= '-';
	chain_g: for i in n-1 downto 1 generate
		attribute dont_touch     of lut : label is "true";
		attribute keep           of lut : label is "true";
		attribute keep_hierarchy of lut : label is "true";
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
