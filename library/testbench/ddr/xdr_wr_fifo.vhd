library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_wr_fifo of testbench is
	constant byte_size   : natural := 8;
	constant data_phases : natural := 4;
	constant data_edges  : natural := 2;

	signal sys_clk  : std_logic := '1';
	signal sys_req  : std_logic;
	signal sys_di   : std_logic_vector(data_phases*byte_size-1 downto 0);
	signal xdr_clks : std_logic_vector(data_phases/data_edges-1 downto 0);
	signal xdr_enas : std_logic_vector(data_phases-1 downto 0);
	signal xdr_dqo  : std_logic_vector(data_phases*byte_size-1 downto 0);

begin

	sys_clk <= not sys_clk after 4 ns;
	process (sys_clk)
	begin
		for i in sys_clk'range loop
			xdr_clks(i) <= sys_clk after i * 1 ns;
		end loop;
	end process;
	sys_req <= '0', '1' after 80 ns;

	process (sys_clk)
		variable i : natural range 0 to dqi'length-1;
		type word is array (natural range <>) of std_logic_vector(xdr_dqo'range);
	begin
		if rising_edge(sys_clk) then
			i := (i+1) mod dqi'length;
		end if;
	end process;

	xdr_wr_fifo_e : entity hdl4fpga.xdr_wr_fifo
	generic map (
		data_edges  => data_edges,
		data_phases => data_phases,
		byte_size   => xdr_di'length/data_phases)
	port map (
		sys_clk => sys_clk,
		sys_req => sys_req,
		sys_di  => sys_di,

		xdr_clks => xdr_clks,
		xdr_enas => xdr_enas,
		xdr_dqo  => xdr_dqo);
end;
