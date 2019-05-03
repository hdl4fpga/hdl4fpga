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

architecture scopeio_formatu of testbench is

	signal rst      : std_logic := '0';
	signal clk      : std_logic := '0';
	signal frm      : std_logic;
	signal irdy     : std_logic;
	signal trdy     : std_logic;
	signal wu_frm   : std_logic;
	signal wu_irdy  : std_logic;
	signal wu_trdy  : std_logic;
	signal wu_value : std_logic_vector(4*4-1 downto 0);
	signal value    : std_logic_vector(3*4-1 downto 0);
	signal format   : std_logic_vector(0 to 8*4-1);

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk after 10 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				frm  <= '0';
			else
				frm <= '1';
			end if;
		end if;
	end process;

	irdy <= frm;
	ticks_e : entity hdl4fpga.scopeio_ticks
	port map (
		clk      => clk,
		frm      => frm,
		irdy     => irdy,
		trdy     => trdy,
		base     => x"000",
		step     => x"019",
		last     => x"005",
		wu_frm   => wu_frm,
		wu_irdy  => wu_irdy,
		wu_trdy  => wu_trdy,
		wu_value => value);
	
	wu_value <= value & x"f";

	du : entity hdl4fpga.scopeio_formatu
	port map (
		clk    => clk,
		frm    => wu_frm,
		irdy   => wu_irdy,
		trdy   => wu_trdy,
		width  => b"1000",
		unit   => b"0000",
		sign   => '0',
		neg    => '0',
		align  => '1',
		prec   => b"1111",
		float  => wu_value,
		format => format);

end;
