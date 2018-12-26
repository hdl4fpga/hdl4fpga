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
		bcd_eddn  : in  std_logic := '0';
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
	signal bcd_ptr  : unsigned(bcd_left'range);
	signal fix_inc  : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal bcd_inc  : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal codes_d  : unsigned(bcd_di'length-1 downto 0);
	signal codes_q  : unsigned(bcd_di'length-1 downto 0);
	signal fmt_d    : unsigned(fix_do'length-1 downto 0);
	signal fmt_q    : unsigned(fix_do'length-1 downto 0);
	signal fix_ptr  : unsigned(bcd_left'range);

begin

	frm_p : process (clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	fixptr_p : process (clk)
		variable cntr : unsigned(fix_ptr'range);
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				cntr := unsigned(bcd_left);
			else
				cntr := cntr + 1;
			end if;
		end if;
		fix_ptr <= cntr;
	end process;

	bcdptr_p : process (clk)
		variable cntr : unsigned(bcd_ptr'range);
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				cntr := unsigned(bcd_left);
			else
				cntr := cntr - 1;
			end if;
			bcd_ptr <= cntr;
		end if;
	end process;

	fixcntr_p : process (bcd_frm, clk)
		variable cntr : unsigned(fix_cntr'range);
	begin
		if bcd_frm='0' then
			fmt_q    <= unsigned(fill(value => space, size => fmt_q'length));
			fix_cntr <= (others => '0');
		elsif rising_edge(clk) then
			cntr := fix_cntr+fix_inc;
			if cntr < fix_do'length/space'length then
				fmt_q    <= fmt_d;
				fix_cntr <= cntr;
			else
				fmt_q    <= unsigned(fill(value => space, size => fmt_d'length));
				fix_cntr <= (others => '0');
			end if;
		end if;
	end process;

	bcdcntr_p : process (bcd_frm, clk)
		variable cntr : unsigned(bcd_cntr'range);
	begin
		if bcd_frm='0' then
			codes_q  <= unsigned(bcd_di);
			bcd_cntr <= (others => '0');
		elsif rising_edge(clk) then
			cntr := bcd_cntr+bcd_inc;
			if cntr < bcd_di'length/space'length then
				codes_q  <= codes_d;
				bcd_cntr <= cntr;
			else
				codes_q  <= unsigned(bcd_di);
				bcd_cntr <= (others => '0');
			end if;
		end if;
	end process;

	fixfmt_p : process (bcd_left, bcd_di, bcd_frm, fix_cntr, bcd_cntr, codes_q, fmt_q)
		variable fmt     : unsigned(fix_do'length-1 downto 0);
		variable codes   : unsigned(bcd_di'length-1 downto 0);
		variable fix_cnt : unsigned(fix_cntr'range);
		variable bcd_cnt : unsigned(bcd_cntr'range);
		variable fix_pos : unsigned(fix_cntr'range);
		variable bcd_pos : unsigned(bcd_cntr'range);
		variable bcd_idx : unsigned(bcd_left'range);
		variable fix_idx : unsigned(bcd_left'range);
		variable msg     : line;
	begin

		if bcd_frm='0' then
			codes   := unsigned(bcd_di);
			fmt     := unsigned(fill(value => space, size => fmt'length));
			bcd_idx := unsigned(bcd_left);
			fix_idx := unsigned(bcd_left);
			bcd_pos := (others => '0');
			fix_pos := (others => '0');
		elsif frm='0' then
			codes   := unsigned(bcd_di);
			fmt     := unsigned(fill(value => space, size => fmt'length));
			bcd_idx := unsigned(bcd_left);
			fix_idx := unsigned(bcd_left);
			bcd_pos := (others => '0');
			fix_pos := (others => '0');
		else
			codes   := codes_q;
			fmt     := fmt_q;
			bcd_idx := bcd_ptr;
			fix_idx := fix_ptr;
			bcd_pos := bcd_cntr;
			fix_pos := fix_cntr;
		end if;

		bcd_cnt := (others => '0');
		fix_cnt := (others => '0');
		fmt := unsigned(fill(value => space, size => fmt'length));
		for i in 0 to fmt'length/space'length-1 loop
			if signed(fix_idx)+i > 0 or fix_idx=(fix_idx'range => '0') then
				if fix_pos+i < fix_do'length/space'length then
					if bcd_cnt+bcd_pos >= bcd_di'length/space'length then
						exit;
					end if;

					fmt := fmt rol space'length;
					if signed(bcd_idx)-i = -1 then 
						fmt(space'range) := unsigned(dot);
					else
						codes := codes rol space'length;
						fmt(space'range) := unsigned(codes(space'range));
						bcd_cnt := bcd_cnt + 1;
					end if;
				else
					exit;
				end if;
			else
				fmt := fmt rol space'length;
				if i=1 then
					fmt(space'range) := unsigned(dot);
				elsif i >= fix_pos then
					fmt(space'range) := unsigned(zero);
				end if;
			end if;
			fix_cnt := fix_cnt + 1;
		end loop;

		codes_d <= codes;
		fix_inc <= fix_cnt;
		bcd_inc <= bcd_cnt;
		fmt_d   <= fmt;
	end process;

	fix_do <= std_logic_vector(fmt_d);
	fix_irdy <= setif(fix_cntr+fix_inc >= fix_do'length/space'length);
	bcd_trdy <= setif(bcd_cntr+bcd_inc >= bcd_di'length/space'length);
	bcd_addr <=
		bcd_left when bcd_frm='0' else
		bcd_left when frm='0'     else
	   	std_logic_vector(bcd_ptr);

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
