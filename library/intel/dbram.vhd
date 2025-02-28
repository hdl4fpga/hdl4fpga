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

entity dbram is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
end;

library hdl4fpga;

architecture intel of dbram is
begin
	dram_p : process (ra, clk)
		type ram16x4 is array(0 to 2**wa'length-1) of std_logic_vector(di'range);
		variable ram : ram16x4;
	begin
		if rising_edge(clk) then
			if we='1' then
				ram(to_integer(unsigned(wa))) := di;
			end if;
		end if;
		do <= ram(to_integer(unsigned(ra)));
	end process;

	-- ram_e : entity hdl4fpga.dpram 
	-- generic map (
		-- synchronous_rdaddr => false,
		-- synchronous_rddata => false)
	-- port map (
		-- rd_clk  => clk,
		-- rd_addr => ra,
		-- rd_data => do,
-- 
		-- wr_clk  => clk,
		-- wr_ena  => we,
		-- wr_addr => wa,
		-- wr_data => di);
end;


