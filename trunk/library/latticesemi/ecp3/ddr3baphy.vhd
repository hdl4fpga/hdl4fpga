library ieee;
use ieee.std_logic_1164.all;

entity ddr3baphy is
	generic (
		bank_bits : natural := 2;
		addr_bits : natural := 13;
		byte_size : natural;
		data_bytes : natural);
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;

		sys_cke : in std_logic;
		sys_odt : in std_logic;
		sys_ras : in std_logic;
		sys_cas : in std_logic;
		sys_we  : in std_logic;
		sys_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_b   : in std_logic_vector(bank_bits-1 downto 0);

		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_bits-1 downto 0);
		ddr_a   : out std_logic_vector(addr_bits-1 downto 0));

	constant data_edges : natural := 2;
	constant r : natural := 0;
	constant f : natural := 1;

end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr3baphy is
begin

	a_g : for i in 0 to addr_bits-1 generate
		oddr_i : oddrxd1
		port map (
			sclk => clk,
			da => dr,
			db => df,
			q  => q);
	end generate;
end;
