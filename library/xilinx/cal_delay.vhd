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

library unisim;
use unisim.vcomponents.all;

entity cal_delay is
	generic (
		m : natural := 2);
    port (
		r : in std_logic;
		a : in std_logic;
		o : out std_logic;
		q : out std_logic_vector(0 to 8*m-1));
end;

architecture mix of cal_delay is

	function to_ascii (
		constant arg : integer)
		return string is
		constant dgt : string(1 to 10) := "0123456789";
		variable buf : string(1 to 32);
		variable aux : natural;
		variable n : natural;
	begin
		aux := arg;
		if arg < 0 then
			aux := -aux;
		end if;

		n := 1;
		loop
			buf := dgt(aux mod 10 + 1) & buf(1 to buf'right-1);
			aux := aux / 10;
			exit when aux=0;
			n := n + 1;
		end loop;

		if arg < 0 then
			buf := '-' & buf(1 to buf'right-1);
			n := n + 1;
		end if;
		return buf(1 to n);
	end function;

	function to_string (
		constant arg : character)
		return string is
		variable aux : string(1 to 1);
	begin
		aux(1) := arg;
		return aux;
	end function;
		
	function loc_slice (
		constant x : integer;
		constant y : integer) 
		return string is
	begin
		return "X" & to_ascii(x) & "Y" & to_ascii(y);
	end function;

	constant lutxclb: natural := 8;
	constant lutxslc: natural := 2;
	constant slcxclb: natural := 4;
	constant slcxhnd: natural := 2;
	signal p : std_logic_vector(0 to m*8);
	signal q1 : std_logic_vector(0 to m*8);
begin
	p(0) <= a;
	o <= p(m*lutxclb);
	clb: for c in 0 to m-1 generate

		attribute bel : string;
		attribute loc : string;
		attribute rloc : string;
		attribute lock_pins: string;
		attribute u_set : string;
		attribute maxdelay : string;
	begin
		col: for x in 0 to 1 generate
			row: for y in 0 to 1 generate
				type string is array (natural range <>) of character;
				constant blut : string(0 to 1) := "FG";
			begin
				lc: for b in 0 to 1 generate 
					attribute bel   of lut, ffd: label is to_string(blut(b));
					attribute rloc  of lut, ffd: label is loc_slice(2*x+c mod 2,y+2*(c/2));
					attribute u_set of lut, ffd : label is "mio";
					function n (
						constant x : integer;
						constant y : integer;
						constant b : natural)
						return natural is
					begin
						return x + lutxslc*(b + slcxhnd*y + slcxclb*c);
					end function;

				begin
					lut: lut4
					generic map (
						init => x"e2e2")
					port map (
						i0 => '1',
						i1 => p(n(x,y,b)),
						i2 => '0',
						i3 => '1',
						o  => p(n(x,y,b)+1));

					ffd: fdrse
					generic map (
						init => '0')
					port map (
						s => '0',
						r => r,
						d => p(n(x,y,b)+1),
						c => a,
						ce => '1',
						q => q1(n(x,y,b)));
							
				end generate lc;
			end generate row;
		end generate col;
	end generate clb;

	q1(q1'right) <= '1';
	xnor_ff : for i in q'range generate
		signal xnor_out : std_logic;
	begin
		xnor_out <= q1(i) xnor q1(i+1);
		ffd : fdrse
		generic map (
			init => '0')
		port map (
			s => '0',
			r => r,
			d => xnor_out,
			c => a,
			ce => '1',
			q => q(i));
	end generate;

end;
