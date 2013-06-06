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
