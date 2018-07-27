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

architecture btod of testbench is
	constant n : natural := 12;
	constant m : natural := 16;

	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal bin_dv : std_logic;
	signal bin_di : std_logic_vector(4-1 downto 0); 

	signal bcd_dv : std_logic;
	signal bcd_di : std_logic_vector(2*4-1 downto 0);
	signal bcd_en : std_logic;
	signal bcd_do : std_logic_vector(bcd_di'range);
	signal fix_do : std_logic_vector(bcd_di'range);
	signal int    : std_logic_vector(3*4-1 downto 0);
	signal conv   : std_logic_vector(4*4-1 downto 0);
	signal bcd : std_logic_vector(4*(3+4)-1 downto 0);

		signal ena : std_logic;
		signal cntr : natural;
begin
	rst <= '1', '0' after 5 ns;
	clk <= not clk after 10 ns;

	process (rst, clk)
		variable aux  : unsigned(conv'range);
		variable aux1 : unsigned(int'range);
	begin
		if rst='1' then
			bin_dv <= '0';
			bcd_dv <= '0';
			cntr   <= 0;
			int    <= x"f0f";
			conv   <= (others => '0');
			ena    <= '0';
		elsif rising_edge(clk) then
			aux1 := unsigned(int);
			if cntr mod 2=0 then
				bin_dv <= '1';
				aux1 := aux1 rol bin_di'length;
			else
				ena <= '1';
				bin_dv <= '0';
			end if;
			bin_di <= std_logic_vector(aux1(bin_di'range));
			int <= std_logic_vector(aux1);

			if cntr mod 2=0 then
				bcd_dv <= '1';
			else
				bcd_dv <= '1';
			end if;
			aux := unsigned(conv);
			aux(bcd_do'range) := unsigned(bcd_do);
			aux := aux rol bcd_do'length;
			if ena='1' then
				conv <= std_logic_vector(aux);
			end if;

			cntr <= cntr + 1;
		end if;
	end process;
--	bcd_di <= conv(16-1 downto 8);
	bcd_di <= x"01" when cntr =1 else x"40";


	du : entity hdl4fpga.ftod
	generic map (
		fracbin_size => 4,
		fracbcd_size => 4)
	port map (
		clk  => clk,
		bin  => x"0f1",
		bcd  => bcd);

end;
