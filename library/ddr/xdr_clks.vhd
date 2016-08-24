--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_clks is
	generic (
		DATA_PHASES : natural := 2;
		DATA_EDGES  : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_ini   : in  std_logic;
		sys_clk0  : in  std_logic;
		sys_clk90 : in  std_logic;
		clk_phs0  : out std_logic_vector(DATA_PHASES*DATA_EDGES-1 downto 0);
		clk_phs90 : out std_logic_vector(DATA_PHASES*DATA_EDGES-1 downto 0);

		dqs_rst  : in  std_logic;
		ddr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);
		dqs_phs  : out std_logic_vector(data_bytes*DATA_PHASES*DATA_EDGES-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;

architecture uni of xdr_clks is
	type ephs_vector is array (natural range <>) of std_logic_vector(DATA_PHASES-1 downto 0);

	signal clks  : std_logic_vector(2*DATA_EDGES-1 downto 0);
	signal eclks : ephs_vector(clks'range);
	signal ephs  : ephs_vector(data_bytes*DATA_EDGES-1 downto 0);

	signal srst : std_ulogic_vector(clks'range);
	constant wave : std_logic_vector(DATA_PHASES-1 downto 0) := (0 to DATA_PHASES/2-1 => '0') & (0 to DATA_PHASES/2-1 => '1');
begin

	clks <= (
		2*r+0 => sys_clk0, 2*r+1 => sys_clk90,
		2*f+0 => not sys_clk0, 2*f+1 => not sys_clk90);

	assert DATA_PHASES=2 
		report "DATA_PHASES /= 2"
		severity FAILURE;

	srst(0) <= sys_ini;
	eclk_e : for i in clks'range generate
		signal phs : std_logic_vector(0 to DATA_PHASES-1);
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
						phs <= wave rol 1;
					else
						phs <= wave;
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

	phsdqs_e : for i in ddr_dqsi'range generate
		signal delayed_dqsi : std_logic_vector(DATA_EDGES-1 downto 0);
	begin
		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi => ddr_dqsi(i),
			x_p => delayed_dqsi(r),
			x_n => delayed_dqsi(f));

		dqsi_e : for j in delayed_dqsi'range generate
			signal cphs : std_logic_vector(0 to DATA_PHASES-1);
		begin
			process (dqs_rst, delayed_dqsi(i))
			begin
				if dqs_rst='1' then
					cphs <= wave;
				elsif rising_edge(delayed_dqsi(i)) then
					cphs <= cphs rol 1;
				end if;
			end process;
			ephs(i*data_bytes+j) <= cphs;
		end generate;
	end generate;

	process (ephs)
	begin
		for i in data_bytes-1 downto 0 loop
			for j in ephs(0)'range loop
				for k in DATA_EDGES-1 downto 0 loop
					dqs_phs((i*DATA_PHASES+j)*DATA_EDGES+k) <= ephs(i*DATA_EDGES)(j);
				end loop;
			end loop;
		end loop;
	end process;
end;
