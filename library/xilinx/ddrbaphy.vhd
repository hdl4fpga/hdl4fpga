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

entity ddrbaphy is
	generic (
		cmnd_phases : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		sys_clk   : in  std_logic;

		sys_cs  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cke : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_b   : in  std_logic_vector(cmnd_phases*bank_size-1 downto 0);
		sys_a   : in  std_logic_vector(cmnd_phases*addr_size-1 downto 0);
		sys_ras : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cas : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_we  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_odt : in  std_logic_vector(cmnd_phases-1 downto 0);

		ddr_rst : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ck  : out std_logic;
		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture ecp3 of ddrbaphy is
begin

	ck_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr => '0',
		df => '1',
		q  => ddr_ck);

	b_g : for i in 0 to bank_size-1 generate
		oddr_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk,
			dr => sys_b(bank_size*0+i),
			df => sys_b(bank_size*1+i),
			q  => ddr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
	begin
		oddr_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk,
			dr  => sys_a(addr_size*0+i),
			df  => sys_a(addr_size*1+i),
			q   => ddr_a(i));
	end generate;

	ras_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr  => sys_ras(0),
		df  => sys_ras(1),
		q   => ddr_ras);

	cas_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr  => sys_cas(0),
		df  => sys_cas(1),
		q   => ddr_cas);

	we_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr  => sys_we(0),
		df  => sys_we(1),
		q   => ddr_we);

	cs_i :  entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr => sys_cs(0),
		df => sys_cs(1),
		q  => ddr_cs);

	cke_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr => sys_cke(0),
		df => sys_cke(1),
		q  => ddr_cke);

	odt_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clk,
		dr => sys_odt(0),
		df => sys_odt(1),
		q  => ddr_odt);

end;
