library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dq is
	generic (
		debug_delay : time := 0 ns;
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dqz : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dq_r : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_f : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq  : inout std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dqi : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture spartan3 of ddr_io_dq is
	signal ddr_io_fclk : std_logic;
begin
	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in data_bytes-1 downto 0 generate
		bits_g : for j in byte_bits-1 downto 0 generate
			signal dqo : std_logic;
			signal dqz : std_logic;
			signal di  : std_logic;
		begin

			oddr : oddr
			port map (
				clk ddr_io_clk,
				dr => ddr_io_dq_r(i*byte_bits+j),
				df => ddr_io_dq_f(i*byte_bits+j),
				q  => dqo);

			oddrt : fdrse
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

			ddr_io_dqi(i*byte_bits+j) <= transport di after debug_delay;
		end generate;
	end generate;
end;
