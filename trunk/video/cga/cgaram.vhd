library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cgaram is
	port (
		wr_clk  : in std_logic;
		wr_ena  : in std_logic;
		wr_row  : in std_logic_vector;
		wr_col  : in std_logic_vector;
		wr_code : in std_logic_vector;

		rd_clk  : in std_logic;
		rd_row  : in  std_logic_vector;
		rd_col  : in  std_logic_vector;
		rd_code : out std_logic_vector);

end;

use work.std.all;

architecture def of cgaram is

	subtype word is std_logic_vector(rd_code'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	signal charram  : word_vector(2**(rd_row'length+rd_col'length)-1 downto 0);

	signal wr_addr : std_logic_vector(wr_row'length+wr_col'length-1 downto 0);
	signal rd_addr : std_logic_vector(rd_row'length+rd_col'length-1 downto 0);

begin

	wr_addr <= wr_row & wr_col;
	rd_addr <= rd_row & rd_col;
	assert rd_addr'length=wr_addr'length
		report "cgaram"
		severity ERROR;
	dpram_e : entity work.dpram
	generic map (
		address_size => wr_row'length+wr_col'length,
		data_size => rd_code'length)
	port map (
		wr_clk => wr_clk,
		wr_ena => wr_ena,
		wr_address => wr_addr,
		wr_data => wr_code,

		rd_clk => rd_clk,
		rd_address => rd_addr,
		rd_data => rd_code);
end;
