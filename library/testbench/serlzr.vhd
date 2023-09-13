library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture serlzr of testbench is
	constant n : natural := 16;
	constant m : natural := 24;

	signal rst      : std_logic;
	signal src_clk  : std_logic := '1';
	signal src_frm  : std_logic := '0';
	signal src_trdy : std_logic := '1';
	signal src_data : std_logic_vector(n-1 downto 0);
	signal dst_frm  : std_logic := '0';
	signal dst_trdy : std_logic := '0';
	signal dst_clk  : std_logic := '1';
	signal dst_data : std_logic_vector(m*1-1 downto 0);

begin
	rst  <= '0','1' after 10 ns;
	src_clk  <= not src_clk  after n*10 ns;
	dst_clk <= not dst_clk after m*10 ns;
	process (src_clk, dst_clk)
	begin
		if rising_edge(src_clk) then
			if rising_edge(dst_clk) then
				src_frm <= rst;
				dst_frm <= rst;
			end if;
		end if;
	end process;

	process (src_clk)
		variable frm  : std_logic := '0';
		variable data : unsigned(0 to 96-1) := x"0102030405060708090a0b0c";
	begin
		if rising_edge(src_clk) then
			if src_frm='1' then
				data := data rol src_data'length;
			end if;
		end if;
		src_data <= std_logic_vector(data(0 to src_data'length-1));
	end process;

	process (dst_clk)
	begin
		if rising_edge(dst_clk) then
			if rising_edge(src_clk) then
			end if;
		end if;
	end process;

	du_e : entity hdl4fpga.serlzr
	generic map (
		lsdfirst => false)
	port map (
		src_clk  => src_clk,
		src_frm  => src_frm,
		src_trdy => src_trdy,
		src_data => src_data,
		dst_clk  => dst_clk,
		dst_frm  => dst_frm,
		dst_data => dst_data);
end;