library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_wr_fifo of testbench is
	constant word_size   : natural := 32;
	constant byte_size   : natural := 8;
	constant data_phases : natural := 1;
	constant data_edges  : natural := 1;

	signal sys_clk  : std_logic := '1';
	signal sys_req  : std_logic := '1';
	signal sys_di   : std_logic_vector(data_phases*word_size-1 downto 0);
	signal sys_dmi  : std_logic_vector(sys_di'length/byte_size-1 downto 0);

	signal xdr_clks : std_logic_vector(data_phases/data_edges-1 downto 0);
	signal xdr_enas : std_logic_vector(data_phases-1 downto 0) := (others => '1');
	signal xdr_dmo  : std_logic_vector(sys_dmi'range);
	signal xdr_dqo  : std_logic_vector(sys_di'range);

begin

	sys_clk <= not sys_clk after 4 ns;
	process (sys_clk)
	begin
		for i in xdr_clks'range loop
			xdr_clks(i) <= sys_clk after i * 2 ns;
		end loop;
	end process;
	sys_req <= '0', '1' after 80 ns;
	xdr_enas <= (others => '0'), (others => '1') after 80 ns;

	process (sys_clk)
		type xdrword_vector is array (natural range <>) of std_logic_vector(xdr_dqo'range);
		constant data : xdrword_vector(0 to 2-1) := (
			0 => x"abcd_f788",
			1 => x"3421_59ee");
		type xdrdmword_vector is array (natural range <>) of std_logic_vector(xdr_dqo'length/byte_size-1 downto 0);
		constant dmdata : xdrdmword_vector (0 to 2-1) := (
			0 => x"4",
			1 => x"4");
		variable i : natural range 0 to data'length-1;
	begin
		if rising_edge(sys_clk) then
			sys_di <= data(i);
			i := (i+1) mod data'length;
		end if;
	end process;

	xdr_wr_fifo_e : entity hdl4fpga.xdr_wr_fifo
	generic map (
		data_edges  => data_edges,
		data_phases => data_phases,
		word_size   => sys_di'length/data_phases,
		byte_size   => sys_di'length/sys_dmi'length)
	port map (
		sys_clk => sys_clk,
		sys_req => sys_req,
		sys_di  => sys_di,
		sys_dm => sys_dmi,

		xdr_clks => xdr_clks,
		xdr_enas => xdr_enas,
		xdr_dmo  => xdr_dmo,
		xdr_dqo  => xdr_dqo);
end;
