library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stuSync is
	port (
		clk  : in  std_ulogic;
		a    : in  std_ulogic_vector(0 to 1);
		sz   : in  std_ulogic_vector(0 to 1);
		din  : in  std_ulogic_vector(0 to 31);
		dout : out std_ulogic_vector(31 downto 0);
		memE : out std_ulogic_vector(0 to 3));
end;

architecture behavioral of stusync is

	component stu
		port (
			a     : in  std_ulogic_vector(0 to 1);
			sz    : in  std_ulogic_vector(0 to 1);
			din   : in  std_ulogic_vector(0 to 31);
			dout  : out std_ulogic_vector(31 downto 0);
			memE : out std_ulogic_vector(0 to 3));
	end component;
			
	signal aS    : std_ulogic_vector(1 downto 0);
	signal szS   : std_ulogic_vector(0 to 1);
	signal dinS  : std_ulogic_vector(0 to 31);
	signal doutS : std_ulogic_vector(31 downto 0);
	signal memES : std_ulogic_vector(3 downto 0);

begin
	dut : stu
		port map (
			a    => aS,
			sz   => szS,
			din  => dinS,
			dout => doutS,
			memE => memES);

	process (clk)
	begin
		if rising_edge(clk) then
			dinS <= din;
			aS  <= a;
			szS <= sz;
			dout <= doutS;
			memE <= memES;
		end if;
	end process;
end;