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

entity mii_rxpre is
    port (
		mii_clk  : in  std_logic;
		mii_frm  : in  std_logic;
		mii_irdy : in  std_logic;
		mii_trdy : out std_logic := '1';
        mii_data : in std_logic_vector;
		mii_pre  : buffer std_logic);
end;

architecture def of mii_rxpre is
begin
	process(mii_frm, mii_clk)
		variable vld  : std_logic;
		variable data : unsigned(0 to mii_data'length);
		variable cy   : std_logic;
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				vld  := '0';
				cy   := '0';
				data := (others => '0');
			elsif mii_irdy='1' then
				if vld ='0' then
					data := data(0) & unsigned(mii_data);
					for i in mii_data'range loop
						if (data(0) xnor data(1))='1' then
							if cy='1' then
								if data(0)='1' then
									vld := '1';
								end if;
							end if;
							cy := '0';
						else
							cy := '1';
						end if;
						data := data sll 1;
					end loop;
				end if;
			end if;
		end if;
		mii_pre <= mii_frm and vld;
	end process;
end;





