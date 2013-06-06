library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity align is
	generic (
		n : natural := 1;
		d : natural_vector);
	port (
		clk : in  std_logic;
		ena : in  std_logic := '1';
		di  : in  std_logic_vector(0 to n-1);
		do  : out std_logic_vector(0 to n-1));
end;

architecture arch of align is
	constant dly : natural_vector(0 to d'length-1) := d;
begin
	delay: for i in 0 to n-1 generate
		signal q : std_logic_vector(0 to dly(i));
	begin
		q(q'right) <= di(i);
		process (clk)
		begin
			if rising_edge(clk) then
				if ena='1' then
					q(0 to q'right-1) <= q(1 to q'right);
				end if;
			end if;
		end process;
		do(i) <= q(0);
	end generate;
end;
