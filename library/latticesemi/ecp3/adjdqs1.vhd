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

entity adjdqs is
	generic (
		tCP : natural) -- ps
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		smp : in  std_logic;
		pha : out std_logic_vector);
	constant td : natural := 27; -- tap delay ps
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdqs is

	function (
		constant xxx : natural;
		constant yyy : natural)
		return natural_vector is
		variable val : natural_vector(yyy+1 downto 0);
		variable aux : natural;
	begin
		val := (others => 0);
		val(yyy) := 2**yyy;
		aux := 2;
		for i in yyy downto 1 loop
			val(i) := xxx / aux;
			aux := aux * 2;
		end loop;
	end;

	constant xxx : natural := CP/2*td;
	constant yyy : natural := unsigned_num_bits(xxx/2)-1;

	signal hld : std_logic;
	signal adj : std_logic;

begin

	process(clk)
		variable cntr : unsigned(0 to 4-1);
	begin
		if rising_edge(clk) then
			if req='0' then
				cntr := (others => '0');
			elsif adj='1' then
				cntr := (others => '0');
			elsif cntr(0)='1' then
				cntr := (others => '0');
			else
				cntr := cntr + 1;
			end if;
			hld <= cntr(0);
		end if;
	end process;

	process(clk)
		variable zzz : unsigned();
		variable pha : unsigned;
		variable phb : unsigned;
	begin
		if rising_edge(clk) then
			if req='0' then
				mph := (others => '0');
				sph := '0';
				fst := '0';
				adj <= '0';
			else
				if adj='0' then
					if hld='1' then
						if then
						if smp='1' then
							phb := pha;
							phc := pha;
						else
							phc := phb;
						end if;
						pha := phc + ph(i);
					end if;
				end if;
			end if;
		end if;
	end process;

end;
