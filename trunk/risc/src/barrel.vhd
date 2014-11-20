library ieee;
use ieee.std_logic_1164.all;

entity barrel is
		generic (
			N : natural;
			M : natural);
	port (
		sht  : in  std_ulogic_vector(M-1 downto 0);
		din  : in  std_ulogic_vector(N-1 downto 0);
		dout : out std_ulogic_vector(N-1 downto 0));
end;

architecture beh of barrel is
begin
	process (din, sht)

		function RotateLeft (val: std_ulogic_vector; disp : natural) 
			return std_ulogic_vector is
			variable aux : std_ulogic_vector (val'length-1 downto 0) := val;
		begin
			return aux(aux'left-disp downto 0) & aux(aux'left downto aux'left-disp+1);
		end;

		variable auxIn:  std_ulogic_vector(din'length-1 downto 0);
		variable auxSht: std_ulogic_vector(sht'length-1 downto 0);
		
	begin
		auxIn  := din;

		for i in sht'range loop
			if sht(i)= '1' then
				auxIn := RotateLeft(auxIn, 2**i);
			end if;
		end loop;

		dout<= auxIn;
	end process;
end;
