entity dqs3i is
	port (

end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of dqs is
begin
	dqsbufd_i : dqsbufd 
	port map (
		dqsi => ,
		sclk => ,
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
