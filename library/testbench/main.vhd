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

package pp is
	function pru
		generic (
			type mytype)
		parameter (
			arg : mytype)
		return mytype;
end;

package body pp is
	function pru
		generic (
			type mytype)
		parameter (
			arg : mytype)
		return mytype is
	begin
		return arg;
	end;

end;

library ieee;
use ieee.std_logic_1164.all;
use work.pp.all;

entity main is
	port (
		i : in std_logic;
		o : out std_logic);
end;

architecture pgm of main is
	function pp is new pru generic map(mytype => std_logic);
	function pp is new pru generic map(mytype => std_logic_vector);
begin
	o <= pp(i);
end;
