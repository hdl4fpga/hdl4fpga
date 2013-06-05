library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2bcd is
	generic (
		n : natural := 16;
		m : natural := 20);
	port (
		clk : in std_logic;
		ldd  : in std_logic;
		bin : in std_logic_vector(n-1 downto 0);
		bcd : out std_logic_vector(m-1 downto 0));
end;

architecture def of bin2bcd is
	signal p : unsigned(bcd'length+bin'length-1 downto 0);
begin
	process(clk)
		variable mux : unsigned(bcd'length+bin'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if ldd='1' then
				p <= unsigned((1 to bcd'length => '0') & bin);
			else
				mux := p;
				for i in 0 to (bcd'length+4-1)/4-1 loop
					if mux(4*(i+1)-1+bin'length downto 4*i+bin'length) >= unsigned'("0101")  then
						mux(4*(i+1)+bin'length-1 downto 4*i+bin'length) := mux(4*(i+1)+bin'length-1 downto 4*i+bin'length) + 3;
					end if;
				end loop;
				p <= mux(mux'left-1 downto mux'right) & '0';
			end if;
		end if;
	end process;
	bcd <= std_logic_vector(p(p'left downto bin'length));
end;
