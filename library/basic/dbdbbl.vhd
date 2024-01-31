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

entity dbdbbl_ser is
	generic (
		bcd_digits : natural);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		feed : buffer std_logic;
		load : in  std_logic;
		bin  : in  std_logic_vector;
		ini  : in  std_logic_vector := (0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	constant n : natural := bcd_length*bcd_digits;
end;

architecture beh of dbdbbl_ser is

	signal cy       : std_logic_vector(bin'length-1 downto 0);
	signal ini_als  : std_logic_vector(bcd'length-1 downto 0);
	signal ini_shr  : std_logic_vector(bcd'length-1 downto 0);
	signal bin_dbbl : std_logic_vector(bin'range);
	signal ini_dbbl : std_logic_vector(n-1 downto 0);
	signal bcd_dbbl : std_logic_vector(bin'length+n-1 downto 0);

begin

	ini_als <= std_logic_vector(resize(unsigned(ini), ini_als'length));
	bin_dbbl <= 
		bin when load='1' else
		bin when feed='1' else
		cy;
		
	ini_dbbl <= 
		ini_als(n-1 downto 0) when load='1' else
		ini_shr(n-1 downto 0);

	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

	assert ((10-1)*2**bin'length+2**bin'length) < 10**(bcd_digits+1)
		report "Constraint parameters do not match : " &
			natural'image(9*2**bin'length+2**bin'length) & " : " & natural'image(10**(bcd_digits+1))
		severity failure;

	process (clk)
		variable shr0 : unsigned(ini_shr'length-1 downto 0);
		variable shr1 : unsigned(0 to bcd'length/(bcd_digits*bcd_length)-1);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if load='1' then
					shr1 := (others => '0');
					shr1(0) := '1';
					shr0 := unsigned(ini_als);
				end if;
				shr0(n-1 downto 0) := unsigned(bcd_dbbl(n-1 downto 0));
				shr0 := rotate_right(shr0, n);
				ini_shr <= std_logic_vector(shr0);
				cy  <= bcd_dbbl(bin'length+n-1 downto n);
				shr1 := rotate_left(shr1, 1);
				feed <= shr1(0);
			end if;
		end if;
	end process;

	bcd <= ini_shr;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_seq is
	generic (
		bcd_digits : natural := 1;
		bin_digits : natural := 3);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		req : in  std_logic;
		rdy  : buffer std_logic;
		bin  : in  std_logic_vector;
		ini  : in  std_logic_vector := std_logic_vector'(0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	alias bin_als    : std_logic_vector(0 to bin'length-1) is bin;
end;

architecture def of dbdbbl_seq is
	signal load : std_logic;
	signal feed : std_logic;
	signal bin_slice : std_logic_vector(0 to bin_digits-1);
	signal cntr : integer range -1 to bin'length/bin_digits-2;
begin
	process (load, clk)
		variable shr  : unsigned(0 to bin'length-1);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if (to_bit(req) xor to_bit(rdy))='0' then
					shr  := unsigned(bin);
					shr  := shr sll bin_slice'length;
					cntr <= bin'length/bin_digits-2;
				elsif feed='1' then
					shr := shr sll bin_slice'length;
					if cntr >= 0 then
						cntr <= cntr - 1;
					end if;
					if cntr < 0 then
						rdy <= req;
					end if;
				end if;
			end if;
		end if;
		if (to_bit(req) xor to_bit(rdy))='0' then
			bin_slice <= bin_als(0 to bin_slice'length-1);
		else
			bin_slice <= std_logic_vector(shr(0 to bin_slice'length-1));
		end if;
	end process;

	load <= not (to_stdulogic(to_bit(req) xor to_bit(rdy)));
	dbdbblser_e : entity hdl4fpga.dbdbbl_ser
	generic map (
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		ena  => ena,
		load => load,
		feed => feed,
		ini  => ini,
		bin  => bin_slice,
		bcd  => bcd);
end;