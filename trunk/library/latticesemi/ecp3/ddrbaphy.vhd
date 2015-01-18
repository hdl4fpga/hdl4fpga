library ieee;
use ieee.std_logic_1164.all;

entity ddrbaphy is
	generic (
		cmnd_phases : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		sys_sclk   : in  std_logic;
		sys_sclk2x : in  std_logic;

		sys_rw  : in  std_logic;
		sys_rst : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cs  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cke : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_b   : in  std_logic_vector(cmnd_phases*bank_size-1 downto 0);
		sys_a   : in  std_logic_vector(cmnd_phases*addr_size-1 downto 0);
		sys_ras : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cas : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_we  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_odt : in  std_logic_vector(cmnd_phases-1 downto 0);

		ddr_rst : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ck  : out std_logic;
		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddrbaphy is

	signal dqsi_delay : std_logic;
	signal idqs_eclk  : std_logic;
	signal dqsw  : std_logic;
	signal dqclk0 : std_logic;
	signal dqclk1 : std_logic;

	signal dqst : std_logic_vector(cmnd_phases-1 downto 0);
	
	signal dqsdll_lock : std_logic;
	signal prmbdet : std_logic;
	signal ddrclkpol : std_logic;
	signal ddrlat : std_logic;
	signal dqstclk : std_logic;
	attribute oddrapps : string;
	attribute oddrapps of ras_i, cas_i, we_i, cs_i, cke_i, odt_i, rst_i : label is "SCLK_ALIGNED";
	attribute oddrapps of ck_i : label is "SCLK_ALIGNED";
begin

	b_g : for i in 0 to bank_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sys_sclk,
			da => sys_b(bank_size*0+i),
			db => '1', --sys_b(bank_size*1+i),
			q  => ddr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sys_sclk,
			da => sys_a(addr_size*0+i),
			db => '1', --sys_a(addr_size*1+i),
			q => ddr_a(i));
	end generate;

	ras_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_ras(0),
		db => '1', --sys_ras(1),
		q  => ddr_ras);

	cas_i :oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_cas(0),
		db => '1', --sys_cas(1),
		q  => ddr_cas);

	we_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_we(0),
		db => '1', --sys_we(1),
		q  => ddr_we);

	ck_i : oddrxd1
	port map (
		sclk => sys_sclk2x,
		da => '0',
		db => '1',
		q  => ddr_ck);

	cs_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_cs(0),
		db => '1', --sys_cs(0),
		q  => ddr_cs);

	cke_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_cke(0),
		db => sys_cke(0),
		q  => ddr_cke);

	odt_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_odt(0),
		db => sys_odt(0),
		q  => ddr_odt);

	rst_i : oddrxd1
	port map (
		sclk => sys_sclk,
		da => sys_rst(0),
		db => sys_rst(0),
		q  => ddr_rst);

end;
