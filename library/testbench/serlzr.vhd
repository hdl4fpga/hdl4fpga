library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture serlzr of testbench is
	constant n : natural := 16;
	constant m : natural := 24;
	signal src_trdy  : std_logic := '0';
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
		variable xxx : unsigned(0 to 2*m-1) := unsigned(reverse(reverse(std_logic_vector'(x"010203040506")),8));
	begin
		if rising_edge(clk) then
				datai <= std_logic_vector(xxx(0 to datai'length-1));
				xxx := xxx rol datai'length;
				-- datai <= std_logic_vector(unsigned(datai) + 1);
		end if;
	end process;

	du_e : entity hdl4fpga.serlzr
	port map (
		src_clk  => clk,
		src_trdy => src_trdy,
		src_data => datai,
		dst_clk  => clk_shift,
		dst_data => datao);
end;