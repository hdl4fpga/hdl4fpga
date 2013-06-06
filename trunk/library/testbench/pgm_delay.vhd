use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

architecture pgm_delay of testbench is
	constant n : natural := 4;
	signal clk : std_logic := '0';
	signal xp : std_logic;
	signal xn : std_logic;
	signal ena : std_logic_vector(0 to n-1) := (others => '0');
begin
	clk <= not clk after 5 ns;
	ena(n-n) <= '0', '1' after 40 ns;

	du : entity work.pgm_delay
	generic map (
		n => 4)
	port map (
		ena => ena,
		xi => clk,
		x_p => xp,
		x_n => xn);

end;
