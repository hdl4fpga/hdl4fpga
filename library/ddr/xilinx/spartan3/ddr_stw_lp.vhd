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

architecture spartan3 of ddr_stw_lp is
begin
	bytes_g : for i in ddr_stw_sti'range generate
		ibuf_i : ibuf
		port map (
			i => ddr_stw_sti(i),
			o => ddr_stw_sto(i));
	end generate;
end;
