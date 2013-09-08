library ieee;
use ieee.std_logic_1164.all;

entity ddr_stw_lp is
	generic (
		data_bytes : natural);
	port (
		ddr_stw_sti : in  std_logic_vector(data_bytes-1 downto 0);
		ddr_stw_sto : out std_logic_vector(data_bytes-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture lttsm of ddr_stw_lp is
begin
	bytes_g : for i in ddr_stw_sti'range generate
		ddr_stw_sto(i) <= ddr_stw_sti(i);
	end generate;
end;
