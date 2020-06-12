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

entity dbram is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

architecture lscc of dbram is
	type dw_vector is array (natural range <>) of std_logic_vector(4-1 downto 0);

	function to_dwvector (
		arg : std_logic_vector)
		return dw_vector is
		constant n : natural := (arg'length+4-1)/4;
		variable dat : unsigned(0 to 4*n-1);
		variable val : dw_vector(n-1 downto 0);
	begin
		dat := resize(unsigned(arg), 4*n);
		val := (others => (others => '-'));
		for i in val'range loop
			val(i) := std_logic_vector(dat(0 to 4-1));
			dat := dat sll 4;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : dw_vector)
		return std_logic_vector is
		variable dat : unsigned(4*arg'length-1 downto 0);
	begin
		dat := (others => '0');
		for i in arg'range loop
			dat := dat sll 4;
			dat(4-1 downto 0) := unsigned(arg(i));
		end loop;
		return std_logic_vector(dat);
	end;

	constant l : natural := (n+4-1)/4;

	signal rd_slice : dw_vector(l-1 downto 0);
	signal wd_slice : dw_vector(l-1 downto 0);
	signal dat : std_logic_vector(0 to 4*l-1);

begin
	wd_slice <= dw_vector(to_dwvector(di));
	ram_g : for i in l-1 downto 0 generate
		ram_i : dpr16x4c
		port map (
			wck  => clk,
			wre  => we,
			rad0 => ra(0),
			rad1 => ra(1),
			rad2 => ra(2),
			rad3 => ra(3),
			wad0 => wa(0),
			wad1 => wa(1),
			wad2 => wa(2),
			wad3 => wa(3),
			do0  => rd_slice(i)(0),
			do1  => rd_slice(i)(1),
			do2  => rd_slice(i)(2),
			do3  => rd_slice(i)(3), 
			di0  => wd_slice(i)(0),
			di1  => wd_slice(i)(1),
			di2  => wd_slice(i)(2),
			di3  => wd_slice(i)(3));
	end generate;
	do <= std_logic_vector(resize(unsigned(to_stdlogicvector(rd_slice)), do'length));
end;
