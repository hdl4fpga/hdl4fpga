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

library hdl4fpga;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

package alt_profiles is

	type pll_record is record
		m     : natural;
		n     : natural;
		c0_pw : natural;
		c1_pw : natural;
		c2_pw : natural;
	end record;

	type video_record is record
		id     : video_modes;
		pll    : pll_record;
		timing : videotiming_ids;
		pixel  : pixel_types;
		gear   : natural;
	end record;

	type videoparams_vector is array (natural range <>) of video_record;
	constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio
	function videoparam (
		constant video_id : video_modes;
		constant clk_ref  : real)
		return video_record;

end package;

package body alt_profiles is

	-- video_clk       = (clk_ref*m/(2*n*c0_pw)
	-- video_shift_clk = (clk_ref*m/(2*n*c1_pw)
	-- videoio_clk     = (clk_ref*m/(2*n*c2_p)
	-- c0_pw      = clkop_div*video_ratio
	constant acyiibvideo_tab : videoparams_vector := (
		-- (id => modedebug,        pll => (m => 25, clkop_div => 5, n => 1, c0_pw => video_ratio*5, c2_pw => 16), gear => 2, pixel => rgb888, timing => pclk_debug),
		(id => modedebug,     pll => (m => 80, c1_pw => 1, n => 3, c0_pw => video_ratio*1, c2_pw => 17), gear => 2, pixel => rgb888, timing => pclk_debug),
		(id => mode600p16bpp, pll => (m => 16, c1_pw => 2, n => 1, c0_pw => video_ratio*2, c2_pw => 10), gear => 2, pixel => rgb565, timing => pclk40_00m800x600at60),
		(id => mode600p24bpp, pll => (m => 16, c1_pw => 2, n => 1, c0_pw => video_ratio*2, c2_pw => 10), gear => 2, pixel => rgb888, timing => pclk40_00m800x600at60));

	function videoparam (
		constant video_id : video_modes;
		constant clk_ref  : real)
		return video_record is
		variable retval : video_record;
	begin
		if clk_ref=50.0e6 then
			for i in acyiibvideo_tab'range loop
				if video_id=acyiibvideo_tab(i).id then
					return acyiibvideo_tab(i);
				end if;
			end loop;
			retval := acyiibvideo_tab(acyiibvideo_tab'left);
		end if;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return retval;
	end;

end package body;
