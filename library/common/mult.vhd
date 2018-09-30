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

entity mult is
	port (
		clk     : in  std_logic := '-';
		multand : in  std_logic_vector;
		multier : in  std_logic_vector;
		product : out std_logic_vector);
end;

architecture def of mult is

	function mult_f (
		constant multand : signed;
		constant multier : unsigned);
		return std_logic_vector is
		variable retval : signed(0 to multand'length+multier'length-1) := (others => '0');
	begin
		retval(0 to multier'length-1) := signed(multier);
		retval := retval rol multier'length;
		for i in multier'range loop
			lsb    := retval(retval'right);
			retval := shift_right(retval, 1);
			if lsb='1' then
				retval(0 to multand'length) := retval(0 to multand'length) + resize(multand, multand'length+1);
			end if;
			retval := shift_right(retval, 1);
		end loop;
		return retval;
	end;

	function macc_f 
		constant product : signed;
		constant multand : signed;
		constant multier : unsigned)
		return std_logic_vector is
		variable lsb    : std_logic;
		variable retval : signed(0 to product'length+multier'length-1);
	begin
		retval(0 to multier'length-1) := signed(multier);
		retval := retval rol multier'length;
		retval(0 to product'length-1) := product;
		for i in multier'range loop
			lsb    := retval(retval'right);
			retval := shift_right(retval, 1);
			if lsb='1' then
				retval(0 to multand'length) := retval(0 to multand'length) + resize(multand, multand'length+1);
			end if;
		end loop;
		return retval;
	end;


begin
	process (clk)
		variable p : std_logic_vector(0 to multand'length+multier'length-1);
	begin
		if rising_edge(clk) then
			if ld='1' then
				p := mult_f((p'range => '0'), multand, (0 to 0 => multier(multier'right)));
			else
				p := mult_f(multand, p);
			end if;
			
		end if;
	end process;
end;
