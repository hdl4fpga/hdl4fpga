entity dqs3ctrl is
	port (
		sys_clk : in std_logic;
		sys_ddrclk : in std_logic;
		ddr_dqsi : in std_logic;

end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of dqs3ctrl is
begin
	dqsbufd_i : dqsbufd 
	port map (
		rst  => ,
		dyndelpol => ,
		dyndelay  => ,
		sclk => sys_clk,
		eclk => ,
		eclkw  => ,
		read => ,
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

end;
