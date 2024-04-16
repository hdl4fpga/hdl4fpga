
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity btof is
	generic (
		max_decimal : natural := 3;
		min_decimal : integer := -4;
		tab      : std_logic_vector := to_ascii("0123456789 +-,."));
	port (
		clk      : in  std_logic;
		btof_req : in  std_logic;
		btof_rdy : out std_logic;
		sht      : in  std_logic_vector := (0 to 0 => '0');
		dec      : in  std_logic_vector;
		exp      : in  std_logic_vector;
		neg      : in  std_logic;
		bin      : in  std_logic_vector;
		code_frm : buffer std_logic;
		code     : out std_logic_vector);
end;

architecture def of btof is
	constant bcd_length  : natural := 4;
	constant bcd_width   : natural := 8;
	constant bcd_digits  : natural := 1;
	constant bin_digits  : natural := 3;

	signal   dbdbbl_req  : std_logic;
	signal   dbdbbl_rdy  : std_logic;

	signal   sll_frm     : std_logic;
	signal   sll_trdy    : std_logic := '1';
	signal   sll_bcd     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal   slr_frm     : std_logic;
	signal   slr_irdy    : std_logic;
	signal   slr_trdy    : std_logic;
	signal   slr_ini     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal   slr_bcd     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal   format_frm  : std_logic;
	signal   format_irdy : std_logic;
	signal   format_trdy : std_logic;
	signal   format_bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

begin

	dbdbbl_req <= btof_req;
	dbdbbl_seq_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		req  => dbdbbl_req,
		rdy  => dbdbbl_rdy,
		bin  => bin,
		bcd_frm => sll_frm,
		bcd_trdy =>  sll_trdy,
		bcd  => sll_bcd);

	lifo_b : block
		generic (
			max_decimal : natural := 2);
		generic map (
			max_decimal => max_decimal);
		port (
			clk      : in  std_logic;
			sll_frm  : in  std_logic;
			sll_trdy : buffer std_logic;
			sll_bcd  : in  std_logic_vector;
			slr_frm  : buffer std_logic;
			slr_dec  : in std_logic_vector;
			slr_irdy : buffer std_logic;
			slr_trdy : in  std_logic;
			slr_ini  : out std_logic_vector);
		port map (
			clk      => clk,
			sll_frm  => sll_frm,
			sll_trdy => sll_trdy,
			sll_bcd  => sll_bcd,
			slr_frm  => slr_frm,
			slr_dec  => dec,
			slr_irdy => slr_irdy,
			slr_trdy => slr_trdy,
			slr_ini  => slr_ini);

		signal lifo_ov   : std_logic;
		-- alias  push_ena  is sll_frm; -- tools crashes
		-- alias  push_data is sll_bcd; -- tools crashes
		signal push_ena  : std_logic;
		signal push_data : std_logic_vector(sll_bcd'range);
		signal pop_ena   : std_logic;
		signal pop_data  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	begin

		process (clk)
			variable data : std_logic_vector(push_data'range);
			variable cntr : integer range -(1+max_decimal) to max_decimal;
		begin
			if rising_edge(clk) then
				if sll_frm='1' then
					if signed(sht) > cntr then
						sll_trdy  <= '0';
						push_ena  <= '0';
						push_data <= (others => '-');
						data      := (others => '-');
					elsif cntr=signed(dec) then
						sll_trdy  <= '0';
						push_ena  <= '1';
						push_data <= x"e";
						data      := sll_bcd;
					elsif cntr >= 0 then
						sll_trdy  <= '1';
						push_ena  <= '1';
						push_data <= data;
						data       := sll_bcd;
					elsif cntr < 0 then
						sll_trdy  <= '0';
						push_ena  <= sll_trdy;
						push_data <= x"0";
						data      := sll_bcd;
					end if;

					cntr := cntr + 1;
				else
					sll_trdy  <= '0';
					push_ena  <= '0';
					push_data <= (others => '-');
					data      := sll_bcd;
					if signed(sht) < 0 then
						cntr := to_integer(signed(sht));
					else 
						cntr := 0;
					end if;
				end if;
			end if;
		end process;

		lifo_e : entity hdl4fpga.lifo
		port map (
			clk       => clk,
			ov        => lifo_ov,
			push_ena  => push_ena,
			push_data => push_data,
			pop_ena   => pop_ena,
			pop_data  => pop_data);

	end block;

	dbdbblsrl_ser_e : entity hdl4fpga.dbdbblsrl_ser
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		frm  => slr_frm,
		irdy => slr_irdy,
		trdy => slr_trdy,
		cnt  => exp,
		bcd_ini => slr_ini,
		bcd  => slr_bcd);

	process (format_frm , clk)
		variable cntr : integer range -(1+max_decimal) to max_decimal;
	begin
		if rising_edge(clk) then
			if slr_frm='1' then
				if signed(dec) > 0 then
					if cntr < 0 then
						format_frm  <= '1';
						format_irdy <= '1';
					else
						format_frm  <= '0';
						format_irdy <= '0';
						cntr := cntr - 1;
					end if;
				elsif signed(dec) < 0 then
					if cntr >= 0 then
						format_frm  <= '1';
						format_irdy <= '1';
					else
						format_frm  <= '0';
						format_irdy <= '0';
						cntr := cntr + 1;
					end if;
				else
					format_frm  <= '1';
					format_irdy <= '1';
				end if;
			else
				format_frm  <= '0';
				format_irdy <= '0';
				cntr := to_integer(signed(dec));
			end if;
			format_bcd <= slr_bcd;
		end if;
	end process;

	format_e : entity hdl4fpga.format
	generic map (
		max_width => bcd_width)
	port map (
		tab      => tab,
		neg      => neg,
		clk      => clk,
		bcd_frm  => format_frm,
		bcd_irdy => format_irdy,
		bcd_trdy => format_trdy,
		bcd      => format_bcd,
		code_frm => code_frm,
		code     => code);
	
	process (code_frm, clk)
		type states is (s_dbdbbl, s_fmt);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_dbdbbl =>
				if (to_bit(dbdbbl_rdy) xor to_bit(dbdbbl_req))='0' then
					if code_frm='1' then
						state := s_fmt;
					end if;
				end if;
			when s_fmt =>
				if code_frm='0' then
					btof_rdy <= to_stdulogic(to_bit(btof_req));
					state := s_dbdbbl;
				end if;
			end case;
		end if;
	end process;
end;
