library ieee;
use ieee.std_logic_1164.all;

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

library unisim;
use unisim.vcomponents.all;

architecture mix of ddr_st is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin
	rclk <= 
		not ddr_st_clk when ddr_st_hlf='1' else
		ddr_st_clk;

	fclk <= 
		ddr_st_clk when ddr_st_hlf='1' else
		not ddr_st_clk;

	oddr_du : oddr2
	port map (
		c0 => rclk,
		c1 => fclk,
		ce => '1',
		r  => '0',
		s  => '0',
		d0 => ddr_st_drr,
		d1 => ddr_st_drf,
		q  => ddr_st_dqs);
end;
