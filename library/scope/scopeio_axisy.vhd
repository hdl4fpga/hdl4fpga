use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axisy is
	generic (
		fonts       : std_logic_vector;
		input_bias  : real    := 0.0;
		scale_start : natural := 0);
	port (
		video_clk   : in  std_logic;
		win_x       : in  std_logic_vector;
		win_y       : in  std_logic_vector;
		axis_on     : in  std_logic;
		axis_scale  : in  std_logic_vector(4-1 downto 0);
		axis_dot    : out std_logic);
end;

architecture def of scopeio_axisy is

	constant font_width  : natural := 8;
	constant font_height : natural := 8;

	function marker (
		constant step   : real;
		constant num    : natural;
		constant bias   : real;
		constant start  : natural)
		return std_logic_vector is
		type real_vector is array (natural range <>) of real;
		constant scales : real_vector(0 to 3-1) := (1.0, 2.0, 5.0);
		variable aux    : real;
		variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*(20+12)-1 downto 0) := (others => '0');
		variable i, j   : natural;
		variable a : real;
	begin
		for l in 0 to 16-1 loop
			i := (((l+start) / 3)) mod 3;
			j := (l+start) mod 3;
			a := 10.0**(i);
			aux := real((num-1)/2)*scales(j)*step*a; --bias/real(10**(3*((l+start) / 9)));
			for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
				retval := retval sll (20+12);
				retval((20+12)-1 downto 0) := unsigned(to_bcd(aux,20, true)) & (1 to 12 => '0');
				aux := aux - scales(j)*step*a;
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	signal pstn      : std_logic_vector(win_y'length-1 downto 0); 
	signal offset    : std_logic_vector(pstn'left downto 5); 

	signal char_addr : std_logic_vector(0 to axis_scale'length+offset'length+2-1);
	signal char_code : std_logic_vector(2*4-1 downto 0);
	signal char_line : std_logic_vector(0 to 8-1);
	signal char_dot  : std_logic_vector(0 to 0);
	signal mark_on   : std_logic;
	signal dot_on    : std_logic;

	signal sel_code  : std_logic_vector(0 to 0);
	signal sel_line  : std_logic_vector(0 to char_code'length/2+unsigned_num_bits(font_width-1)-1);
	signal sel_dot   : std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);

begin

	process (video_clk)
		variable bsln : unsigned(pstn'range); 
		variable refn : unsigned(pstn'range); 
		variable aon  : std_logic;
	begin
		if rising_edge(video_clk) then

			if    to_integer(refn(refn'left downto 4)) > 24 then
				bsln := (others => '0');
			elsif to_integer(refn(refn'left downto 4)) > 8 then
				bsln := to_unsigned(  8,bsln'length);
			elsif to_integer(refn(refn'left downto 4)) < 8-1 then
				bsln := (others => '0');
			else
				bsln := to_unsigned(8/2,bsln'length);
			end if;

			pstn    <= std_logic_vector(refn + bsln);
			refn    := unsigned(win_y);
			offset  <= std_logic_vector(unsigned(pstn(pstn'left downto 5)) + unsigned'(B"0011"));
			aon     := axis_on;
			mark_on <= setif(pstn(5-1 downto 3)=(1 to 2 => '0')) and aon;
		end if;
	end process;

	char_addr <= axis_scale & offset & win_x(6-1 downto 4);
	charrom : entity hdl4fpga.rom
	generic map (
		synchronous => 2,
		bitrom => marker(1.0001, 16, input_bias, 3))
	port map (
		clk  => video_clk,
		addr => char_addr,
		data => char_code);

	winx_e : entity hdl4fpga.align
	generic map (
		n => 5,
		d => (0 to 2 => 4,  3 => 2, 4 => 3))
	port map (
		clk => video_clk,
		di(0)  => win_x(0),
		di(1)  => win_x(1),
		di(2)  => win_x(2),
		di(3)  => win_x(3),
		di(4)  => mark_on,
		do(0)  => sel_dot(0),
		do(1)  => sel_dot(1),
		do(2)  => sel_dot(2),
		do(3)  => sel_code(0),
		do(4)  => dot_on);

	sel_line <= word2byte(char_code, not sel_code) & pstn(3-1 downto 0);
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
