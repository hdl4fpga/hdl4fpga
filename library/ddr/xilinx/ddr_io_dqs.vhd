library ieee;
use ieee.std_logic_1164.all;

entity ddr_io_dqs is
	generic (
		std : positive range 1 to 3 := 3;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqz : in std_logic_vector(0 to data_bytes-1);
		ddr_io_dqs_p : inout std_logic_vector(0 to data_bytes-1);
		ddr_io_dqs_n : inout std_logic_vector(0 to data_bytes-1);
		ddr_io_dso : out std_logic_vector(0 to data_bytes-1));
end;

