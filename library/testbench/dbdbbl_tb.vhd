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

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_tb of testbench is
	signal bcd : std_logic_vector(5*4-1 downto 0);
begin
	du_e : entity hdl4fpga.dbdbbl
	port map (
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		report to_string(bcd);
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_seq_tb of testbench is
	signal clk : std_logic := '0';
	signal ld  : std_logic := '1';
	signal nxt : std_logic := '0';
	signal ena : std_logic := '1';
	signal bin : std_logic_vector(3-1 downto 0);
	constant bcd_length : natural := 4;
	constant dgs : natural := 1;
	signal bcd : std_logic_vector(bcd_length*dgs*((5+dgs-1)/dgs)-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
		variable xxx : unsigned(0 to 15-1) := to_unsigned(32065,15);
	begin
		if rising_edge(clk) then
			if ld='1' then
				ld <= '0';
				xxx := xxx sll bin'length;
			elsif nxt='1' then
				xxx := xxx sll bin'length;
			end if;
		end if;
		bin <= std_logic_vector(xxx(0 to bin'length-1));
	end process;

	du_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		dgs => dgs)
	port map (
		clk => clk,
		ena => ena,
		ld  => ld,
		rdy => nxt,
		nxt => nxt,
		ini => x"00000",
		bin => bin, -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		report to_string(bcd);
	end process;

end;