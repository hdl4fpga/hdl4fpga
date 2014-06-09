library ieee;
use ieee.std_logic_1164.all;

architecture ecp3 of ecp3versa is
	signal ddr_dqi  : std_logic_vector(1-1 downto 0);
	signal ddr_dqt  : std_logic_vector(1-1 downto 0);
	signal ddr_dqo  : std_logic_vector(1-1 downto 0);

	signal ddr_dqsi : std_logic;
	signal ddr_dqst : std_logic;
	signal ddr_dqso : std_logic;
begin

	ddr3byte_g : for i in 0 to 2-1 generate
		ddr3phy_i : entity work.ddr3phy
		generic map (
			n => 8)
		port map (
			sys_rst  => expansion(0),
			sys_sclk => expansion(1),
			sys_eclk => expansion(2),
			sys_rw   => expansion(3),
			sys_dqsi => expansion(4 to 5),
			sys_dqst => expansion(6 to 7),
			sys_do   => expansion(8 to 11),
			sys_di   => expansion(12 to 15),
			sys_cfgi => expansion(15 to 23),
			sys_cfgo => expansion(24 to 24),
	
			ddr_dqi  => ddr_dqi(i),
			ddr_dqt  => ddr_dqt(i),
			ddr_dqo  => ddr_dqo(i),
	
			ddr_dqsi => ddr_dqsi(i),
			ddr_dqst => ddr_dqst(i),
			ddr_dqso => ddr_dqso(i));
	end generate;

	ddr3dq_i : entity work.ddr3iob
	port map (
		di => ddr_dqi,
		dt => ddr_dqt,
		do => ddr_dqo,
		io => ddr3_dq);

	ddr3dqs_i : entity work.ddr3iob
	port map (
		di => ddr_dqsi,
		dt => ddr_dqst,
		do => ddr_dqso,
		io => ddr3_dqs);
end;
