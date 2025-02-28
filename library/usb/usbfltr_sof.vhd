-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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



