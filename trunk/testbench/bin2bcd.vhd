library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end;

architecture bin2def of testbench is
	constant n : natural := 12;
	constant m : natural := 16;

	signal clk : std_logic := '0';
	signal ld  : std_logic := '1';
	signal bcd : std_logic_vector(15 downto 0);
begin
	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			ld <= '0';
		end if;
	end process;

	du : entity work.bin2bcd
 	generic map (
		n => n,
		m => m)
	port map (
		clk => clk,
		ld  => ld,
		bin => X"579",
		bcd => bcd);
end;
