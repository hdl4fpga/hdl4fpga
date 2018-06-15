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

entity mii_pll2ser is
    port (
		mii_data : in  std_logic_vector;
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_tena : in  std_logic := '1';
		mii_trdy : out std_logic;
		mii_teoc : out std_logic;
        mii_txdv : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_pll2ser is
	constant data_size : natural := (mii_data'length+mii_txd'length-1)/mii_txd'length;
	constant cntr_size : natural := unsigned_num_bits(mii_data'length/mii_txd'length-1);

	signal cntr  : unsigned(0 to cntr_size);

begin

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if mii_treq='0' then
				cntr <= to_unsigned(data_size-1, cntr'length);
			elsif cntr(0)='0' then
				if mii_tena='1' then
					cntr <= cntr - 1;
				end if;
			end if;
		end if;
	end process;

	mii_teoc <= cntr(0);
	mii_trdy <= mii_treq and cntr(0);
	mii_txdv <= mii_treq and not cntr(0) and mii_tena;
	mii_txd  <= word2byte(reverse(mii_data), std_logic_vector(cntr(1 to cntr'right)), mii_txd'length);

end;
