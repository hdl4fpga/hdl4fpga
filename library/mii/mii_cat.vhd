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

entity mii_cat is
    port (
		mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txd  : in  std_logic_vector;
        mii_txdv : in  std_logic_vector;
		mii_trdy : in  std_logic_vector;
        mii_txdv : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_cat is
begin

	process (
		mii_rxd, 
		mii_rxdv, 
		mii_trdy)
		variable ardy  : unsigned(0 to mii_trdy'length-1);
		variable arxdv : unsigned(0 to mii_rxdv'length-1);
		variable arxd  : unsigned(0 to mii_rxd'length-1);
	begin
		ardy  := unsigned(mii_trdy);
		arxd  := unsigned(mii_rxd);
		arxdv := unsigned(mii_rxdv);
		mii_txdv <= '0';
		mii_txd  <= (mii_txd'range => '-');
		for i in ardy'range loop
			if ardy(0)='0' then
				mii_txdv <= arxdv(0);
				mii_txd  <= std_logic_vector(arxd(0 to mii_txd'length-1));
				exit;
			end if;
			ardy  := ardy  rol 1;
			arxdv := arxdv rol 1;
			arxd  := arxd  rol mii_txd'length;
		end loop;
	end process;

	process (mii_req, mii_trdy)
		variable aux : unsigned(0 to mii_trdy'length-1);
	begin
		aux      := unsigned(mii_trdy) ror 1;
		mii_rdy  <= aux(0);
		aux(0)   := mii_req;
		mii_treq <= std_logic_vector(aux);
	end process;
end;
