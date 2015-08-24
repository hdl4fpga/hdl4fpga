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

function split (
	constant arg : std_logic_vector)
	return %byte%_vector is
	variable dat : unsigned(arg'length-1 downto 0);
	variable val : %byte%_vector(arg'length/%byte%'length-1 downto 0);
begin
	dat := unsigned(arg);
	for i in val'reverse_range loop
		val(i) := std_logic_vector(dat(%byte%'range));
		dat := dat srl val(val'left)'length;
	end loop;
	return val;
end;

function join (
	constant arg : %byte%_vector)
	return std_logic_vector is
	variable dat : %byte%_vector(arg'length-1 downto 0);
	variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
begin
	dat := unsigned(arg);
	for i in dat'range loop
		val := val sll arg(arg'left)'length;
		val(arg(arg'left)'range) := dat(i);
	end loop;
	return val;
end;
