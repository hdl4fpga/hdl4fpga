library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

entity main is
end;

architecture ip_checksum of main is

	function oneschecksum (
		constant data : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		constant n : natural := (data'length+size-1)/size;
		variable aux : unsigned(0 to data'length-1);
		variable checksum : unsigned(0 to size);
	begin
		aux := unsigned(data);
		checksum := (others => '0');
		for i in 0 to n-1 loop
			checksum := checksum + resize(unsigned(aux(0 to checksum'right-1)), checksum'length);
			if checksum(0)='1' then
				checksum := checksum + 1;
			end if;
			aux := aux sll checksum'right;
		end loop;
		return std_logic_vector(checksum(1 to size));	
	end;

	function ipheader_checksum(
		constant ipheader : std_logic_vector)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to ipheader'length-1);
	begin
		aux := ipheader;
		aux(80 to 96-1) := not checksum(ipheader, 16);
		return aux;
	end;
begin

	process
		variable msg : line;
	begin
		hwrite (msg, ipheader_checksum (
			x"4500"     & 
			x"021c"     & 
			x"0000"     & 
			x"0000"     & 
			x"0511"     & 
			x"0000"     & 
			x"c0a802c8" & 
			x"ffffffff"));
		writeline (output, msg);
		wait;
	end process;
end;
