
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity btof is
	generic (
		max_decimal : natural := 15;
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
		bcd_trdy => sll_trdy,
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
			variable cntr : integer range -(1+max_decimal) to max_decimal;
			variable data : std_logic_vector(push_data'range);
			variable dv   : std_logic;
		begin
			if rising_edge(clk) then
				if sll_frm='1' then
					if cntr < signed(sht) then
						push_ena  <= '0';
						push_data <= (others => '-');
						if sll_trdy= '1' then
							cntr := cntr + 1;
						end if;
						dv       := '0';
						sll_trdy <= '1';
					elsif cntr < 0 then
						push_ena <= '1';
						if cntr=signed(dec) then
							if signed(sht)/=signed(dec) then
								if push_data=x"e" then
									push_data <= x"0";
									cntr := cntr + 1;
								else
									push_data <= x"e";
								end if;
							else
								push_data <= x"0";
								cntr := cntr + 1;
							end if;
						else
							push_data <= x"0";
							cntr := cntr + 1;
						end if;
						dv       := '0';
						sll_trdy <= '0';
					else
						if dv='1' then
							push_ena  <= '1';
							push_data <= data;
							cntr      := cntr + 1;
							dv        := '0';
							sll_trdy  <= '1';
						elsif cntr=signed(dec) then
							if signed(sht)/=signed(dec) then
								push_ena  <= '1';
								push_data <= x"e";
								cntr      := cntr + 1;
								dv        := sll_trdy;
								sll_trdy  <= '0';
							else
								-- push_ena  <= '0';
								-- push_data <= (others => '-');
								push_ena  <= sll_trdy;
								push_data <= sll_bcd;
								cntr      := cntr + 1;
								dv        := '0';
								sll_trdy  <= '0';
							end if;
						elsif sll_trdy='1' then
							push_ena  <= '1';
							push_data <= sll_bcd;
							cntr      := cntr + 1;
							dv        := '0';
							sll_trdy  <= '1';
						else
							push_ena  <= '0';
							push_data <= (others => '-');
							dv        := '0';
							sll_trdy  <= '1';
						end if;
					end if;
					data := sll_bcd;
				else
					if signed(dec) > signed(sht) then
						-- report ">>>>>> SUMO + 1 <<<<<<<<";
					end if;
					dv        := '0';
					sll_trdy  <= '0';
					push_ena  <= '0';
					push_data <= (others => '-');
					if signed(sht) < 0 then
						cntr := to_integer(signed(sht));
					else 
						cntr := 0;
					end if;
				end if;
				data := sll_bcd;
			end if;
		end process;

		process (sll_frm)
		begin
			if rising_edge(sll_frm) then
				report natural'image(bcd_width-to_integer(signed(sht)));
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

		process (clk)
		begin
			if rising_edge(clk) then
				if (sll_frm or sll_trdy)='1' then
					slr_frm  <= '0';
					slr_irdy <= '0';
					slr_ini  <= (slr_ini'range => '-');
					pop_ena  <= '0';
				elsif lifo_ov='1' then
					slr_frm  <= '0';
					slr_irdy <= '0';
					slr_ini  <= (slr_ini'range => '-');
					pop_ena  <= '0';
				else
					slr_frm  <= pop_ena;
					slr_irdy <= pop_ena;
					slr_ini  <= pop_data;
					pop_ena  <= '1';
				end if;
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
		-- trdy => slr_trdy,
		cnt  => exp,
		bcd_ini => slr_ini,
		bcd  => slr_bcd);

	align_b : block
		generic (
			max_width : natural);
		generic map (
			max_width => bcd_width);
		port (
			tab       : in  std_logic_vector; -- := x"0123456789abcde";
			clk       : in  std_logic;
			neg       : in  std_logic := '0';
			sign      : in  std_logic := '0';
			bcd_frm   : in  std_logic;
			bcd_irdy  : in  std_logic := '1';
			bcd_trdy  : out std_logic := '1';
			bcd       : in  std_logic_vector(0 to 4-1);
			code_frm  : buffer std_logic;
			code_irdy : buffer std_logic;
			code_trdy : in  std_logic := '1';
			code      : out std_logic_vector);
		port map (
			tab      => tab,
			neg      => neg,
			clk      => clk,
			bcd_frm  => slr_frm,
			bcd_irdy => slr_irdy,
			bcd_trdy => slr_trdy,
			bcd      => slr_bcd,
			code_frm => code_frm,
			code     => code);
	
		constant bcd_digits : natural := 1;
		constant bcd_tab    : std_logic_vector := x"0123456789abcdef";

		constant zero       : std_logic_vector(0 to bcd'length-1) := x"0";
		constant blank      : std_logic_vector(0 to bcd'length-1) := x"a";
		constant plus       : std_logic_vector(0 to bcd'length-1) := x"b";
		constant minus      : std_logic_vector(0 to bcd'length-1) := x"c";
		constant comma      : std_logic_vector(0 to bcd'length-1) := x"d";
		constant dot        : std_logic_vector(0 to bcd'length-1) := x"e";

		type xxx is array (0 to 3-1) of std_logic_vector(bcd'range);
		signal fmt_bcd : xxx;
		signal fmt_ena : std_logic_vector(xxx'range);

	begin

		process (clk)
			type states is (s_init, s_blank, s_blanked);
			variable state : states;
		begin
			if rising_edge(clk) then
				fmt_ena(0) <= fmt_ena(1);
				fmt_bcd(0) <= fmt_bcd(1);
				if bcd_frm='1' then
					case state is
					when s_init =>
						if bcd=x"0" then
							fmt_ena(1) <= '0';
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab, blank, bcd'length);
							state := s_blank;
						elsif neg='1' then
							fmt_ena(1) <= '0';
							fmt_bcd(1) <= multiplex(bcd_tab, minus, bcd'length);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab,   bcd,   bcd'length);
							state := s_blanked;
						elsif sign='1' then
							fmt_ena(1) <= '1';
							fmt_bcd(1) <= multiplex(bcd_tab, plus, bcd'length);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab, bcd,  bcd'length);
							state := s_blanked;
						else
							fmt_ena(1) <= '0';
							fmt_bcd(1) <= multiplex(bcd_tab, bcd, bcd'length);
							fmt_ena(2) <= '0';
							fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
							state := s_blanked;
						end if;
					when s_blank =>
						if bcd=x"0" then
							fmt_ena(1) <= fmt_ena(2);
							fmt_bcd(1) <= fmt_bcd(2);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab, blank, bcd'length);
						elsif neg='1' then
							fmt_ena(1) <= '1';
							fmt_bcd(1) <= multiplex(bcd_tab, minus, bcd'length);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab,   bcd, bcd'length);
							state := s_blanked;
						elsif sign='1' then
							fmt_ena(1) <= '1';
							fmt_bcd(1) <= multiplex(bcd_tab, plus, bcd'length);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab,  bcd, bcd'length);
							state := s_blanked;
						elsif bcd=x"e" then 
							fmt_ena(1) <= '1';
							fmt_bcd(1) <= multiplex(bcd_tab, x"0", bcd'length);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
							state := s_blanked;
						else 
							fmt_ena(1) <= fmt_ena(2);
							fmt_bcd(1) <= fmt_bcd(2);
							fmt_ena(2) <= '1';
							fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
							state := s_blanked;
						end if;
					when s_blanked =>
						fmt_ena(1) <= fmt_ena(2);
						fmt_bcd(1) <= fmt_bcd(2);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
					end case;
				else
					fmt_ena(1) <= fmt_ena(2);
					fmt_bcd(1) <= fmt_bcd(2);
					fmt_ena(2) <= '0';
					fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
					state := s_init;
				end if;
			end if;
		end process;
		bcd_trdy <= bcd_frm;
		code_frm <= '0' when fmt_bcd(0)=x"a" else fmt_ena(0);
		code     <= multiplex(tab, fmt_bcd(0), code'length);
	end block;

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
