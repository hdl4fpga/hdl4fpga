library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axisx is
	generic (
		fonts        : std_logic_vector;
		num_of_seg   : natural;
		scales       : real_vector;
		mark_per_seg : natural := 5;
		div_per_seg  : natural := 1);
	port (
		video_clk    : in  std_logic;
		win_x        : in  std_logic_vector;
		win_y        : in  std_logic_vector;

		axis_hztl    : in  std_logic;
		axis_sgmt    : in  std_logic_vector;
		axis_on      : in  std_logic;
		axis_scale   : in  std_logic_vector(4-1 downto 0);
		axis_dot     : out std_logic);
end;

architecture def of scopeio_axisx is

	constant font_width   : natural := 8;
	constant font_height  : natural := 8;
	constant code_size    : natural := 4;
	constant num_of_digit : natural := 4;

	signal mark  : std_logic_vector(unsigned_num_bits(div_per_seg)-1 downto 0);

	function marker (
		constant num  : natural;
		constant sign : boolean)
		return std_logic_vector is
		type real_vector is array (natural range <>) of real;
		variable retval : unsigned(2**axis_scale'length*2**unsigned_num_bits(num-1)*num_of_digit*code_size-1 downto 0) := (others => '1');
		variable aux    : real;
	begin
		for l in 0 to 2**axis_scale'length-1 loop
			for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
				retval := retval sll (num_of_digit*code_size);
				if (k mod (2**mark'length))=0 then
					aux := real((k/(2**mark'length))*div_per_seg)*scales(l);
				end if;
				retval(num_of_digit*code_size-1 downto 0) := unsigned(to_bcd(aux, num_of_digit*code_size, sign));
				aux := aux + scales(l);
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	signal sgmt      : std_logic_vector(axis_sgmt'range);
	signal win_x4    : std_logic;

	signal char_addr : std_logic_vector(0 to axis_scale'length+sgmt'length+mark'length);
	signal char_code : std_logic_vector(2*code_size-1 downto 0);
	signal char_line : std_logic_vector(0 to font_width-1);
	signal char_dot  : std_logic_vector(0 to 1-1);
	signal mark_on   : std_logic;
	signal dot_on    : std_logic;

	signal sel_code  : std_logic_vector(0 to 0);
	signal sel_line  : std_logic_vector(0 to char_code'length/2+unsigned_num_bits(font_width-1)-1);
	signal sel_dot   : std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);
	signal sel_winy  : std_logic_vector(3-1 downto 0);

	signal mark_y    : std_logic;
	signal aon_y     : std_logic;

begin
	mark_y <= setif(win_y(5-1 downto 3)=(5-1 downto 3 => '0'));
	alignrow_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => 4))
	port map (
		clk => video_clk,
		di(0) => mark_y,
		do(0) => aon_y);

	process (video_clk)
		variable sgmt_x : unsigned(unsigned_num_bits(mark_per_seg-1)-1 downto 0);
		variable next_x : std_logic;
		variable aon    : std_logic;

	begin
		if rising_edge(video_clk) then
			mark_on <= setif(sgmt_x=(sgmt_x'range => '0')) and aon;
			if axis_hztl='1' then 
				if axis_on='0' then
					sgmt_x := (others => '0');
					mark   <= (others => '0');
				elsif next_x='1' then
					if to_integer(sgmt_x)=mark_per_seg-1 then
						sgmt_x := (others => '0');
						mark   <= std_logic_vector(unsigned(mark) + 1);
					else
						sgmt_x := sgmt_x + 1;
					end if;
				end if;
			else
				mark <= win_y(5+mark'length-1 downto 5);
			end if;
			aon  := axis_on and aon_y;
			next_x := setif(win_x(5-1 downto 0)=(1 to 5 => '1'));
		end if;
	end process;

	char_addr <= axis_scale & sgmt & mark & win_x4;
	charrom : entity hdl4fpga.rom
	generic map (
		synchronous => 2,
		bitrom => marker(num_of_seg*div_per_seg+1, false))
	port map (
		clk  => video_clk,
		addr => char_addr,
		data => char_code);

	sgmt_e : entity hdl4fpga.align
	generic map (
		n => axis_sgmt'length,
		d => (1 to axis_sgmt'length => 3))
	port map (
		clk => video_clk,
		di  => axis_sgmt,
		do  => sgmt);

	winx_e : entity hdl4fpga.align
	generic map (
		n => 6,
		d => (0 to 2 => 6,  3 => 4, 4 => 2, 5 => 4))
	port map (
		clk => video_clk,
		di(0)  => win_x(0),
		di(1)  => win_x(1),
		di(2)  => win_x(2),
		di(3)  => win_x(3),
		di(4)  => win_x(4),
		di(5)  => mark_on,
		do(0)  => sel_dot(0),
		do(1)  => sel_dot(1),
		do(2)  => sel_dot(2),
		do(3)  => sel_code(0),
		do(4)  => win_x4,
		do(5)  => dot_on);

	winy_e : entity hdl4fpga.align
	generic map (
		n => 3,
		d => (0 to 2 => 6))
	port map (
		clk => video_clk,
		di  => win_y(3-1 downto 0),
		do  => sel_winy);

	sel_line <= word2byte(char_code, not sel_code) & sel_winy;
	cgarom : entity hdl4fpga.rom
	generic map (
		synchronous => 2,
		bitrom => fonts)
	port map (
		clk  => video_clk,
		addr => sel_line,
		data => char_line);

	char_dot <= word2byte(char_line, not sel_dot);
	axis_dot <= dot_on and char_dot(0);

end;
