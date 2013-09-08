library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dqs is
	generic (
		std : positive range 1 to 3 := 3;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in   std_logic_vector(data_bytes-1 downto 0);
		ddr_mpu_dqsz : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqsz : out std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqso : out std_logic_vector(data_bytes-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture arch of ddr_io_dqs is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin

	rclk <= ddr_io_clk;
	fclk <= not ddr_io_clk;

	ddr_io_dqs_u : for i in 0 to data_bytes-1 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrdqs : label is "DDR2_MEM_DQS";

		signal tclk : std_logic;
	begin

		assert std=1 or std=2
		report "Invalid standard"
		severity failure;

		oddrt_i : oddrtdqsa
		port map (
			sclk => rclk,
			dqsw => fclk,
			dqstclk => tclk,
			ta => ddr_mpu_dqsz(i),
			db => '0',
			q  => ddr_io_dqsz(i));

		oddrdqs : oddrxdqsa
		port map (
			sclk => rclk,
			da => ddr_io_ena(i),
			dqclk1 => ddr_io_clk,
			dqsw   => fclk,
			dqstclk => tclk,
			q  => ddr_io_dqso(i));

	end generate;
end;
