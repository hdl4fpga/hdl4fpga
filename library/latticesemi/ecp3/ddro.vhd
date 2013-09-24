library ieee;
use ieee.std_logic_1164.all;

entity ddro is
	generic (
		ddr_phases : natural := 0;
		data_edges : natural := 2);
	port (
		clk : in  std_logic;
		phs : in  std_logic_vector(ddr_phases-1 downto 0) := (others => '0');
		d   : in  std_logic_vector(2**ddr_phases*data_edges-1 downto 0);
		q   : out std_logic);

	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;
use hdl4fpga.std;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddro is
	attribute oddrapps : string;
	attribute oddrapps of oddr_i : label is "SCLK_ALIGNED";
	type ddrd_vector is array (natural range <>) of std_logic_vector(d'length/data_edges-1 downto 0);
	signal ddrd : ddrd_vector(data_edges-1 downto 0);
	signal dr : std_logic;
	signal df : std_logic;
begin
	process (d)
		variable aux : std_logic_vector(d'length-1 downto 0);
	begin
		for i in d'range loop
			aux((i mod data_edges)*(d'length/data_edges)+(i/data_edges)) := d(i);
		end loop;
		ddrd(0) <= aux(ddrd(0)'range);
		aux := hdl4fpga.std."srl"(aux, aux'length);
		ddrd(1) <= aux(ddrd(0)'range);
	end process;
	dr <= hdl4fpga.std.mux(ddrd(r),phs);
	df <= hdl4fpga.std.mux(ddrd(f),phs);

	oddr_i : oddrxd1
	port map (
		sclk => clk,
		da => dr,
		db => df,
		q  => q);
end;

library ieee;
use ieee.std_logic_1164.all;

entity ddrto is
	port (
		clk : in std_logic;
		d   : in std_logic;
		q   : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddrto is
begin
	oddrt_i : ofd1s3ax
	port map (
		sclk => clk,
		d => d,
		q => q);
end;
