library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dbdbbl is
	generic (
		adder : boolean := true);
	port (
		bin   : in  std_logic_vector;
		bcd   : out std_logic_vector);
end;

architecture def of dbdbbl is
	constant bcd_length : natural := 4;
	subtype digit_word is unsigned(bcd_length*((bcd'length+bcd_length-1)/bcd_length)-1 downto 0);
	type bcdword_vector is array(natural range <>) of digit_word;
	signal digits_out : bcdword_vector(bin'range);
begin

	digits_g : for k in bin'range generate
		signal digits_in : digit_word;
		signal digits    : digit_word;
	begin

		process (bin(k), digits_out)
		begin
			if k=bin'left then
				digits_in <= (others => '0');
			elsif bin'ascending then
				digits_in <= digits_out(k-1);
			else
				digits_in <= digits_out(k+1);
			end if;
		end process;

		dbdbbl_g : for i in 0 to digit_word'length/bcd_length-1 generate
		begin

			adder_g : if adder generate
				process (digits_in(bcd_length*(i+1)-1 downto bcd_length*i))
				begin
					if digits_in(bcd_length*(i+1)-1 downto bcd_length*i) < x"5" then
						digits(bcd_length*(i+1)-1 downto bcd_length*i) <= digits_in(bcd_length*(i+1)-1 downto bcd_length*i);
					else
						digits(bcd_length*(i+1)-1 downto bcd_length*i) <= digits_in(bcd_length*(i+1)-1 downto bcd_length*i) + x"3";
					end if;
				end process;
			end generate;

			lut_e : if not adder generate
				signal sel : unsigned(bcd_length-1 downto 0);
			begin
				sel <= digits_in(bcd_length*(i+1)-1 downto bcd_length*i);
				with sel select
				digits(bcd_length*(i+1)-1 downto bcd_length*i) <= 
					digits_in(bcd_length*(i+1)-1 downto bcd_length*i) when "0000"|"0001"|"0010"|"0011"|"0100",
					"1000"   when "0101",
					"1001"   when "0110",
					"1010"   when "0111",
					"1011"   when "1000",
					"1100"   when "1001",
					"----"   when others;
			end generate;

		end generate;
		process (digits)
		begin
			digits_out(k) <= shift_left(unsigned(digits),1);
			digits_out(k)(digits'right) <= bin(k);
		end process;
	end generate;
	bcd <= std_logic_vector(resize(digits_out(digits_out'right), bcd'length)); 

end;
