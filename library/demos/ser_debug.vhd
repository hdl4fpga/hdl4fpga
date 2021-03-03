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
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;

library ieee;
use ieee.std_logic_1164.all;

entity ser_debug is
	generic (
		timing_id    : videotiming_ids;
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

    signal video_on        : std_logic;
	signal video_dot       : std_logic;

begin

	video_b : block
		signal hzsync : std_logic;
		signal vtsync : std_logic;
		signal von    : std_logic;
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
			video_on    => von,
			video_hs    => hzsync,
			video_vs    => vtsync);

		video_lat_e : entity hdl4fpga.align
		generic map (
			n => 3,
			d => (0 to 3-1 => 4))
		port map (
			clk => video_clk,
			di(0) => von,
			di(1) => hzsync,
			di(2) => vtsync,
			do(0) => video_on,
			do(1) => video_hzsync,
			do(2) => video_vtsync);

		video_blank <= not video_on;
	end block;

	-- VGA --
	---------

	dvi_b : block
		constant subpixel_length : natural := hdl4fpga.std.min(hdl4fpga.std.min(red_length, green_length), blue_length);

		signal dvid_blank : std_logic;
		signal in_red     : unsigned(0 to subpixel_length-1);
		signal in_green   : unsigned(0 to subpixel_length-1);
		signal in_blue    : unsigned(0 to subpixel_length-1);

	begin

		video_pixel <= (video_pixel'range => video_dot);
		process (video_pixel)
			variable pixel : unsigned(0 to video_pixel'length-1);
		begin
			pixel    := unsigned(video_pixel);
			in_red   <= pixel(in_red'range);
			pixel    := pixel sll red_length;
			in_green <= pixel(in_green'range);
			pixel    := pixel sll green_length;
			in_blue  <= pixel(in_blue'range);
		end process;

		dvid_blank <= video_blank;

		vga2dvid_e : entity hdl4fpga.vga2dvid
		generic map (
			C_shift_clock_synchronizer => '0',
			C_ddr   => '1',
			C_depth => subpixel_length)
		port map (
			clk_pixel => video_clk,
			clk_shift => video_shift_clk,
			in_red    => std_logic_vector(in_red),
			in_green  => std_logic_vector(in_green),
			in_blue   => std_logic_vector(in_blue),
			in_hsync  => video_hzsync,
			in_vsync  => video_vtsync,
			in_blank  => dvid_blank,
			out_clock => dvid_crgb(7 downto 6),
			out_red   => dvid_crgb(5 downto 4),
			out_green => dvid_crgb(3 downto 2),
			out_blue  => dvid_crgb(1 downto 0));

	end block;

end;
