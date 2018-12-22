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
		fix_irdy  : out  std_logic;
		fix_trdy  : in  std_logic := '1';
		fix_do    : out std_logic_vector);
end;
		
architecture def of stof is

	signal align_left  : std_logic_vector(fix_do'range);

	signal fix_ptr : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal bcd_ptr : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal fix_inc : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal bcd_inc : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);

begin

	fixptr_p : process (clk)
		variable ptr : unsigned(fix_ptr'range);
	begin
		if rising_edge(clk) then
			ptr := fix_ptr+fix_inc;
			if ptr < fix_do'length/space'length then
				fix_ptr  <= ptr;
				fix_irdy <= '0';
			else
				fix_ptr  <= (others => '0');
				fix_irdy <= '1';
			end if;
		end if;
	end process;

	bcdptr_p : process (clk)
		variable ptr : unsigned(fix_ptr'range);
	begin
		if rising_edge(clk) then
			ptr := fix_ptr+fix_inc;
			if ptr < bcd_di'length/space'length then
				bcd_ptr  <= ptr;
				bcd_trdy <= '0';
			else
				bcd_ptr  <= (others => '0');
				bcd_trdy <= '1';
			end if;
		end if;
	end process;

	process (bcd_left, bcd_di, bcd_frm)
		variable fmt     : unsigned(fix_do'length-1 downto 0);
		variable codes   : unsigned(0 to bcd_di'length-1);
		variable fix_cnt : unsigned(fix_ptr'range);
		variable bcd_cnt : unsigned(bcd_ptr'range);
		variable fix_pos : unsigned(fix_ptr'range);
		variable bcd_pos : unsigned(bcd_ptr'range);
		variable msg     : line;
	begin

		fix_cnt := (others => '0');
		bcd_cnt := (others => '0');

		if bcd_frm='0' then
			fix_pos := (others => '0');
			bcd_pos := (others => '0');
			fmt     := unsigned(fill(value => space, size => fmt'length));
			codes   := unsigned(bcd_di);
		else
			fix_pos := fix_ptr;
			bcd_pos := bcd_ptr;
			fmt     := unsigned(fill(value => space, size => fmt'length));
			codes   := unsigned(bcd_di);
		end if;

		fmt := unsigned(fill(value => space, size => fmt'length));
		for i in 0 to fmt'length/space'length-1 loop
					write (msg, i);
					writeline (output, msg);
			if signed(bcd_left)+i < 0 then
				if i >= fix_pos then
					fmt(space'range) := unsigned(zero);
					if i=0 then
						fmt := fmt rol space'length;
						fmt(space'range) := unsigned(dot);
						fix_cnt := fix_cnt + 1;
					end if;
					fix_cnt := fix_cnt + 1;
					write (msg, string'("pase por aca"));
					writeline (output, msg);
				end if;
			else
				if i > fix_pos then
					if signed(bcd_left)-i = -1 then 
						fmt := fmt rol space'length;
						fmt(space'range) := unsigned(dot);
						fix_cnt := fix_cnt + 1;
					end if;
					fmt := fmt rol space'length;
					fmt(space'range) := unsigned(codes(space'reverse_range));
					bcd_cnt := bcd_cnt + 1;
					fix_cnt := fix_cnt + 1;
				end if;
				if i+bcd_pos < bcd_di'length/space'length then
					codes   := codes sll space'length;
				else
					exit;
				end if;
			end if;
		end loop;

		fix_inc <= fix_cnt;
		bcd_inc <= bcd_cnt;
		fix_do  <= std_logic_vector(fmt);
	end process;
	
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
