library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_clks is
	generic (
		data_phases : natural := 1;
		data_edges  : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_ini   : in std_logic;
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;
		clk_phs   : out std_logic_vector(2*data_phases*data_edges-1 downto 0);

		sys_rea  : in std_logic;
		ddr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);
		dqs_phs  : out std_logic_vector(2*data_phases*data_edges*data_bytes-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
end

architecture uni of ddr_clks is

	signal ddr_eclk0  : std_logic_vector(data_edges-1 downto 0);
	signal ddr_eclk90 : std_logic_vector(data_edges-1 downto 0);

	type ephs_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);

	signal clks  : std_logic_vector(2*data_edges-1 downto 0);
	signal eclks : ephs_vector(2*data_edges-1 downto 0);
	signal ephs  : ephs_vector(data_bytesdata_edges-1 downto 0);

begin

	clks <= (
		2*r+0 => ddr_clk0, 2*r+1 => ddr_clk90,
		2*f+0 => not ddr_clk0, 2*f+1 => not ddr_clk90);

	eclk_e : for i in clks'range generate
		signal phs : std_logic_vector(0 to data_phases-1);
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				if sys_ini='1' then
					phs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
				else
					phs <= phs rol 1;
				end if;
			end if;
		end process;
		eclks(i) <= phs;
	end generate;

	process (eclks)
		variable aux : unsigned(phs_clk'range);
	begin
		aux := (others => '-');
		for i in eclks'range loop
			aux := aux sll data_phases;
			aux(eclks'range) := eclks(i);
		end loop;
		phs_clk <= aux;
	end process;

	phsdqs_e : for i in ddr_dqsi'range loop
		signal delay_dqsi : std_logic_vector(data_edges-1 downto 0);
	begin
		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi => ddr_dqsi(k),
			x_p => delayed_dqsi(r),
			x_n => delayed_dqsi(f));

		dqsi_e : for j in delayed_dqsi'range generate
			signal cphs : std_logic_vector(0 to data_phases-1);
		begin
			process (delayed_dqsi(i))
			begin
				if sys_rea='1' then
					cphs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
				elsif rising_edge(delay_dqsi(i)) then
					cphs <= cphs rol 1;
				end if;
			end process;
			ephs(i*data_bytes+j) <= cphs;
		end generate;
	end generate;

	process (ephs)
		variable aux : unsigned(dqs_phs'range);
	begin
		phs_dqs <= (others => '-');
		for ephs'range loop
			for 
			phs_dqs <= phs_dqs sll ephs(i);
		end loop;
	end process;

end;
