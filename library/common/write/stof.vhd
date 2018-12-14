library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity stof is
	generic (
		minus : std_logic_vector(4-1 downto 0) := x"d";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		zero  : std_logic_vector(4-1 downto 0) := x"0";
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		space : std_logic_vector(4-1 downto 0) := x"f";
		check : boolean := true);
		
	port (
		left    : in  std_logic_vector;
		right   : in  std_logic_vector;
		sgnfcnd : in  std_logic_vector;
		fixfmt  : out std_logic_vector);
end;
		
architecture def of stof is

begin


	process (left, sgnfcnd)
		variable fmt  : unsigned(fixfmt'length-1 downto 0);
		variable scnd : unsigned(0 to sgnfcnd'length-1);
	begin
		for i in 0 to fixfmt'length/space'length-1 loop
			scnd := unsigned(sgnfcnd);
			if signed(left)+i < 0 then
				fmt(space'range) := unsigned(zero);
			elsif signed(left)+i=0 then 
				fmt(space'range) := unsigned(dot);
			elsif signed(left)-i > 0 then
				fmt(space'range) := unsigned(scnd(space'reverse_range));
				scnd := scnd rol space'length;
			elsif signed(left)-i=0 then 
				fmt(space'range) := unsigned(dot);
			else
				fmt(space'range) := unsigned(scnd(space'reverse_range));
				scnd := scnd rol space'length;
			end if;
			fmt  := fmt rol space'left;
		end loop;
	end process;
	
	process (right, sgnfcnd)
		variable fmt  : unsigned(fixfmt'length-1 downto 0);
		variable scnd : unsigned(0 to sgnfcnd'length-1);
	begin
		for i in 0 to fixfmt'length/space'length-1 loop
			scnd := unsigned(sgnfcnd);
			if signed(right)-i >= 0 then
				fmt(space'range) := unsigned(zero);
			elsif signed(right)-i=0 then 
				fmt(space'range) := unsigned(dot);
			elsif signed(right)+i > 0 then
				fmt(space'range) := unsigned(scnd(space'reverse_range));
				scnd := scnd ror space'length;
			elsif signed(right)+i=0 then 
				fmt(space'range) := unsigned(dot);
			else
				fmt(space'range) := unsigned(scnd(space'reverse_range));
				scnd := scnd ror space'length;
			end if;
			fmt  := fmt rol space'left;
		end loop;
	end process;
	
end;
