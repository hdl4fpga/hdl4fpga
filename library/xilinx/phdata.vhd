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

entity phdata is
	generic (
		data_width0   : natural := 1;
		data_width90  : natural := 1;
		data_width180 : natural := 1;
		data_width270 : natural := 1);
	port (
		clk0   : in  std_logic := '-';
		clk270 : in  std_logic := '-';
		di0    : in  std_logic_vector(data_width0-1   downto 0) := (others => '-');
		di90   : in  std_logic_vector(data_width90-1  downto 0) := (others => '-');
		di180  : in  std_logic_vector(data_width180-1 downto 0) := (others => '-');
		di270  : in  std_logic_vector(data_width270-1 downto 0) := (others => '-');
		do0    : out std_logic_vector(data_width0-1   downto 0);
		do90   : out std_logic_vector(data_width90-1  downto 0);
		do180  : out std_logic_vector(data_width180-1 downto 0) := (others => '-');
		do270  : out std_logic_vector(data_width270-1 downto 0));
end;

architecture inference of phdata is

	signal cntr    : unsigned(4-1 downto 0);
	signal cntr0   : unsigned(cntr'range);
	signal cntr90  : unsigned(cntr'range);
	signal cntr180 : unsigned(cntr'range);
	signal cntr270 : unsigned(cntr'range);

	type mem0   is array (natural range <>) of std_logic_vector(di0'range);
	type mem90  is array (natural range <>) of std_logic_vector(di90'range);
	type mem180 is array (natural range <>) of std_logic_vector(di180'range);
	type mem270 is array (natural range <>) of std_logic_vector(di270'range);

	signal ram0   : mem0(0 to 2**cntr'length-1);
	signal ram90  : mem90(0 to 2**cntr'length-1);
	signal ram180 : mem180(0 to 2**cntr'length-1);
	signal ram270 : mem270(0 to 2**cntr'length-1);

begin
	
	process (clk0)
	begin
		if rising_edge(clk0) then
			cntr0 <= cntr;
			cntr  <= unsigned(to_stdlogicvector(to_bitvector(std_logic_vector(cntr)))) + 1;
		end if;
		if falling_edge(clk0) then
			cntr180 <= cntr270 + 1; 
		end if;
	end process;

	process (clk270)
	begin
		if rising_edge(clk270) then
			cntr270 <= cntr - 1;
		end if;
		if falling_edge(clk270) then
			cntr90 <= cntr180 + 1;
		end if;
	end process;

	process (clk0)
	begin
		if rising_edge(clk0) then
			ram0(to_integer(cntr))   <= di0;
			ram90(to_integer(cntr))  <= di90;
			ram180(to_integer(cntr)) <= di180;
			ram270(to_integer(cntr)) <= di270;
		end if;
	end process;

	do0   <= ram0(to_integer(cntr0));
	do90  <= ram90(to_integer(cntr90));
	do180 <= ram180(to_integer(cntr180));
	do270 <= ram270(to_integer(cntr270));

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g4_phdata is
	generic (
		data_width270 : natural := 1);
	port (
		clk0   : in  std_logic := '-';
		clk270 : in  std_logic := '-';
		di270  : in  std_logic_vector(data_width270-1 downto 0) := (others => '-');
		do270  : out std_logic_vector(data_width270-1 downto 0));
end;

architecture inference of g4_phdata is

begin
	
	-- mem_b : block
		-- signal cntr    : unsigned(4-1 downto 0);
		-- signal cntr270 : unsigned(4-1 downto 0);
	-- 
		-- type mem270 is array (natural range <>) of std_logic_vector(di270'range);
	-- 
		-- signal ram270 : mem270(0 to 2**cntr'length-1);
-- 
	-- begin
    	-- process (clk0, clk270)
    	-- begin
    		-- if rising_edge(clk0) then
    			-- cntr  <= unsigned(to_stdlogicvector(to_bitvector(std_logic_vector(cntr)))) + 1;
    		-- end if;
    		-- if rising_edge(clk270) then
    			-- cntr270 <= cntr;
    		-- end if;
    	-- end process;
    -- 
    	-- process (clk0)
    	-- begin
    		-- if rising_edge(clk0) then
    			-- ram270(to_integer(cntr)) <= di270;
    		-- end if;
    	-- end process;
	-- end block;

	process (clk270)
	begin
		if rising_edge(clk270) then
			do270 <= di270;
		end if;
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g4_phdata270 is
	generic (
		data_width0 : natural := 1);
	port (
		clk270 : in  std_logic := '-';
		clk0   : in  std_logic := '-';
		di0  : in  std_logic_vector(data_width0-1 downto 0) := (others => '-');
		do0  : out std_logic_vector(data_width0-1 downto 0));
end;

architecture inference of g4_phdata270 is

	signal cntr    : unsigned(4-1 downto 0);
	signal cntr270 : unsigned(4-1 downto 0);

	type mem0 is array (natural range <>) of std_logic_vector(di0'range);

	signal ram0 : mem0(0 to 2**cntr'length-1);

begin
	
	process (clk0, clk270)
	begin
		if rising_edge(clk0) then
			cntr  <= unsigned(to_stdlogicvector(to_bitvector(std_logic_vector(cntr)))) + 1;
		end if;
		if rising_edge(clk270) then
			cntr270 <= cntr + 2 ;
		end if;
	end process;

	process (clk270)
	begin
		if rising_edge(clk270) then
			ram0(to_integer(cntr270)) <= di0;
		end if;
	end process;

	do0 <= ram0(to_integer(cntr));

end;