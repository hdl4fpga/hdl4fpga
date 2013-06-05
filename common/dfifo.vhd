library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity dfifo is
	generic (
		n : natural := 14;
		m : natural := 4);
	port (
		clki : in std_logic;
		clko : in std_logic;
		di : in std_logic_vector(0 to n-1);
		do : out std_logic_vector(0 to n-1) := (others => '0'));
end;

architecture def of dfifo is
	signal ni : unsigned(0 to m-1);
	signal no : unsigned(0 to m-1);

	subtype word is std_logic_vector(0 to n-1);
	type word_vector is array (natural range <>) of word;
	signal ram : word_vector(0 to 2**m-1) := (others => (others => '0'));
begin
	process (clki)
		variable waddr : unsigned(0 to m-1) := (others => '0');
	begin
		if rising_edge(clki) then
			ram(to_integer(waddr)) <= di;
			waddr := ni;
			ni <= ni + 1;
		end if;
	end process;

	process (clko)
		variable raddr : unsigned(0 to m-1) := (others => '0');
	begin
		if rising_edge(clko) then
			do <= ram(to_integer(raddr));
			raddr := no;
			no <= no + 1;
		end if;
	end process;
end;