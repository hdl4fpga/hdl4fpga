library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_rd_fifo of testbench is
	signal sys_clk : std_logic := '1';
	signal sys_clk2 : std_logic := '1';
	signal sys_rea : std_logic;
	signal sys_rdy : std_logic;
	signal xdr_dqsi : std_logic := '1';
	signal xdr_dqi : std_logic_vector(8-1 downto 0);
	signal xdr_win_dq : std_logic;
	signal xdr_win_dqs : std_logic;
	signal sys_do  : std_logic_vector(2**4*xdr_dqi'length-1 downto 0);
begin
	sys_clk <= not sys_clk after 2 ns;
	sys_clk2 <= not sys_clk2 after (sys_do'length/xdr_dqi'length) * 1 ns;
	xdr_dqsi <= sys_clk after 50 ps;
	sys_rea <= '0', '1' after 80 ns;
	xdr_win_dq <= '0', '1' after 129 ns, '0' after 463 ns;
	xdr_win_dqs <= '0', '1' after 81 ns, '0' after 463 ns;

	process (xdr_dqsi)
		type byte_vector is array (natural range <>) of std_logic_vector(xdr_dqi'range);
		constant dqi : byte_vector(0 to 16-1) := ( x"ab", x"34", x"75", x"89", x"e6", x"bc", x"fd", x"21",
		x"bb", x"33", x"77", x"99", x"ee", x"bb", x"dd", x"a1");
		variable i : natural range 0 to dqi'length-1;
	begin
		xdr_dqi <= dqi(i);
		i := (i+1) mod dqi'length;
	end process;

	xdr_rd_fifo_e : entity hdl4fpga.xdr_rd_fifo
	generic map (
		data_delay  => 1,
		data_edges  => 2,
		data_phases => sys_do'length/xdr_dqi'length,
		byte_size   => xdr_dqi'length)
	port map (
		sys_clk => sys_clk2,
		sys_rdy => sys_rdy,
		sys_rea => sys_rea,
		sys_do  => sys_do,

		xdr_win_dq  => xdr_win_dq,
		xdr_win_dqs => xdr_win_dqs,
		xdr_dqsi => xdr_dqsi,
		xdr_dqi  => xdr_dqi);
end;
