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
use hdl4fpga.std.all;

architecture mult of testbench is

	signal clk : std_logic := '0';
	signal rst : std_logic;

	signal product : std_logic_vector(0 to 8-1);
begin
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 26 ns;

	mulp_b : block

		constant ma : std_logic_vector := x"0EDC";
		constant mr : std_logic_vector := x"FDEF";

		signal mier   : std_logic_vector(4-1 downto 0);
		signal mand   : std_logic_vector(mier'range);

		constant sizma : natural := ma'length/mier'length;
		constant sizmb : natural := mr'length/mier'length;

		signal sela   : std_logic_vector(0 to unsigned_num_bits(sizma-1)-1);
		signal selb   : std_logic_vector(0 to unsigned_num_bits(sizmb-1)-1);

		signal prod   : std_logic_vector(mand'length+mier'length-1 downto 0);

		signal ci     : std_logic;
		signal b      : std_logic_vector(mier'length-1 downto 0);
		signal s      : std_logic_vector(mier'length-1 downto 0);
		signal co     : std_logic;

		signal fifo_i : std_logic_vector(mier'length-1 downto 0);
		signal fifo_o : std_logic_vector(mier'length-1 downto 0);
		signal inia   : std_logic;
		signal inim   : std_logic;
		signal dv     : std_logic;

	begin

		mand <= word2byte(std_logic_vector(unsigned(ma) rol mand'length), sela);
		mier <= word2byte(std_logic_vector(unsigned(mr) rol mier'length), selb);

		multp_e : entity hdl4fpga.mult
		port map (
			clk     => clk,
			ini     => inim,
			multand => mand,
			multier => mier,
			product => prod);

		b  <= fifo_o(b'range) when inia='0' else (b'range => '0');

		adder_e : entity hdl4fpga.adder
		port map (
			clk => clk,
			ini => inim,
			ci  => ci,
			a   => prod(mier'range),
			b   => b,
			s   => s,
			co  => co);

		fifo_i <= s when inim='0' else (others => '0');
		fifo_e : entity hdl4fpga.align
		generic map (
			n => mier'length,
			d => (0 to fifo_i'length => sizma-1))
		port map (
			clk => clk,
			di  => fifo_i,
			do  => fifo_o);

		state_p : process (clk, rst)
			variable cntra : unsigned(sela'length downto 0);
			variable cntrb : unsigned(selb'length downto 0);
			variable vinia : std_logic;
			variable vinim : std_logic;
			variable last  : std_logic;
		begin
			if rising_edge(clk) then 
				sela <= std_logic_vector(cntra(sela'reverse_range));
				selb <= std_logic_vector(cntrb(selb'reverse_range));
				inia <= vinia;
				inim <= vinim;
				if rst='1' then
					dv    <= '0';
					ci    <= '0';
					last  <= '0';
					cntra := to_unsigned(sizma-2, cntra'length);
					cntrb := to_unsigned(sizmb-2, cntrb'length);
					vinia := '1';
					vinim := '1';
				else
					dv <= vinim or last;
					ci <= co;
					if vinim='1' then
						ci <= '0';
					end if;

					last  := cntrb(cntrb'left) and not cntra(cntra'left);
					vinim := '0';
					if cntra(cntra'left)='1' then
						if cntrb(cntrb'left)='0' then
							cntra := to_unsigned(sizma-2, cntra'length);
							cntrb := cntrb - 1;
							vinia := '0';
							vinim := '1';
						end if;
					else
						cntra := cntra - 1;
					end if;
				end if;
			end if;
		end process;

	end block;

end;
