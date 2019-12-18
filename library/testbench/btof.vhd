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

architecture btof of testbench is

	signal rst      : std_logic := '0';
	signal clk      : std_logic := '0';

	signal frm      : std_logic;
	signal bin_irdy : std_logic;
	signal bin_trdy : std_logic;
	signal bin_neg  : std_logic;
	signal bin_flt  : std_logic;
	signal bin_di   : std_logic_vector(0 to 4-1);
	signal bcd_irdy : std_logic;
	signal bcd_trdy : std_logic;
	signal bcd_end  : std_logic;
	signal bcd_do   : std_logic_vector(0 to 4-1);

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk  after 10 ns;
	frm <= not rst;

	float2btof_e : entity hdl4fpga.scopeio_float2btof
	port map (
		clk      => clk,
		frac     => x"000",
		exp      => x"0",
		bin_frm  => frm,
		bin_irdy => bin_irdy,
		bin_trdy => bin_trdy,
		bin_neg  => bin_neg,
		bin_exp  => bin_flt,
		bin_di   => bin_di);

	du_e : entity hdl4fpga.btof
	port map (
		clk      => clk,
		frm      => frm,
		bin_trdy => bin_trdy,
		bin_irdy => bin_irdy,
		bin_di   => bin_di,
		bin_flt  => bin_flt,
		bin_neg  => '0',

		bcd_sign  => '0',
		bcd_width => x"8",
		bcd_unit  => x"1",
		bcd_prec  => x"f",
		bcd_align => '0',
		bcd_trdy  => bcd_trdy,
		bcd_irdy  => '1',
		bcd_end   => bcd_end,
		bcd_do    => bcd_do);

	process (clk)
		variable num  : unsigned(8*4-1 downto 0) := x"aaaaaaaa";
		variable stop : std_logic := '0';
	begin
		if rising_edge(clk) then
			if bcd_trdy='1' then
				if stop='0' then
					num := num sll 4;
					num(4-1 downto 0) := unsigned(bcd_do);
				end if;
			end if;
			stop := bcd_end;
		end if;
	end process;
end;
