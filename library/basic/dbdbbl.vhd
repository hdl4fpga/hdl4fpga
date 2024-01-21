library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

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
use hdl4fpga.base.all;

entity dbdbbl is
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		bin  : in  std_logic;
		bcd  : out std_logic_vector);
end;

architecture def of dbdbbl is
	subtype bcd_word : std_logic_vector(3*((bcd'lenth+3-1)/3)-1 downto 0);
	type bcdword_vector is array(natural range <>) of bcd_word;
	signal bcd_in  : bcdword_vector(bin'range);
	signal bcd_out : bcdword_vector(bin'range);;
begin

	g : for k in bin'range loop
	begin
		dbdbbl_g : for i in bcd'range generate
			digit_e : entity hdl4fpga.dbdbbl_digit 
			port (
				digit_in  => bcd_in (k)(3*(i+1)-1 downto 3*i),
				digit_out => bcd_out(k)(3*(i+1)-1 downto 3*i));
		end generate;
	end generate;

end;
