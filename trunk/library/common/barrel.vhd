library ieee;
use ieee.std_logic_1164.all;

entity barrel is
		generic (
			N : natural;
			M : natural);
	port (
		rot  : in  std_logic_vector(M-1 downto 0);
		din  : in  std_logic_vector(N-1 downto 0);
		dout : out std_logic_vector(N-1 downto 0));
end;

architecture beh of barrel is
begin
	process (din, rot)

		function RotateLeft (val: std_logic_vector; disp : natural) 
			return std_logic_vector is
			variable aux : std_logic_vector (val'length-1 downto 0) := val;
		begin
			return aux(aux'left-disp downto 0) & aux(aux'left downto aux'left-disp+1);
		end;

		variable auxIn:  std_logic_vector(din'length-1 downto 0);
		variable auxSht: std_logic_vector(rot'length-1 downto 0);
		
	begin
		auxIn  := din;

		for i in rot'range loop
			if rot(i)= '1' then
				auxIn := RotateLeft(auxIn, 2**i);
			end if;
		end loop;

		dout<= auxIn;
	end process;
end;
