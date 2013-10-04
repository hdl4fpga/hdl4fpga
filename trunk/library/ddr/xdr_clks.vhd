library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_clks is
	generic (
		data_phases : natural := 1;
		data_edges  : natural := 2;
		data_bytes  : natural := 2);
	port (
		ddr_clk0 : in  std_logic;
		ddr_clk90 : in  std_logic;
		ddr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);

		phs_clk0  : out std_logic_vector(data_phases*data_edges-1 downto 0);
		phs_clk90 : out std_logic_vector(data_phases*data_edges-1 downto 0);
		phs_dqs   : out std_logic_vector(data_phases*data_edges*data_bytes-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
end

architecture uni of ddr_clks is

	signal ddr_eclk0  : std_logic_vector(data_edges-1 downto 0);
	signal ddr_eclk90 : std_logic_vector(data_edges-1 downto 0);

	type ephs_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);

	signal eclk0  : ephs_vector(data_edges-1 downto 0);
	signal eclk90 : ephs_vector(data_edges-1 downto 0);
	signal ephs   : ephs_vector(data_edges*data_bytes-1 downto 0);

begin

	ddr_eclk0 <= (f => not ddr_clk, r => ddr_clk);
	for l in clk_-1 downto 0 generate
		phsclk_e : for i in data_edges-1 downto 0 generate
			signal cphs : std_logic_vector(0 to data_phases-1);
		begin
			process (ddr_eclk0(i))
			begin
				if rising_edge(ddr_eclk0(i)) then
					if sys_ini='1' then
						cphs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
					else
						cphs <= cphs rol 1;
					end if;
				end if;
			end process;
			eclk(i*data_bytes+j) <= cphs;
		end generate;

		process (eclk0)
		begin
			for eclk'range loop
				phs_clk <= phs_clk sll eclk0(i);
			end loop;
		end process;
	end generate;

	phsdqs_e : for i in ddr_dqsi'range loop
		signal delay_dqsi : std_logic_vector(data_edges-1 downto 0);
	begin
		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi => ddr_dqsi(k),
			x_p => delayed_dqsi(r),
			x_n => delayed_dqsi(f));

		dqsi_e : for j in delay_dqsi'range generate
			signal cphs : std_logic_vector(0 to data_phases-1);
		begin
			process (delayed_dqsi(i))
			begin
				if then
					cphs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
				elsif rising_edge(delay_dqsi(i)) then
					cphs <= cphs rol 1;
				end if;
			end process;
			ephs(i*data_bytes+j) <= cphs;
		end generate;
	end generate;

	process (ephs)
	begin
		phs_dqs <= (others => '-');
		for ephs'range loop
			for 
			phs_dqs <= phs_dqs sll ephs(i);
		end loop;
	end process;

end;
