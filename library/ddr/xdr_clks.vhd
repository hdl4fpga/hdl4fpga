library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_clks is
	generic (
		data_phases : natural := 2;
		data_edges  : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_ini   : in  std_logic;
		sys_clk0  : in  std_logic;
		sys_clk90 : in  std_logic;
		clk_phs0  : out std_logic_vector(data_phases*data_edges-1 downto 0);
		clk_phs90 : out std_logic_vector(data_phases*data_edges-1 downto 0);

		dqs_rst  : in  std_logic;
		ddr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);
		dqs_phs  : out std_logic_vector(2*data_phases*data_edges*data_bytes-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture uni of xdr_clks is
	type ephs_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);

	signal clks  : std_logic_vector(2*data_edges-1 downto 0);
	signal eclks : ephs_vector(data_phases*data_edges-1 downto 0);
	signal ephs  : ephs_vector(data_bytes*data_edges-1 downto 0);

	signal srst : std_ulogic_vector(clks'range);
	constant wave : unsigned(data_phases-1 downto 0) := (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
begin

	clks <= (
		2*r+0 => sys_clk0, 2*r+1 => sys_clk90,
		2*f+0 => not sys_clk0, 2*f+1 => not sys_clk90);

	assert data_phases=2 
		report "data_phases /= 2"
		severity FAILURE;

	srst(0) <= sys_ini;
	eclk_e : for i in clks'range generate
		signal phs : std_logic_vector(0 to data_phases-1);
	begin
		ini_g : if i /= 1 generate 
			process (clks(i))
			begin
				if rising_edge(clks(i)) then
					srst((i+3) mod 4) <= srst(i);
				end if;
			end process;
		end generate;

		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				if srst(i)='1' then
					if i=2 then
						phs <= std_logic_vector(wave rol 1);
					else
						phs <= std_logic_vector(wave);
					end if;
				else
					phs <= phs rol 1;
				end if;
			end if;
		end process;
		eclks(i) <= phs;
	end generate;

	process (eclks)
	begin
		for i in eclks(0)'range loop
			clk_phs0(2*i) <= eclks(0)(i);
			clk_phs0(2*i+1) <= eclks(2)(i);
			clk_phs90(2*i) <= eclks(1)(i);
			clk_phs90(2*i+1) <= eclks(3)(i);
		end loop;
	end process;

--	phsdqs_e : for i in ddr_dqsi'range generate
--		signal delayed_dqsi : std_logic_vector(data_edges-1 downto 0);
--	begin
--		dqs_delayed_e : entity hdl4fpga.pgm_delay
--		port map (
--			xi => ddr_dqsi(i),
--			x_p => delayed_dqsi(r),
--			x_n => delayed_dqsi(f));
--
--		dqsi_e : for j in delayed_dqsi'range generate
--			signal cphs : std_logic_vector(0 to data_phases-1);
--		begin
--			process (dqs_rst, delayed_dqsi(i))
--			begin
--				if dqs_rst='1' then
--					cphs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
--				elsif rising_edge(delayed_dqsi(i)) then
--					cphs <= cphs rol 1;
--				end if;
--			end process;
--			ephs(i*data_bytes+j) <= cphs;
--		end generate;
--	end generate;
--
--	process (ephs)
--		variable aux : std_logic_vector(dqs_phs'range);
--	begin
--		dqs_phs <= (others => '-');
--		for i in ephs'range loop
--			aux := aux sll data_phases;
--			aux(ephs(0)'range) := ephs(i);
--		end loop;
--		dqs_phs <= aux;
--	end process;

end;
