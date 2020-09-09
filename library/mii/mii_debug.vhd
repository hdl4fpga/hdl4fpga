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
use hdl4fpga.cgafonts.all;
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity mii_debug is
	generic (
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_width  : natural := 8;
		font_height : natural := 16;

		timing_id   : videotiming_ids;
		code_spce   : std_logic_vector := to_ascii(" ");
		code_digits : std_logic_vector := to_ascii("0123456789abcdef");
		cga_bitrom  : std_logic_vector := (1 to 0 => '-'));
	port (
		mii_rxc     : in  std_logic;
		mii_rxd     : in  std_logic_vector;
		mii_rxdv    : in  std_logic;

		dhcp_req    : in  std_logic;
		mii_txc     : in  std_logic;
		mii_txd     : buffer std_logic_vector;
		mii_txen    : buffer std_logic;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : out std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic;

		tp          : buffer std_logic_vector(1 to 4));

	end;

architecture struct of mii_debug is

	signal debug_txd  : std_logic_vector(0 to 8-1);
	signal debug_txen : std_logic;

begin

	miiipoe_e : entity hdl4fpga.mii_ipoe
	port map (
		mii_rxc    => mii_rxc,
		mii_rxd    => mii_rxd,
		mii_rxdv   => mii_rxdv,

		dhcp_req   => dhcp_req,
		mii_txc    => mii_txc,
		mii_txd    => mii_txd,
		mii_txen   => mii_txen,

		debug_txen => debug_txen,
		debug_txd  => debug_txd,

		tp       => tp);

--	mii_display_e : entity hdl4fpga.mii_display
--	generic map (
--		timing_id   => timing_id,
--		code_spce   => code_spce, 
--		code_digits => code_digits, 
--		cga_bitrom  => cga_bitrom)
--	port map (
--		mii_txc     => mii_txc,
--		mii_txen    => debug_txen,
--		mii_txd     => debug_txd(0 to mii_txd'length-1),
--
--		video_clk   => video_clk,
--		video_dot   => video_dot,
--		video_on    => video_on ,
--		video_hs    => video_hs,
--		video_vs    => video_vs);

end;
