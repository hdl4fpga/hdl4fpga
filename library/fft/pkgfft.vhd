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
use ieee.numeric_std.all;
use ieee.math_real.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

package fft is

	constant n : natural := 18;
	constant p : natural := 18;

	type cfixed is record
		re : sfixed(n-1 downto 0);
		im : sfixed(n-1 downto 0);
	end record;
	type cfixed_vector is array (natural range <>) of cfixed;

	type ctwd is record
		re : sfixed(-1 downto -p);
		im : sfixed(-1 downto -p);
	end record;
	type ctwd_vector is array (natural range <>) of ctwd;

	function "+" (
		constant arg1 : cfixed;
		constant arg2 : cfixed) 
		return cfixed;

	function "-" (
		constant arg : cfixed)
		return cfixed;

	function "-" (
		constant arg1 : cfixed;
		constant arg2 : cfixed) 
		return cfixed;

	function "*" (
		constant arg1 : cfixed;
		constant arg2 : ctwd) 
		return cfixed;

	function sin (
		constant i : natural;
		constant n : natural;
		constant p : natural)
		return std_logic_vector;

	function to_stdlogicvector (
		constant arg : sfixed)
		return std_logic_vector;

end package;

package body fft is

	function "+" (
		constant arg1 : cfixed;
		constant arg2 : cfixed) 
		return cfixed is
		variable val : cfixed;
	begin
		val.re := arg1.re + arg2.re;
		val.im := arg1.im + arg2.im;
		return val;
	end;

	function "-" (
		constant arg : cfixed)
		return cfixed is
	begin
		return (re => -arg.re, im => -arg.im);
	end;

	function "-" (
		constant arg1 : cfixed;
		constant arg2 : cfixed) 
		return cfixed is
		variable val : cfixed;
	begin
		val.re := arg1.re - arg2.re;
		val.im := arg1.im - arg2.im;
		return val;
	end;

	function "*" (
		constant arg1 : cfixed;
		constant arg2 : ctwd) 
		return cfixed is
		variable val : cfixed;
	begin
		val.re := resize(arg1.re*arg2.re - arg1.im*arg2.im, val.re);
		val.im := resize(arg1.re*arg2.im + arg1.im*arg2.re, val.im);
		return val;
	end;

	function sin (
		constant i : natural;
		constant n : natural;
		constant p : natural)
		return std_logic_vector is
		constant ph : real := (2.0*math_pi*real(i))/real(n);
	begin
		return std_logic_vector(to_unsigned(integer(round(2.0**p*sin(ph))), p));
	end function;

	function to_stdlogicvector (
		constant arg : sfixed)
		return std_logic_vector is
	begin
		return std_logic_vector(to_signed(arg,arg'length));
	end;

end package body;
