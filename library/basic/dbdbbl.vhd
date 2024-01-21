library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbdbbl_digit is
	port (
		digit_in  : in  std_logic_vector(3-1 downto 0);
		digit_out : out std_logic_vector(3-1 downto 0));
end;


architecture beh of dbdbbl_digit is
	signal b  : std_logic_vector(3-1 downto 0);
	signal s  : std_logic_vector(b'range);
begin
	with digit_in select
	digit_out <= 
		digit_in when "000"|"001"|"010"|"011"|"100",
		"100"    when "101",
		"101"    when "110",
		"110"    when "111",
		"---"    when others;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl is
	port (
		bin  : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of dbdbbl is
	subtype digit_word is std_logic_vector(3*((bcd'length+3-1)/3)-1 downto 0);
	type bcdword_vector is array(natural range <>) of digit_word;
	signal digits_out : bcdword_vector(bin'range);
begin

	digits_g : for k in bin'range generate
		signal digits_in : unsigned(digit_word'range);
	begin
		process (bin(k), digits_out)
			subtype bin_range is natural range bin'range;
		begin
			if k=bin'left then
				digits_in <= (others => '0');
			else
				digits_in <= shift_left(unsigned(digits_out(bin_range'pred(k))), 1);
			end if;
			digits_in(digits_in'right) <= bin(k);
		end process;

		dbdbbl_g : for i in bcd'range generate
			digit_e : entity hdl4fpga.dbdbbl_digit 
			port map (
				digit_in  => std_logic_vector(digits_in(3*(i+1)-1 downto 3*i)),
				digit_out => digits_out(k)(3*(i+1)-1 downto 3*i));
		end generate;
	end generate;

end;
