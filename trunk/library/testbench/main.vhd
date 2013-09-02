use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

entity main is
end;

architecture pgm of main is
begin
	process
		variable msg : line;

	    function pp (
	        arg : real)
	        return string is
	        variable msg : line;
	    begin
	        write (msg, arg, digits => 7);
	        return msg.all;
	    end;

	begin
		write (msg, pp(2.8e8));
		writeline (output, msg);
		wait;
	end process;
end;
