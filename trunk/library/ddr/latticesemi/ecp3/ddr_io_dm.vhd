library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		debug_delay : time := 0 ns;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dmx_r : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmx_f : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_st_r : in std_logic;
		ddr_io_st_f : in std_logic;
		ddr_io_dm_r : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dm_f : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dm  : inout std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmi : out std_logic_vector(data_bytes-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture arch of ddr_io_dm is
	signal ddr_io_fclk : std_logic;
	signal ddr_clk : std_logic_vector(0 to 1);
	signal ddr_st  : std_logic_vector(ddr_clk'range);

	attribute oddrapps : string;
	attribute oddrapps of oddrdm : label is "SCLK_ALIGNED";
begin
	ddr_clk <= (0 => ddr_io_clk,  1 => not ddr_io_clk);
	ddr_st  <= (0 => ddr_io_st_r, 1 =>     ddr_io_st_f);

	bytes_g : for i in ddr_io_dm'range generate
		signal dqz : std_logic;
		signal dqo : std_logic;
		signal di  : std_logic;
		signal d   : std_logic_vector(ddr_clk'range);
		signal dmi : std_logic;
		signal ddr_dmx : std_logic_vector(ddr_clk'range);
		signal ddr_dm  : std_logic_vector(ddr_clk'range);
	begin
		ddr_dmx <= (0 => ddr_io_dmx_r(i), 1 => ddr_io_dmx_f(i));
		ddr_dm  <= (0 =>  ddr_io_dm_r(i), 1 =>  ddr_io_dm_f(i));

		dmff_g: for l in ddr_clk'range generate
			signal di : std_logic;
		begin
			with ddr_dmx(l) select
			di <=
				ddr_st(l) when '0',
				ddr_dm(l) when others;

			process (ddr_clk(l))
			begin
				if rising_edge(ddr_clk(l)) then
					d(l) <= di;
				end if;
			end process;

		end generate;

		oddrt_i : ofd1s3ax
		port map (
			sclk => ddr_io_clk,
			d => '0',
			q => dqz);

		oddrdm : oddrxd1
		port map (
			sclk => ddr_io_clk,
			da => d(0),
			db => d(1),
			q  => dqo);

		ddr_io_dm(i)  <= 'Z' when dqz='1' else dqo;
		ddr_io_dmi(i) <= transport ddr_io_dm(i) after debug_delay;

	end generate;
end;
