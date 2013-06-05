library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc is
	generic (
		n : natural);
    port (
        clk : in std_logic;
		pl : in std_logic := '0';
		sl : in std_logic := '0';
		g  : in std_logic_vector(0 to n-1);
		x0 : in std_logic_vector(0 to n-1) := (others => '0');
		xi : in std_logic;
		xo : out std_logic;
		xp : buffer std_logic_vector(0 to n-1));
end;

architecture mix of crc is
	signal sin : std_logic;
begin
	sin <= xp(0) when sl='0' else '0';
	process (clk)
		function "and" (
			arg1 : std_logic_vector;
			arg2 : std_logic)
			return std_logic_vector is
			variable aux : std_logic_vector(arg1'range);
		begin
			for i in arg1'range loop
				aux(i) := arg1(i) and arg2;
			end loop;
			return aux;
		end;
	begin
		if rising_edge(clk) then
			if pl='1' then
				xp <= x0;
			else
				xp <= (xp(1 to n-1) & xi) xor (g and sin);
			end if;
		end if;
	end process;
end;
