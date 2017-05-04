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

	function marker (
		constant step   : real;
		constant num    : natural;
		constant sign   : boolean)
		return std_logic_vector is
		type real_vector is array (natural range <>) of real;
		constant scales : real_vector(0 to 3-1) := (1.0, 2.0, 5.0);
		variable retval : unsigned(4*4*2**unsigned_num_bits(num-1)*4*4-1 downto 0) := (others => '-');
		variable aux    : real;
	begin
		for i in 0 to 4-1 loop
			for j in 0 to 4-1 loop
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
		end loop;
		return std_logic_vector(retval);
	end;

	signal marks     : std_logic_vector(128-1 downto 0);
	signal mark      : std_logic_vector(3-1 downto 0);
	signal sgmt      : std_logic_vector(4-1 downto 0);

	signal char_digt : std_logic_vector(5-1 downto 0);
	signal char_code : std_logic_vector(4-1 downto 0);
	signal char_line : std_logic_vector(0 to 8-1);
	signal dot       : std_logic_vector(0 to 0);
begin
	process (video_clk)
		variable edge : std_logic;
	begin
		if rising_edge(video_clk) then
			if axis_on='0' then
				sgmt <= (others => '0');
				mark <= (others => '0');
			elsif (win_x(5) xor edge)='1' then
				if (sgmt(3) and sgmt(0))='1' then
					sgmt <= (others => '0');
					mark <= std_logic_vector(unsigned(mark) + 1);
				else
					sgmt <= std_logic_vector(unsigned(sgmt)  + 1);
				end if;
			end if;
			edge := win_x(5);
		end if;
	end process;

	process (video_clk)
		variable sel  : std_logic_vector(1 downto 0);
	begin
		if rising_edge(video_clk) then
			sel(0) := win_on(1) or win_on(3);
			sel(1) := win_on(2) or win_on(3);
			marks  <= reverse(word2byte(reverse(marker(0.05001, 25, false)), axis_scale & sel));

			char_code <= reverse(word2byte(reverse(marks), mark & char_digt(4 downto 3)));
			char_digt <= win_x(char_digt'range);
		end if;
	end process;

	char_line <= reverse(word2byte(reverse(fonts), char_code & win_y(3-1 downto 0)));
	dot       <= word2byte(reverse(std_logic_vector(unsigned(char_line) ror 1)), char_digt(2 downto 0));
	axis_dot  <= dot(0) and axis_on and setif(sgmt=(1 to 4 =>'0'));

end;
