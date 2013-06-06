library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity schmitt_trigger is
	port (
		clk : in std_logic;
		tl  : in std_logic_vector;
		th  : in std_logic_vector;
		xin : in std_logic_vector;
		stt : out std_logic);
end;

architecture def of schmitt_trigger is
	signal edge : boolean;
begin
	assert tl'length=th'length and th'length=xin'length
		report "Size missmatch"
		severity ERROR;
		
	process(clk)
	begin
		if rising_edge(clk) then
			if not edge then
				if to_integer(unsigned(xin)) >= to_integer(unsigned(th)) then
					edge <= true;
				end if;
			else
				if to_integer(unsigned(xin)) <= to_integer(unsigned(tl)) then
					edge <= false;
				end if;
			end if;
		end if;
	end process;
	stt <= '1' when edge else '0';
end;
