use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

entity main is
end;

architecture pgm of main is
begin
	process
		variable cnt : std_logic_vector(0 to 5);
		variable msg : line;

		function graycode_succ (
			arg : std_logic_vector)
			return std_logic_vector is
			variable a : std_logic_vector(arg'length-1 downto 0);
			variable t : std_logic_vector(a'range) := (others => '0');
		begin
			a:= arg;
			for i in a'reverse_range loop
				for j in i to a'left loop
					t(i) := t(i) xor a(j);
				end loop;
				t(i) := not t(i);
				for j in 0 to i-1 loop
					t(i) := t(i) and (not t(j));
				end loop;
			end loop;
			if t(a'left-1 downto 0)=(1 to a'left => '0') then
				t(a'left) := '1';
			end if;
			return a xor t;
		end function;
	begin
		cnt := (others => '0');
		for i in 0 to 2**cnt'length-1 loop
			write (msg, cnt xor graycode_succ(cnt));
			writeline (output, msg);
			cnt := graycode_succ(cnt);
		end loop;
		wait;
	end process;
end;
