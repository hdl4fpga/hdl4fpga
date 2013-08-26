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

architecture def of ddr_st is
	signal clk : std_logic;
begin
	clk <= 
		not ddr_st_clk when ddr_st_hlf='1' else
		ddr_st_clk;

	oddr_du : oddr
	port map (
		r => '0',
		s => '0',
		c => clk,
		ce => '1',
		d1 => ddr_st_drr,
		d2 => ddr_st_drf,
		q  => ddr_st_dqs);
end;
