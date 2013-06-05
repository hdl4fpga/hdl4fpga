library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
	generic (
		m : natural);
	port (
		sel : in  std_logic_vector(m-1 downto 0);
		di  : in  std_logic_vector(0 to 2**m-1);
		do  : out std_logic);
end;

architecture arch of mux is
begin
	do <= di(to_integer(unsigned(sel)));
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxw is
	generic (
		addr_size : natural;
		data_size : natural);
	port (
		sel : in  std_logic_vector(addr_size-1 downto 0);
		di  : in  std_logic_vector(0 to 2**addr_size*data_size-1);
		do  : out std_logic_vector(0 to data_size-1));
end;

architecture arch of muxw is
begin
	mux_g : for i in 0 to data_size-1 generate
		signal d : std_logic_vector(0 to 2**addr_size-1);
	begin
		process (di)
		begin
			for j in 0 to 2**addr_size-1 loop
				d(j) <= di(data_size*j+i);
			end loop;
		end process;

		do(i) <= d(to_integer(unsigned(sel)));
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux is
	generic (
		n : natural);
	port (
		s : in  std_logic_vector(n-1 downto 0);
		e : in  std_logic := '1';
		o : out std_logic_vector(2**n-1 downto 0));
end;

architecture arch of demux is
begin
	process (e,s)
	begin
		o <= (others => '0');
		o(to_integer(unsigned(s))) <= e;
	end process;
end;
