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

entity spi_flash is
	generic (
		sclk_phases : natural :=  4;
		sclk_edges  : natural :=  2;
		word_size   : natural :=  4;
		data_phases : natural :=  2;
		data_edges  : natural :=  2;
		data_gear   : natural :=  1);
	port (
		ctlr_rst     : in std_logic;
		ctlr_clks    : in std_logic_vector(0 to sclk_phases/sclk_edges-1);
		ctlr_inirdy  : out std_logic;

		ctlr_irdy    : in  std_logic;
		ctlr_trdy    : out std_logic;
		ctlr_rw      : in  std_logic;
		ctlr_a       : in  std_logic_vector;
		ctlr_di_dv   : in  std_logic;
		ctlr_di_req  : out std_logic;
		ctlr_do_dv   : out std_logic_vector(data_phases*word_size-1 downto 0);
		ctlr_do_req  : out std_logic;
		ctlr_dio_req : out std_logic;
		ctlr_di      : in  std_logic_vector(data_gear*word_size-1 downto 0);
		ctlr_do      : out std_logic_vector(data_gear*word_size-1 downto 0);

		phy_rst      : out std_logic;
		phy_cs       : out std_logic;

		phy_dqi      : in  std_logic_vector(data_gear*word_size-1 downto 0);
		phy_dqt      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqo      : out std_logic_vector(data_gear*word_size-1 downto 0);
		phy_sti      : in  std_logic;
		phy_sto      : out std_logic);

end;
