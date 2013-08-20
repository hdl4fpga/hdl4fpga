library ieee;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dqs is
	generic (
		debug_delay : time := 0 ns;
		std : positive range 1 to 3 := 3;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqz : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqs : inout std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqs_n : inout std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dso : out std_logic_vector(0 to data_bytes-1));
end;

library unisim;
use unisim.vcomponents.all;

architecture v5 of ddr_io_dqs is
	signal fclk : std_logic;
begin

	fclk <= not ddr_io_clk;

	ddr_io_dqs_u : for i in ddr_io_dqs'range generate
		signal dqs : std_logic;
		signal dqz : std_logic;
		signal d1  : std_logic;
		signal d2  : std_logic;
		signal x : std_logic;
		signal y : std_logic;
	begin

		with std select
		d1 <= 
			'0' when 1|2,
			ddr_io_ena(i) when 3;

		with std select
		d2 <= 
			ddr_io_ena(i) when 1|2,
			'1' when 3;

		oddr_du : oddr
		port map (
			r => '0',
			s => '0',
			c => ddr_io_clk,
			ce => '1',
			d1 => d1,
			d2 => d2,
			q  => dqs);

		ffd_i : fdrse
		port map (
			s => '0',
			r => '0',
			c => fclk,
			ce => '1',
			d => ddr_io_dqz(i),
			q => dqz);

		iobufds_i : iobufds
		generic map (
			iostandard => "DIFF_SSTL18_II_DCI")
		port map (
			t => dqz,
			i => dqs,
			io => ddr_io_dqs(i),
			iob => ddr_io_dqs_n(i),
--			o => ddr_io_dso(i));
			o => x);

		idelay_i : idelay 
		port map (
			rst => '0',
			c  =>'0',
			ce => '0',
			inc => '0',
			i => x,
--			o => ddr_io_dso(i));
			o => y);

		ddr_io_dso(i) <= transport y after debug_delay;
	end generate;
end;
