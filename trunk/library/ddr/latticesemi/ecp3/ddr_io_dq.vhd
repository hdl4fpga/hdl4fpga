library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dq2 is
	generic (
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk2 : in std_logic := '0';
		ddr_io_clk290 : in std_logic := '0';
		ddr_io_dqz : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dq_r : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_f : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_r2 : in std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => '-');
		ddr_io_dq_f2 : in std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => '-');
		ddr_io_dq  : inout std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dqi : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture ecp3ea of ddr_io_dq2 is
	signal ddr_io_fclk : std_logic;
	signal dqclk0 : std_logic;
	signal dqclk1 : std_logic;
begin
	process (ddr_io_clk2)
	begin
		if rising_edge(ddr_io_clk2) then
		end if;
	end process;

	ddr_io_fclk <= not ddr_io_clk;
	bytes_g : for i in data_bytes-1 downto 0 generate
		bits_g : for j in byte_bits/2-1 downto 0 generate
			signal dqo : std_logic;
			signal dqz : std_logic;
			signal di : std_logic;
		begin

			oddr_i : oddrx2d
			port map (
				sclk => ddr_io_clk,
				dqclk0 => dqclk0,
				dqclk1 => dqclk1,
				da0 => ddr_io_dq_r(i*byte_bits+j),
				db0 => ddr_io_dq_f(i*byte_bits+j),
				da1 => ddr_io_dq_r2(i*byte_bits+j),
				db1 => ddr_io_dq_f2(i*byte_bits+j),
				q  => dqo);

			oddrtdqa_i : oddrtdqa
			port map (
				sclk => ddr_io_clk,
				dqclk0 => dqclk0,
				dqclk1 => dqclk1,
				ta => ddr_io_dqz(i),
				q  => dqz);

			ddr_io_dq(i*byte_bits+j) <= 'Z' when dqz='1' else dqo;
			ddr_io_dqi(i*byte_bits+j) <= ddr_io_dq(i*byte_bits+j);
		end generate;
	end generate;
end;
