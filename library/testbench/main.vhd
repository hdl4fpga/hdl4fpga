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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity main is
end;

architecture def of main is
begin
	process
		variable video_addr : std_logic_vector(13-1 downto 0);
		variable time_offset : std_logic_vector(14-1 downto 0);

		constant video_size : natural := 2**video_addr'length/2;
		variable index   : signed(time_offset'length-1  downto 0);
		variable bound   : signed(time_offset'length-1  downto 0);
		variable base    : signed(video_addr'length-1 downto 0);
		variable rd_addr : signed(video_addr'length-1 downto 0);
		variable wr_addr : signed(video_addr'length-1 downto 0);
		variable delay   : signed(time_offset'range);

		variable running : std_logic := '0';
		variable valid : std_logic;
		variable mesg : line;
	begin
		for i in 0 to 2**video_addr'length-1 loop
			video_addr := std_logic_vector(to_unsigned(i, video_addr'length));
			delay := (others => '0');
			index := signed(resize(unsigned(video_addr), index'length));
			video_valid_p : valid := setif(not running='1',
				setif(index > -video_size and delay <= index and -2*video_size < delay-index),
				setif(index > -video_size and delay <= index and -2*video_size < delay-index+bound));

			if valid='0' then
				if not (index > -video_size)  then
					write (mesg, string'("primero"));
					write (mesg, std_logic_vector(index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(to_signed(-video_size, index'length)));
					writeline (output, mesg);
					wait;
				end if;
				if not (delay <= index)  then
					write (mesg, string'("segundo"));
					write (mesg, string'(" : "));
					write (mesg, std_logic_vector(index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(delay));
					writeline (output, mesg);
					wait;
				end if;
				if not (-2*video_size < delay-index)  then
					write (mesg, string'("tercero"));
					write (mesg, string'(" : "));
					write (mesg, std_logic_vector(index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(delay-index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(to_signed(-video_size, index'length)));
					writeline (output, mesg);
					wait;
				end if;
				write (mesg, std_logic_vector'(video_addr));
				write (mesg, string'(" : "));
				write (mesg, to_integer(unsigned(video_addr)));
				writeline (output, mesg);
			else
				if (-video_size < delay-index)  then
					write (mesg, string'("tercero"));
					write (mesg, string'(" : "));
					write (mesg, -2*video_size);
					write (mesg, string'(" : "));
					write (mesg, to_integer(index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(delay-index));
					write (mesg, string'(" : "));
					write (mesg, to_integer(to_signed(-video_size, index'length)));
					writeline (output, mesg);
				end if;
			end if;
		end loop;
		wait;
	end process;

end;
