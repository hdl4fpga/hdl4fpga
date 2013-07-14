library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dq is
	generic (
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dqz : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqh : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dql : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq  : inout std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dqi : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr_io_dq is
	signal ddr_io_fclk : std_logic;
begin
	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in 0 to data_bytes-1 generate
		bits_g : for j in 0 to byte_bits-1 generate
			signal dqo : std_logic;
			signal dqz : std_logic;
			signal di : std_logic;
		begin

			oddr_du : oddr
			port map (
				r => '0',
				s => '0',
				c => ddr_io_fclk,
				ce => '1',
				d1 => ddr_io_dql(i*byte_bits+j),
				d2 => ddr_io_dqh(i*byte_bits+j),
				q => dqo);

			ffd_i : fdrse
			port map (
				s  => '0',
				r  => '0',
				c  => ddr_io_clk,
				ce => '1',
				d  => ddr_io_dqz(i),
				q  => dqz);

			ddr_io_dq(i*byte_bits+j) <= 'Z' when dqz='1' else dqo;
			ibuf_dq : ibuf
			port map (
				i => ddr_io_dq(i*byte_bits+j),
				o => di);
			ddr_io_dqi(i*byte_bits+j) <= di;
		end generate;
	end generate;
end;
