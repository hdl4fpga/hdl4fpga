library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_tobcd is
	generic (
		fracbin_size : natural;
		fracbcd_size : natural;
		blank_code   : std_logic_vector := b"1000";
		dot_code     : std_logic_vector := b"1001";
		plus_code    : std_logic_vector := b"1010";
		minus_code   : std_logic_vector := b"1011");
	port (
		clk          : in  std_logic;
		fix          : in  std_logic_vector;
		mgntd        : in  std_logic_vector(0 to 2-1);
		mult         : in  std_logic_vector(0 to 2-1);
		bcd_str      : out std_logic_vector);
end;

architecture def of scopeio_tobcd is

	constant x1  : std_logic_vector := "00";    -- x 1.0
	constant x2  : std_logic_vector := "01";    -- x 2.0
	constant x2h : std_logic_vector := "10";    -- x 2.5 
	constant x5  : std_logic_vector := "11";    -- x 5.0

	constant m1  : std_logic_vector := "11";    -- x 10**(-1);
	constant p0  : std_logic_vector := "00";    -- x 10**0;
	constant p1  : std_logic_vector := "01";    -- x 10**1;
	constant p2  : std_logic_vector := "10";    -- x 10**2;

	constant intbcd_size : natural := integer(ceil(log(5.0*2.0**(fix'length-fracbin_size), 10.0)));

	signal bcd_do : std_logic_vector(0 to bcd_str'length-1);

	signal value : std_logic_vector(0 to fix'length-1+3);
	signal order : std_logic_vector(mgntd'range);
begin

	mult_p : process (clk)
		variable temp : unsigned(value'range);
	begin
		if rising_edge(clk) then
			case mgntd is
			when "00" =>
				temp := resize(unsigned(fix), temp'length);
			when "01" =>
				temp := resize(unsigned(fix), temp'length) sll 1;
			when "10" =>
				temp := resize(unsigned(fix), temp'length);
				temp := (temp sll 1) + (temp srl 1);
			when "11" =>
				temp := resize(unsigned(fix), temp'length);
				temp := (temp sll 2) + temp;
			when others =>
				temp := (others => '-');
			end case;
			value <= std_logic_vector(temp);
		end if;
	end process;

	ftod_e : entity hdl4fpga.ftod
	generic map (
		fracbin_size => fracbin_size,
		fracbcd_size => fracbcd_size)
	port map (
		clk  => clk,
		fix  => value,
		bcd  => bcd_do);

	latency_e : entity hdl4fpga.align
	generic map (
		n => mgntd'length,
		d => (mgntd'range => 3))
	port map (
		clk => clk,
		di  => mgntd,
		do  => order);
	
	process (clK)
		variable temp : unsigned(bcd_do'range);
	begin
		if rising_edge(clk) then
			case order is
			when m1 =>
				temp := unsigned(bcd_do) srl 4;
			when p0 =>
				temp := unsigned(bcd_do);
			when p1 =>
				temp := unsigned(bcd_do) sll 4;
			when p2 =>
				temp := unsigned(bcd_do) sll 8;
			when others =>
				temp := (others => '-');
			end case;

			-- Add dot or comma --
			----------------------

			temp(4*intbcd_size to temp'right) := temp(4*intbcd_size to temp'right) srl 4;
			temp(4*intbcd_size to 4*intbcd_size+4-1) := unsigned(dot_code);

			-- Replace left zeros by blanks --
			----------------------------------

			for i in 0 to intbcd_size-1 loop
				if temp(0 to 4-1)/="0000" then
					temp := temp ror (4*i);
					exit;
				end if;
				temp(0 to 4-1) := unsigned(blank_code);
				temp := temp rol 4;
			end loop;

			bcd_str <= std_logic_vector(temp);
		end if;
	end process;
end;
