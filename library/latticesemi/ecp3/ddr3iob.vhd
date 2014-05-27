library ieee;
use ieee.std_logic_1164.all;

entity ddr3iob is
	port (
		di : in  std_logic_vector;
		dt : out std_logic_vector;
		do : out std_logic_vector;
		io : inout std_logic_vector);
end;

architecture ecp3 is ddr3iob is
begin
	iob_g : for i in io'range generate
		io(i) <= do(i) when dt(i)='0' else 'Z';
		di(i) <= io(i);
	end generate;
end;
