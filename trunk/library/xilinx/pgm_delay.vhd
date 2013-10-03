library ieee;
use ieee.std_logic_1164.all;

entity pgm_delay is
	generic (
		n : natural := 1;
		x : natural := 0;
		y : natural := 0);
	port (
		xi  : in  std_logic;
		ena : in  std_logic_vector(n-1 downto 0) := (others => '1');
		x_p : out std_logic;
		x_n : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of pgm_delay is
	constant blut : string(1 to 2) := "FG";
	signal d : std_logic_vector(0 to n-1);

begin
	d(n-1) <= '-';
	chain_g: for i in n-1 downto 1 generate
	begin
		lut : lut4 
		generic map (
			init => x"00ca")
		port map (
			i0 => d(i),
			i1 => xi,
			i2 => ena(i),
			i3 => '0',
			o  => d(i-1));
	end generate;
	lutp : lut4 
	generic map (
		init => x"00ca")
	port map (
		i0 => d(0),
		i1 => xi,
		i2 => ena(0),
		i3 => '0',
		o  => x_p);
	lutn : lut4 
	generic map (
		init => x"0035")
	port map (
		i0 => d(0),
		i1 => xi,
		i2 => ena(0),
		i3 => '0',
		o  => x_n);
end;
