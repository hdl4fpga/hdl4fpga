entity dqs3i is
	port (
		sys_clk : in std_logic;
		sys_ddrclk : in std_logic;
		ddr_dqsi : in std_logic;

end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of dqs is
begin
	dqsbufd_i : dqsbufd 
	port map (
		rst  => ,
		dqsi => ddr_dqsi,
		sclk => sys_clk,
		read => ,
		dqsdel => ,
		eclk => ,
		eclkw => ,
		rst => ,
		dyndelpol => ,

		dqsw => ,
		ddrclkpol => ,
		prmbdet => ,
		datavalid => ,
		ddrlat => ,
		eclkdqsr => ,
		dqclk0 => ,
		dqclk1 => );

end;
