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
use hdl4fpga.videopkg.all;

architecture display_tp of testbench is
	constant encoded_size : natural := 10;
	constant video_gear   : natural := 2;

	signal sweep_clk   : std_logic := '1';
	signal video_clk   : std_logic := '1';
	signal video_shift_clk : std_logic := '1';
	signal video_pixel : std_logic_vector(32-1 downto 0);

	signal tp : std_logic_vector(0 to 5-1);
begin
	sweep_clk       <= not sweep_clk after 10 ns;
	video_clk       <= not video_clk after encoded_size*10 ns;
	video_shift_clk <= not video_shift_clk after video_gear*10 ns;

	du_e : entity hdl4fpga.display_tp
	generic map (
		timing_id  => pclk40_00m800x600at60,
		video_gear => video_gear,
		num_of_cols  => 3,
		field_widths => (15,10,3),
		labels     => 
			"hello" & NUL &
			"again" & NUL &
			"again" & NUL &
			"again" & NUL &
			"world" & NUL )
	port map (
		sweep_clk   => sweep_clk,
		tp          => tp,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_hs    => open,
		video_vs    => open,
		video_blank => open,
		video_pixel => video_pixel,
		dvid_crgb   => open);

