-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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


