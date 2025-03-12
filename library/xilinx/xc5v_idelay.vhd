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

entity xc5v_idelay is
	generic (
		delay_src      : string := "I";
		signal_pattern : string := "DATA");
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture def of xc5v_idelay is

	signal ce   : std_logic;
	signal inc  : std_logic;
	signal irst : std_logic;
	signal del  : std_logic_vector(delay'range);
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			irst <= rst;
		end if;
	end process;

	del <= to_stdlogicvector(to_bitvector(delay));
	adjser_i : entity hdl4fpga.adjser
	generic map (
		tap_value => 0)
	port map (
		clk   => clk,
		rst   => irst,
		delay => del,
		ce    => ce,
		inc   => inc);

	idelay_i : iodelay
	generic map (
		delay_src      => delay_src,
		signal_pattern => signal_pattern,
		idelay_value => 0,
		idelay_type  => "VARIABLE")
	port map (
		c    => clk,
		rst  => irst,
		ce   => ce,
		inc  => inc,
		t => '1',
		odatain => '0',
		datain  => '0',
		idatain => idatain,
		dataout => dataout);
end;