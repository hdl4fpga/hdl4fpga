library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;

entity ddr_stw is
	port (
		ddr_st_hlf : in  std_logic;
		ddr_st_clk : in  std_logic;
		ddr_st_drr : in  std_logic;
		ddr_st_drf : in  std_logic;
		ddr_st_dqs : out std_logic);
end;

library hdl4fpga;

architecture mix of ddr_stw is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin
	rclk <= 
		not ddr_st_clk when ddr_st_hlf='1' else
		ddr_st_clk;

	oddr_i : entity hdl4fpga.ddro
	port map (
		clk => rclk,
		dr => ddr_st_drr,
		df => ddr_st_drf,
		q  => ddr_st_dqs);
end;
