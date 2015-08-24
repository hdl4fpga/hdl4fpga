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

use hdl4fpga.std.all;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity test is
end;

architecture def of test is
	type finteger is file of integer;
	file finput  : finteger open READ_MODE  is "../ppp";
	file foutput : text     open WRITE_MODE is "../xxx.dat";

	signal clk : std_logic := '0';
	signal sample  : integer;
	signal acc : integer64_vector(0 to 3-1) := (others => 0 ps);
begin

	fetch_sample_p : process 
		variable msg : line;
		variable data : integer;
	begin
		while not endfile(finput) loop
			if rising_edge(clk) then
				read (finput, data);
				sample <= data;
			end if;
			clk <= not clk after 1 ns;
			wait on clk;
		end loop;
		wait;
	end process;

	frame_bound_p : block
		signal max  : integer64_vector(0 to 3-1) := (others => 0 ps);
		signal len0 : natural_vector(0 to 3-1) := (others => 0);
		signal len1 : natural_vector(0 to 3-1) := (others => 0);
		signal ena  : std_logic_vector(0 to 3-1);
	begin
		process (clk)
		begin
			if rising_edge(clk) then
				for i in max'range loop
					ena (i) <= '0';
					if abs(acc(i)) > max(i) then
						max(i)  <= abs(acc(i));
						len1(i) <= len1(i) + len0(i) + 1;
						len0(i) <= 0;
					else
						if  len0(i) < 8192*2 then
							len0(i) <= len0(i) + 1;
						else
							max(i) <= 0 ps;
							len1(i) <= len0(i);
							len0(i) <= 0;
							ena(i) <= '1';

						end if;
					end if;
				end loop;
			end if;
		end process;

		mean_g : for i in 0 to 3-1 generate
			signal mem : natural_vector(0 to 4-1);
		begin
			process (clk)
				variable msg : line;
				variable mean : natural_vector(0 to 3-1);
			begin
				if rising_edge(clk) then
					if ena(i)='1' then
						for j in mem
						mean(i) := mean(i) + len1(i);
						write (msg, i);
						write (msg, string'(" ----> "));
						write (msg, len1(i));
						writeline (output, msg);
					end if;
				end if;
			end process;
		end generate;
	end block;

	process (clk)
		variable msg  : line;

		variable ram  : hdl4fpga.std.integer_vector(0 to 2**14-3) := (others => 0);
		variable pfx  : hdl4fpga.std.integer_vector(0 to ram'length/8-1) := (others => 0);
		variable ram1 : hdl4fpga.std.integer_vector(0 to 3-1) := (others => 0);
		variable pfx1 : hdl4fpga.std.integer_vector(0 to 3-1) := (others => 0);

		variable prod : integer;
		variable mul  : integer;
		variable data1 : integer;
		variable i,j,k : natural := 0;
	begin
		if rising_edge(clk) then
			data1   := ram((i + ram'length - pfx'length) mod ram'length);
			ram1(1) := ram(i);
			pfx1(1) := pfx(j);		 -- pfx1(1) := pfx(i mod pfx'length);
			pfx(j)  := ram(i);		 -- pfx(i mod pfx'length) := ram(i);
			ram(i)  := sample;
			i := (i+1) mod ram'length;
			j := (j+1) mod pfx'length;
			ram1(2) := ram(i);
			pfx1(2) := pfx(j);		 -- pfx1(2) := pfx(i mod pfx'length);


			write (msg, k, field => 6);

			for j in 0 to 3-1 loop

				prod   := ram1(j) * sample;
				mul    := pfx1(j) * data1;
				acc(j) <= acc(j)  + (prod * 1 ps) - (mul * 1 ps);

				write (msg, string'(" "));
				write (msg, acc(j), field => 14, unit =>  ps);
			end loop;
			writeline (foutput, msg);
			k := k + 1;

			ram1(0) := ram1(1);
			pfx1(0) := pfx1(1);
		end if;
	end process;

end;
