library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dq is
	generic (
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dqz : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dq_r : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_f : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq  : inout std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dqi : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dq is
	signal ddr_io_fclk : std_logic;
begin
	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in ddr_io_dqz'range generate
		bits_g : for j in byte_bits-1 downto 0 generate
			signal dqo : std_logic;
			signal dqz : std_logic;
			signal di : std_logic;
		begin

			oddr_du : oddr
			port map (
				r => '0',
				s => '0',
				c => ddr_io_clk,
				ce => '1',
				d1 => ddr_io_dq_r(i*byte_bits+j),
				d2 => ddr_io_dq_f(i*byte_bits+j),
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
			idelay_i : idelay 
			port map (
				rst => '0',
				c  =>'0',
				ce => '0',
				inc => '0',
				i => di,
				o => ddr_io_dqi(i*byte_bits+j));
--			ddr_io_dqi(i*byte_bits+j) <= di;
		end generate;
	end generate;
end;
