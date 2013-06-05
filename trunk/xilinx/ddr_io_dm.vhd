library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		n : natural);
	port (
		ddr_io_clk : in  std_logic;
		ddr_io_drw : in  std_logic;
		ddr_io_dml : in  std_logic_vector(0 to n-1);
		ddr_io_dmh : in  std_logic_vector(0 to n-1);
		ddr_io_dm  : out std_logic_vector(0 to n-1) := (others => '1'));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dm is
	signal rclk : std_logic;
	signal fclk : std_logic;
	signal ena  : std_logic;
begin

	rclk <=     ddr_io_clk;
	fclk <= not ddr_io_clk;
	ena  <= not ddr_io_drw;

	ddr_io_dm_u : for i in 0 to n-1 generate
	begin
		oddr_du : fddrrse
		port map (
			c0 => rclk,
			c1 => fclk,
			ce => ena,
			r  => '0',
			s  => '0',
			d0 => ddr_io_dmh(i),
			d1 => ddr_io_dml(i),
			q  => ddr_io_dm(i));
	end generate;
end;
