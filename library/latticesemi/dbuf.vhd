--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity odbuf is
	port (
		i   : in std_logic;
		o_p : out std_logic;
		o_n : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of odbuf is
begin
	odbuf_i : olvds
	port map (
		a  => i,
		z  => o_p,
		zn => o_n);
end;

library ieee;
use ieee.std_logic_1164.all;

entity idbuf is
	port (
		i_p : in std_logic;
		i_n : in std_logic;
		o   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of idbuf is
begin
	idbuf_i : ilvds
	port map (
		a  => i_p,
		an => i_n,
		z  => o);
end;
