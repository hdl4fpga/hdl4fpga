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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ethpkg.all;

entity eth_rx is
	port (
		mii_clk    : in  std_logic;
		mii_frm    : in  std_logic;
		mii_irdy   : in  std_logic;
		mii_trdy   : buffer std_logic;
		mii_data   : in  std_logic_vector;

		dll_frm    : buffer std_logic;
		dll_irdy   : buffer std_logic;
		dll_trdy   : in  std_logic := '1';
		dll_data   : buffer std_logic_vector;

		hwda_irdy  : buffer std_logic;
		hwda_trdy  : in  std_logic := '1';
		hwda_end   : in  std_logic := '1';
		hwsa_irdy  : buffer std_logic;
		hwsa_trdy  : in  std_logic := '1';
		hwsa_end   : in  std_logic := '1';
		hwtyp_irdy : buffer std_logic;
		hwtyp_trdy : in  std_logic := '1';
		hwtyp_end  : in  std_logic := '1';
		pl_irdy    : out std_logic;
		pl_trdy    : in  std_logic := '1';

		fcs_sb     : out std_logic;
		fcs_vld    : out std_logic;
		fcs_rem    : buffer std_logic_vector(0 to 32-1));

end;

architecture def of eth_rx is
	signal pream_vld : std_logic;
begin
	mii_pre_e : entity hdl4fpga.mii_rxpre
	port map (
		mii_clk  => mii_clk,
		mii_frm  => mii_frm,
		mii_irdy => mii_irdy,
		mii_data => mii_data,
		mii_pre  => pream_vld);

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => mii_clk,
		serdes_frm => pream_vld,
		ser_irdy   => mii_irdy,
		ser_trdy   => mii_trdy,
		ser_data   => mii_data,

		des_frm    => dll_frm,
		des_irdy   => dll_irdy,
		des_trdy   => dll_trdy,
		des_data   => dll_data);

	dllrx_e : entity hdl4fpga.dll_rx
	port map (
		mii_clk    => mii_clk,
		dll_frm    => dll_frm,
		dll_irdy   => dll_irdy,
		dll_trdy   => open,
		dll_data   => dll_data,

		hwda_irdy  => hwda_irdy,
		hwda_end   => hwda_end,
		hwsa_irdy  => hwsa_irdy,
		hwtyp_irdy => hwtyp_irdy,
		pl_irdy    => pl_irdy,
		crc_sb     => fcs_sb,
		crc_equ    => fcs_vld,
		crc_rem    => fcs_rem);

end;

