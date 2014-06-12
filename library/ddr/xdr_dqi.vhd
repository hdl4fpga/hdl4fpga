library ieee;
use ieee.std_logic_1164.all;

entity xdr_dqi is
	generic (
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 2);
	port (
		sys_clk : in  std_logic_vector;
		sys_dqi : in  std_logic_vector(byte_size*data_phases-1 downto 0);
		xdr_dqi : out std_logic_vector(byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture std of xdr_dqo is
begin
	byte_g : for i in byte_size-1 downto 0 generate
		signal dqi : std_logic_vector(0 to data_phases-1);
	begin
		ixdr_i : entity hdl4fpga.iddr
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges)
		port map (
			clk => sys_clk(sys_clk'right),
			d   => xdr_dqi(i),
			q   => dqi);
	end generate;
end;
