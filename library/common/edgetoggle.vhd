library ieee;
use ieee.std_logic_1164.all;

entity edgetoggle is
	port (
		clk   : in  std_logic;
		d     : in  std_logic;
		t     : buffer std_logic);
end;

architecture def of edgetoggle is
begin

	process (d, clk)
		variable q0 : std_logic;
	begin
		if rising_edge(clk) then
			t  <= t xor (not q0 and d);
			q0 := d;
		end if;
	end process;

end;
