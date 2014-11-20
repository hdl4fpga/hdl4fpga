library ieee;
use ieee.std_logic_1164.all;

entity ffdArray is
 	generic (
 		ini : std_ulogic_vector);
 	port (
 		rst : in  std_ulogic;
 		clk : in  std_ulogic;
 		q     : out std_ulogic_vector;
 		d     : in  std_ulogic_vector;
 		ena   : in  std_ulogic);
end;

architecture beh of ffdArray is 
begin
 	process (clk, rst)
 	begin
 		if clk='1' and clk'event then
-- 			if rst='1' then
-- 				q <= ini;
-- 			els
				if ena='1' then
 				q <= d;
 			end if;
 		end if;
 	end process;
end;
