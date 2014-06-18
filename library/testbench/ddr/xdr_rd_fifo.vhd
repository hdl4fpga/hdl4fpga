library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_rd_fifo of testbench is
	signal sys_clk : std_logic := '1';
	signal xdr_dqsi : std_logic := '1';
	signal xdr_dqi : std_logic_vector(8-1 downto 0);
	signal xdr_win_dq : std_logic;
	signal xdr_win_dqs : std_logic;
	signal sys_do  : std_logic_vector(2**2*xdr_dqi'length-1 downto 0)
begin
	sys_clk <= not sys_clk after 2 ns;
	xdr_dqsi <= not sys_clk after 2 ns;
	sys_rea <= '0', '1' after 4 ns;
	xdr_win_dq <= '0';
	xdr_win_dqs <= '0';

	xdr_rd_fifo_e : entity hdl4fpga.xdr_rd_fifo
	generic map (
		data_delay  : natural := 1;
		data_edges  : natural := 2;
		data_phases : natural := sys_do'length/xdr_dqi'length;
		byte_size   : natural := xdr_dqi'length)
	port map (
		sys_clk => sys_clk,
		sys_rdy => sys_rdy,
		sys_rea => sys_rea,
		sys_do  => sys_do,

		xdr_win_dq  => xdr_win_dq,
		xdr_win_dqs => xdr_win_dqs,
		xdr_dqsi => xdr_dqsi,
		xdr_dqi  => xdr_dqi);
end;
