library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_io_ba is
	generic (
		bank_bits  : natural := 2;
		addr_bits  : natural := 13);
	port (
		sys_rst : in std_logic;
		sys_clk : in std_logic;
		sys_ini : in std_logic;
		sys_cke : in std_logic;
		sys_odt : in std_logic;
		sys_ras : in std_logic;
		sys_cas : in std_logic;
		sys_we  : in std_logic;
		sys_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_b   : in std_logic_vector(bank_bits-1 downto 0);

		sys_ini_ras : in std_logic;
		sys_ini_cas : in std_logic;
		sys_ini_we  : in std_logic;
		sys_ini_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_ini_b   : in std_logic_vector(bank_bits-1 downto 0);

		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b  : out std_logic_vector(bank_bits-1 downto 0);
		ddr_a   : out std_logic_vector(addr_bits-1 downto 0));
end;

library hdl4fpga;

architecture mix of xdr_io_ba is
	signal ras_d : std_logic;
	signal cas_d : std_logic;
	signal we_d  : std_logic;
begin
	ddr_cke_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => sys_cke,
		q => ddr_cke);

	ddr_odt_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => sys_odt,
		q => ddr_odt);

	ras_d <= sys_ras when sys_ini='1' else sys_ini_ras;
	ddr_ras_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => ras_d,
		q => ddr_ras);

	cas_d <= sys_cas when sys_ini='1' else sys_ini_cas;
	ddr_cas_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => cas_d,
		q => ddr_cas);

	we_d  <= sys_we when sys_ini='1' else sys_ini_we;
	ddr_we_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => we_d,
		q => ddr_we);

	ddr_a_g : for i in ddr_a'range generate
		signal d : std_logic;
	begin
		d <= sys_a(i) when sys_ini='1' else sys_ini_a(i);
		ff_i : entity hdl4fpga.ff
		port map (
			clk => sys_clk,
			d => d,
			q => ddr_a(i));
	end generate;

	ddr_b_g : for i in ddr_b'range generate
		signal d : std_logic;
	begin
		d <= sys_b(i) when sys_ini='1' else sys_ini_b(i);
		ff_i : entity hdl4fpga.ff
		port map (
			clk => sys_clk,
			d => d,
			q => ddr_b(i));
	end generate;
end;
