library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end;

architecture behavioral of testbench is

	type dinT is array (natural range <>) of std_ulogic_vector (31 downto 0);
	type szT  is array (natural range <>) of std_ulogic_vector ( 0   to   1);

	constant a0C : std_ulogic_vector := "01";
	constant a1C : std_ulogic_vector := "01";
	constant szC  : szT (0 to 2) := ("00", "01", "11");
	constant dinC : dinT(0 to 0) := (0 => X"01020304");

	component stu
		port (
			a    : in  std_ulogic_vector;
			sz   : in  std_ulogic_vector( 0   to   1);
			din  : in  std_ulogic_vector(31 downto 0); 
			dout : out std_ulogic_vector(31 downto 0);
			memE : out std_ulogic_vector( 0   to   3));
	end component;
			
	signal aS  : std_ulogic_vector(1 downto 0);
	signal szS : std_ulogic_vector(0 to 1);
	signal dinS  : std_ulogic_vector(31 downto 0);
	signal doutS : std_ulogic_vector(31 downto 0);
	signal memES : std_ulogic_vector(0 to 3);

begin
	dut : stu
		port map (
			a => aS,
			sz => szS,
			din => dinS,
			dout => doutS,
			memE => memES);

	process
		variable step : natural := 0;
	begin
		dinS <= dinC(0);
		aS(0)  <= a0C((step / 1) mod 2);
		aS(1)  <= a1C((step / 2) mod 2);
		szS  <= szC((step / 4) mod 3);

		step := step + 1;

		wait for 20 ns;
	end process;
end;
