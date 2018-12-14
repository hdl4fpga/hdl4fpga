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
		clk     : in  std_logic := '-';
		ini     : in  std_logic := '1';
		left    : in  std_logic_vector;
		right   : in  std_logic_vector;
		sgnfcnd : in  std_logic_vector;
		fixfmt  : out std_logic_vector);
end;
		
architecture def of stof is

begin

	process (left, sgnfcnd, ini, clk)
		variable fmt   : unsigned(fixfmt'length-1 downto 0);
		variable codes : unsigned(0 to sgnfcnd'length-1);
	begin

		if ini='1' then
			fmt := unsigned(fill(fmt'length, space));
			for i in 0 to fmt'length/space'length-1 loop
				if signed(left)+i < 0 then
					fmt(space'range) := unsigned(zero);
					if i=0 then
						fmt := fmt rol space'left;
						fmt(space'range) := unsigned(dot);
					end if;
				else
					exit;
				end if;
			end loop;
		end if;

		codes := unsigned(sgnfcnd);
		for i in 0 to codes'length/space'length-1 loop
			if signed(left)-i = -1 then 
				fmt(space'range) := unsigned(dot);
				fmt := fmt sll space'left;
			end if;
			fmt(space'range) := unsigned(codes(space'reverse_range));
			codes := codes sll space'length;
			fmt   := fmt   rol space'length;
		end loop;

	end process;
	
	process (right, sgnfcnd)
		variable fmt   : unsigned(fixfmt'length-1 downto 0);
		variable codes : unsigned(sgnfcnd'length-1 downto 0);
	begin
		if ini='1' then
			fmt := unsigned(fill(fmt'length, space));
			for i in 0 to fmt'length/space'length-1 loop
				if signed(right) > i then
					fmt(space'range) := unsigned(zero);
				else
					exit;
				end if;
				fmt := fmt srl space'left;
			end loop;
		end if;

		codes := unsigned(sgnfcnd);
		for i in 0 to codes'length/space'length-1 loop
			fmt(space'range)   := unsigned(codes(space'range));
			codes(space'range) := unsigned(space);
			codes := codes ror space'length;
			if signed(right)+i = -1 then
				fmt := fmt ror space'left;
				fmt(space'range) := unsigned(dot);
			end if;
			fmt := fmt srl space'left;
		end loop;
	end process;
	
end;
