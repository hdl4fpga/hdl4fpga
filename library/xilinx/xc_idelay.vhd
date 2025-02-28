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
use hdl4fpga.profiles.all;

entity xc_idelay is
	generic (
		device         : fpga_devices;
		signal_pattern : string);
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of xc_idelay is
begin
	xc5v_g : if device=xc5v generate
		idelay_i : entity hdl4fpga.xc5v_idelay
		generic map (
			delay_src      => string'("I"),
			signal_pattern => signal_pattern)
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => idatain,
			dataout => dataout);
	end generate;

	xc7a_g : if device=xc7a generate
		idelay_i : entity hdl4fpga.xc7a_idelay
		generic map (
			delay_src      => "IDATAIN",
			signal_pattern => signal_pattern)
		port map (
			rst     => rst,
			clk     => clk,
			delay   => delay,
			idatain => idatain,
			dataout => dataout);
	end generate;
end;


