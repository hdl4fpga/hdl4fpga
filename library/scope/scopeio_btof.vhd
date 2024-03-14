
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_btof is
	generic (
		max_decimal : natural := 3;
		min_decimal : integer := -4;
		tab      : std_logic_vector := to_ascii("0123456789 +-,."));
	port (
		clk      : in  std_logic;
		btof_req : in  std_logic;
		btof_rdy : out std_logic;
		dec      : in  std_logic_vector;
		neg      : in  std_logic;
		bin      : in  std_logic_vector;
		code_frm : out std_logic;
		code     : out std_logic_vector);
end;

architecture def of scopeio_btof is
	constant bcd_length  : natural := 4;
	constant bcd_width   : natural := 8;
	constant bcd_digits  : natural := 1;
	constant bin_digits  : natural := 3;

	signal   dbdbbl_req  : std_logic;
	signal   dbdbbl_rdy  : std_logic;

	signal   sll_frm     : std_logic;
	signal   sll_bcd     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal   slr_frm     : std_logic;
	signal   slr_irdy    : std_logic;
	signal   slr_trdy    : std_logic;
	signal   slr_bcd     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal   slr_ini     : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal   slrbcd_trdy : std_logic;
	signal   slrbcd      : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal   xxx      : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal   format_frm  : std_logic;
	signal   format_irdy : std_logic;
	signal   format_trdy : std_logic;
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
		bcd  => sll_bcd);

	lifo_b : block
		generic (
			max_decimal : natural := 2);
		generic map (
			max_decimal => max_decimal);
		port (
			clk      : in  std_logic;
			sll_frm  : in  std_logic;
			sll_bcd  : in  std_logic_vector;
			slr_frm  : buffer std_logic;
			slr_dec  : in std_logic_vector;
			slr_irdy : buffer std_logic;
			slr_trdy : in  std_logic;
			slr_bcd  : buffer std_logic_vector);
		port map (
			clk      => clk,
			sll_frm  => sll_frm,
			sll_bcd  => sll_bcd,
			slr_frm  => slr_frm,
			slr_dec  => dec,
			slr_irdy => slr_irdy,
			slr_trdy => slr_trdy,
			slr_bcd  => slr_bcd);

		signal lifo_ov   : std_logic;
		signal push_ena  : std_logic;
		signal push_data : std_logic_vector(sll_bcd'range);
		signal pop_ena   : std_logic;

	begin

		push_ena  <= sll_frm;
		push_data <= sll_bcd;
		lifo_e : entity hdl4fpga.lifo
		port map (
			clk       => clk,
			ov        => lifo_ov,
			push_ena  => push_ena,
			push_data => push_data,
			pop_ena   => pop_ena,
			pop_data  => slr_bcd);

		process (clk)
			type states is (s_push, s_pop);
			variable state : states;
			variable cntr : integer range -1 to max_decimal;
		begin
			if rising_edge(clk) then
				case state is
				when s_push =>
					if sll_frm='0' then
						if lifo_ov='0' then
							slr_frm  <= '1';
							slr_irdy <= '1';
							slr_ini  <= slr_bcd;
							pop_ena  <= '1';
						else
							slr_frm  <= '1';
							slr_irdy <= '1';
							slr_ini  <= x"e";
							pop_ena  <= '1';
							state := s_pop;
						end if;
					else
						slr_frm  <= '0';
						slr_irdy <= '0';
						pop_ena  <= '0';
						slr_ini  <= (others => '-');
						cntr := to_integer(unsigned(slr_dec));
					end if;
				when s_pop =>
					if sll_frm='1' then
						slr_frm  <= '0';
						slr_irdy <= '0';
						cntr     := to_integer(unsigned(slr_dec));
						pop_ena  <= '0';
						slr_ini  <= (others => '-');
						state    := s_push;
					else
						if lifo_ov='1' then
							if cntr > 0 then
								slr_frm  <= '1';
								slr_irdy <= '1';
								pop_ena  <= '1';
								cntr     := cntr - 1;
							else
								slr_frm  <= '0';
								slr_irdy <= '0';
								pop_ena  <= '0';
							end if;
							slr_ini <= x"0";
						else
							slr_frm  <= '1';
							slr_irdy <= '1';
							cntr     := to_integer(unsigned(slr_dec));
							pop_ena  <= '1';
							slr_ini <= slr_bcd;
						end if;
					end if;
				end case;
			end if;
		end process;
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
		cnt  => b"101",
		bcd_ini  => slr_ini,
		bcd  => slrbcd);

	process (clk)
		variable cntr : integer range -1 to max_decimal;
	begin
		if rising_edge(clk) then
			if slr_frm='1' then
				if cntr < 0 then
					format_frm  <= '1';
					format_irdy <= '1';
				else
					format_frm  <= '0';
					format_irdy <= '0';
					cntr := cntr - 1;
				end if;
			else
				format_frm <= '0';
				format_irdy <= '0';
				cntr := to_integer(unsigned(dec));
			end if;
			xxx <= slrbcd;
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
		bcd      => xxx,
		code_frm => code_frm,
		code     => code);
end;
