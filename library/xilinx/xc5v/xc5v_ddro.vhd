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

entity xc5v_ddro is
	port (
		clk : in std_logic;
		dr  : in std_logic;
		df  : in std_logic;
		q   : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture xc5v of xc5v_ddro is
begin
	oddr_i : oddr
	port map (
		c => clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d1 => dr,
		d2 => df,
		q  => q);

end;

library ieee;
use ieee.std_logic_1164.all;

entity ddrto is
	port (
		clk : in std_logic;
		d : in std_logic;
		q : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture virtex5 of ddrto is
	attribute s : string;
	attribute s of q : signal is "TRUE";
begin
	ffd_i : fdrse
	port map (
		c  => clk,
		ce => '1',
		s  => '0',
		r  => '0',
		d  => d,
		q  => q);
end;
