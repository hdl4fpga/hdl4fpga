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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture mult of testbench is

	signal clk : std_logic := '0';
	signal rst : std_logic;
	signal ini : std_logic;

	signal product : std_logic_vector(0 to 8-1);
begin
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 26 ns;

	process (clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;


	ini <= rst;
	mulp_b : block
		constant n    : natural := 4;
		constant m    : natural := 4;
		constant mand : std_logic_vector(0 to n-1);
		constant mier : std_logic_vector(0 to m-1);

		signal prod   : std_logic_vector(0 to m+n-1);
		signal sela   : std_logic_vector(0 to 2-1);
		signal selb   : std_logic_vector(0 to 2-1);
		signal a      : std_logic_vector(0 to m-1);
		signal b      : std_logic_vector(0 to m-1);
		signal s      : std_logic_vector(0 to m-1);
		signal fifo_i : std_logic_vector(0 to m);
		signal fifo_o : std_logic_vector(0 to m);
	begin
		mand <= word2byte(x"1234"), sela);
		mier <= word2byte(x"5678",  selb);
		multp_e : entity hdl4fpga.mult
		port map (
			clk     => clk,
			ini     => ini ,
			accmltr => fifo_o(mand'range),
			multand => mand,
			multier => mier,
			product => prod);

		co <= fifo_o(b'length) when ini='0' else '0';
		b  <= fifo_o(b'range)  when ini='0' else (b'range => '0');

		acc_e : entity hdl4fpga.adder
		port map (
			ci => ci,
			a  => a,
			b  => b,
			s  => s,
			co => co);

		fifo_i <= s & ci;
		fifo_e : entity hdl4fpga.align
		generic map (
			n => ,
			d => 0 to fifo_i'length => )
		port map (
			clk => clk,
			di  => fifo_i,
			do  => fifo_o);

		process (clk, ini)
			variable cntra : unsigned(0 to sela'length-1);
			variable cntrb : unsigned(0 to selb'length-1);
		begin
			if ini='1' then
				cntra := (others => '0');
				cntrb := (others => '0');
			elsif rising_edge(clk) then 
				if cntrb(0)='0' then
					if cntra(0)='1' then
						cntrb := cntrb + 1;
					end if;
					cntra := cntra + 1;
				end if;
			end if;
		end process;
	end block;

end;
