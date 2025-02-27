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
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrtrigger is
	port (
		rgtr_clk        : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_oneshot : out std_logic;
		trigger_chanid  : buffer std_logic_vector;
		trigger_level   : buffer std_logic_vector;
		trigger_slope   : out std_logic);
end;

architecture def of scopeio_rgtrtrigger is
begin
	trigger_dv      <= rgtr_dv when rgtr_id=rid_trigger else '0';
	trigger_freeze  <= bitfield(rgtr_data, hdo(trigger_fields)**".freeze");
	trigger_slope   <= bitfield(rgtr_data, hdo(trigger_fields)**".slope");
	trigger_oneshot <= bitfield(rgtr_data, hdo(trigger_fields)**".oneshot");
	trigger_level   <= std_logic_vector(resize(unsigned(std_logic_vector'(bitfield(rgtr_data, hdo(trigger_fields)**".level"))),  trigger_level'length));
	trigger_chanid  <= std_logic_vector(resize(unsigned(std_logic_vector'(bitfield(rgtr_data, hdo(trigger_fields)**".chanid"))), trigger_chanid'length));
end;
