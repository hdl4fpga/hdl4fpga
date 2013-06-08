library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

architecture ddr_pgm of testbench is
	signal ddr_clk : std_logic := '0';
	signal ddr_clk90 : std_logic := '0';
	signal ddr_rst : std_logic := '1';
	signal ddr_ras : std_logic := '1';
	signal ddr_cas : std_logic := '1';
	signal ddr_we  : std_logic := '1';
	signal ddr_as  : std_logic := '1';
	signal ddr_rw  : std_logic := '0';
	signal ddr_ref : std_logic := '1';
	type str10_vector is array (natural range <>) of string(1 to 7);
	constant ddr_cname : str10_vector(0 to 7) := 
		("DDR_LRM", "DDR_AUT", "DDR_PRE", "DDR_ACT", "DDR_WRT", "DDR_REA", "DDR_BRT", "DDR_NOP");
begin

	ddr_clk <= not ddr_clk after 5 ns;
	du : entity hdl4fpga.ddr_pgm
	port map (
		ddr_pgm_rst => ddr_rst,
		ddr_pgm_clk => ddr_clk);
end;
