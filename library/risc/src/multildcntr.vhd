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

-- Date   : November 2007
-- Author : Miguel Angel Sagreras

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MultiLdCntr is
	port (
		rst : in std_ulogic;
		clk : in std_ulogic;
		ena : in std_ulogic;
		enaSel : in std_ulogic;
		sel : in std_ulogic_vector; -- (2-1 downto 0);
		data   : in std_ulogic_vector; -- ((2**2-1)*16-1 downto 0);
		dataP2 : in std_ulogic_vector; -- ((2**2-1)*16-1 downto 0);
		q   : out std_ulogic_vector; -- (16-1 downto 0);
		cy  : out std_ulogic);
end;

architecture Mixed of MultiLdCntr is
	signal dataLH : std_ulogic_vector(q'range);
	signal ldData : std_ulogic;
	signal selP2  : std_ulogic;
	signal selData : std_ulogic_vector (sel'range);

	component PipeCntr
		port (
			rst : in  std_ulogic;
			clk : in  std_ulogic;
			ena : in  std_ulogic;
			ldData : in  std_ulogic;
			data   : in  std_ulogic_vector;
			q   : out std_ulogic_vector;
			cy  : out std_ulogic);
	end component;

begin
	cntr : PipeCntr 
		port map (
			rst => rst,
			clk => clk,
			ena => ena,
			ldData => ldData,
			data   => dataLH,
			q   => q,
			cy  => cy);
			
	mux : process (selP2, selData, data, dataP2)
	begin
		dataLH <= (others => '-');		-- quartus complain if it is not placed
		for i in 0 to 2**selData'length-1 loop
			if i=TO_INTEGER(UNSIGNED(selData)) then
				if i=0 then
					dataLH <= (dataLH'range => '0');
				else
					if selP2='1' then
						dataLH <= data(q'length*(i+1)-1 downto q'length*i);
					else 
						dataLH <= dataP2(q'length*(i+1)-1 downto q'length*i);
					end if;
				end if;
			end if;
		end loop;
	end process;

	process (rst, clk)
	begin
		if rst='1' then
			ldData <= '0';
			selP2  <= '0';
			selData <= (others => '0');
		elsif rising_edge(clk) then
			if ena='1' and enaSel='0' then
				if selP2 = '1' then
					selP2   <= '0';
				else
					ldData <= '0';
					selP2  <= '0';
					selData <= sel;
				end if;
			elsif ena='1' and enaSel='1' then
				if sel /= (sel'range => '0') then
					ldData <= '1';
					selP2  <= '1';
					selData <= sel;
				elsif selP2 = '1' then
					selP2 <= '0';
				else
					ldData <= '0';
					selP2  <= '0';
					selData <= sel;
				end if;
			elsif ena='0' and enaSel='1' then 
				if sel /= (sel'range => '0') then
					ldData <= '1';
					selP2  <= '1';
					selData <= sel;
				end if;
			end if;
		end if;
	end process;
end;
