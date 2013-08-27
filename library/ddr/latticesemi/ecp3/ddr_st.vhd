library ieee;
use ieee.std_logic_1164.all;

entity ddr_st is
	port (
		ddr_st_hlf : in  std_logic;
		ddr_st_clk : in  std_logic;
		ddr_st_drr : in  std_logic;
		ddr_st_drf : in  std_logic;
		ddr_st_dqs : out std_logic);
end;

library ecp3;
use unisim.vcomponents.all;

architecture def of ddr_st is
	signal clk : std_logic;
begin
	clk <= 
		not ddr_st_clk when ddr_st_hlf='1' else
		ddr_st_clk;

	oddr_i : oddrxd
	port map (
		sclk => clk,
		dqclk1 => clk,
		da => ddr_st_drr,
		db => ddr_st_drf,
		q  => ddr_st_dqs);

end;
