library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbdbbl_digit is
	port (
		digit_in  : in  std_logic_vector(4-1 downto 0);
		digit_out : out std_logic_vector(4-1 downto 0));
end;

architecture beh of dbdbbl_digit is
	signal b  : unsigned(digit_in'range);
begin
	b <= x"0" when unsigned(digit_in) < x"5" else x"3";
	digit_out <= std_logic_vector(unsigned(digit_in)+b);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dbdbbl is
	port (
		bin  : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of dbdbbl is
	subtype digit_word is std_logic_vector(4*((bcd'length+4-1)/4)-1 downto 0);
	type bcdword_vector is array(natural range <>) of digit_word;
	signal digits_out : bcdword_vector(bin'range);
begin

	digits_g : for k in bin'range generate
		signal digits_in  : bcdword_vector(bin'range);
		signal digits : digit_word;
	begin
		process (bin(k), digits_out)
			subtype bin_range is natural range bin'range;
		begin
			if k=bin'left then
				digits_in <= (others => '0');
			else
				digits_in <= digits_out(bin_range'pred(k));
			end if;
		end process;

		dbdbbl_g : for i in 0 to digit_word'length/4-1 generate
		begin
			process(digits_out(k)(4*(i+1)-1 downto 4*i))
			begin
				report "digits_in  " & natural'image(k) & " : " & natural'image(i) & " : " & to_string(digits_in(4*(i+1)-1 downto 4*i));
				report "digits_out " & natural'image(k) & " : " & natural'image(i) & " : " & to_string(digits_out(k)(4*(i+1)-1 downto 4*i));
			end process;

			digit_e : entity hdl4fpga.dbdbbl_digit 
			port map (
				digit_in  => digits_in(k)(4*(i+1)-1 downto 4*i),
				digit_out => digits(4*(i+1)-1 downto 4*i));
		end generate;
		process (digits)
		begin
			digits_out(k) <= std_logic_vector(shift_left(unsigned(digits),1));
			digits_out(k)(digits'right) <= bin(k);
		end process;
	end generate;
	bcd <= digits_out(digits_out'right); 

end;
