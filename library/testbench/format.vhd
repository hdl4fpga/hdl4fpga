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
use hdl4fpga.std.all;

entity format_bcd is
	port (
		value  : in  std_logic_vector;
		right  : in  std_logic_vector;
		align  : in  std_logic := '1';
		format : out std_logic_vector);
end;
		
architecture def of format_bcd is
	function bcd_format (
		constant value : std_logic_vector;
		constant right : std_logic_vector;
		constant align : std_logic := '0') 
		return std_logic_vector is
		variable temp  : std_logic_vector(value'length-1 downto 0);
		variable digit : std_logic_vector(4-1 downto 0);

		constant dot   : std_logic_vector(digit'range) := x"b";
		constant space : std_logic_vector(digit'range) := x"f";

	begin

		temp  := value;
		digit := dot;

		if signed(right) < 0 then

			for i in 0 to value'length/4-1 loop
				if signed(right)+i < 0 then
					temp := std_logic_vector(unsigned(temp) ror 4);
					if temp(4-1 downto 0)=x"f" then
						temp(digit'range) := x"0";
					end if;
				end if;
			end loop;

			temp := std_logic_vector(unsigned(temp) rol 4);
			swap(digit, temp(digit'range));

			for i in 0 to value'length/4-1 loop
				if signed(right)+i < 0 then
					temp := std_logic_vector(unsigned(temp) rol 4);
					swap(digit, temp(digit'range));
				end if;
			end loop;

		end if;

		if align='1' then
			for i in 0 to value'length/4-1 loop
				temp := std_logic_vector(unsigned(temp) rol 4);
				if temp(digit'range) /= space then
					temp := std_logic_vector(unsigned(temp) ror 4);
					exit;
				end if;
			end loop;
		end if;

		return temp;
	end;

begin
	format <= bcd_format(
		value => value,
		right => right,
		align => align);
		
end;
