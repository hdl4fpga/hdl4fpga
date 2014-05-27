library ieee;
use ieee.std_logic_1164.all;

entity ddr3iob is
	port (
		di : out  std_logic_vector;
		dt : in std_logic_vector;
		do : in std_logic_vector;
		io : inout std_logic_vector);
end;

architecture ecp3 of ddr3iob is
begin
	iob_g : for i in io'range generate
		io(i) <= do(i) when dt(i)='0' else 'Z';
		di(i) <= io(i);
	end generate;
end;
