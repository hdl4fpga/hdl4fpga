library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_mpu of testbench is
	constant data_phases : natural := 4;
	constant data_edges  : natural := 2;
	constant period : time := 4 ns;
	constant word_size : natural := 1;
	constant byte_size : natural := 1;

	signal clk : std_logic := '0';
	signal sys_clks : std_logic_vector(0 to data_phases/data_edges-1);
	signal sys_rea : std_logic := '0';
begin
	clk <= not clk after period/2;
	du : entity hdl4fpga.xdr_mpu
	generic map (
		lat_RCD =>;
		lat_RFC =>;
		lat_WR  =>;
		lat_RP  =>);
	port map (
		xdr_mpu_bl  =>;
		xdr_mpu_cl  =>;
		xdr_mpu_cwl =>;

		xdr_mpu_rst =>;
		xdr_mpu_clk =>;
		xdr_mpu_cmd =>;
		xdr_mpu_rdy =>;
		xdr_mpu_act =>;
		xdr_mpu_cas =>;
		xdr_mpu_ras =>;
		xdr_mpu_we  =>;

		xdr_mpu_rea  =>;
		xdr_mpu_rwin =>;
		xdr_mpu_wri  =>;
		xdr_mpu_wwin =>);

end;
