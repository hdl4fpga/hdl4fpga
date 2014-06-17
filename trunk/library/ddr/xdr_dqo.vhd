library ieee;
use ieee.std_logic_1164.all;

entity xdr_dqo is
	generic (
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 2);
	port (
		sys_clk : in  std_logic_vector(0 to data_phases-1);

		sys_dqz : in  std_logic;
		sys_dqo : in  std_logic_vector(byte_size*data_phases-1 downto 0);

		xdr_dqz : out std_logic_vector(byte_size-1 downto 0);
		xdr_dqo : out std_logic_vector(byte_size-1 downto 0));
end;

library hdl4fpga;

architecture std of xdr_dqo is
begin
	byte_g : for i in 0 to byte_size-1 generate
		oddrt_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk(sys_clk'right),
			d   => sys_dqz,
			q   => xdr_dqz(i));

		oddr_i : entity hdl4fpga.oddr
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges)
		port map (
			clk => sys_clk,
			d   => sys_dqo(i),
			q   => xdr_dqo(i));
	end generate;
end;
