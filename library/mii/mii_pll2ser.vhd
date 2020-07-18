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

entity mii_mux is
    port (
		mux_data : in  std_logic_vector;
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_tena : in  std_logic := '1';
		mii_trdy : out std_logic;
        mii_txdv : out std_logic;
        mii_txd  : out std_logic_vector);
end;

architecture def of mii_mux is
	constant data_size : natural := (mux_data'length+mii_txd'length-1)/mii_txd'length;
	constant cntr_size : natural := unsigned_num_bits(mux_data'length/mii_txd'length-1);

	signal cntr : unsigned(0 to cntr_size);
	signal data : std_logic_vector(0 to ((mux_data'length+8-1)/8)*8-1);

begin

	process (desser_clk)
	begin
		if rising_edge(desser_clk) then
			if mux_data'length=mii_txd'length then
				cntr <= to_unsigned(data_size-1, cntr'length);
			elsif desser_frm='0' then
				cntr <= (others => '0');
			elsif des_irdy='1' then
				if cntr=0 then
					if ser_trdy='1' then
						cntr <= cntr + 1;
					end if;
				elsif 2**cntr'length=mux_data'length/mii_txd'length then
					cntr <= cntr + 1;
				elsif cntr=mux_data'length/mii_txd'length-1 then
					cntr <= (others => '0');
				end if;
			end if;
		end if;
	end process;

end;
