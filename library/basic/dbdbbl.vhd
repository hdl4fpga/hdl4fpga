library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_srlfix is
	generic (
		adder : boolean := false);
	port (
		rnd   : in  std_logic := '0';
		ini   : in  std_logic_vector := (0 to 0 => '0');
		bin   : buffer std_logic_vector;
		bcd   : out std_logic_vector);

	constant bcd_length : natural := 4;
	alias    bin_rev    : std_logic_vector(bin'reverse_range) is bin;
end;

architecture def of dbdbbl_srlfix is
	subtype digit_word  is unsigned(bcd_length*((bcd'length+bcd_length-1)/bcd_length)-1 downto 0);
	type bcdword_vector is array(natural range <>) of digit_word;

	signal digits_out : bcdword_vector(bin'range);
	signal s          : std_logic_vector(digit_word'range);
begin

	digits_g : for k in bin'range generate
		signal digits_in : digit_word;
		signal digits    : digit_word;
	begin

		process (digits_out, ini)
		begin
			if k=bin'left then
				bin_rev(k) <= ini(ini'right);
				digits_in  <= shift_right(resize(unsigned(ini), digits'length),1);
			elsif bin'ascending then
				bin_rev(k) <= digits_out(k-1)(digit_word'right);
				digits_in  <= shift_right(digits_out(k-1),1);
			else
				bin_rev(k) <= digits_out(k+1)(digit_word'right);
				digits_in  <= shift_right(digits_out(k+1),1);
			end if;
		end process;

		dbdbbl_g : for i in 0 to digit_word'length/bcd_length-1 generate
			alias digit_in  : unsigned(bcd_length-1 downto 0) is digits_in(bcd_length*(i+1)-1 downto bcd_length*i);
			alias digit_out : unsigned(bcd_length-1 downto 0) is digits   (bcd_length*(i+1)-1 downto bcd_length*i);
			signal a : std_logic_vector(digit_word'range);
			signal s : std_logic_vector(digit_word'range);
		begin

			adder_g : if adder generate
				process (digit_in)
				begin
					if digit_in < x"5" then
						digit_out <= digit_in;
					else
						digit_out <= digit_in - x"3";
					end if;
				end process;
			end generate;

			lut_e : if not adder generate
				with digit_in select
				digit_out <= 
					digit_in when "0000"|"0001"|"0010"|"0011"|"0100",
					"0101"  when "1000",
					"0110"  when "1001",
					"0111"  when "1010",
					"1000"  when "1011",
					"1001"  when "1100",
					"----"  when others;
			end generate;

			digits_out(k) <= digits;
		end generate;

	end generate;

	bcd_adder_e : entity hdl4fpga.bcd_adder
	port map (
		ci => bin(bin'left),
		a  => std_logic_vector(digits_out(digits_out'right)),
		s  => s);
	bcd <= 
		s when rnd='1' else
		std_logic_vector(resize(digits_out(digits_out'right), bcd'length)); 

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_srl is
	generic (
		round : boolean := false;
		adder : boolean := false);
	port (
		ini   : in  std_logic_vector := (0 to 0 => '0');
		cnt   : in  std_logic_vector;
		bcd   : out std_logic_vector);

	constant bcd_length : natural := 4;
end;

architecture def of dbdbbl_srl is
	subtype digit_word  is std_logic_vector(bcd_length*((bcd'length+bcd_length-1)/bcd_length)-1 downto 0);
	type bcdword_vector is array(natural range <>) of digit_word;

	alias sel : std_logic_vector(cnt'length-1 downto 0) is cnt;
	signal digits : bcdword_vector(0 to cnt'length);
begin
	digits(0) <= std_logic_vector(resize(unsigned(ini), digit_word'length));
	g : for i in sel'range generate
		signal bin : std_logic_vector(0 to 2**i-1);
		signal bcd : digit_word;
	begin
		dbdbbl_srlfix_e : entity hdl4fpga.dbdbbl_srlfix
		port map (
			ini => digits(i),
			bin => bin,
			bcd => bcd);

		digits(i+1) <= bcd when sel(i)='1' else digits(i);
	end generate;
	bcd <= std_logic_vector(resize(unsigned(digits(digits'right)), bcd'length));

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dbdbblsrl_ser is
	generic (
		bcd_width  : natural;
		bcd_digits : natural);
	port (
		clk  : in  std_logic;
		frm  : in  std_logic;
		irdy : in  std_logic := '1';
		trdy : buffer std_logic := '1';
		bin  : out std_logic_vector;
		ini  : in  std_logic_vector := (0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
	constant n : natural := bcd_length*bcd_digits;
end;

architecture beh of dbdbblsrl_ser is

	signal bin_dbbl : std_logic_vector(bin'range);
	signal bcd_dbbl : std_logic_vector(n-1 downto 0);
	signal ini_dbbl : std_logic_vector(bin'length+n-1 downto 0);

	constant addr_size : natural := unsigned_num_bits(bcd_width/bcd_digits-1);
	signal addr        : std_logic_vector(1 to addr_size);
	signal rd_data     : std_logic_vector(bcd'range);
	signal init        : boolean;
begin

	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => addr,
		wr_ena  => irdy,
		wr_data => bcd_dbbl(n-1 downto 0),
		rd_addr => addr,
		rd_data => rd_data);

	process (bin_dbbl, clk)
		type states is (s_init, s_run);
		variable state : states;
		variable cntr  : unsigned(0 to addr'length);
		variable cy    : std_logic_vector(bin'length-1 downto 0);
	begin
		ff_l : if rising_edge(clk) then
			case state is
			when s_init =>
				if frm='1' then
					if irdy='1' then
						cntr := to_unsigned(bcd_width/bcd_digits-2, cntr'length);
						state := s_run;
					end if;
				else
					cntr := (others => '1');
				end if;
				init <= true;
			when s_run =>
				if irdy='1' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						if cntr(0)='1' then
							init <= false;
						end if;
					elsif frm='1' then
						cntr := to_unsigned(bcd_width/bcd_digits-2, cntr'length);
					else
						init  <= true;
						state := s_init;
					end if;
				end if;
			end case;
			trdy <= cntr(0);
			if irdy='1' then
				cy   := bcd_dbbl(bin'length+n-1 downto n);
				bcd  <= bcd_dbbl(n-1 downto 0);
				addr <= std_logic_vector(cntr(addr'range));
			end if;
		end if;

		comb_l : case state is
		when s_init => 
			cy := (others => '0');
		when s_run => 
			if cntr(0)='1' then
				bin <= cy;
			else
				cy := bin_dbbl;
			end if;
		end case;

	end process;

	ini_dbbl <= 
		std_logic_vector(resize(unsigned(ini), ini_dbbl'length)) when init else
		rd_data;

	dbdbbl_e : entity hdl4fpga.dbdbbl_srlfix
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbdbbl_sll is
	generic (
		adder : boolean := false);
	port (
		bin   : in  std_logic_vector;
		ini   : in  std_logic_vector := (0 to 0 => '0');
		bcd   : out std_logic_vector);
end;

architecture def of dbdbbl_sll is
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

entity dbdbbl_shr is
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

architecture beh of dbdbbl_shr is

	signal bin_dbbl : std_logic_vector(bin'range);
	signal ini_dbbl : std_logic_vector(n-1 downto 0);
	signal bcd_dbbl : std_logic_vector(bin'length+n-1 downto 0);

begin

	process (bin, ini, clk)
		type states is (s_init, s_run);
		variable state : states;
		variable shr  : unsigned(bcd'length-1 downto 0);
		variable cntr : integer range -1 to bcd'length/(bcd_digits*bcd_length)-2;
		variable cy   : std_logic_vector(bin'length-1 downto 0);
	begin
		ff_l : if rising_edge(clk) then
			case state is
			when s_init =>
				if frm='1' then
					shr := resize(unsigned(ini), shr'length);
					shr(n-1 downto 0) := unsigned(bcd_dbbl(n-1 downto 0));
					shr := rotate_right(shr, n);
					bcd <= std_logic_vector(shr);
					cntr := bcd'length/(bcd_digits*bcd_length)-2;
					state := s_run;
				else
					cntr := -1;
				end if;
			when s_run =>
				shr(n-1 downto 0) := unsigned(bcd_dbbl(n-1 downto 0));
				shr := rotate_right(shr, n);
				if cntr >= 0 then
					bcd <= std_logic_vector(shr);
					cntr := cntr -1;
				elsif frm='1' then
					cntr := bcd'length/(bcd_digits*bcd_length)-2;
					bcd <= std_logic_vector(shr);
				else
					state := s_init;
				end if;
			end case;
			if cntr < 0 then
				trdy <= '1';
			else
				trdy <= '0';
			end if;
			cy  := bcd_dbbl(bin'length+n-1 downto n);
		end if;

		com_l : case state is
		when s_init => 
			ini_dbbl <= std_logic_vector(resize(rotate_left(resize(unsigned(ini), bcd'length), ini_dbbl'length), ini_dbbl'length));
			bin_dbbl <= bin;
		when s_run => 
			ini_dbbl <= std_logic_vector(shr(n-1 downto 0));
			if cntr < 0 then
				bin_dbbl <= bin;
			else
				bin_dbbl <= cy;
			end if;
		end case;

	end process;

		
	dbdbbl_e : entity hdl4fpga.dbdbbl_sll
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

	assert ((10-1)*2**bin'length+2**bin'length) < 10**(bcd_digits+1)
		report "Constraint parameters do not match : " &
			natural'image(9*2**bin'length+2**bin'length) & " : " & natural'image(10**(bcd_digits+1))
		severity failure;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_seqshr is
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
end;

architecture def of dbdbbl_seqshr is
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic := '1';
	signal ser_trdy : std_logic;
	signal ser_bin  : std_logic_vector(0 to bin_digits-1);
begin
	process (clk)
		type states is (s_init, s_run);
		variable state : states;
		variable shr  : unsigned(0 to bin'length-1);
		variable cntr : integer range -1 to bin'length/bin_digits-2;
	begin
		if rising_edge(clk) then
			if (to_bit(req) xor to_bit(rdy))='1' then
				case state is
				when s_init =>
					shr     := unsigned(bin);
					ser_frm <= '1';
					ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
					cntr    := bin'length/bin_digits-2;
					trdy    <= '0';
					state   := s_run;
				when s_run =>
					if irdy='1' then
						if ser_trdy='1' then
							if cntr < 0 then
								if ser_frm='0' then
									trdy  <= '0';
									rdy   <= to_stdulogic(to_bit(req));
									state := s_init;
								else
									trdy  <= '1';
								end if;
								ser_frm <= '0';
							else
								ser_frm <= '1';
								cntr := cntr - 1;
							end if;
						end if;

						if ser_frm='1' then
							if ser_trdy='1' then
								shr     := shift_left(shr, ser_bin'length);
								ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
							end if;
						end if;

					end if;
				end case;
			else
				state := s_init;
			end if;

		end if;

	end process;

	dbdbblser_e : entity hdl4fpga.dbdbbl_shr
	generic map (
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		ini  => ini,
		frm  => ser_frm,
		trdy => ser_trdy,
		bin  => ser_bin,
		bcd  => bcd);
end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dbdbbl_ser is
	generic (
		bcd_width  : natural;
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

architecture beh of dbdbbl_ser is

	signal bin_dbbl : std_logic_vector(bin'range);
	signal ini_dbbl : std_logic_vector(n-1 downto 0);
	signal bcd_dbbl : std_logic_vector(bin'length+n-1 downto 0);

	constant addr_size : natural := unsigned_num_bits(bcd_width/bcd_digits-1);
	signal addr        : std_logic_vector(1 to addr_size);
	signal rd_data     : std_logic_vector(bcd'range);
	signal init        : boolean;
begin

	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => addr,
		wr_ena  => irdy,
		wr_data => bcd_dbbl(n-1 downto 0),
		rd_addr => addr,
		rd_data => rd_data);

	process (bin, clk)
		type states is (s_init, s_run);
		variable state : states;
		variable cntr  : unsigned(0 to addr'length);
		variable cy    : std_logic_vector(bin'length-1 downto 0);
	begin
		ff_l : if rising_edge(clk) then
			case state is
			when s_init =>
				if frm='1' then
					if irdy='1' then
						cntr := to_unsigned(bcd_width/bcd_digits-2, cntr'length);
						state := s_run;
					end if;
				else
					cntr := (others => '1');
				end if;
				init <= true;
			when s_run =>
				if irdy='1' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						if cntr(0)='1' then
							init <= false;
						end if;
					elsif frm='1' then
						cntr := to_unsigned(bcd_width/bcd_digits-2, cntr'length);
					else
						init  <= true;
						state := s_init;
					end if;
				end if;
			end case;
			trdy <= cntr(0);
			if irdy='1' then
				cy   := bcd_dbbl(bin'length+n-1 downto n);
				bcd  <= bcd_dbbl(n-1 downto 0);
				addr <= std_logic_vector(cntr(addr'range));
			end if;
		end if;

		comb_l : case state is
		when s_init => 
			bin_dbbl <= bin;
		when s_run => 
			if cntr(0)='1' then
				bin_dbbl <= bin;
			else
				bin_dbbl <= cy;
			end if;
		end case;

	end process;

	ini_dbbl <= 
		std_logic_vector(resize(unsigned(ini), ini_dbbl'length)) when init else
		rd_data;

	dbdbbl_e : entity hdl4fpga.dbdbbl_sll
	port map (
		bin => bin_dbbl,
		ini => ini_dbbl,
		bcd => bcd_dbbl);

	assert ((10-1)*2**bin'length+2**bin'length) < 10**(bcd_digits+1)
		report "Constraint parameters do not match : " &
			natural'image(9*2**bin'length+2**bin'length) & " : " & natural'image(10**(bcd_digits+1))
		severity failure;

end;

-- Lattice Diamond wrong synthesis 
-- https://github.com/hdl4fpga/hdl4fpga/blob/ba3f85bc17be9a722309060171e843c23c38b3a1/library/basic/dbdbbl.vhd#L276

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dbdbbl_seq is
	generic (
		bcd_width  : natural;
		bcd_digits : natural := 1;
		bin_digits : natural := 3);
	port (
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic;
		bin_irdy : in  std_logic := '1';
		bin  : in  std_logic_vector;
		bcd_frm  : out std_logic;
		bcd_irdy : buffer std_logic;
		bcd_trdy : in  std_logic := '1';
		ini  : in  std_logic_vector := std_logic_vector'(0 to 0 => '0');
		bcd  : out std_logic_vector);

	constant bcd_length : natural := 4;
end;

architecture def of dbdbbl_seq is
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic; -- : '1';
	signal ser_trdy : std_logic;
	signal ser_bin  : std_logic_vector(0 to bin_digits-1);
begin
	bcd_frm  <= bcd_irdy;
	ser_irdy <= not bcd_irdy or bcd_trdy;
	process (clk)
		type states is (s_init, s_run);
		variable state : states;
		variable shr  : unsigned(0 to bin'length-1);
		variable cntr : integer range -1 to bin'length/bin_digits-2;
	begin
		if rising_edge(clk) then
			if (to_bit(req) xor to_bit(rdy))='1' then
				case state is
				when s_init =>
					shr     := unsigned(bin);
					ser_frm <= '1';
					ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
					cntr    := bin'length/bin_digits-2;
					bcd_irdy <= '0';
					state   := s_run;
				when s_run =>
					if (bin_irdy and bcd_trdy)='1' then
						if ser_trdy='1' then
							if cntr < 0 then
								if ser_frm='0' then
									bcd_irdy <= '0';
									rdy   <= to_stdulogic(to_bit(req));
									state := s_init;
								else
									bcd_irdy <= '1';
								end if;
								ser_frm <= '0';
							else
								ser_frm <= '1';
								cntr := cntr - 1;
							end if;
						end if;

						if ser_frm='1' then
							if ser_trdy='1' and ser_irdy='1' then
								shr     := shift_left(shr, ser_bin'length);
								ser_bin <= std_logic_vector(shr(0 to ser_bin'length-1));
							end if;
						end if;

					end if;
				end case;
			else
				state := s_init;
			end if;

		end if;

	end process;

	dbdbblser_e : entity hdl4fpga.dbdbbl_ser
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		ini  => ini,
		frm  => ser_frm,
		irdy => ser_irdy,
		trdy => ser_trdy,
		bin  => ser_bin,
		bcd  => bcd);
end;
