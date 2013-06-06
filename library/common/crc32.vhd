library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc is
    port (
        clk : in std_logic;
		g  : in std_logic_vector(31 downto 0);
		x0 : in std_logic_vector(31 downto 0) := (others => '0');
		pl : in std_logic := '0';
		so : in std_logic := '0';
		xi : in std_logic_vector(3 downto 0);
		xo : out std_logic_vector(3 downto 0);
		xp : buffer std_logic_vector(31 downto 0));
end;

architecture mix of crc is
	function next_crc32w4 (
		data: std_logic_vector(3 downto 0);
		crc:  std_logic_vector(31 downto 0))
		return std_logic_vector is

		variable d:      std_logic_vector(data'range);
		variable c:      std_logic_vector(crc'range);
		variable newcrc: std_logic_vector(crc'range);

	begin
		d := Data;
		c := crc;

		newcrc(0) := d(0) xor c(28);
		newcrc(1) := d(1) xor d(0) xor c(28) xor c(29);
		newcrc(2) := d(2) xor d(1) xor d(0) xor c(28) xor c(29) xor c(30);
		newcrc(3) := d(3) xor d(2) xor d(1) xor c(29) xor c(30) xor c(31);
		newcrc(4) := d(3) xor d(2) xor d(0) xor c(0) xor c(28) xor c(30) xor c(31);
		newcrc(5) := d(3) xor d(1) xor d(0) xor c(1) xor c(28) xor c(29) xor c(31);
		newcrc(6) := d(2) xor d(1) xor c(2) xor c(29) xor c(30);
		newcrc(7) := d(3) xor d(2) xor d(0) xor c(3) xor c(28) xor c(30) xor c(31);
		newcrc(8) := d(3) xor d(1) xor d(0) xor c(4) xor c(28) xor c(29) xor c(31);
		newcrc(9) := d(2) xor d(1) xor c(5) xor c(29) xor c(30);
		newcrc(10) := d(3) xor d(2) xor d(0) xor c(6) xor c(28) xor c(30) xor c(31);
		newcrc(11) := d(3) xor d(1) xor d(0) xor c(7) xor c(28) xor c(29) xor c(31);
		newcrc(12) := d(2) xor d(1) xor d(0) xor c(8) xor c(28) xor c(29) xor c(30);
		newcrc(13) := d(3) xor d(2) xor d(1) xor c(9) xor c(29) xor c(30) xor c(31);
		newcrc(14) := d(3) xor d(2) xor c(10) xor c(30) xor c(31);
		newcrc(15) := d(3) xor c(11) xor c(31);
		newcrc(16) := d(0) xor c(12) xor c(28);
		newcrc(17) := d(1) xor c(13) xor c(29);
		newcrc(18) := d(2) xor c(14) xor c(30);
		newcrc(19) := d(3) xor c(15) xor c(31);
		newcrc(20) := c(16);
		newcrc(21) := c(17);
		newcrc(22) := d(0) xor c(18) xor c(28);
		newcrc(23) := d(1) xor d(0) xor c(19) xor c(28) xor c(29);
		newcrc(24) := d(2) xor d(1) xor c(20) xor c(29) xor c(30);
		newcrc(25) := d(3) xor d(2) xor c(21) xor c(30) xor c(31);
		newcrc(26) := d(3) xor d(0) xor c(22) xor c(28) xor c(31);
		newcrc(27) := d(1) xor c(23) xor c(29);
		newcrc(28) := d(2) xor c(24) xor c(30);
		newcrc(29) := d(3) xor c(25) xor c(31);
		newcrc(30) := c(26);
		newcrc(31) := c(27);
		return newcrc;
	end;
begin
	xo <= xp(31 downto 28);
	process (clk)
	begin
		if rising_edge(clk) then
			if pl='1' then
				xp <= x0;
			elsif so='0' then
				xp <= next_crc32w4(xi, xp);
			else
				xp <= xp(27 downto 0) & (1 to 4 => '1');
			end if;
		end if;
	end process;
end;

