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

entity fontrom is
	generic (
		bitrom : std_logic_vector);		-- Font Bit Rom
	port (
		clk  : in std_logic;
		code : in std_logic_vector;
		row  : in std_logic_vector;
		data : out std_logic_vector);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of fontrom is

	signal ddoa  : std_logic_vector(data'range);
	signal addrb : std_logic_vector(code'length+row'length-1 downto 0);
begin

	addrb <= code & row;
	samples_e : entity hdl4fpga.bram
	generic map (
		data =>  bitrom)
	port map (
		clka  => clk,
		addra => (addrb'range => '-'),
		enaa  => '0',
		dia   => (data'range => '-'),
		doa   => ddoa,

		clkb  => clk,
		addrb => addrb,
		dib   => (data'range => '-'),
		dob   => data);
		
end;
