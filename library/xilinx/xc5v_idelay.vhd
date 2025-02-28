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

entity xc5v_idelay is
	generic (
		delay_src      : string := "I";
		signal_pattern : string := "DATA");
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture def of xc5v_idelay is

	signal ce   : std_logic;
	signal inc  : std_logic;
	signal irst : std_logic;
	signal del  : std_logic_vector(delay'range);
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			irst <= rst;
		end if;
	end process;

	del <= to_stdlogicvector(to_bitvector(delay));
	adjser_i : entity hdl4fpga.adjser
	generic map (
		tap_value => 0)
	port map (
		clk   => clk,
		rst   => irst,
		delay => del,
		ce    => ce,
		inc   => inc);

	idelay_i : iodelay
	generic map (
		delay_src      => delay_src,
		signal_pattern => signal_pattern,
		idelay_value => 0,
		idelay_type  => "VARIABLE")
	port map (
		c    => clk,
		rst  => irst,
		ce   => ce,
		inc  => inc,
		t => '1',
		odatain => '0',
		datain  => '0',
		idatain => idatain,
		dataout => dataout);
end;



