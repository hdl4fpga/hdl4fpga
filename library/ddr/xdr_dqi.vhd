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

	constant r : natural := 0;
	constant f : natural := 1;

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture std of xdr_dqo is
begin
	bits_g : for i in byte_size-1 downto 0 generate
		oddrt_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk(sys_clk'right),
			d   => sys_dqz,
			q   => xdr_dqz);

		oxdr_i : entity hdl4fpga.ddri
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges)
		port map (
			d   => xdr_dqo(i),
			q   => sys_dqo);
	end generate;
end;
