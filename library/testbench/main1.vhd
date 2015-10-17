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

architecture main1 of testbench is

	impure function pulse_delay (
		constant phase     : std_logic_vector;
		constant latency   : natural := 12;
		constant extension : natural := 4;
		constant word_size : natural := 4;
		constant width     : natural := 3)
		return std_logic_vector is
	
		variable latency_mod : natural;
		variable latency_quo : natural;
		variable delay : natural;
		variable pulse : std_logic;

		variable distance : natural;
		variable width_quo : natural;
		variable width_mod : natural;
		variable tail : natural;
		variable tail_quo : natural;
		variable tail_mod : natural;
		variable pulses : std_logic_vector(0 to word_size-1);
	begin

		latency_mod := latency mod pulses'length;
		latency_quo := latency  /  pulses'length;
		for j in pulses'range loop
			distance  := (extension-j+pulses'length-1)/pulses'length;
			width_quo := (distance+width-1)/width;
			width_mod := (width_quo*width-distance) mod width;

			delay := latency_quo+(j+latency_mod)/pulses'length;
			pulse := phase(delay);


			if width_quo /= 0 then
				tail_quo := width_mod  /  width_quo;
				tail_mod := width_mod mod width_quo;
				for l in 1 to width_quo loop
					tail  := tail_quo + (l*tail_mod) / width_quo;
					pulse := pulse or phase(delay+l*width-tail);
				end loop;
			end if;
			pulses((latency+j) mod pulses'length) := pulse;
		end loop;
		return pulses;
	end;

	subtype word is std_logic_vector(0 to 4);

	signal ph : std_logic_vector(0 to 10) := (others => '0');
	signal pulse : std_logic := '0';
	signal ppp : word;
	signal clk : std_logic := '0';

begin

	clk <= not clk after 10 ns;
	process (clk)
		variable pw : natural;
	begin
		if rising_edge(clk) then
			ph <= pulse & ph(0 to ph'right-1);
			if pw = 0 then
				pulse <= not pulse;
				if pulse='0' then
					pw := 1-1;
				else
					pw := 5-1;
				end if;
			else
				pw := pw -1;
			end if;
		end if;
	end process;

	ppp <= pulse_delay(
		phase     => ph,
		latency   => 11,
		extension => 7,
		word_size => word'length,
		width     => 1);

end;
