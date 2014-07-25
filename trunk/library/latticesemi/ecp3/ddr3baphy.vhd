library ieee;
use ieee.std_logic_1164.all;

entity ddrphy is
	generic (
		ctlr_phases : natural := 2;
		data_phases : natural := 2;
		dqso_phases : natural := 2;

		bank_size : natural := 2;
		addr_size : natural := 13;
		
		line_size : natural := 32;
		word_size : natural := 16;
		byte_size : natural :=  8);
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;

		sys_cfgi : in  std_logic_vector(9-1 downto 0);
		sys_cfgo : out std_logic_vector(1-1 downto 0);

		sys_cke : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_odt : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_ras : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_cas : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_we  : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_a   : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_b   : in  std_logic_vector(ctlr_phases-1 downto 0);
		sys_dt  : in  std_logic_vector(ctlr_phases*line_size-1 downto 0);
		sys_di  : in  std_logic_vector(ctlr_phases*line_size-1 downto 0);
		sys_do  : out std_logic_vector(ctlr_phases*line_size-1 downto 0);
		sys_dqsi : in  std_logic_vector(dqso_phases-1 downto 0);
		sys_dqst : in  std_logic_vector(2-1 downto 0);

		ddr_dqi  : in  std_logic_vector(1*n-1 downto 0);
		ddr_dqt  : out std_logic_vector(1*n-1 downto 0);
		ddr_dqo  : out std_logic_vector(1*n-1 downto 0);

		ddr_dqsi : in  std_logic;

		ddr_ck  : out std_logic;
		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);
		ddr_dmo  : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqst : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqso : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(word_size-1 downto 0));

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

architecture ecp3 of ddrphy is

	signal dqsi_delay : std_logic;
	signal idqs_eclk  : std_logic;
	signal dqsw  : std_logic;
	signal dqclk0 : std_logic;
	signal dqclk1 : std_logic;

	signal dqst : std_logic_vector(data_size-1 downto 0);
	
	signal dqsdll_lock : std_logic;
	signal dqsbuf_prmbdet : std_logic;
	signal dqsbuf_ddrclkpol : std_logic;
	signal dqsbuf_ddrlat : std_logic;
	
begin

	b_i : hdl4fpga.oddr
	generic map (
		data_size => bank_size,
		data_phases => ctlr_phases) 
	port map (
		clk => sys_clk,
		d => sys_b,
		q => ddr_b);

	a_i : hdl4fpga.oddr
	generic map (
		data_size => addr_size,
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_a,
		q => ddr_a);

	a_i : hdl4fpga.oddr
	generic map (
		data_size => addr_bits,
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_a,
		q => ddr_a);

	ras_i : hdl4fpga.oddr
	generic map (
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_ras,
		q => ddr_ras);

	cas_i : hdl4fpga.oddr
	generic map (
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_cas,
		q => ddr_cas);

	we_i : hdl4fpga.oddr
	generic map (
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_cas,
		q => ddr_cas);

	cke_i : hdl4fpga.oddr
	generic map (
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_cke,
		q => ddr_cke);

	odt_i : hdl4fpga.oddr
	generic map (
		data_phases => ctlr_phases) 
	port map (
		sclk => sys_clk,
		d => sys_odt,
		q => ddr_odt);


	dqsdllb_i : dqsdllb
	port map (
		rst => sys_rst,
		clk => sys_eclk,
		uddcntln => sys_cfgi(uddcntln),
		dqsdel => dqsi_delay,
		lock => dqsdll_lock);

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

		dqsw => dqsw,
		dqclk0 => dqclk0,
		dqclk1 => dqclk1);

	oddrt_i : entity hdl4fpga.oddrt
	port map (
		sclk => sys_sclk,
		ta => sys_dqst(data_edges*0+f),
		dqclk0 => oddr_dqclk0,
		dqclk1 => oddr_dqclk1,
		q  => ddr_dqt(i));

	oddr_i : entity hdl4fpga.oddr
	generic map (
		data_phases => 
		data_size => byte_size)
	port map (
		sclk => sclk,
		dclk(0) => oddr_dqclk0,
		dclk(1) => oddr_dqclk1,
		d => sys_di(byte_size*),
		q => ddr_dqo);

	oddrtdqsa_i : entity hdl4fpga.oddrtdqsa
	generic map (
		data_size => word_size/byte_size)
	port map (
		sclk => sys_sclk,
		db => sys_dqst(data_edges*0+r),
		ta => sys_dqst(data_edges*0+f),
		dqstclk => dqstclk,
		dqsw => oddr_dqsw,
		q => dqst);

	oddrx2dqsa_i : entity hdl4fpga.oddrtdqsa
	generic map (
		data_size => word_size/byte_size)
	port map (
		sclk => sys_sclk,
		dqsw => oddr_dqsw,
		dclks(0) => oddr_dqclk0,
		dclks(1) => oddr_dqclk1,
		dclks(2) => dqstclk,
		t => dqst,
		d => sys_dqsi,
		q => ddr_dqso);
end;
