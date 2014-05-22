
entity ddr3ioctlr is
	port (
		sys_clk : in std_logic;
		sys_ddrclk : in std_logic;
		sys_rw  : in std_logic;

		ddr_dqsi : in  std_logic;
		ddr_dqso : out std_logic;
		ddr_dqi  : in  std_logic;
		ddr_dqo  : out std_logic;

	constant data_width : natural : ddr_dqi'length;
	constant data_edges : natural : 2;
	constant r : natural : 0;
	constant f : natural : 1;
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr3ioctlr is
	constant cell_width : natural := 2;
	constant cell_group : natural := data_width/(cell_width*data_edges)

	signal oddr_dqclk0: std_logic;
	signal oddr_dqclk1 : std_logic;
begin
	dqsdllb_i : dqsdllb
	port map (
		rst => ,
		clk => sys_ddrclk,
		uddcntrl => ,
		lock => );

	dqsbufd_i : dqsbufd 
	port map (
		rst  => ,
		dyndelpol => ,
		dyndelay  => ,

		sclk => sys_clk,
		read => ,
		eclk => ,
		eclkw  => ,
		dqsi => ddr_dqsi,
		dqsdel => ,

		ddrclkpol => ,
		prmbdet => ,
		datavalid => ,
		ddrlat => ,
		eclkdqsr => ,
		dqsw => oddr_dqsw,
		dqclk0 => oddr_dqclk0,
		dqclk1 => oddr_dqclk1);

	iddr_i : for i in 0 to cell_group-1 generate
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_clk,
			eclk => ,
			eclkdqsr => ,
			ddrclkpol => ,
			ddrlat => ,

			qa0 => ddr_dqi(i*cell_width*data_edges+data_edges*0+r),
			qb0 => ddr_dqi(i*cell_width*data_edges+data_edges*0+f),
			qa1 => ddr_dqi(i*cell_width*data_edges+data_edges*1+r),
			qb1 => ddr_dqi(i*cell_width*data_edges+data_edges*1+f));
	end generate;

	oddr_i : for i in 0 to cell_group-1 generate
		oddrx2d_i : iddrx2d
		port map (
			sclk => sys_clk,
			dqclk0 => oddr_dqclk0,
			dqclk1 => oddr_dqclk1,
			da0 => ddr_dqo(i*cell_width*data_edges+data_edges*0+r),
			db0 => ddr_dqo(i*cell_width*data_edges+data_edges*0+f),
			da1 => ddr_dqo(i*cell_width*data_edges+data_edges*1+r),
			db1 => ddr_dqo(i*cell_width*data_edges+data_edges*1+f));
	end generate;

	dqso_b : block 
		signal dqstclk : std_logic;
	begin
		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk => sys_clk,
			db0  => ,
			db1  => ,
			dqsw => oddr_dqsw,
			dqclk0 => oddr_dqclk0,
			dqclk1 => oddr_dqclk1,
			dqstclk => dqstclk);
			q    => ddr_dqso);

		oddrtdqsa_i : oddrtdqsa
		port map (
			sclk => sys_clk,
			db => ,
			dqstclk => dqstclk,
			ta => );


				 );
	end block;
end;
