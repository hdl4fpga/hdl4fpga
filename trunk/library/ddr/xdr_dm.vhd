library ieee;
use ieee.std_logic_1164.all;

entity xdr_dm is
	generic (
		data_strobe : string  := "NONE_LOOPBACK";
		data_edges  : natural := 2;
		data_phases : natural := 2);
	port (
		sys_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		sys_dmi  : in  std_logic_vector(data_phases-1 downto 0);
		sys_st   : in  std_logic_vector(data_phases-1 downto 0);
		sys_dmx  : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_phases-1 downto 0));
end;

architecture arch of xdr_dm is
	signal clks : std_logic_vector(data_phases-1 downto 0);
begin

	clks(xdr_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases-1 downto data_phases/data_edges) <= not sys_clks;
	end generate;

	dmff_g: for i in clks'range generate
		signal di : std_logic;
	begin
		di <=
			sys_dmi when data_strobe /= "INTERNAL_LOOPBACK" else
			sys_dmi when sys_dmx(i)='1' else
			sys_st(i);

		ffd_i : entity hdl4fpga.ff
		port map (
			clk => clks(i),
			d => di,
			q => xdr_dmo(i));
	end generate;

end;
