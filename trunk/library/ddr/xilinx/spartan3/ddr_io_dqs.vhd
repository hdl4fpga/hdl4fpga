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

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dqs is
	signal rclk : std_logic;
	signal fclk : std_logic;
begin

	rclk <=     ddr_io_clk;
	fclk <= not ddr_io_clk;

	ddr_io_dqs_u : for i in 0 to data_bytes-1 generate
		signal dso : std_logic;
		signal dqs : std_logic;
		signal dqz : std_logic;
		signal d0  : std_logic;
		signal d1  : std_logic;
	begin

		with std select
		d0 <= 
			'0' when 1|2,
			ddr_io_ena(i) when 3;

		with std select
		d1 <= 
			ddr_io_ena(i) when 1|2,
			'1' when 3;

		oddr_du : fddrrse
		port map (
			c0 => rclk,
			c1 => fclk,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => d0,
			d1 => d1,
			q  => dqs);

		ffd_i : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => fclk,
			ce => '1',
			d  => ddr_io_dqz(i),
			q  => dqz);

		ibuf_i : ibuf 
		port map (
			i => ddr_io_dqs(i),
			o => dso);
		ddr_io_dso(i) <= transport dso after debug_delay;

		ddr_io_dqs(i) <= 'Z' when dqz='1' else dqs;
	end generate;
end;
