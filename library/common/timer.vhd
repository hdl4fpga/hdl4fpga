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

library hdl4fpga;
use hdl4fpga.std.all;

entity timer is
	generic (
		stage_size : natural_vector);
	port (
		data : in  std_logic_vector;
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : out std_logic);
end;

architecture def of timer is

	signal cy : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal en : std_logic_vector(stage_size'length downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(stage_size'length-1 downto 0);
	alias stage_length : natural_vector(stage_size'length-1 downto 0) is stage_size;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to stage_length'length-1 loop
				if req='1' then
					cy(i+1) <= '0';
				elsif cy(stage_length'length)='0' then
					cy(i+1) <= q(i) and cy(i);
				end if;
			end loop;
		end if;
	end process;
	en <= cy(stage_length'length downto 1) & not cy(stage_length'length);

	cntr_g : for i in 0 to stage_length'length-1 generate

		impure function csize (
			constant i : natural)
			return natural is
		begin
			if i = 0 then
				return 0;
			end if;
			return stage_length(i-1);
		end;
		constant size : natural := csize(i+1)-csize(i);
		signal cntr : unsigned(0 to size-1);

	begin
		cntr_p : process (clk)
			variable csize : natural_vector(stage_length'length downto 0) := (others => 0);
		begin
			if rising_edge(clk) then
				csize(stage_length'length downto 1) := stage_length;
				if req='1' then
					cntr <= resize(shift_right(unsigned(data), csize(i)), size);
				elsif en(i)='1' then
					if cntr(0)='1' then
						cntr <= to_unsigned((2**(size-1)-2), size);
					else
						cntr <= cntr - 1;
					end if;
				end if;
			end if;
		end process;
		q(i) <= cntr(0);
	end generate;
	rdy <= cy(stage_length'length);
end;
