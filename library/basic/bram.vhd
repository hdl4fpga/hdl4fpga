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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity bram is
	generic (
		bitrom : std_logic_vector := (1 to 0 => '-'));
	port (
		clka  : in  std_logic;
		addra : in  std_logic_vector;
		enaa  : in  std_logic := '1';
		wea   : in  std_logic := '0';
		dia   : in  std_logic_vector;
		doa   : out std_logic_vector;

		clkb  : in  std_logic;
		addrb : in  std_logic_vector;
		enab  : in  std_logic := '1';
		web   : in  std_logic := '0';
		dib   : in  std_logic_vector;
		dob   : out std_logic_vector);
		
end;

architecture inference of bram is
	subtype word is std_logic_vector(max(dia'length,dib'length)-1 downto 0);
	type word_vector is array (natural range <>) of word;


	function init_ram (
		constant bitrom : std_logic_vector;
		constant size   : natural)
		return   word_vector is
		variable aux    : std_logic_vector(0 to size*word'length-1);
		variable retval : word_vector(0 to size-1);
	begin
		aux(0 to bitrom'length-1) := bitrom;
		if bitrom'length > 0 then  -- "if" WORKAROUND suggested by emard @ github.com
			for i in retval'range loop
				retval(i) := aux(i*retval(0)'length to (i+1)*retval(0)'length-1);
			end loop;
		end if;
		return retval;
	end;

	constant addr_size : natural := hdl4fpga.base.min(addra'length,addrb'length);

	shared variable ram : word_vector(0 to 2**addr_size-1) := init_ram(bitrom, 2**addr_size);

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
