library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;

entity xdr_stw is
	port (
		xdr_st_hlf : in  std_logic;
		xdr_st_clk : in  std_logic;
		xdr_st_drr : in  std_logic;
		xdr_st_drf : in  std_logic;
		xdr_st_dqs : out std_logic);
end;

library hdl4fpga;

architecture mix of xdr_stw is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin
	rclk <= 
		not xdr_st_clk when xdr_st_hlf='1' else
		xdr_st_clk;

	oxdr_i : entity hdl4fpga.oddr
	port map (
		clk => rclk,
		dr => xdr_st_drr,
		df => xdr_st_drf,
		q  => xdr_st_dqs);
end;
