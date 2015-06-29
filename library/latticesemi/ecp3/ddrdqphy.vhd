library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddrdqphy is
	generic (
		period : natural;
		line_size : natural;
		byte_size : natural);
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;
		sys_eclkw : in  std_logic;
		sys_dqsdel : in  std_logic;
		sys_rw : in  std_logic;
		sys_wlreq : in std_logic;
		sys_wlrdy : in std_logic;
		sys_wlnxt : in std_logic;
		sys_wldg  : in std_logic_vector;
		sys_dmt  : in  std_logic_vector(0 to line_size/byte_size-1) := (others => '-');
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(0 to line_size/byte_size-1);
		sys_dqi  : out std_logic_vector(line_size-1 downto 0);
		sys_dqso : in  std_logic_vector(0 to line_size/byte_size-1);
		sys_dqst : in  std_logic_vector(0 to line_size/byte_size-1);

		ddr_dmt  : out std_logic;
		ddr_dmi  : in  std_logic := '-';
		ddr_dmo  : out std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqsi : in  std_logic;
		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of ddrdqphy is

	signal idqs_eclk  : std_logic;
	signal dqsw  : std_logic;
	signal dqclk0 : std_logic;
	signal dqclk1 : std_logic;
	
	signal prmbdet : std_logic;
	signal ddrclkpol : std_logic := '1';
	signal ddrlat : std_logic;
	signal rw : std_logic;
	
	signal wlpha : std_logic_vector(sys_wldg'length-1 downto 0);
	signal dyndelay : unsigned(8-1 downto 0);
	signal wlok : std_logic;
	signal dqi : std_logic_vector(sys_dqi'range);

	signal dqt : std_logic_vector(sys_dqt'range);
	signal dqst : std_logic_vector(sys_dqst'range);
	signal dqso : std_logic_vector(sys_dqso'range);
	signal wle : std_logic;
	signal dsqbufd_rst : std_logic;

begin
	rw <= not sys_rw;
	adjpha_e : entity hdl4fpga.adjpha
	generic map (
		period => period)
	port map (
		clk => sys_sclk,
		rdy => sys_wlrdy,
		req => sys_wlreq,
		smp => wlok,
		hld => sys_wlnxt,
		dg  => sys_wldg,
		pha => wlpha);

	dsqbufd_rst <= sys_rst;
	dyndelay <= resize(unsigned(wlpha), dyndelay'length);
	dqsbufd_i : dqsbufd 
	port map (
		dqsdel => sys_dqsdel,
		dqsi   => ddr_dqsi,
		eclkdqsr => idqs_eclk,

		sclk => sys_sclk,
		read => rw,
		ddrclkpol => ddrclkpol,
		ddrlat  => ddrlat,
		prmbdet => prmbdet,

		eclk => sys_eclk,
		datavalid => open,

		rst  => dsqbufd_rst,
		dyndelay0 => dyndelay(0),
		dyndelay1 => dyndelay(1),
		dyndelay2 => dyndelay(2),
		dyndelay3 => dyndelay(3),
		dyndelay4 => dyndelay(4),
		dyndelay5 => dyndelay(5),
		dyndelay6 => '0', --dyndelay(6),
		dyndelpol => dyndelay(6),
		eclkw => sys_eclkw,

		dqsw => dqsw,
		dqclk0 => dqclk0,
		dqclk1 => dqclk1);


	iddr_g : for i in 0 to byte_size-1 generate
		attribute iddrapps : string;
		attribute iddrapps of iddrx2d_i : label is "DQS_CENTERED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_sclk,
			eclk => sys_eclk,
			eclkdqsr => idqs_eclk,
			ddrclkpol => ddrclkpol,
			ddrlat => ddrlat,
			d   => ddr_dqi(i),
			qa0 => sys_dqi(0*byte_size+i),
			qb0 => sys_dqi(1*byte_size+i),
			qa1 => sys_dqi(2*byte_size+i),
			qb1 => sys_dqi(3*byte_size+i));
	end generate;
	wlok <= ddr_dqi(0);

	dmi_g : block
		attribute iddrapps : string;
		attribute iddrapps of iddrx2d_i : label is "DQS_CENTERED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_sclk,
			eclk => sys_eclk,
			eclkdqsr => idqs_eclk,
			ddrclkpol => ddrclkpol,
			ddrlat => ddrlat,
			d   => ddr_dmi,
			qa0 => sys_dmo(0),
			qb0 => sys_dmo(1),
			qa1 => sys_dmo(2),
			qb1 => sys_dmo(3));
	end block;

	wle <= not sys_wlrdy and sys_wlreq;
	dqt <= sys_dqt when wle='0' else (others => '1');
	oddr_g : for i in 0 to byte_size-1 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk => sys_sclk,
			ta => dqt(0),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q  => ddr_dqt(i));

		oddrx2d_i : oddrx2d
		port map (
			sclk => sys_sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0 => sys_dqo(0*byte_size+i),
			db0 => sys_dqo(1*byte_size+i),
			da1 => sys_dqo(2*byte_size+i),
			db1 => sys_dqo(3*byte_size+i),
			q   => ddr_dqo(i));
	end generate;

	dm_b : block
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk => sys_sclk,
			ta => sys_dmt(0),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q  => ddr_dmt);

		oddrx2d_i : oddrx2d
		port map (
			sclk => sys_sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0 => sys_dmi(0),
			db0 => sys_dmi(1),
			da1 => sys_dmi(2),
			db1 => sys_dmi(3),
			q   => ddr_dmo);
	end block;

	dqst <= sys_dqst when wle='0' else (others => '0');
	dqso <= sys_dqso when wle='0' else (others => '1');
	dqso_b : block 
		signal dqstclk : std_logic;
		attribute oddrapps : string;
		attribute oddrapps of oddrx2dqsa_i : label is "DQS_CENTERED";
	begin

		oddrtdqsa_i : oddrtdqsa
		port map (
			sclk => sys_sclk,
			ta => dqst(2*0),
			db => dqst(2*1),
			dqstclk => dqstclk,
			dqsw => dqsw,
			q => ddr_dqst);

		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk => sys_sclk,
			db0 => dqso(2*0),
			db1 => dqso(2*1),
			dqsw => dqsw,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			dqstclk => dqstclk,
			q => ddr_dqso);

	end block;
end;
