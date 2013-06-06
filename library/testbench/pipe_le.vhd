library ieee;
use ieee.std_logic_1164.all;


architecture cypf of testbench is
	signal clk : std_logic := '0';
	signal rdy : std_logic;
	signal req : std_logic;
begin
	clk <= not clk after 5 ns;
	du : entity work.cypf
	generic map (
		m => 4,
		n => 5)
	port map (
		clk => clk,
		req => req,
		rdy => rdy,
		dly => "1000",
		xi => xi,
		xo => xo);
end;
