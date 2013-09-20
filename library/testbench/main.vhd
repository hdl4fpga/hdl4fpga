library ieee;
use ieee.std_logic_1164.all;

entity main is
	port (
		i : in std_logic;
		o : out std_logic);
end;

architecture pgm of main is
	function pru
		generic (
			type mytype)
		parameter (
			arg : mytype)
		return mytype is
	begin
		return arg;
	end;

	function pp is new pru generic map(mytype => std_logic);
	function pp is new pru generic map(mytype => std_logic_vector);
begin
	o <= pp(i);
end;
