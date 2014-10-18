library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
	port (
		rd_clk  : in std_logic;
		rd_ena  : in std_logic := '1';
		rd_addr : in std_logic_vector;
		rd_data : out std_logic_vector;

		wr_clk  : in std_logic := '-';
		wr_ena  : in std_logic := '0';
		wr_addr : in std_logic_vector;
		wr_data : in std_logic_vector);
end;

architecture def of dpram is
	type word_vector is array (natural range <>) of std_logic_vector(wr_data'range);

	signal RAM : word_vector(0 to 2**rd_addr'length-1);
begin
	process (rd_clk)
	begin
		if rising_edge(rd_clk) then
			if rd_ena='1' then
				rd_data <= ram(to_integer(unsigned(rd_addr)));
			end if;
		end if;
	end process;
	
	process (wr_clk)
	begin
		if rising_edge(wr_clk) then
			if wr_ena='1' then
				ram(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
		end if;
	end process;
end;
