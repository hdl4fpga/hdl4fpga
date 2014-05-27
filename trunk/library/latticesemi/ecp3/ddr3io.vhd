library ieee;
use ieee.std_logic_1164.all;

entity ddr3io is
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;
		sys_cfgi : in  std_logic_vector(9-1 downto 0);
		sys_cfgo : out std_logic_vector(1-1 downto 0);
		sys_rw   : in  std_logic;
		sys_do   : out std_logic_vector(2-1 downto 0);
		sys_di   : in  std_logic_vector(2-1 downto 0);
		sys_dqsi : in  std_logic_vector(2-1 downto 0);
		sys_dqst : in  std_logic_vector(2-1 downto 0);
		ddr_dqsio : inout std_logic_vector(1-1 downto 0);
		ddr_dqio : inout std_logic_vector(2-1 downto 0));
end;

architecture ecp3 of ddr3io is
	signal ddr_dqi  : std_logic_vector(2-1 downto 0);
	signal ddr_dqt  : std_logic_vector(1-1 downto 0);
	signal ddr_dqo  : std_logic_vector(2-1 downto 0);

	signal ddr_dqsi : std_logic;
	signal ddr_dqst : std_logic;
	signal ddr_dqso : std_logic);
begin
	ddr3phy_i : entity work.ddr3phy
	port map (
		sys_rst  => sys_rst,
		sys_sclk => sys_sclk,
		sys_eclk => sys_eclk,
		sys_cfgi => sys_cfgi,
		sys_cfgo => sys_cfgo,
		sys_rw   => sys_rw,
		sys_do   => sys_do,
		sys_di   => sys_di,
		sys_dqsi => sys_dqsi,
		sys_dqst => sys_dqst,

		ddr_dqi  => ddr_dqi,
		ddr_dqt  => ddr_dqt,
		ddr_dqo  => ddr_dqo,

		ddr_dqsi => ddr_dqsi,
		ddr_dqst => ddr_dqst,
		ddr_dqso => ddr_dqso);

	ddr3dq_i : entity work.ddr3iob
	port map (
		di => ddr_dqi,
		dt => ddr_dqt,
		do => ddr_dqo,
		io => ddr_dqio);

	ddr3dqs_i : entity work.ddr3iob
	port map (
		di => ddr_dqsi,
		dt => ddr_dqst,
		do => ddr_dqso
		io => ddr_dqsio);
end;
