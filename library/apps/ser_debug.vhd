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
use hdl4fpga.hdo.all;
use hdl4fpga.videopkg.all;

library ieee;
use ieee.std_logic_1164.all;

entity ser_debug is
	generic (
		settings      : string);
	port (
		ser_clk       : in  std_logic;
		ser_frm       : in  std_logic;
		ser_irdy      : in  std_logic;
		ser_data      : in  std_logic_vector;
		
		video_clk     : in  std_logic;
		video_shift_clk :  in std_logic := '-';
		video_hzsync  : buffer std_logic;
		video_vtsync  : buffer std_logic;
		video_blank   : buffer std_logic;
		video_pixel   : buffer std_logic_vector;
		dvid_crgb     : out std_logic_vector(4*hdo(settings)**".gear=2"-1 downto 0));

	constant video_gear   : natural := hdo(settings)**".gear=2";
	constant red_length   : natural := hdo(settings)**".pixel.R=8";
	constant green_length : natural := hdo(settings)**".pixel.G=8";
	constant blue_length  : natural := hdo(settings)**".pixel.B=8";

end;

architecture def of ser_debug is
	signal video_on   : std_logic;
	signal video_dot  : std_logic;
	signal dvid_blank : std_logic;
	signal rgb        : std_logic_vector(0 to 3*8-1) := (others => '0');
begin

	assert false
		report "entity ser_debug : settings : " & settings
		severity note;

	ser_display_e : entity hdl4fpga.ser_display
	generic map (
		code_spce   => to_ascii(" "),
		code_digits => to_ascii("0123456789abcdef"),
		cga_bitrom  => to_ascii("Ready Steady GO!"),
		timings =>  hdo(settings)**".timings")
	port map (
		phy_clk     => ser_clk,
		phy_frm     => ser_frm,
		phy_irdy    => ser_irdy,
		phy_data    => ser_data,

		video_clk   => video_clk, 
		video_dot   => video_dot,
		video_on    => video_on,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync);

	video_blank <= not video_on;

	-- VGA --
	---------

	video_pixel <= (video_pixel'range => video_dot);
	process (video_pixel)
		variable urgb  : unsigned(0 to 3*8-1);
		variable pixel : unsigned(0 to video_pixel'length-1);
	begin
		pixel := unsigned(video_pixel);

		urgb(0 to red_length-1)  := pixel(0 to red_length-1);
		urgb  := urgb rol 8;
		pixel := pixel sll red_length;

		urgb(0 to green_length-1) := pixel(0 to green_length-1);
		urgb  := urgb rol 8;
		pixel := pixel sll green_length;

		urgb(0 to blue_length-1) := pixel(0 to blue_length-1);
		urgb  := urgb rol 8;
		pixel := pixel sll blue_length;

		rgb <= std_logic_vector(urgb);
	end process;

	dvid_blank <= video_blank;

	dvi_e : entity hdl4fpga.dvi
	generic map (
		gear => video_gear)
	port map (
		clk   => video_clk,
		rgb   => rgb,
		hsync => video_hzsync,
		vsync => video_vtsync,
		blank => dvid_blank,
		cclk  => video_shift_clk,
		chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
		chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
		chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
		chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

end;
