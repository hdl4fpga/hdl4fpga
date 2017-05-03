library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_axisy is
	generic (
		height     : natural;
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

architecture def of scopeio_axisy is

	function marker (
		constant step   : real;
		constant num    : natural)
		return std_logic_vector is
		type real_vector is array (natural range <>) of real;
		constant scales : real_vector(0 to 4-1) := (1.0, 2.0, 5.0,0.0);
		variable aux    : real;
		variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*(20+12)-1 downto 0) := (others => '-');
	begin
		for i in 0 to 4-1 loop
			for j in 0 to 4-1 loop
				aux := real((num-1)/2)*scales(j)*step*real(10**i);
				for k in 0 to 2**unsigned_num_bits(num-1)-1 loop
					retval := retval sll (20+12);
					if j < 3 then
						if i < 3 then
							retval((20+12)-1 downto 0) := unsigned(to_bcd(aux,20, true)) & (1 to 12 => '-');
							aux := aux - scales(j)*step*real(10**i);
						end if;
					end if;
				end loop;
			end loop;
		end loop;
		return std_logic_vector(retval);
	end;

	signal marks     : std_logic_vector(16*(20+12)-1 downto 0);
	signal pstn      : unsigned(win_y'length-1 downto 0); 
	signal char_code : std_logic_vector(4-1 downto 0);
	signal char_dot  : std_logic_vector(0 to 0);
	signal char_line : std_logic_vector(0 to 8-1);
begin

	process (video_clk)
		variable bsln : unsigned(pstn'range); 
		variable bias : unsigned(pstn'left downto 5); 
		variable refn : unsigned(pstn'range); 
	begin
		if rising_edge(video_clk) then
			marks     <= reverse(word2byte(reverse(marker(0.05001, 16)), axis_scale));
			char_code <= reverse(word2byte(reverse(marks), std_logic_vector(bias) & win_x(6-1 downto 3)));

			if refn(refn'left downto 2) > to_unsigned(height/8,refn'length-2) then
				bsln := to_unsigned(  8,bsln'length-2);
			elsif refn(refn'left downto 2) >= to_unsigned(height/8-1,refn'length-2) then
				bsln := to_unsigned(8/2,bsln'length-2);
			else
				bsln := (others => '0');
			end if;

			pstn <= refn + bsln;
			refn := unsigned(win_y) + unsigned'(B"0_0001_0011");
			bias := unsigned(pstn(pstn'left downto 5)) + unsigned'(B"0011");
		end if;
	end process;

	char_line <= reverse(word2byte(reverse(fonts), char_code & std_logic_vector(pstn(3-1 downto 0))));
	char_dot  <= word2byte(reverse(std_logic_vector(unsigned(char_line) ror 1)), win_x(3-1 downto 0));
	axis_dot  <= axis_on and char_dot(0) and setif(pstn(5-1 downto 3)=(1 to 2 => '0'));
end;
