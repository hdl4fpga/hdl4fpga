--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.videopkg.all;

library ieee;
use ieee.std_logic_1164.all;

entity ser_debug is
	generic (
		timing_id    : videotiming_ids;
		vserlzr_size : natural := 2;
		red_length   : natural := 5;
		green_length : natural := 6;
		blue_length  : natural := 5);
	port (
		ser_clk      : in  std_logic;
		ser_frm      : in  std_logic;
		ser_irdy     : in  std_logic;
		ser_data     : in  std_logic_vector;
		
		video_clk    : in  std_logic;
		video_shift_clk :  in std_logic := '-';
		video_hzsync : buffer std_logic;
		video_vtsync : buffer std_logic;
		video_blank  : buffer std_logic;
		video_pixel  : buffer std_logic_vector;
		dvid_crgb    : out std_logic_vector(7 downto 0));
end;

architecture def of ser_debug is
	signal video_on   : std_logic;
	signal video_dot  : std_logic;
	signal dvid_blank : std_logic;
	signal red        : std_logic_vector(0 to 8-1) := (others => '1');
	signal green      : std_logic_vector(0 to 8-1) := (others => '1');
	signal blue       : std_logic_vector(0 to 8-1) := (others => '1');
begin

	ser_display_e : entity hdl4fpga.ser_display
	generic map (
		code_spce   => to_ascii(" "),
		code_digits => to_ascii("0123456789abcdef"),
		cga_bitrom  => to_ascii("Ready Steady GO!"),
		timing_id   => timing_id)
	port map (
		phy_clk     => ser_clk,
		phy_frm     => ser_frm,
		phy_irdy    => ser_irdy,
		phy_data    => ser_data,

		video_clk   => video_clk, 
		video_dot   => video_dot,
		video_on    => video_on,
		video_hs    => video_hzsync,
		video_vs    => video_vtsync);

	video_blank <= not video_on;

	-- VGA --
	---------

	dvi_b : block
	begin

		video_pixel <= (video_pixel'range => video_dot);
		process (video_pixel)
			variable pixel : unsigned(0 to video_pixel'length-1);
		begin
			-- pixel := unsigned(video_pixel);
			-- red(0 to red_length-1)  <= std_logic_vector(pixel(0 to red_length-1));
			-- pixel := pixel sll red_length;
			-- green(0 to green_length-1) <= std_logic_vector(pixel(0 to green_length-1));
			-- pixel := pixel sll green_length;
			-- blue(0 to blue_length-1) <= std_logic_vector(pixel(0 to blue_length-1));
		end process;

		dvid_blank <= video_blank;

		dvi_e : entity hdl4fpga.dvi
		generic map (
			ser_size => vserlzr_size)
		port map (
			clk   => video_clk,
			red   => b"11111111", --red,
			green => green,
			blue  => blue,
			hsync => video_hzsync,
			vsync => video_vtsync,
			blank => dvid_blank,
			cclk  => video_shift_clk,
			chnc  => dvid_crgb(vserlzr_size*4-1 downto vserlzr_size*3),
			chn2  => dvid_crgb(vserlzr_size*3-1 downto vserlzr_size*2),  
			chn1  => dvid_crgb(vserlzr_size*2-1 downto vserlzr_size*1),  
			chn0  => dvid_crgb(vserlzr_size*1-1 downto vserlzr_size*0));

	end block;

end;
