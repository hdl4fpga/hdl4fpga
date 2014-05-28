library ieee;
use ieee.std_logic_1164.all;

entity ddr3phy is
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;
		sys_cfgi : in  std_logic_vector(9-1 downto 0);
		sys_cfgo : out std_logic_vector(1-1 downto 0);
		sys_rw   : in  std_logic;
		sys_do   : out std_logic_vector(4-1 downto 0);
		sys_di   : in  std_logic_vector(4-1 downto 0);
		sys_dqsi : in  std_logic_vector(2-1 downto 0);
		sys_dqst : in  std_logic_vector(2-1 downto 0);

		ddr_dqi  : in  std_logic_vector(1-1 downto 0);
		ddr_dqt  : out std_logic_vector(1-1 downto 0);
		ddr_dqo  : out std_logic_vector(1-1 downto 0);

		ddr_dqsi : in  std_logic;
		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

	constant data_width : natural := sys_di'length;
	constant data_edges : natural := 2;
	constant r : natural := 0;
	constant f : natural := 1;

	constant dyndelay0 : natural := 0;
	constant dyndelay1 : natural := 1;
	constant dyndelay2 : natural := 2;
	constant dyndelay3 : natural := 3;
	constant dyndelay4 : natural := 4;
	constant dyndelay5 : natural := 5;
	constant dyndelay6 : natural := 6;
	constant dyndelpol : natural := 7;
	constant uddcntln  : natural := 8;
	constant datavalid : natural := 0;
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr3phy is

	constant cell_width : natural := 2;
	constant cell_group : natural := data_width/(cell_width*data_edges);

	signal dqsi_delay : std_logic;
	signal idqs_eclk  : std_logic;
	signal iddr_eclk  : std_logic;
	signal oddr_dqsw  : std_logic;
	signal oddr_dqclk0 : std_logic;
	signal oddr_dqclk1 : std_logic;
	signal oddr_eclk  : std_logic;
	
	signal dqsdll_lock : std_logic;
	signal dqsbuf_prmbdet : std_logic;
	signal dqsbuf_ddrclkpol : std_logic;
	signal dqsbuf_ddrlat : std_logic;
	
begin

	dqsdllb_i : dqsdllb
	port map (
		rst => sys_rst,
		clk => sys_eclk,
		uddcntln => sys_cfgi(uddcntln),
		dqsdel => dqsi_delay,
		lock => dqsdll_lock);

	dqsbufd_i : dqsbufd 
	port map (
		dqsdel => dqsi_delay,
		dqsi   => ddr_dqsi,
		eclkdqsr => idqs_eclk,

		sclk => sys_sclk,
		read => sys_rw,
		ddrclkpol => dqsbuf_ddrclkpol,
		ddrlat  => dqsbuf_ddrlat,
		prmbdet => dqsbuf_prmbdet,

		eclk => sys_eclk,
		datavalid => sys_cfgo(datavalid),

		rst  => sys_rst,
		dyndelay0 => sys_cfgi(dyndelay0),
		dyndelay1 => sys_cfgi(dyndelay1),
		dyndelay2 => sys_cfgi(dyndelay2),
		dyndelay3 => sys_cfgi(dyndelay3),
		dyndelay4 => sys_cfgi(dyndelay4),
		dyndelay5 => sys_cfgi(dyndelay5),
		dyndelay6 => sys_cfgi(dyndelay6),
		dyndelpol => sys_cfgi(dyndelpol),
		eclkw => sys_eclk,

		dqsw => oddr_dqsw,
		dqclk0 => oddr_dqclk0,
		dqclk1 => oddr_dqclk1);

	iddr_g : for i in 0 to cell_group-1 generate
		attribute iddrapps : string;
		attribute iddrapps of iddrx2d_i : label is "DQS_ALIGNED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_sclk,
			eclk => sys_eclk,
			eclkdqsr => idqs_eclk,
			ddrclkpol => dqsbuf_ddrclkpol,
			ddrlat => dqsbuf_ddrlat,
			d   => ddr_dqi(i),
			qa0 => sys_do(i*cell_width*data_edges+data_edges*0+r),
			qb0 => sys_do(i*cell_width*data_edges+data_edges*0+f),
			qa1 => sys_do(i*cell_width*data_edges+data_edges*1+r),
			qb1 => sys_do(i*cell_width*data_edges+data_edges*1+f));
	end generate;

	oddr_g : for i in 0 to cell_group-1 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk => sys_sclk,
			ta => open,
			dqclk0 => oddr_dqclk0,
			dqclk1 => oddr_dqclk1,
			q  => ddr_dqt(i*cell_width));

		oddrx2d_i : oddrx2d
		port map (
			sclk => sys_sclk,
			dqclk0 => oddr_dqclk0,
			dqclk1 => oddr_dqclk1,
			da0 => sys_di(i*cell_width*data_edges+data_edges*0+r),
			db0 => sys_di(i*cell_width*data_edges+data_edges*0+f),
			da1 => sys_di(i*cell_width*data_edges+data_edges*1+r),
			db1 => sys_di(i*cell_width*data_edges+data_edges*1+f),
			q   => ddr_dqo(i));
	end generate;

	dqso_b : block 
		signal dqstclk : std_logic;
		attribute oddrapps : string;
		attribute oddrapps of oddrx2dqsa_i : label is "DQS_CENTERED";
	begin
		oddrtdqsa_i : oddrtdqsa
		port map (
			sclk => sys_sclk,
			db => sys_dqst(data_edges*0+r),
			ta => sys_dqst(data_edges*0+f),
			dqstclk => dqstclk,
			dqsw => oddr_dqsw,
			q => ddr_dqst);

		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk => sys_sclk,
			db0 => sys_dqsi(data_edges*0+r),
			db1 => sys_dqsi(data_edges*0+f),
			dqsw => oddr_dqsw,
			dqclk0 => oddr_dqclk0,
			dqclk1 => oddr_dqclk1,
			dqstclk => dqstclk,
			q => ddr_dqso);

	end block;
end;
