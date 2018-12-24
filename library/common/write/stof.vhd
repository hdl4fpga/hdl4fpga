use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity stof is
	generic (
		minus : std_logic_vector(4-1 downto 0) := x"d";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		zero  : std_logic_vector(4-1 downto 0) := x"0";
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk       : in  std_logic := '-';
		bcd_eddn  : in  std_logic;
		bcd_frm   : in  std_logic := '1';
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_di    : in  std_logic_vector;
		bcd_addr  : out std_logic_vector;
		fix_irdy  : out std_logic;
		fix_trdy  : in  std_logic := '1';
		fix_do    : out std_logic_vector);
end;
		
architecture def of stof is

	signal align_left  : std_logic_vector(fix_do'range);

	signal frm      : std_logic;
	signal fix_cntr : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal bcd_cntr : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal bcd_ptr  : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal fix_inc  : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal bcd_inc  : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal fmt_d    : unsigned(fix_do'length-1 downto 0);
	signal fmt_q    : unsigned(fix_do'length-1 downto 0);
	signal fix_ptr  : unsigned(bcd_addr'range);

begin

	frm_p : process (clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	fixptr_p : process (clk)
		variable cntr : unsigned(fix_cntr'range);
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				cntr := bcd_left;
			else
				cntr := cntr + 1;
			end if;
		end if;
		fix_ptr := cntr;
	end process;

	bcdptr_p : process (clk)
		variable cntr : unsigned(fix_cntr'range);
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				cntr := bcd_left;
			else
				cntr := cntr - 1;
			end if;
			bcd_ptr  <= cntr;
		end if;
	end process;

	fixcntr_p : process (clk)
		variable cntr : unsigned(fix_cntr'range);
	begin
		if rising_edge(clk) then
			cntr := fix_cntr+fix_inc;
			if cntr < fix_do'length/space'length then
				fix_cntr <= cntr;
				fix_irdy <= '0';
			else
				fix_cntr <= (others => '0');
				fix_irdy <= '1';
			end if;
			fmt_q <= fmt_d;
		end if;
	end process;

	bcdcntr_p : process (clk)
		variable cntr : unsigned(fix_cntr'range);
	begin
		if rising_edge(clk) then
			cntr := fix_cntr+fix_inc;
			if cntr < bcd_di'length/space'length then
				bcd_cntr <= cntr;
				bcd_trdy <= '0';
			else
				bcd_cntr <= (others => '0');
				bcd_trdy <= '1';
			end if;
		end if;
	end process;

	process (bcd_left, bcd_di, bcd_frm, fix_cntr, bcd_cntr)
		variable fmt     : unsigned(fix_do'length-1 downto 0);
		variable codes   : unsigned(bcd_di'length-1 downto 0);
		variable fix_cnt : unsigned(fix_cntr'range);
		variable bcd_cnt : unsigned(bcd_cntr'range);
		variable fix_pos : unsigned(fix_cntr'range);
		variable bcd_pos : unsigned(bcd_cntr'range);
		variable msg     : line;
	begin

		fix_cnt := (others => '0');
		bcd_cnt := (others => '0');

		if bcd_frm='0' then
			codes   := unsigned(bcd_di);
			fmt     := unsigned(fill(value => space, size => fmt'length));
			bcd_idx := bcd_left;
			fix_idx := bcd_left;
			bcd_pos := (others => '0');
			fix_pos := (others => '0');
		elsif frm='0' then
			codes   := unsigned(bcd_di);
			fmt     := unsigned(fill(value => space, size => fmt'length));
			bcd_idx := bcd_left;
			fix_idx := bcd_left;
			bcd_pos := (others => '0');
			fix_pos := (others => '0');
		else
			codes   := codes_d; --unsigned(bcd_di);
			fmt     := fix_d; --unsigned(fill(value => space, size => fmt'length));
			bcd_idx := bcd_ptr;
			fix_idx := fix_ptr;
			bcd_pos := bcd_cntr;
			fix_pos := fix_cntr;
		end if;

		fmt := unsigned(fill(value => space, size => fmt'length));
		for i in 0 to fmt'length/space'length-1 loop
			if signed(fix_idx) < 0 then
				if fix_cnt >= fix_pos then
					fmt := fmt rol space'length;
					fmt(space'range) := unsigned(zero);
					if i=0 then
						fmt := fmt rol space'length;
						fmt(space'range) := unsigned(dot);
						fix_cnt := fix_cnt + 1;
					end if;
					fix_cnt := fix_cnt + 1;
				end if;
			else
				if bcd_cnt+bcd_pos < bcd_di'length/space'length then
					codes := codes rol space'length;
				else
					exit;
				end if;
				if fix_cnt+fix_pos < fix_do'length/space'length then
					if signed(bcd_idx) = -1 then 
						fmt := fmt rol space'length;
						fmt(space'range) := unsigned(dot);
						fix_cnt := fix_cnt + 1;
					end if;
					fmt := fmt rol space'length;
					fmt(space'range) := unsigned(codes(space'range));
					fix_cnt := fix_cnt + 1;
					bcd_cnt := bcd_cnt + 1;
				else
					exit;
				end if;
			end if;
		end loop;

		fix_inc <= fix_cnt;
		bcd_inc <= bcd_cnt;
		fmt_d   <= std_logic_vector(fmt);
	end process;

	fix_do <= fmt_d;
	bcd_addr <=
		bcd_left when bcd_frm='0' else
		bcd_left when frm='0'     else
	   	bcd_ptr;

--	process (bcd_right, bcd_di)
--		variable fmt   : unsigned(fix_do'length-1 downto 0);
--		variable codes : unsigned(bcd_di'length-1 downto 0);
--	begin
--		if bcd_frm='0' then
--			fmt := unsigned(fill(value => space, size => fmt'length));
--			for i in 0 to fmt'length/space'length-1 loop
--				if signed(bcd_right) > i then
--					fmt(space'range) := unsigned(zero);
--				else
--					exit;
--				end if;
--				fmt := fmt srl space'length;
--			end loop;
--		end if;
--
--		codes := unsigned(bcd_di);
--		for i in 0 to codes'length/space'length-1 loop
--			fmt(space'range)   := unsigned(codes(space'range));
--			codes(space'range) := unsigned(space);
--			codes := codes ror space'length;
--			if signed(bcd_right)+i = -1 then
--				fmt := fmt ror space'length;
--				fmt(space'range) := unsigned(dot);
--			end if;
--			fmt := fmt srl space'length;
--		end loop;
--
--		align_right <= std_logic_vector(fmt);
--	end process;
	

end;
