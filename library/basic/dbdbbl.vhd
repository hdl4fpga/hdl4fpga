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
		irdy : in  std_logic := '1';
		trdy : buffer std_logic;
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
		bin when trdy='1' else
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
			if irdy='1' then
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
				trdy <= shr1(0);
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
		req  : in  std_logic;
		rdy  : buffer std_logic;
		irdy : in  std_logic := '1';
		trdy : out std_logic;
		bin  : in  std_logic_vector;
		ini  : in  std_logic_vector := std_logic_vector'(0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	alias bin_als    : std_logic_vector(0 to bin'length-1) is bin;
end;

architecture def of dbdbbl_seq is
	signal ser_irdy : std_logic;
	signal load : std_logic;
	signal ser_trdy : std_logic;
	signal bin_slice : std_logic_vector(0 to bin_digits-1);
begin
	process (bin_als, rdy, req, ser_trdy, clk)
		variable shr    : unsigned(0 to bin'length-1);
		variable cntr   : integer range -1 to bin'length/bin_digits-2;
		variable in_rdy : std_logic;
		variable in_req : std_logic;
	begin
		if rising_edge(clk) then
			if irdy='1' then
				if (to_bit(req) xor to_bit(rdy))='0' then
					cntr   := bin'length/bin_digits-2;
					in_rdy := to_stdulogic(to_bit(req));
				elsif (to_bit(in_rdy) xor to_bit(in_req))='0' then
					cntr   := bin'length/bin_digits-2;
					shr    := unsigned(bin);
					shr    := shr sll bin_slice'length;
				elsif ser_trdy/='0' then
					shr := shr sll bin_slice'length;
					if cntr < 0 then
						if (to_bit(req) xor to_bit(rdy))='1' then
							shr  := unsigned(bin);
							shr  := shr sll bin_slice'length;
							cntr := bin'length/bin_digits-2;
						end if;
						in_rdy := to_stdulogic(to_bit(in_req));
					else
						cntr := cntr - 1;
					end if;
				end if;
				in_req := to_stdulogic(to_bit(req));
				if cntr < 0 then
					trdy <= '1';
				else
					trdy <= '0';
				end if;
			end if;
		end if;

		rdy <= to_stdulogic(to_bit(in_rdy));
		if ser_trdy/='0' then
			if cntr < 0 then
				rdy <= to_stdulogic(to_bit(in_req));
			end if;
		end if;

		load <= '0';
		bin_slice <= std_logic_vector(shr(0 to bin_slice'length-1));
		if (to_bit(req) xor to_bit(rdy))='0' then
			load <= '0';
			bin_slice <= std_logic_vector(shr(0 to bin_slice'length-1));
		elsif (to_bit(in_req) xor to_bit(in_rdy))='0' then
			load <= '1';
			bin_slice <= bin_als(0 to bin_slice'length-1);
		elsif ser_trdy/='0' then
			if cntr < 0 then
				if (to_bit(req) xor to_bit(rdy))='1' then
					load <= '1';
					bin_slice <= bin_als(0 to bin_slice'length-1);
				end if;
			end if;
		end if;
	end process;

	ser_irdy <= 
		'0' when irdy='0' else
		'0' when (to_bit(req) xor to_bit(rdy))='0' else
		'1';

	dbdbblser_e : entity hdl4fpga.dbdbbl_ser
	generic map (
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		irdy => ser_irdy,
		load => load,
		trdy => ser_trdy,
		ini  => ini,
		bin  => bin_slice,
		bcd  => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_ser1 is
	generic (
		bcd_digits : natural);
	port (
		clk  : in  std_logic;
		frm  : in  std_logic;
		irdy : in  std_logic := '1';
		trdy : buffer std_logic := '1';
		bin  : in  std_logic_vector;
		ini  : in  std_logic_vector := (0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	constant n : natural := bcd_length*bcd_digits;
end;

architecture beh of dbdbbl_ser1 is

	signal ini_als  : std_logic_vector(bcd'length-1 downto 0);
	signal ini_shr  : std_logic_vector(bcd'length-1 downto 0);
	signal bin_dbbl : std_logic_vector(bin'range);
	signal ini_dbbl : std_logic_vector(n-1 downto 0);
	signal bcd_dbbl : std_logic_vector(bin'length+n-1 downto 0);

begin

	ini_als  <= std_logic_vector(resize(unsigned(ini), ini_als'length));
	process (bin, ini_als, clk)
		type states is (s_load, s_run);
		variable state : states;
		variable shr0 : unsigned(ini_shr'length-1 downto 0);
		variable shr1 : unsigned(0 to bcd'length/(bcd_digits*bcd_length)-1);
	variable cy       : std_logic_vector(bin'length-1 downto 0);
	begin
		if rising_edge(clk) then
			case state is
			when s_load =>
				if frm='1' then
					shr0  := unsigned(ini_als);
					shr1  := rotate_left(shr1, 1);
					state := s_run;
				else
					shr1 := (others => '0');
					shr1(0) := '1';
				end if;
			when s_run =>
				if frm='1' then
					shr1 := rotate_left(shr1, 1);
				else
					shr1 := (others => '0');
					shr1(0) := '1';
					state := s_load;
				end if;
			end case;
			trdy <= shr1(0);
			shr0(n-1 downto 0) := unsigned(bcd_dbbl(n-1 downto 0));
			shr0 := rotate_right(shr0, n);
			ini_shr <= std_logic_vector(shr0);
			cy   := bcd_dbbl(bin'length+n-1 downto n);
		end if;

		case state is
		when s_load => 
			ini_dbbl <= ini_als(n-1 downto 0);
			bin_dbbl <= bin;
		when s_run => 
				ini_dbbl <= std_logic_vector(shr0(n-1 downto 0));
				if shr1(0)='1' then
					bin_dbbl <= bin;
				else
					bin_dbbl <= cy;
				end if;
		end case;
	end process;

		
	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

	assert ((10-1)*2**bin'length+2**bin'length) < 10**(bcd_digits+1)
		report "Constraint parameters do not match : " &
			natural'image(9*2**bin'length+2**bin'length) & " : " & natural'image(10**(bcd_digits+1))
		severity failure;

	bcd <= ini_shr;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_seq1 is
	generic (
		bcd_digits : natural := 1;
		bin_digits : natural := 3);
	port (
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic;
		irdy : in  std_logic := '1';
		trdy : out std_logic;
		bin  : in  std_logic_vector;
		ini  : in  std_logic_vector := std_logic_vector'(0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	alias bin_als    : std_logic_vector(0 to bin'length-1) is bin;
end;

architecture def of dbdbbl_seq1 is
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic;
	signal ser_trdy : std_logic;
	signal ser_bin  : std_logic_vector(0 to bin_digits-1);
begin
	process (clk)
		type states is (s_init, s_run);
		variable state : states;
		variable shr  : unsigned(0 to bin'length-1);
		variable cntr : integer range -1 to bin'length/bin_digits-1;
	begin
		if rising_edge(clk) then
			if (to_bit(req) xor to_bit(rdy))='1' then
    			case state is
    			when s_init =>
    				ser_frm <= '1';
    				ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
    				shr     := unsigned(bin);
    				cntr    := bin'length/bin_digits-1;
					trdy    <= '0';
					state   := s_run;
    			when s_run =>
        			if irdy='1' then
        				if ser_trdy='1' then
        					if cntr < 0 then
        						ser_frm <= '0';
								trdy  <= '0';
        						rdy   <= to_stdulogic(to_bit(req));
								state := s_init;
        					else
        						ser_frm <= '1';
        						cntr := cntr - 1;
								if cntr < 0 then
									trdy <= '1';
								end if;
        					end if;
        				end if;

						if ser_frm='1' then
							if ser_trdy='1' then
        						ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
        						shr     := shift_left(shr, ser_bin'length);
        					end if;
						end if;
					end if;
    			end case;
			else
				state := s_init;
			end if;

		end if;

	end process;

	dbdbblser_e : entity hdl4fpga.dbdbbl_ser1
	generic map (
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		ini  => ini,
		frm  => ser_frm,
		trdy  => ser_trdy,
		bin  => ser_bin,
		bcd  => bcd);
end;
