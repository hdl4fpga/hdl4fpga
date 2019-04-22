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

entity scopeio_writeu is
	port (
		clk    : in  std_logic;
		frm    : in  std_logic;
		irdy   : in  std_logic := '1';
		trdy   : out std_logic;
		float  : in  std_logic_vector;
		width  : in  std_logic_vector := b"1000";
		unit   : in  std_logic_vector := b"0000";
		prec   : in  std_logic_vector := b"1101";
		format : out std_logic_vector);
end;

architecture def of scopeio_writeu is
	signal ser_irdy : std_logic;
	signal ser_trdy : std_logic;
	signal ser_data : std_logic_vector(4-1 downto 0);
	signal flt      : std_logic := '0';
	signal bcd_irdy : std_logic;
	signal bcd_end  : std_logic;
	signal bcd_do   : std_logic_vector(4-1 downto 0);
begin


	pll2ser_e : entity hdl4fpga.pll2ser
	port map (
		clk      => clk,
		frm      => frm,
		pll_irdy => irdy,
		pll_trdy => open,
		pll_data => float,
		ser_trdy => ser_trdy,
		ser_irdy => ser_irdy,
		ser_last => flt,
		ser_data => ser_data);

	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		frm       => frm,
		bin_irdy  => ser_irdy,
		bin_trdy  => ser_trdy,
		bin_di    => ser_data,
		bin_flt   => flt,
		bcd_width => width,
		bcd_unit  => unit,
		bcd_prec  => prec,
		bcd_irdy  => bcd_irdy,
		bcd_end   => bcd_end,
		bcd_do    => bcd_do);

	ser2pll_e : entity hdl4fpga.ser2pll
	port map(
		clk      => clk,
		ser_irdy => bcd_irdy,
		ser_data => bcd_do,
		pll_data => format);

	process (clk)
	begin
		if rising_edge(clk) then
			if frm='0' then
				trdy <= '0';
			else
				trdy <= bcd_end and bcd_irdy;
			end if;
		end if;
	end process;
end;
