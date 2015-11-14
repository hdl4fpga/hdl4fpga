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

entity ddrdqphy is
	generic (
		loopback : boolean;
		gear : natural;
		byte_size : natural);
	port (
		sys_clk0 : in  std_logic;
		sys_clk90 : in  std_logic;
		sys_dmt  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_dmi  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sti  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_sto  : out std_logic_vector(0 to gear-1);
		sys_dqo  : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(gear-1 downto 0);
		sys_dqi  : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqso : in  std_logic_vector(0 to gear-1);
		sys_dqst : in  std_logic_vector(0 to gear-1);

		ddr_dmt  : out std_logic;
		ddr_dmo  : out std_logic;
		ddr_sto  : out std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

end;

library hdl4fpga;

architecture virtex of ddrdqphy is

	signal dqi : std_logic_vector(sys_dqi'range);

	signal dqt : std_logic_vector(sys_dqt'range);
	signal dqst : std_logic_vector(sys_dqst'range);
	signal dqso : std_logic_vector(sys_dqso'range);

begin

	iddr_g : for i in 0 to byte_size-1 generate
		phase_g : for j in  gear-1 downto 0 generate
			sys_dqi(j*byte_size+i) <= ddr_dqi(i);
		end generate;
	end generate;

	oddr_g : for i in 0 to byte_size-1 generate
	begin
		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk90,
			d => sys_dqt(0),
			q => ddr_dqt(i));

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => sys_dqo(0*byte_size+i),
			df  => sys_dqo(1*byte_size+i),
			q   => ddr_dqo(i));
	end generate;

	dmo_g : block
		signal dmi : std_logic_vector(sys_dmi'range);
		signal dmt : std_logic_vector(sys_dmt'range);
	begin

		process (sys_dmi, sys_dmt, sys_sti)
		begin
			for i in sys_dmi'range loop
				if sys_dmt(i)='0' then
					dmi(i) <= sys_dmi(i);
				else
					dmi(i) <= sys_sti(i);
				end if;

				if loopback=false then
					dmt(i) <= '0';
				else
					dmt(i) <= sys_dmt(i);
				end if;
			end loop;
		end process;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk90,
			d => dmt(0),
			q => ddr_dmt);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => dmi(0),
			df  => dmi(1),
			q   => ddr_dmo);
	end block;

	sto_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk90,
		dr  => sys_sti(0),
		df  => sys_sti(1),
		q   => ddr_sto);

	dqso_b : block 
		signal clk_n : std_logic;
	begin

		clk_n <= not sys_clk0;
		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => clk_n,
			d => sys_dqst(1),
			q => ddr_dqst);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk0,
			dr  => '0',
			df  => sys_dqso(0),
			q   => ddr_dqso);

	end block;
end;
