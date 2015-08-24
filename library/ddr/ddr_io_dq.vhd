--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity ddr_io_dq is
	generic (
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk  : in  std_logic;
		ddr_mpu_dqz : in  std_logic_vector(data_bytes-1 downto 0);
		ddr_io_dqz  : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_r : in  std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq_f : in  std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dqo  : out std_logic_vector(data_bytes*byte_bits-1 downto 0));
end;

library hdl4fpga;

architecture std of ddr_io_dq is
begin
	bytes_g : for i in data_bytes-1 downto 0 generate
		bits_g : for j in byte_bits-1 downto 0 generate

			oddrt_i : entity hdl4fpga.ddrto
			port map (
				clk => ddr_io_clk,
				d  => ddr_mpu_dqz(i),
				q  => ddr_io_dqz(i*byte_bits+j));

			oddr_i : entity hdl4fpga.ddro
			port map (
				clk => ddr_io_clk,
				dr => ddr_io_dq_r(i*byte_bits+j),
				df => ddr_io_dq_f(i*byte_bits+j),
				q  => ddr_io_dqo(i*byte_bits+j));

		end generate;
	end generate;
end;
