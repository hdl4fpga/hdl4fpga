library ieee;
use ieee.std_logic_1164.all;

entity idly is
	port (
		i : in std_logic;
		o : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture virtex5 of idly is
begin
	id : ibuf 
	port map (
		i => i,
		o => o);
--	idelay_i : idelay 
--	port map (
--		rst => '0',
--		c   => '0',
--		ce  => '0',
--		inc => '0',
--		i => i,
--		o => o);
end;
