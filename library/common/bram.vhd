--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity bram is
	port (
		clka  : in  std_logic;
		addra : in  std_logic_vector;
		enaa  : in  std_logic := '1';
		wea   : in  std_logic;
		dia   : in  std_logic_vector;
		doa   : out std_logic_vector;

		clkb  : in  std_logic;
		addrb : in  std_logic_vector;
		enab  : in  std_logic := '1';
		web   : in  std_logic;
		dib   : in  std_logic_vector;
		dob   : out std_logic_vector);
		
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of bram is
	subtype word is std_logic_vector(max(dia'length,dib'length)-1 downto 0);
	type word_vector is array (natural range <>) of word;

	shared variable ram : word_vector (2**hdl4fpga.std.min(addra'length,addrb'length)-1 downto 0);
begin
	process (clka)
		variable addr : std_logic_vector(addra'range);
	begin
		if rising_edge(clka) then
			if enaa='1' then
				doa <= ram(to_integer(unsigned(addr)));
				if wea='1' then
					ram(to_integer(unsigned(addra))) := dia;
				end if;
				addr := addra;
			end if;
		end if;
	end process;

	process (clkb)
		variable addr : std_logic_vector(addrb'range);
	begin
		if rising_edge(clkb) then
			if enab='1' then
				dob <= ram(to_integer(unsigned(addr)));
				if web='1' then
					ram(to_integer(unsigned(addrb))) := dib;
				end if;
				addr := addrb;
			end if;
		end if;
	end process;
end;
