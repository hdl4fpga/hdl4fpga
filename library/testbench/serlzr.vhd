library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture serlzr of testbench is
	constant n : natural := 32;
	constant m : natural := 24;
	signal dst_frm   : std_logic := '0';
	signal clk       : std_logic := '1';
	signal clk_shift : std_logic := '1';
	signal datai     : std_logic_vector(n-1 downto 0) := (others => '0');
	signal datao     : std_logic_vector(m*1-1 downto 0);

begin
	clk       <= not clk after n*10 ns;
	clk_shift <= not clk_shift after m*10 ns;
	dst_frm   <= '0', '1' after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			datai <= datai xor (datai'range => '1');
			-- datai <= std_logic_vector(unsigned(datai) + 1);
		end if;
	end process;

	du_e : entity hdl4fpga.serlzr
	port map (
		src_clk  => clk,
		src_data => datai,
		dst_clk  => clk_shift,
		dst_data => datao);
end;