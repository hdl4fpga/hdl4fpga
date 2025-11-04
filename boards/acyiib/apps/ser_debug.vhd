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
use hdl4fpga.hdo.all;

architecture ser_debug of acyiib is

	constant settings : string := "{"                                                      &
		"io_link: io_ipoe,"                                                                &
		"video:{"                                                                          &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'640x400'.'@60'.'25mhz'") & ',' &
			"pixel:"   & "{R:1,G:1,B:1}}}";

	signal video_clk : std_logic;
	alias video_hzsync is p1(1);
	alias video_vtsync is p1(1);

	signal video_pixel : std_logic_vector(0 to 3-1);

begin

	process (osc_50mhz)
	begin
		if rising_edge(osc_50mhz) then
			video_clk <= not video_clk;
		end if;
	end process;

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		settings => hdo(settings)**".video")
	port map (
		ser_clk      => ser_clk, 
		ser_frm      => ser_frm, 
		ser_irdy     => ser_irdy, 
		ser_data     => ser_data, 
		
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => video_blank,
		video_pixel  => video_pixel);

end;
