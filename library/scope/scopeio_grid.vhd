library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_grid is
	generic (
		latency : natural);
	port (
		clk     : in  std_logic;
		ena     : in  std_logic;
		x       : in  std_logic_vector;
		y       : in  std_logic_vector;
		dot     : out std_logic);
end;

architecture def of scopeio_grid is
	signal hena  : std_logic;
	signal hdot  : std_logic;
	signal hmask : std_logic_vector(0 to 3-1);
	signal vena  : std_logic;
	signal vdot  : std_logic;
	signal vmask : std_logic_vector(0 to 3-1);
	signal hvdot : std_logic;
begin

	hena <= ena     when y(3-1 downto 0)=(3-1 downto 0 => '0') else '0';
	hmask <= b"001" when y(5-1 downto 3)=(5-1 downto 3 => '0') else b"111";
	hzline_e : entity hdl4fpga.draw_line
	port map (
		ena  => hena,
		mask => hmask,
		x    => x(5-1 downto 0),
		dot  => hdot);

	vena  <= ena    when x(3-1 downto 0)=(3-1 downto 0 => '0') else '0';
	vmask <= b"001" when x(5-1 downto 3)=(5-1 downto 3 => '0') else b"111";
	vtline_e : entity hdl4fpga.draw_line
	port map (
		ena  => vena,
		mask => vmask,
		x    => y(5-1 downto 0),
		dot  => vdot);

	hvdot <= vdot or hdot;
	align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => latency))
	port map (
		clk   => clk,
		di(0) => hvdot,
		do(0) => dot);

end;
