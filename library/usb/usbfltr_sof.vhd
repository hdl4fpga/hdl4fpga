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

entity usbfltr_sof is
	port (
		usb_clk  : in  std_logic;
		usb_cken : in  std_logic;
		fltr_on  : in  std_logic := '1';
		phy_en   : in  std_logic;
		phy_bs   : in  std_logic;
		phy_d    : in  std_logic;
		fltr_en  : out std_logic;
		fltr_bs  : out std_logic;
		fltr_d   : out std_logic);
end;

architecture def of usbfltr_sof is
	signal sof_en : std_logic;
	signal sof_bs : std_logic;
	signal sof_d  : std_logic;
begin

	sof_filter_p : process(usb_clk)
		variable data : unsigned(0 to 8-1);
		variable tken : unsigned(0 to 8-1);
		variable ena  : unsigned(0 to 8-1);
		variable cntr : natural range 0 to 8;
	begin
		if rising_edge(usb_clk) then
			if usb_cken='1' then
				if phy_en='1' or ena(0)='1' then
					if phy_bs='0' then
						data(0) := phy_d;
						data    := data rol 1;
						if cntr/=0 then
							cntr := cntr - 1;
							if cntr=0 then
								tken := data;
							end if;
						end if;
					end if;
				else
					cntr := 8;
				end if;
				ena(0) := phy_en;
				ena    := ena rol 1;

				if cntr=0 then
					if reverse(tken)=x"a5" then
						ena  := (others => '0');
					elsif reverse(tken)=x"80" then
						ena  := (others => '0');
						cntr := 8;
					elsif (tken(0 to 4-1) xor tken(4 to 8-1))/=x"f" then
						ena := (others => '0');
					end if;
				end if;

				sof_en <= ena(0); 
				if phy_en='1' then
					sof_bs <= phy_bs;
				else
					sof_bs <= '0';
				end if;

				sof_d <= data(0);
			else
				sof_bs <= '1';
			end if;
		end if;
	end process;
	fltr_en <= sof_en when fltr_on='1' else phy_en;
	fltr_bs <= sof_bs when fltr_on='1' else phy_bs or not usb_cken;
	fltr_d  <= sof_d  when fltr_on='1' else phy_d;

end;
