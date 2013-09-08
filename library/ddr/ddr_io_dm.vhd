library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		data_bytes : natural);
	port (
		ddr_io_clk    : in std_logic;
		ddr_mpu_dmx_r : in std_logic_vector(data_bytes-1 downto 0);
		ddr_mpu_dmx_f : in std_logic_vector(data_bytes-1 downto 0);
		ddr_mpu_st_r  : in std_logic;
		ddr_mpu_st_f  : in std_logic;
		ddr_mpu_dm_r  : in std_logic_vector(data_bytes-1 downto 0);
		ddr_mpu_dm_f  : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmo    : out std_logic_vector(data_bytes-1 downto 0));
end;

library hdl4fpga;

architecture arch of ddr_io_dm is
	signal ddr_clk : std_logic_vector(0 to 1);
	signal ddr_st  : std_logic_vector(ddr_clk'range);
begin
	ddr_clk <= (0 => ddr_io_clk,  1 => not ddr_io_clk);
	ddr_st  <= (0 => ddr_mpu_st_r, 1 =>     ddr_mpu_st_f);

	bytes_g : for i in ddr_io_dmo'range generate
		signal d       : std_logic_vector(ddr_clk'range);
		signal ddr_dmx : std_logic_vector(ddr_clk'range);
		signal ddr_dm  : std_logic_vector(ddr_clk'range);
	begin
		ddr_dmx <= (0 => ddr_mpu_dmx_r(i), 1 => ddr_mpu_dmx_f(i));
		ddr_dm  <= (0 => ddr_mpu_dm_r(i),  1 => ddr_mpu_dm_f(i));

		dmff_g: for l in ddr_clk'range generate
			signal di : std_logic;
		begin
			with ddr_dmx(l) select
			di <=
				ddr_st(l) when '0',
				ddr_dm(l) when others;

			ffd_i : entity hdl4fpga.ff
			port map (
				clk => ddr_clk(l),
				d => di,
				q => d(l));

		end generate;

		oddr_du : entity hdl4fpga.ddro
		port map (
			clk => ddr_io_clk,
			dr  => d(0),
			df  => d(1),
			q   => ddr_io_dmo(i));

	end generate;
end;
