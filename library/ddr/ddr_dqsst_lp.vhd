library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dm is
	generic (
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_dm  : inout std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dmi : out std_logic_vector(data_bytes-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_io_dm is
	signal ddr_io_fclk : std_logic;
	signal ddr_clk : std_logic_vector(0 to 1);
	signal ddr_st  : std_logic_vector(ddr_clk'range);
begin
	bytes_g : for i in ddr_io_dm'range generate
	begin
		ibuf_i : ibuf
		port map (
			i => ddr_io_dm(i),
			o => di);

		idelay_i : idelay 
		port map (
			rst => '0',
			c   => '0',
			ce  => '0',
			inc => '0',
			i => di,
			o => ddr_io_dmi(i));
	end generate;
end;
