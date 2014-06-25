library ieee;
use ieee.std_logic_1164.all;

entity xdr_dm is
	generic (
		data_strobe : string  := "NONE_LOOPBACK";
		data_edges  : natural := 2;
		data_phases : natural);
	port (
		sys_clk : in  std_logic;
		sys_dmo : in  std_logic_vector(data_phases-1 downto 0);
		sys_st  : in  std_logic_vector(data_phases-1 downto 0);
		sys_dmx : in  std_logic_vector(data_phases-1 downto 0);
		sys_dmo : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo : out std_logic);
end;

architecture arch of xdr_dm is
begin

	dmff_g: for i in 0 to data_phases-1 generate
		signal di : std_logic;
	begin
		di <=
			sys_dmo when data_strobe /= "INTERNAL_LOOPBACK" else
			sys_dmo when sys_dmx(i)='1' else
			sys_st(i);

		ffd_i : entity hdl4fpga.ff
		port map (
			clk => clks(i),
			d   => di,
			q   => d(i));
	end generate;

	oddr_du : entity hdl4fpga.ddro
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges)
	port map (
		clk => sys_clk,
		d   => d,
		q   => xdr_dmo);
end;
