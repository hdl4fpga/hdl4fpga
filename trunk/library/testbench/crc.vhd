use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture crc of testbench is
	constant n : natural := 8;
	signal clk : std_logic := '0';
	signal xi  : unsigned(0 to 8-1) := "01010111";
	signal xq  : std_logic_vector(0 to 8-1);
	signal pl  : std_logic;
begin
	clk <= not clk after 5 ns;
	pl  <= '1', '0' after 12 ns;

	du : entity hdl4fpga.crc
	generic map (
		n => n)
	port map (
		clk => clk,
		g  => b"0000_0111",
		pl => pl,
		x0 => (others => '0'),
		xi => xi(0),
		xp => xq);

	process
		variable msg : line;
	begin
		if pl='0' then
			xi <= xi sll 1;
		end if;
		write (msg, string'("xq : "));
		write (msg, xq);
		writeline (output, msg);
		wait on clk until clk='1';
	end process;
end;
