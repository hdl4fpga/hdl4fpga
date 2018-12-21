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

	constant xxx : natural := hdl4fpga.std.min(bcd_di'length,fix_do'length)/space'length;
	signal eddn : std_logic;

	signal align_left  : std_logic_vector(fix_do'range);
	signal align_right : std_logic_vector(fix_do'range);
	signal ptr : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0) := (others => '0');
begin

	process (clk)
		variable cntr : unsigned(ptr'range);
	begin
		if rising_edge(clk) then
			if ptr >= fix_do'length/space'length-xxx then
				ptr      <= (others => '0');
				fix_irdy <= '1';
			else
				ptr      <= ptr + xxx;
				fix_irdy <= '0';
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;

	process (bcd_left, bcd_di, bcd_frm)
		variable fmt   : unsigned(fix_do'length-1 downto 0);
		variable codes : unsigned(0 to bcd_di'length-1);
		variable yyy   : unsigned(ptr'range);
	begin

		if bcd_frm='0' then
			fmt := unsigned(fill(value => space, size => fmt'length));
			for i in 0 to fmt'length/space'length-1 loop
				if i > yyy then
					if signed(bcd_left)+i < 0 then
						fmt(space'range) := unsigned(zero);
						if i=0 then
							fmt := fmt rol space'length;
							fmt(space'range) := unsigned(dot);
						end if;
						zzz := zzz + 1;
					else
						if signed(bcd_left)-i = -1 then 
							fmt(space'range) := unsigned(dot);
							fmt := fmt sll space'length;
						end if;
						fmt(space'range) := unsigned(codes(space'reverse_range));
						codes := codes sll space'length;
						fmt   := fmt   rol space'length;
					end if;
				else
					exit;
				end if;
			end loop;
		end if;

		codes := unsigned(bcd_di);
		align_left <= std_logic_vector(fmt);
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
	
	fix_do <= align_right when eddn='1' else align_left;

end;
