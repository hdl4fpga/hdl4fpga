library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ba is
	generic (
		bank_bits  : natural := 2;
		addr_bits  : natural := 13);
	port (
		sys_rst : in std_logic;
		sys_clk : in std_logic;
		sys_cfg : in std_logic;
		sys_cke : in std_logic;
		sys_odt : in std_logic;
		sys_ras : in std_logic;
		sys_cas : in std_logic;
		sys_we  : in std_logic;
		sys_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_b   : in std_logic_vector(bank_bits-1 downto 0);

		sys_cfg_ras : in std_logic;
		sys_cfg_cas : in std_logic;
		sys_cfg_we  : in std_logic;
		sys_cfg_a   : in std_logic_vector(addr_bits-1 downto 0);
		sys_cfg_b   : in std_logic_vector(bank_bits-1 downto 0);

		xdr_cke : out std_logic;
		xdr_odt : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_b   : out std_logic_vector(bank_bits-1 downto 0);
		xdr_a   : out std_logic_vector(addr_bits-1 downto 0));
end;

library hdl4fpga;

architecture mix of xdr_ba is
	signal ras_d : std_logic;
	signal cas_d : std_logic;
	signal we_d  : std_logic;
begin
	xdr_cke_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => sys_cke,
		q => xdr_cke);

	xdr_odt_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => sys_odt,
		q => xdr_odt);

	ras_d <= sys_ras when sys_cfg='1' else sys_cfg_ras;
	xdr_ras_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => ras_d,
		q => xdr_ras);

	cas_d <= sys_cas when sys_cfg='1' else sys_cfg_cas;
	xdr_cas_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => cas_d,
		q => xdr_cas);

	we_d  <= sys_we when sys_cfg='1' else sys_cfg_we;
	xdr_we_i : entity hdl4fpga.ff
	port map (
		clk => sys_clk,
		d => we_d,
		q => xdr_we);

	xdr_a_g : for i in xdr_a'range generate
		signal d : std_logic;
	begin
		d <= sys_a(i) when sys_cfg='1' else sys_cfg_a(i);
		ff_i : entity hdl4fpga.ff
		port map (
			clk => sys_clk,
			d => d,
			q => xdr_a(i));
	end generate;

	xdr_b_g : for i in xdr_b'range generate
		signal d : std_logic;
	begin
		d <= sys_b(i) when sys_cfg='1' else sys_cfg_b(i);
		ff_i : entity hdl4fpga.ff
		port map (
			clk => sys_clk,
			d => d,
			q => xdr_b(i));
	end generate;
end;
