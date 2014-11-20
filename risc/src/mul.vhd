library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul is
	port (
		c : in std_ulogic;
		s : in std_logic_vector(1 downto 0);
		a : in  std_logic_vector(31 downto 0);
		b : in  std_logic_vector(31 downto 0);
		d : out std_logic_vector(31 downto 0));
end;

architecture behavioral of mul is
begin
	process (c)
		variable a1,b1 : std_logic_vector(31 downto 0);
		variable s1 : std_logic_vector(1 downto 0);
	begin
		if rising_edge(c) then
			case s1 is
			when "00" =>
				d <= std_logic_vector(unsigned(a1)*unsigned(b1));
--			when "01" =>
				--d <= std_logic_vector(unsigned(a1)*signed(b1));
			when "11" =>
				d <= std_logic_vector(signed(a1)*signed(b1));
			when others =>
				d <= (others => '-');
			end case;
		

			a1 := a;
			b1 := b;
			s1 := s;
		end if;
	end process;
end;
