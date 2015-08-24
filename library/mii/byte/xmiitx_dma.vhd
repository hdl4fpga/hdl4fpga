--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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
    port (
		mii_data : in  std_logic_vector;
		mii_ena  : out std_logic;
		mii_eoc  : in  std_logic;
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
        mii_txen : out std_logic;
        mii_txd  : out std_logic_vector);

	constant word_byte : natural := mii_data'length/mii_txd'length;

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of miitx_dma is

	signal bcntr : unsigned(0 to unsigned_num_bits(word_byte-1));
	signal sel   : std_logic_vector(1 to bcntr'right);
begin

	process (mii_txc)
		variable aux : std_logic_vector(1 to bcntr'right);
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				bcntr <= to_unsigned(2**unsigned_num_bits(word_byte-1)-2-2, bcntr'length); 
				aux   := to_unsigned(2**unsigned_num_bits(word_byte-1)-2-1, bcntr'length); 
				sel   <= to_unsigned(2**unsigned_num_bits(word_byte-1)-2-0, bcntr'length); 
			elsif bcntr(0)='1' then
				bcntr <= to_unsigned(2**unsigned_num_bits(word_byte-1)-2, bcntr'length); 
			else
				bcntr <= bcntr - 1;
			end if;
			sel <= aux;
			aux := std_logic_vector(bcntr(sel'range));
		end if;
	end process;


	process (mii_txc, mii_treq)
	begin
		if mii_treq='0' then
			mii_txen <= '0';
		elsif rising_edge(mii_txc) then
			mii_txen <= mii_eoc and bcntr(0);
		end if;
	end process;

	mii_txd  <=  reverse (
		word2byte (
			word => mii_data ror ((1*mii_txd'length) mod mii_data'length),
			addr => sel));
end;
