library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbram is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of dbram is
begin
	ram_g : for i in n-1 downto 0 generate
		ram_i : ram16x1d
		port map (
			wclk => clk,
			we  => we,
			dpra0 => ra(0),
			dpra1 => ra(1),
			dpra2 => ra(2),
			dpra3 => ra(3),
			a0 => wa(0),
			a1 => wa(1),
			a2 => wa(2),
			a3 => wa(3),
			d  => di(i),
			dpo => do(i),
			spo => open);
	end generate;
end;
