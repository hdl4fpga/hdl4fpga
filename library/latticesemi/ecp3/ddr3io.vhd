library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of ecp3versa is
	constant n : natural := 2;

	signal ddr_dqi : byte_vector(n-1 downto 0);
	signal ddr_dqt : byte_vector(n-1 downto 0);
	signal ddr_dqo : byte_vector(n-1 downto 0);
	signal ddr_dq  : byte_vector(n-1 downto 0);

	signal ddr_dqsi : std_logic_vector(n-1 downto 0);
	signal ddr_dqst : std_logic_vector(n-1 downto 0);
	signal ddr_dqso : std_logic_vector(n-1 downto 0);

	type sysdqs_vector is array (natural range <>) of std_logic_vector(2-1 downto 0);
	type sysdq_vector  is array (natural range <>) of std_logic_vector(4*byte'length-1 downto 0);
	type syscfgi_vector is array (natural range <>) of std_logic_vector(9-1 downto 0);
	type syscfgo_vector is array (natural range <>) of std_logic_vector(1-1 downto 0);
	signal sys_dqsi : sysdqs_vector(n-1 downto 0);
	signal sys_dqst : sysdqs_vector(n-1 downto 0);
	signal sys_do   : sysdq_vector(n-1 downto 0);
	signal sys_di   : sysdq_vector(n-1 downto 0);
	signal sys_cfgi : syscfgi_vector(n-1 downto 0);
	signal sys_cfgo : syscfgo_vector(n-1 downto 0);
	signal sys_rst  : std_logic;
	signal sys_sclk : std_logic;
	signal sys_eclk : std_logic;
	signal sys_rw   : std_logic;
begin

	ddr3byte_g : for i in 0 to n-1 generate
		ddr3phy_i : entity work.ddr3phy
		generic map (
			n => byte'length)
		port map (
			sys_rst  => sys_rst,
			sys_sclk => sys_sclk,
			sys_eclk => sys_eclk,
			sys_rw   => sys_rw,
			sys_cfgi => sys_cfgi(i),
			sys_cfgo => sys_cfgo(i),
			sys_dqsi => sys_dqsi(i),
			sys_dqst => sys_dqst(i),
			sys_do   => sys_do(i),
			sys_di   => sys_di(i),
	
			ddr_dqi  => ddr_dqi(i),
			ddr_dqt  => ddr_dqt(i),
			ddr_dqo  => ddr_dqo(i),
	
			ddr_dqsi => ddr_dqsi(i),
			ddr_dqst => ddr_dqst(i),
			ddr_dqso => ddr_dqso(i));

		ddr3dq_i : entity work.ddr3iob
		port map (
			di => ddr_dqi(i),
			dt => ddr_dqt(i),
			do => ddr_dqo(i),
			io => ddr_dq(i));
	end generate;

	ddr3_dq <= byte2word(ddr_dq);
	ddr3dqs_i : entity work.ddr3iob
	port map (
		di => ddr_dqsi,
		dt => ddr_dqst,
		do => ddr_dqso,
		io => ddr3_dqs);
end;
