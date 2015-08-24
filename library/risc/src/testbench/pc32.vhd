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

entity testbench is
end;

architecture behavioral of testbench is
	constant N : natural := 6;
	constant M : natural := 2;
	
	constant dataC : std_ulogic_vector := (
		o"76" & o"36" & o"15");
--		X"ffff_fffa" & X"aaaa_fffe" & X"bbbb_fffd");
	constant dataP2C : std_ulogic_vector := (
		o"07" & o"47" & o"16");
--		X"ffff_fffb" & X"0000_ffff" & X"bbbb_fffe");

	type selDataT is array (natural range <>) of std_ulogic_vector(M-1 downto 0);
	constant selDataC : selDataT := (
		"00", "00", "11", "10", "00", "00", "10", "00", "00", "00", "00");
		
	signal rstS : std_ulogic := '0';
	signal clkS : std_ulogic := '0';
	signal enaS : std_ulogic := '1';
	signal enaSelS : std_ulogic := '1';
	signal selDataS : std_ulogic_vector(M-1 downto 0);
	signal dataS   : std_ulogic_vector(dataC'range);
	signal dataP2S : std_ulogic_vector(dataP2C'range);
	signal qDelayS : std_ulogic_vector(N-1 downto 0);
	signal qS   : std_ulogic_vector (N-1 downto 0);

	component PC32
		generic (
			N : natural;
			M : natural);
		port (
			rst : in std_ulogic;
			clk : in std_ulogic;
			ena : in std_ulogic;
			enaSel : in std_ulogic;
			selData : in std_ulogic_vector;
			data   : in std_ulogic_vector;
			dataP2 : in std_ulogic_vector;
			q  : out std_ulogic_vector;
			cy : out std_ulogic);
	end component;
			
begin
	rstS <= '1', '0' after 30 ns;
	clkS <= not clkS after 20 ns;
	dataS  <= dataC;
	dataP2S <= dataP2C;
	
	pc : PC32
		generic map (
			N => N,
			M => M)
		port map (
			rst => rstS,
			clk => clkS,
			ena => enaS,
			enaSel => enaSelS,
			selData => selDataS,
			data   => dataS,
			dataP2 => dataP2S,
			q   => qS,
			cy  => open);

	process (clkS)
	begin
		if rising_edge(clkS) then
			qDelayS(N/2-1 downto 0) <= qS(N/2-1 downto 0);
		end if;
	end process;
	qDelayS(N-1 downto N/2) <= qS(N-1 downto N/2);

	process
		variable step : natural := 0;
	begin
		if rstS = '1' then
			selDataS <= (others => '0');
		elsif clkS = '1' then
			selDataS <= selDataC(step);
			step := step + 1;
			if step > selDataC'high then
				wait;
			end if;
		end if;

		wait on clkS,rstS;
	end process;
end;
