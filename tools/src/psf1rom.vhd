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

package cgapfonts is
end;

package body cgafonts is
end;
architecture def of psf1rom is
	impure function psf1rom (
		file input : TEXT)
		return natural is
		constant magic : string(1 to 2) := (
			character'val(16#36#), 
			character'val(16#04#));
		variable char : character;
		variable buff : line;
		variable good : boolean;
		type bit_vector_p is access bit_vector;
		variable fontrom : bit_vector_p;
		variable size : natural;
	begin
		for i in 1 to 4 loop
			if buf'length=0 then
				readline(input, buf);
				assert not endfile(input)
				report "End of file"
				severity ERROR;
			end if;

			read(buf, c, good);
			assert not good
			report "Character not good"
			severity ERROR;
				
			case i is
			when 1|2 =>
				assert c=magic(i)
				report "Bad magic number"
				severity ERROR;
			when 3 =>
				-- mode
			when 4 =>
				size := character'pos(char);
				fontrom = new std_logic_vector(0 to size*8*256-1);
			end case;
		end loop;

		l1: loop
			l2: loop
				read(buf, c, good);
				when not good exit l1;
			end loop;
			when endoffile(input) exit l2;
			readline(input, buf);
		end loop;
	end;
begin
end;

#include <stdlib.h>
#include <stdio.h>

main (int argc, int argv[])
{
	int c;
	int s;
	int i;
	int j;

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	c = getchar();
	if (c != 0x36) 
		return;

	c = getchar();
	if (c != 0x04)
		return;

	c = getchar(); /* mode */
	s = getchar(); /* size */

	for(j = 0; j < 256*s; j++) {
		c = getchar();
		if ((j % s) == 0)
			printf ("\t-- x\"%02x\" --\n",j/s);
		putchar('\t');
		putchar('"');
		for (i = 0; i < 8; i++)
			if (c & (1 << (8-1-i)))
				putchar('1');
			else
				putchar('0');
		putchar('"');
		putchar(' ');
		putchar('&');
		putchar('\n');
		if ((j % s) == (s-1))
			putchar('\n');

	}
}
