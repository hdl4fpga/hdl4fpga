--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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
	constant N : natural := 16;
	constant M : natural := 2;
	
	subtype dataT is std_ulogic_vector(0 to (2**M-1)*N-1);
	type data_vectorT is array (natural range <>) of dataT;
	constant dataLowC   : data_vectorT(0 to 0) := (
		others => X"ffff" & X"fffe" & X"fffe");
	constant dataLowP2C : data_vectorT(0 to 0) := (
		others => X"0000" & X"ffff" & X"ffff");

	constant dataHighC   : data_vectorT(0 to 0) := (
		others => X"ffff" & X"aaaa" & X"bbbb");
	constant dataHighP2C : data_vectorT(0 to 0) := (
		others => X"0000" & X"0000" & X"bbbc");

	constant cyC : std_ulogic_vector(2*M-1 downto 0) := ('1', '0', '0', '0');
	type selT is array (natural range <>) of std_ulogic_vector(M-1 downto 0);
	constant selC : selT := ("00", "11", "01", "00", "00", "00", "00", "01", "00", "00", "00");
		
	signal rstS : std_ulogic := '0';
	signal clkS : std_ulogic := '0';
	signal enaLowS  : std_ulogic := '0';
	signal selLowS  : std_ulogic_vector(M-1 downto 0);
	signal dataLowS   : dataT;
	signal dataLowP2S : dataT;
	signal dataHighS   : dataT;
	signal dataHighP2S : dataT;
	signal qLowS  : std_ulogic_vector (N-1 downto 0);
	signal qHighS : std_ulogic_vector (N-1 downto 0);

	component MultLdCntr
		port (
			rst : in std_ulogic;
			clk : in std_ulogic;
			enaSel : in std_ulogic;
			ena : in std_ulogic;
			sel : in std_ulogic_vector;
			data   : in std_ulogic_vector;
			dataP2 : in std_ulogic_vector;
			q  : out std_ulogic_vector;
			cy : out std_ulogic := '0');
	end component;
			
	signal ldHigh  : std_ulogic;
	signal enaHigh : std_ulogic;
	signal enaSelHigh : std_ulogic;
	signal selHigh : std_ulogic_vector(M-1 downto 0);
	signal cy : std_ulogic;
	signal disCy   : std_ulogic;
	signal cyDelay : std_ulogic_vector(0 to 1);
begin
	rstS <= '1', '0' after 30 ns;
	clkS <= not clkS after 20 ns;
	enaLowS <= '1';
	dataLowS   <= dataLowC(0);
	dataLowP2S <= dataLowP2C(0);
	dataHighS   <= dataHighC(0);
	dataHighP2S <= dataHighP2C(0);
	
	pcLow : MultLdCntr
		port map (
			rst => rstS,
			clk => clkS,
			enaSel => enaLowS,
			ena => enaLowS,
			sel => selLowS,
			data   => dataLowS,
			dataP2 => dataLowP2S,
			q   => qLowS,
			cy  => cy);

	process (clkS)
	begin
		if rising_edge(clkS) then
			selHigh <= selLowS;
			ldHigh  <= enaSelHigh;

			if selLowS /= (selLowS'range => '0') then
				enaSelHigh <= '1';
			else
				enaSelHigh <= '0';
			end if;

			disCy   <= not cyDelay(1);
			cyDelay <= cyC(TO_INTEGER(UNSIGNED(selHigh))) & cyDelay(0);
		end if;
	end process;

	enaHigh <= ((cy and disCy) or ldHigh) or cyDelay(1);

	pcHigh : MultLdCntr
		port map (
			rst => rstS,
			clk => clkS,
			enaSel => enaSelHigh,
			ena => enaHigh,
			sel => selHigh,
			data   => dataHighS,
			dataP2 => dataHighP2S,
			q   => qHighS,
			cy  => open);

	process
		variable step : natural := 0;
	begin
		if rstS = '1' then
			selLowS <= (others => '0');
		elsif clkS = '1' then
			selLowS <= selC(step);
			step := step + 1;
			if step > selC'high then
				wait;
			end if;
		end if;

		wait on clkS,rstS;
	end process;
end;
