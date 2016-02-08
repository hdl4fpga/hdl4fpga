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

entity adjdqs is
	generic (
		tCP : natural); -- ps
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		smp : in  std_logic;
		dly : out std_logic_vector);
	constant tap_delay : natural := 27; -- tap delay ps
end;

--library ecp3;
--use ecp3.components.all;

architecture beh of adjdqs is
	constant num_of_taps  : natural := tCP/tap_delay;
	constant num_of_steps : natural := unsigned_num_bits(num_of_taps);
	subtype gap_word is unsigned(num_of_steps downto 0);
	type gword_vector is array(natural range <>) of gap_word;

	function create_gaps (
		constant num_of_taps : natural;
		constant num_of_steps : natural)
		return gword_vector is
		variable val : gword_vector(2**unsigned_num_bits(num_of_steps-1)+1 downto 0);
		variable aux : natural;
	begin
		val := (others => (others => '-'));
		val(num_of_steps) := to_unsigned(2**num_of_steps, gap_word'length);
		aux := num_of_steps;
		for i in num_of_steps downto 1 loop
			val(i) := to_unsigned(aux/2, gap_word'length);
			aux := (aux+1)/2;
		end loop;
		val(val'high) := (others => '0');
		return val;
	end;

	constant gaptab : gword_vector := create_gaps(num_of_taps, num_of_steps);

	signal pha : gap_word;
	signal phb : gap_word;
	signal phc : gap_word;
	signal dly0 : std_logic_vector(dly'length-1 downto 0);

begin

	phc <= pha when smp='1' else phb;
	process(clk)
		variable step : unsigned(0 to unsigned_num_bits(num_of_steps-1));
	begin
		if rising_edge(clk) then
			if req='0' then
				step := to_unsigned(num_of_steps, step'length);
			elsif step(0)='1' then
				if smp='1' then
					phb <= pha;
				end if;
				pha  <= phc + gaptab(to_integer(step(1 to step'right)));
				step := step - 1;
			end if;
		end if;
	end process;
	dly0(dly0'left) <= pha(pha'left);
	dly0(dly0'left-1 downto 0) <= std_logic_vector(resize(pha(pha'left-1 downto 0), dly'length-1));


end;
