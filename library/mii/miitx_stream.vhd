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

entity miitx_stream is
    port (
        mii_txc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;
		mii_txd  : out std_logic_vector;
		mii_txdv : out std_logic);
end;

architecture def of miitx_stream is
	signal miicrc_txen : std_logic;
	signal miicrc_txd  : std_logic_vector(mii_txd'range);
	signal miibuf_txiv : std_logic;
	signal miibuf_txi  : std_logic_vector(mii_txd'range);
	signal miibuf_txd  : std_logic_vector(mii_txd'range);
	signal miibuf_txdv : std_logic;
begin

	mii_fcs_e : entity hdl4fpga.miitx_crc32
    port map (
        mii_txc   => mii_txc,
		mii_rxdv  => mii_rxdv,
		mii_rxc   => mii_rxd,
		mii_txen  => miicrc_txen,
		mii_txd   => miicrc_txd);

	mii_txdv <= mii_rxdv or miicrc_txen;
	mii_txd  <= word2byte(mii_rxd & miicrc_txd, not mii_rxdv);

end;

