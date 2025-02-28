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

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_grid is
	generic (
		latency : natural;
		division_size : natural);
	port (
		clk     : in  std_logic;
		ena     : in  std_logic;
		x       : in  std_logic_vector;
		y       : in  std_logic_vector;
		dot     : out std_logic);
end;

architecture def of scopeio_grid is
	constant n : natural := unsigned_num_bits(division_size-1);
	constant m : natural := max(unsigned_num_bits(division_size-1)-2, 2);

	signal hena  : std_logic;
	signal hdot  : std_logic;
	signal hmask : std_logic_vector(m-1 downto 0);
	signal vena  : std_logic;
	signal vdot  : std_logic;
	signal vmask : std_logic_vector(m-1 downto 0);
	signal hvdot : std_logic;
begin

	hena <= ena     when y(m-1 downto 0)=(m-1 downto 0 => '0') else '0';
	hmask <= (1 to m-1 => '0') & '1' when y(n-1 downto m)=(n-1 downto m => '0') else (0 to m-1 => '1');
	hzline_e : entity hdl4fpga.draw_line
	port map (
		ena  => hena,
		mask => hmask,
		x    => x(n-1 downto 0),
		dot  => hdot);

	vena  <= ena    when x(m-1 downto 0)=(m-1 downto 0 => '0') else '0';
	vmask <= (1 to m-1 => '0') & '1' when x(n-1 downto m)=(n-1 downto m => '0') else (0 to m-1 => '1');
	vtline_e : entity hdl4fpga.draw_line
	port map (
		ena  => vena,
		mask => vmask,
		x    => y(n-1 downto 0),
		dot  => vdot);

	hvdot <= vdot or hdot;
	align_e : entity hdl4fpga.latency
	generic map (
		n => 1,
		d => (0 => latency))
	port map (
		clk   => clk,
		di(0) => hvdot,
		do(0) => dot);

end;




