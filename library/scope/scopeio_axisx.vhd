library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axisx is
	generic (
		fonts      : std_logic_vector);
	port (
		video_clk  : in  std_logic;
		win_on     : in  std_logic_vector;
		win_x      : in  std_logic_vector;
		win_y      : in  std_logic_vector;
		axis_on    : in  std_logic;
		axis_scale : in  std_logic_vector(4-1 downto 0);
		axis_dot   : out std_logic);
end;

architecture def of scopeio_axisx is

	constant font_width  : natural := 8;
	constant font_height : natural := 8;

	function marker (
		constant step   : real;
		constant num    : natural;
		constant sign   : boolean)
		return std_logic_vector is
		type real_vector is array (natural range <>) of real;
		constant scales : real_vector(0 to 3-1) := (1.0, 2.0, 5.0);
		variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*4*4-1 downto 0) := (others => '-');
		variable aux    : real;
		variable i, j   : natural;
	begin
		for l in 0 to 16-1 loop
			i := (l / 3) mod 3;
			j := l mod 3;
			for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
				retval := retval sll 16;
				if j < 3 then
					if i < 3 then
						if (k mod 8)=0 then
							aux := real((k/8)) * 5.0 * scales(j)*step*real(10**i);
						end if;
						retval(16-1 downto 0) := unsigned(to_bcd(aux,16, sign));
						aux := aux + scales(j)*step*real(10**i);
					end if;
				end if;
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	signal mark      : std_logic_vector(3-1 downto 0);
	signal axis_sgmt : std_logic_vector(1 downto 0);

	signal char_addr : std_logic_vector(0 to axis_scale'length+axis_sgmt'length+mark'length);
	signal char_code : std_logic_vector(2*4-1 downto 0);
	signal char_line : std_logic_vector(0 to 8-1);
	signal char_dot  : std_logic_vector(0 to 0);
	signal dot_on    : std_logic;
	signal dot_on1   : std_logic;
	signal dot_on2   : std_logic;

	signal sel_code  : std_logic_vector(0 to 0);
	signal sel_line  : std_logic_vector(0 to char_code'length/2+unsigned_num_bits(font_width-1)-1);
	signal sel_dot   : std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);

begin
	process (video_clk)
		variable edge : std_logic;
		variable sgmt : std_logic_vector(4-1 downto 0);
	begin
		if rising_edge(video_clk) then
			if axis_on='0' then
				sgmt := (others => '0');
				mark <= (others => '0');
			elsif (win_x(5) xor edge)='1' then
				if (sgmt(3) and sgmt(0))='1' then
					sgmt := (others => '0');
					mark <= std_logic_vector(unsigned(mark) + 1);
				else
					sgmt := std_logic_vector(unsigned(sgmt)  + 1);
				end if;
			end if;
			edge := win_x(5);
			dot_on1 <= setif(sgmt=(1 to 4 =>'0'));
		end if;
	end process;

	axis_sgmt <= (0 => win_on(1) or win_on(3), 1 => win_on(2) or win_on(3));
	char_addr <= axis_scale & axis_sgmt & mark & win_x(4);
	charrom : entity hdl4fpga.rom
	generic map (
		synchronous => 2,
		bitrom => marker(0.05001, 25, false))
	port map (
		clk  => video_clk,
		addr => char_addr,
		data => char_code);

	winx_e : entity hdl4fpga.align
	generic map (
		n => 6,
		d => (0 to 2 => 4,  3 => 2, 4 => 4, 5 => 3))
	port map (
		clk => video_clk,
		di(0)  => win_x(0),
		di(1)  => win_x(1),
		di(2)  => win_x(2),
		di(3)  => win_x(3),
		di(4)  => axis_on,
		di(5)  => dot_on1,
		do(0)  => sel_dot(0),
		do(1)  => sel_dot(1),
		do(2)  => sel_dot(2),
		do(3)  => sel_code(0),
		do(4)  => dot_on,
		do(5)  => dot_on2);

	sel_line <= word2byte(char_code, not sel_code) & win_y(3-1 downto 0);
	cgarom : entity hdl4fpga.rom
	generic map (
		synchronous => 2,
		bitrom => fonts)
	port map (
		clk  => video_clk,
		addr => sel_line,
		data => char_line);

	char_dot <= word2byte(char_line, not sel_dot);
	axis_dot <= dot_on and dot_on2 and char_dot(0);

end;
