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

entity ddr_io_dqs is
	generic (
		std : positive range 1 to 3 := 3;
		data_bytes : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_io_ena : in    std_logic_vector(data_bytes-1 downto 0);
		ddr_mpu_dqsz : in  std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqsz : out  std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqso : out  std_logic_vector(data_bytes-1 downto 0));
end;

library hdl4fpga;

architecture std of ddr_io_dqs is
	signal rclk : std_logic;
	signal tclk : std_logic;
begin

	rclk <= ddr_io_clk;
	tclk <= not ddr_io_clk when std=1 else ddr_io_clk;

	ddr_io_dqs_u : for i in 0 to data_bytes-1 generate
		signal dr  : std_logic;
		signal df  : std_logic;
	begin

		with std select
		dr <= 
			'0' when 1|2,
			ddr_io_ena(i) when 3;

		with std select
		df <= 
			ddr_io_ena(i) when 1|2,
			'1' when 3;

		oddrt_i : entity hdl4fpga.ddrto
		port map (
			clk => tclk,
			d  => ddr_mpu_dqsz(i),
			q  => ddr_io_dqsz(i));

		oddr_i : entity hdl4fpga.ddro
		port map (
			clk => rclk,
			dr => dr,
			df => df,
			q  => ddr_io_dqso(i));

	end generate;
end;
