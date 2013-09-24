library ieee;
use ieee.std_logic_1164.all;

entity xdr_io_dqs is
	generic (
		std : positive range 1 to 3 := 3;
		data_phases : natural := 2;
		data_edges : natural := 2;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in std_logic_vector(data_phases*data_bytes-1 downto 0);
		ddr_mpu_dqsz : in std_logic_vector(data_phases*data_bytes-1 downto 0);
		ddr_io_dqsz : out std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqso : out std_logic_vector(data_bytes-1 downto 0));
end;

library hdl4fpga;

architecture std of xdr_io_dqs is
	signal rclk : std_logic;
	signal tclk : std_logic;
begin

--	rclk <= ddr_io_clk;
--	tclk <= not ddr_io_clk when std=1 else ddr_io_clk;
--
--	ddr_io_dqs_u : for i in 0 to data_bytes-1 generate
--		signal dr  : std_logic;
--		signal df  : std_logic;
--	begin
--
--		with std select
--		dr <= 
--			'0' when 1|2,
--			ddr_io_ena(i) when 3;
--
--		with std select
--		df <= 
--			ddr_io_ena(i) when 1|2,
--			'1' when 3;
--
--		oddrt_i : entity hdl4fpga.ddrto
--		port map (
--			clk => tclk,
--			d  => ddr_mpu_dqsz(i),
--			q  => ddr_io_dqsz(i));
--
--		oddr_i : entity hdl4fpga.ddro
--		port map (
--			clk => rclk,
--			dr => dr,
--			df => df,
--			q  => ddr_io_dqso(i));
--
--	end generate;
end;
