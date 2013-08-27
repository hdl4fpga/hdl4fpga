library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dqs is
	generic (
		debug_delay : time;
		std : positive range 1 to 3 := 3;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqz : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqs : inout std_logic_vector(0 to data_bytes-1);
		ddr_io_dqs_n : inout std_logic_vector(0 to data_bytes-1) := (others => 'Z');
		ddr_io_dso : out std_logic_vector(0 to data_bytes-1));
end;

library ecp3;
use ecp3.components.all;

architecture arch of ddr_io_dqs is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin

	rclk <=     ddr_io_clk;
	fclk <= not ddr_io_clk;

	ddr_io_dqs_u : for i in 0 to data_bytes-1 generate
		signal tclk : std_logic;
		signal dqs : std_logic;
		signal dqz : std_logic;
	begin

		oddrt_i : oddrtdqsa
		port map (
			sclk => rclk,
			dqsw => fclk,
			dqstclk => tclk,
			ta => ddr_io_dqz(i),
			db => '0',
			q  => dqz);

		oddr_i : oddrxdqsa
		port map (
			sclk => rclk,
			da => ddr_io_ena(i),
			dqclk1 => ddr_io_clk,
			dqsw   => ddr_io_clk,
			dqstclk => tclk,
			q  => dqs);

		ddr_io_dqs(i) <= 'Z' when dqz='1' else dqs;

		ddr_io_dso(i) <= transport ddr_io_dqs(i) after debug_delay;
	end generate;
end;
