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

entity mii_bus is
    port (
		mii_txc  : in  std_logic;
		mii_treq : out std_logic_vector;
		mii_trdy : in  std_logic_vector;
		mii_tena : in  std_logic := '1';
        mii_txdv : out std_logic_vector;
        mii_rxd  : in  std_logic_vector);
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_bus is
	function priencoder (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable retval : std_logic_vector(0 to unsigned_num_bits(max(arg'right, arg'left))-1);
	begin
		retval := (others => '0');
		for i in arg'range loop
			if arg(i)='1' then
				retval := std_logic_vector(to_unsigned(i, retval'length));
				exit;
			end if;
		end loop;
		return retval;
	end;
begin

	process (mii_req, mii_trdy)
	begin
		mii_treq <= (mii_trdy srl 1);
		mii_treq(mii_treq'left) = mii_req;
		mii_rdy  <= mii_trdy(mii_trdy'right);
	end process;

	mii_txd <= word2byte(mii_rxd, priencoder(not mii_trdy), mii_txd'length);
end;
