library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bsbench is
end;

architecture bench of bsbench is
	constant N : natural := 32;
	constant M : natural := 6;
	
	component workbench
		port (
		    reset   : in  std_logic;
			clock   : in  std_logic;
			rotate  : in  std_logic;
			arthSht : in  std_logic;
			outVal  : out std_logic_vector(N-1 downto 0));
	end component;

	signal rst    : std_logic := '1';
	signal ash    : std_logic := '0';
	signal rot    : std_logic := '0';
	signal clk    : std_logic := '0';
	signal outVal : std_logic_vector(N-1 downto 0);

begin

	UUT: workbench
		port map (
		    reset  => rst,
			clock  => clk,
			rotate => rot,
			arthSht => ash,
			outVal => outVal);

	rst <= '0' after 280 ns;
	
	process
	begin
		for i in 0 to 63 loop
	        clk <= not clk after 40 ns;
			wait on clk;
		end loop;
		wait;
	end process;
end;
