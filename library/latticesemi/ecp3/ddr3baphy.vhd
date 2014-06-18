library ieee;
use ieee.std_logic_1164.all;

entity ddr3baphy is
	generic (
		bank_bits : natural := 2;
		addr_bits : natural := 13);
	port (
		sys_rst  : in  std_logic;
		sys_clk : in  std_logic;

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
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr3baphy is
	signal sys_cmmd : std_logic_vector(1 to 5) := (others => '-');
	signal ddr_cmmd : std_logic_vector(sys_cmmd'range) := (others => '-');
begin

	b_g : for i in 0 to bank_bits-1 generate
		oddr_i : oddrxd1
		port map (
			sclk => sys_clk,
			da => sys_b(i),
			db => sys_b(i),
			q  => ddr_b(i));
	end generate;

	a_g : for i in 0 to addr_bits-1 generate
		oddr_i : oddrxd1
		port map (
			sclk => sys_clk,
			da => sys_a(i),
			db => sys_a(i),
			q  => ddr_a(i));
	end generate;

	sys_cmmd <= (1 => sys_ras, 2 => sys_cas, 3 => sys_we, 4 => sys_cke, 5 => sys_odt);
	cmmd_g : for i in sys_cmmd'range generate
		oddr_i : oddrxd1
		port map (
			sclk => sys_clk,
			da => sys_cmmd(i),
			db => sys_cmmd(i),
			q  => ddr_cmmd(i));
	end generate;
	(1 => ddr_ras, 2 => ddr_cas, 3 => ddr_we, 4 => ddr_cke, 5 => ddr_odt) <= ddr_cmmd;
end;
