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
	signal ini : std_logic;

	signal product : std_logic_vector(0 to 8-1);
begin
	clk <= not clk after 5 ns;
	ini <= '1', '0' after 26 ns;

	mulp_b : block

		constant ma : std_logic_vector := x"EDC";
		constant mr : std_logic_vector := x"FDEF";

		signal mier   : std_logic_vector(4-1 downto 0);
		signal mand   : std_logic_vector(mier'range);

		constant sizma : natural := ma'length/mier'length;
		constant sizmb : natural := mr'length/mier'length;

		signal inia   : std_logic;
		signal inim   : std_logic;
		signal sela   : std_logic_vector(0 to unsigned_num_bits(sizma-1)-1);
		signal selb   : std_logic_vector(0 to unsigned_num_bits(sizmb-1)-1);

		signal pprod   : std_logic_vector(mand'length+mier'length-1 downto 0);

		signal cy     : std_logic;
		signal ci     : std_logic;
		signal b      : std_logic_vector(mier'length-1 downto 0);
		signal s      : std_logic_vector(mier'length-1 downto 0);
		signal co     : std_logic;

		signal fifo_i : std_logic_vector(mier'length-1 downto 0);
		signal fifo_o : std_logic_vector(mier'length-1 downto 0);
		signal msppd  : unsigned(mier'range);
		signal mspdg  : unsigned(mier'range);
		signal last   : std_logic;
		signal dg     : std_logic_vector(mier'range);
		signal dv     : std_logic;

	begin

		mand <= word2byte(ma, sela, mand'length);
		mier <= word2byte(mr, selb, mand'length);

		multp_e : entity hdl4fpga.mult
		port map (
			clk     => clk,
			ini     => inim,
			multand => mand,
			multier => mier,
			product => pprod);

		cy_p : process (clk)
		begin
			if rising_edge(clk) then 
				cy <= co;
			end if;
		end process;

		ci <= cy when inim='0' else '0';
		b  <= (b'range => '0') when inia='1' else fifo_o(b'range);
		adder_e : entity hdl4fpga.adder
		port map (
			clk => clk,
			ini => inim,
			ci  => ci,
			a   => pprod(mier'range),
			b   => b,
			s   => s,
			co  => co);

		sign_extension_p : process (clk)

			function sign_extension (
				constant mier : std_logic_vector)
				return unsigned is
				variable retval : unsigned(mier'range);
			begin
				retval := (others => '0');
				for i in mier'range loop
					if mier(i) = '1' then
						retval := retval + ((mier'range => '1') sll i);
					end if;
				end loop;
				return retval;
			end;

			variable temp : unsigned(pprod'range);
			variable sign : std_logic;
			variable extn : std_logic;

		begin

			if rising_edge(clk) then
				temp  := unsigned(pprod);
				temp  := temp srl mier'length;
				if true then
					temp  := temp + sign_extension(mier);
					msppd <= temp(mier'range) + unsigned'(mier'range => extn);
				else
					msppd <= temp(mier'range);
				end if;
				if inia='1' then
					extn := '0';
				elsif inim='1' then
					extn := sign;
				end if;
				sign := mand(mand'left);
			end if;

		end process;

		mspdg  <= msppd + unsigned'(0 to 0 => cy);
		fifo_i <= s when inim='0' else std_logic_vector(mspdg);
		fifo_e : entity hdl4fpga.align
		generic map (
			n => mier'length,
			d => (0 to fifo_i'length => sizma-1))
		port map (
			clk => clk,
			di  => fifo_i,
			do  => fifo_o);

		state_p : process (clk)
			variable cntra : unsigned(sela'length downto 0);
			variable cntrb : unsigned(selb'length downto 0);
		begin
			if rising_edge(clk) then 
				if ini='1' then
					cntra := to_unsigned(sizma-1, cntra'length);
					cntrb := to_unsigned(sizmb-1, cntrb'length);
					inia  <= '1';
					inim  <= '1';
				else
					inim  <= '0';
					cntra := cntra - 1;
					if cntra(cntra'left)='1' then
						if cntrb(cntrb'left)='0' then
							cntra := to_unsigned(sizma-1, cntra'length);
							cntrb := cntrb - 1;
							inia  <= '0';
							inim  <= '1';
						end if;
					end if;
				end if;
				last <= setif(selb=(selb'range => '0'));
				sela <= std_logic_vector(cntra(sela'reverse_range));
				selb <= std_logic_vector(cntrb(selb'reverse_range));
			end if;
		end process;

		dg <= std_logic_vector(mspdg) when last='1' and inim='1' else s;
		dv <= not ini and (inim or last);

	end block;

end;
