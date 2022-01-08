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

library unisim;
use unisim.vcomponents.all;

entity ddrdqphy is
	generic (
		registered_dout : boolean;
		loopback   : boolean;
		gear       : natural;
		byte_size  : natural);
	port (
		sys_clks   : in  std_logic_vector(0 to 2-1);
		sys_wrseq  : in  std_logic := '0';
		sys_dmt    : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_dmi    : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_sto    : out std_logic_vector(0 to gear-1);
		sys_dqi    : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(gear-1 downto 0);
		sys_dqo    : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(0 to gear-1);
		sys_dqst   : in  std_logic_vector(0 to gear-1);

		ddr_dmt    : out std_logic;
		ddr_dmo    : out std_logic;
		ddr_sto    : out std_logic;
		ddr_dqi    : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt    : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo    : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst   : out std_logic;
		ddr_dqso   : out std_logic);

	constant clk0  : natural := 0;
	constant clk90 : natural := 1;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture virtex of ddrdqphy is
begin

	iddr_g : for i in 0 to byte_size-1 generate
		phase_g : for j in  gear-1 downto 0 generate
			sys_dqo(j*byte_size+i) <= ddr_dqi(i);
		end generate;
	end generate;

	oddr_g : for i in 0 to byte_size-1 generate
		signal dqo  : std_logic_vector(0 to gear-1);
		signal rdqo : std_logic_vector(0 to gear-1);
		signal clks : std_logic_vector(0 to gear-1);
	begin
		clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));

		registered_g : for j in clks'range generate
			process (clks(j))
			begin
				if rising_edge(clks(j)) then
					if j mod 2=0 then
						rdqo(j) <= sys_dqi(j*byte_size+i) or      sys_wrseq;
					else
						rdqo(j) <= sys_dqi(j*byte_size+i) and not sys_wrseq;
					end if;
				end if;
			end process;
			dqo(j) <= rdqo(j) when registered_dout else
				sys_dqi(j*byte_size+i) or      sys_calreq when j mod 2=0 else
				sys_dqi(j*byte_size+i) and not sys_calreq when j mod 2=1:
		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk90),
			d => sys_dqt(0),
			q => ddr_dqt(i));

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk90),
			dr  => dqo(0),
			df  => dqo(1),
			q   => ddr_dqo(i));
	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal rdmi : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to gear-1);
	begin

		clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));
		registered_g : for i in clks'range generate
			signal d, t, s : std_logic;
		begin
			dmt(i) <= '0';

			--rdmi(i) <= s when t='1' and not loopback else d;
			process (clks(i))
			begin
				if rising_edge(clks(i)) then

					if t='1' and not loopback then
						rdmi(i) <= s;
					else
						rdmi(i) <= d;
					end if;

					t <= sys_dmt(i);
					d <= sys_dmi(i);
					s <= sys_sti(i);
				end if;
			end process;

			dmi(i) <=
				rdmi(i)    when registered_dout else
				sys_sti(i) when sys_dmt(i)='1' and not loopback else
				sys_dmi(i);

		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk90),
			d => dmt(0),
			q => ddr_dmt);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk90),
			dr  => dmi(0),
			df  => dmi(1),
			q   => ddr_dmo);
	end block;

	sto_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clks(clk90),
		dr  => sys_sti(0),
		df  => sys_sti(1),
		q   => ddr_sto);

	dqso_b : block
		signal clk_n : std_logic;
		signal dt : std_logic;
		signal dqso_r : std_logic;
		signal dqso_f : std_logic;
	begin

		clk_n <= not sys_clks(clk0);
		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk0),
			d => sys_dqst(1),
			q => ddr_dqst);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk0),
			dr  => '0',
			df  => sys_dqsi(0),
			q   => ddr_dqso);

	end block;
end;
