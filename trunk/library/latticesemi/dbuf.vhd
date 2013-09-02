library ieee;
use ieee.std_logic_1164.all;

entity odbuf is
	port (
		i   : in std_logic;
		o_p : out std_logic;
		o_n : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of odbuf is
begin
	odbuf_i : olvds
	port map (
		a  => i,
		z  => o_p,
		zn => o_n);
end;

library ieee;
use ieee.std_logic_1164.all;

entity idbuf is
	port (
		i_p : in std_logic;
		i_n : in std_logic;
		o   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of idbuf is
begin
	idbuf_i : ilvds
	port map (
		a  => i_p,
		an => i_n,
		z  => o);
end;
