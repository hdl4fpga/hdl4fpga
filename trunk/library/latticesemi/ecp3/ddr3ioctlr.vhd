entity ddr3ioctlr is
	port (
		sys_clk : in std_logic;
		sys_ddrclk : in std_logic;
		sys_rw  : in std_logic;

		ddr_dqsi : in  std_logic;
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
begin
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
		dqsw => ,
		dqclk0 => ,
		dqclk1 => );

	iddr_i : for i in 0 to data_width/(cell_width*data_edges)-1 generate
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

	oddr_i : for i in 0 to data_width/(cell_width*data_edges)-1 generate
		oddrx2d_i : iddrx2d
		port map (
			sclk => sys_clk,
			dqclk0 => ,
			dqclk1 => ,
			da0 => ddr_dqo(i*cell_width*data_edges+data_edges*0+r),
			db0 => ddr_dqo(i*cell_width*data_edges+data_edges*0+f),
			da1 => ddr_dqo(i*cell_width*data_edges+data_edges*1+r),
			db1 => ddr_dqo(i*cell_width*data_edges+data_edges*1+f));
	end generate;

end;
