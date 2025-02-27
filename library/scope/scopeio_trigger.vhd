-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_trigger is
	generic (
		inputs           : natural);
	port (
		input_clk        : in  std_logic;
		input_dv         : in  std_logic;
		input_data       : in  std_logic_vector;
		trigger_chanid   : in  std_logic_vector;
		trigger_slope    : in  std_logic;
		trigger_level    : in  std_logic_vector;
		trigger_shot     : out std_logic);

end;

architecture beh of scopeio_trigger is
begin

	shot_p : process (input_clk)
		variable sample : signed(input_data'length/inputs-1 downto 0);
		variable shot   : std_logic;
		variable ge     : std_logic;
		variable lt     : std_logic;
		variable edge   : std_logic;
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				shot   := (lt and ge and not edge) or (not lt and not ge and edge);
				lt     := not ge;
				ge     := setif(sample >= signed(trigger_level));
				edge   := not trigger_slope;
				sample := signed(multiplex(input_data, trigger_chanid, sample'length));
				trigger_shot <= shot;
			end if;
		end if;
	end process;

end;
