library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio_meter is
	generic(
		inputs     : natural;
		ch_width   : natural;
		width      : natural;
		height     : natural);
	port (
		video_clk  : in  std_logic;
		video_nhl  : in  std_logic;
		abscisa    : out std_logic_vector;
		ordinates  : in  std_logic_vector;
		offset     : in  std_logic_vector;
		scale_x    : in  std_logic_vector(4-1 downto 0);
		scale_y    : in  std_logic_vector(4-1 downto 0);
		win_frm    : in  std_logic_vector;
		win_on     : in  std_logic_vector;
		video_dot  : out std_logic_vector);
end;

architecture def of scopeio_meter is
	constant font_width  : natural := 16;
	constant font_height : natural := 32;
	signal   code_dots   : std_logic_vector(0 to psf1mag32x16'length/(font_width*font_height)-1);
	signal   code_char   : std_logic_vector(0 to unsigned_num_bits(code_dots'length-1)-1);
	signal   code_dot    : std_logic_vector(0 to 0);
	signal   s           : std_logic_vector(0 to 8*4-1) := (others => '0');
	signal   bcd_sign    : std_logic_vector(0 to 4-1);
	signal   bcd_frac    : std_logic_vector(0 to 3*4-1);
	signal   bcd_int     : std_logic_vector(2*4-1 downto 0);
	signal   fix         : std_logic_vector(11-1 downto 0);

begin

	fix2bcd : entity hdl4fpga.fix2bcd 
	generic map (
		frac => 5,
		spce => false)
	port map (
		fix      => fix,
		bcd_sign => bcd_sign,
		bcd_frac => bcd_frac,
		bcd_int  => bcd_int);

entity is
	port (
		scale : in  std_logic_vector;
		value : in  std_logic_vector;
		xxxxx : out std_logic_vector);
end;

architecture def of is
begin
	signal fix : std_logic_vector(signed_num_bits(5*2**(value'length-1)-1 downto 0);
end;
	scale_p : process (scale, value)
		variable aux : signed(fix'range);
	begin
		aux := resize(signed(value), aux'length);
		for i in 0 to 2**scale'length-1 loop
			if i=to_integer(unsigned(scale)) then
				case i mod 3 is
				when 1 => 
					aux := aux sll 1;
				when 2 =>
					aux := (aux sll 2) + (aux sll 0);
				when others => 
				end case;
			end if;
		end loop;
		fix <= std_logic_vector(aux);
	end process;

	process (scale, value), bcd_int, bcd_frac, bcd_sign)
		variable auxi : unsigned(bcd_int'length+4*((9-1)/3)-1 downto 0);
		variable auxf : unsigned(0 to bcd_frac'length-1);
	begin

		s   <= (others => '-');
		for i in 0 to 2**scale'length-1 loop
			auxi := resize(unsigned(bcd_int), auxi'length);
			auxf := unsigned(bcd_frac);

			if ((i mod 9)/3) > 0 then
				for k in 0 to ((i mod 9)/3)-1 loop
					auxi := auxi sll 4;
					auxi(4-1 downto 0) := auxf(0 to 4-1);
					auxf := auxf sll 4;
				end loop;
			end if;

			for k in 1 to auxi'length/4-1 loop
				auxi := auxi rol 4;
				if auxi(4-1 downto 0)="0000" then
					auxi(4-1 downto 0) := "1111";
				else
					auxi := auxi rol (auxi'length-4*(k+1));
					exit;
				end if;
			end loop;
			auxi := auxi rol 4;

			if i=to_integer(unsigned(scale_y)) then

				s(0 to 32-1) <=
					bcd_sign &
					std_logic_vector(auxi(bcd_int'length+4*((i mod 9)/3)-1 downto 0)) & 
					"1010" & 
					std_logic_vector(auxf(0 to bcd_frac'length-4*((i mod 9)/3)-1)) &
					"1111";

			end if;
		end loop;
	end process;

end;
