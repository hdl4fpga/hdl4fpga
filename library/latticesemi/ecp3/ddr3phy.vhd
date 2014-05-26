library ieee;
use ieee.std_logic_1164.all;

entity ddr3phy is
	port (
		sys_rst  : in std_logic;
		sys_sclk : in std_logic;
		sys_eclk : in std_logic;
		sys_rw   : in std_logic;
		sys_do   : out std_logic_vector(2-1 downto 0);
		sys_di   : in std_logic_vector(2-1 downto 0);
		sys_dqsi : in std_logic_vector(2-1 downto 0);
		sys_dqst : in std_logic_vector(2-1 downto 0);

		ddr_dqi  : in  std_logic_vector(2-1 downto 0);
		ddr_dqt  : out std_logic_vector(1-1 downto 0);
		ddr_dqo  : out std_logic_vector(2-1 downto 0);

		ddr_dqsi : in  std_logic;
		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

	constant data_width : natural := sys_di'length;
	constant data_edges : natural := 2;
	constant r : natural := 0;
	constant f : natural := 1;

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
	signal dqsdll_update : std_logic;
	signal dqsbuf_prmbdet : std_logic;
	signal dqsbuf_dyndelay : std_logic_vector(8-1 downto 0);
	signal dqsbuf_ddrclkpol : std_logic;
	signal dqsbuf_ddrlat : std_logic;
	
begin

	dqsdllb_i : dqsdllb
	port map (
		rst => sys_rst,
		clk => sys_eclk,
		uddcntln => dqsdll_update,
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

		eclk => iddr_eclk,
		datavalid => open,

		rst  => sys_rst,
		dyndelay0 => dqsbuf_dyndelay(0),
		dyndelay1 => dqsbuf_dyndelay(1),
		dyndelay2 => dqsbuf_dyndelay(2),
		dyndelay3 => dqsbuf_dyndelay(3),
		dyndelay4 => dqsbuf_dyndelay(4),
		dyndelay5 => dqsbuf_dyndelay(5),
		dyndelay6 => dqsbuf_dyndelay(6),
		dyndelpol => dqsbuf_dyndelay(7),
		eclkw => oddr_eclk,

		dqsw => oddr_dqsw,
		dqclk0 => oddr_dqclk0,
		dqclk1 => oddr_dqclk1);

	iddr_g : for i in 0 to cell_group-1 generate
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
