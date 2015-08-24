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

entity miitx_dma is
	generic (
		xd_len : natural := 8);
    port (
		sys_addr : out std_logic_vector;
		sys_data : in  std_logic_vector;

        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector(0 to xd_len-1));
end;

architecture def of miitx_dma is
	constant word_size : natural := sys_data'length;
	constant word_byte : natural := word_size/mii_txd'length;

	constant cntr_size : natural := sys_addr'length-1+unsigned_num_bits(sys_data'length/mii_txd'length-1);

	signal cntr : std_logic_vector(0 to cntr_size);
	signal sel  : std_logic_vector(0 to 2);
	signal ena  : std_logic_vector(0 to 1);
	signal ena_sel : std_logic;
begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			cntr <= dec (
				cntr => cntr,
				ena  => not mii_treq or not cntr(0),
				load => not mii_treq,
				data => (2**cntr_size-1)-2);
			sys_addr <= cntr(1 to sys_addr'length);
			sel <= dec (
				cntr => sel,
				load => not mii_treq or ena_sel,
				data => 3);
			ena_sel <= cntr(0);

			if mii_treq='0' then
				ena <= (others => '0');
			else
				ena <= ena(1) & not cntr(0);
			end if;
		end if;
	end process;

	mii_txen <= mii_treq and ena(0);
	mii_txd  <=  reverse(word2byte(
		word => sys_data,
		addr => sel(0 to 2)));
end;
