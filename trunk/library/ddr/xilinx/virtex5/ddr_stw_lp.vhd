library ieee;
use ieee.std_logic_1164.all;

entity ddr_stw_lp is
	generic (
		data_bytes : natural);
	port (
		ddr_stw_sti : in  std_logic_vector(data_bytes-1 downto 0);
		ddr_stw_sto : out std_logic_vector(data_bytes-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

architecture virtex5 of ddr_stw_lp is
begin
	bytes_g : for i in ddr_stw_lp'range generate
		signal st  : std_logic;
	begin
		ibuf_i : ibuf
		port map (
			i => ddr_stw_sti(i),
			o => st);

		idelay_i : idelay 
		port map (
			rst => '0',
			c   => '0',
			ce  => '0',
			inc => '0',
			i => st,
			o => ddr_stw_sto(i));
	end generate;
end;
