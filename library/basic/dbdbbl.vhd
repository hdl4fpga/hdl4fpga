library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbdbbl is
	generic (
		adder : boolean := false);
	port (
		bin   : in  std_logic_vector;
		ini   : in  std_logic_vector := (0 to 0 => '0');
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

		process (digits_out, ini)
		begin
			if k=bin'left then
				digits_in <= resize(unsigned(ini), digits'length);
			elsif bin'ascending then
				digits_in <= digits_out(k-1);
			else
				digits_in <= digits_out(k+1);
			end if;
		end process;

		dbdbbl_g : for i in 0 to digit_word'length/bcd_length-1 generate
			alias digit_in  : unsigned(bcd_length-1 downto 0) is digits_in(bcd_length*(i+1)-1 downto bcd_length*i);
			alias digit_out : unsigned(bcd_length-1 downto 0) is digits   (bcd_length*(i+1)-1 downto bcd_length*i);
		begin

			adder_g : if adder generate
				process (digit_in)
				begin
					if digit_in < x"5" then
						digit_out <= digit_in;
					else
						digit_out <= digit_in + x"3";
					end if;
				end process;
			end generate;

			lut_e : if not adder generate
				with digit_in select
				digit_out <= 
					digit_in when "0000"|"0001"|"0010"|"0011"|"0100",
					"1000"  when "0101",
					"1001"  when "0110",
					"1010"  when "0111",
					"1011"  when "1000",
					"1100"  when "1001",
					"----"  when others;
			end generate;

		end generate;

		process (bin(k), digits)
		begin
			digits_out(k) <= shift_left(unsigned(digits),1);
			digits_out(k)(digits'right) <= bin(k);
		end process;
	end generate;
	bcd <= std_logic_vector(resize(digits_out(digits_out'right), bcd'length)); 

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_seq is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		ena : in  std_logic := '1';
		ld  : in  std_logic;
		bin : in  std_logic_vector;
		ini : in  std_logic_vector := (0 to 0 => '0');
		bcd : buffer std_logic_vector);
end;

architecture beh of dbdbbl_seq is
	component dbdbbl
		generic (
			adder : boolean := false);
		port (
			bin   : in  std_logic_vector;
			ini   : in  std_logic_vector := (0 to 0 => '0');
			bcd   : out std_logic_vector);
	end component;

	signal ini_als  : std_logic_vector(bcd'length-1 downto 0);
	signal ini_shr  : std_logic_vector(bcd'length-1 downto 0);
	signal bin_cy   : std_logic_vector(bin'length-1   downto 0);
	signal bin_dbbl : std_logic_vector(bin'range);
	signal ini_dbbl : std_logic_vector(n-1 downto 0);
	signal bcd_dbbl : std_logic_vector(bin'length+n-1 downto 0);

begin

	ini_als <= std_logic_vector(resize(unsigned(ini), ini_als'length));
	bin_dbbl <= 
		bin when ld='1' else
		bin_cy(bin'length-1 downto 0);
		
	ini_dbbl <= 
		ini_als(n-1 downto 0) when ld='1' else
		ini_shr(n-1 downto 0);

	dbdbbl_i : entity hdl4fpga.dbdbbl
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

	process (clk)
		variable shr : unsigned(ini_shr'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if ld='1' then
					shr := unsigned(ini_als);
				end if;
				shr(n-1 downto 0) := unsigned(bcd_dbbl(n-1 downto 0));
				bin_cy <= bcd_dbbl(bin'length+n-1 downto n);
				shr := rotate_right(shr, n);
				ini_shr <= std_logic_vector(shr);
			end if;
		end if;
	end process;

	bcd <= ini_shr;
end;
