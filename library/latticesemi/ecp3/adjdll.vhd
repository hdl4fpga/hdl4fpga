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

entity adjdll is
	port (
		rst  : in std_logic;
		sclk : in std_logic;
		eclk : in std_logic;
		synceclk : out std_logic;
		okt : out std_logic;
		pha  : out std_logic_vector);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdll is

	signal ok : std_logic;
	signal adj_rdy : std_logic;
	signal adj_req : std_logic;

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;
	signal eclksynca_rst  : std_logic;

	signal ph : unsigned(0 to pha'length-1);
	signal nextdg_rdy : std_logic;
	signal smp_req : std_logic;

begin

	adj_req <= not rst;
	okt <= ok;
	process (sclk)
		variable cntr : unsigned(0 to 3);
	begin
		if rising_edge(sclk) then
			if smp_req='0' then
				cntr := (others => '0');
			elsif nextdg_rdy='1' then
				cntr := (others => '0');
			elsif cntr(0)='0' then
				cntr := cntr + 1;
			end if;
			nextdg_rdy <= cntr(0);
		end if;
	end process;

	seclk_b : block
	begin
		ok_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => eclk,
			q   => ok);
	end block;
	
	process(sclk)
		variable dg  : unsigned(0 to pha'length+1);
		variable aux : unsigned(ph'range);
	begin
		if rising_edge(sclk) then
			if adj_req='0' then
				ph  <= (others => '0');
				dg  := (0 => '1', others => '0');
				smp_req  <= '0';
				adj_rdy  <= '0';
			else
				if dg(dg'right)='0' then
					if nextdg_rdy='1' then
						aux := ph or dg(0 to aux'length-1);
						if ok='1' then
							aux := aux and not dg(1 to aux'length);
						end if;
						ph <= aux;
						smp_req <= '0';
						dg := dg srl 1;
					else
						smp_req <= '1';
					end if;
				else
					smp_req <= '0';
				end if;
				adj_rdy  <= dg(dg'right);
			end if;
		end if;
	end process;

	process (sclk, rst)
		variable pll_rdy : unsigned(0 to 4-1);
	begin
		if rst='1' then
			pha <= (pha'range => '0');
			pll_rdy := (others => '1');
		elsif rising_edge(sclk) then
			pha <= std_logic_vector(ph);
			pll_rdy := pll_rdy(1 to pll_rdy'right) & not adj_rdy;
			if adj_rdy='1' then
				pha <= std_logic_vector(ph-1);
			end if;
		end if;
		eclksynca_rst <= pll_rdy(0);
	end process;

	process (eclksynca_rst, eclk)
		variable q : std_logic_vector(0 to 1);
	begin
		if eclksynca_rst='1' then
			q := (others => '1');
		elsif falling_edge(eclk) then
			q := q(1 to q'right) & '0';
		end if;
		eclksynca_stop <= q(0);
	end process;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);
	synceclk <= eclksynca_eclk;

end;
