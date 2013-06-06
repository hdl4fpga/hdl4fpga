library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
	generic (
		address_size : natural;
		data_size : natural);
	port (
		rd_clk : in std_logic;
		rd_ena : in std_logic := '1';
		rd_address : in std_logic_vector(address_size-1 downto 0);
		rd_data : out std_logic_vector(data_size-1 downto 0);

		wr_clk : in std_logic := '-';
		wr_ena : in std_logic := '0';
		wr_address : in std_logic_vector(address_size-1 downto 0) := (others => '-');
		wr_data : in std_logic_vector(data_size-1 downto 0) := (others => '-'));
end;

architecture default of dpram is
	type word_vector is array (natural range <>) of std_logic_vector(wr_data'range);
	function init
	return word_vector is
		variable val : word_vector(2**address_size-1 downto 0);
	begin
		for i in val'range loop
			val(i) := std_logic_vector(to_unsigned(i mod 256, data_size));
		end loop;
		return val;
	end;

	signal RAM : word_vector(0 to 2**address_size-1); --:= init;
begin
	process (rd_clk)
	begin
		if rising_edge(rd_clk) then
			if rd_ena='1' then
				rd_data <= ram(to_integer(unsigned(rd_address)));
			end if;
		end if;
	end process;
	
	process (wr_clk)
	begin
		if rising_edge(wr_clk) then
			if wr_ena='1' then
				ram(to_integer(unsigned(wr_address))) <= wr_data;
			end if;
		end if;
	end process;
end;
