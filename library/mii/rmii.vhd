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

entity rmii is
	generic (
		n      : natural;
		enable : boolean := true);
	port (
		rmii_clk   : in  std_logic;
		rmii_crsdv : in  std_logic;
		rmii_rxd   : in  std_logic_vector(0 to n-1);
		rmii_txen  : out std_logic;
		rmii_txd   : out std_logic_vector(0 to n-1);

		mii_rxc    : out std_logic;
		mii_rxdv   : out std_logic;
		mii_rxd    : out std_logic_vector(0 to n-1);

		mii_txc    : out std_logic;
		mii_txen   : in  std_logic;
		mii_txd    : in  std_logic_vector(0 to n-1));
end;

architecture beh of rmii is
begin

	mii_rxc <= rmii_clk;
	mii_txc <= rmii_clk;
	process(rmii_crsdv, rmii_rxd, rmii_clk)
		variable shr_dv  : unsigned(0 to 2-1);
		variable shr_rxd : unsigned(0 to shr_dv'length*rmii_rxd'length-1);
	begin
		if enable then
			if rising_edge(rmii_clk) then
				case std_logic_vector'(shr_dv(0), shr_dv(1), rmii_crsdv) is
				when "000"|"001"|"011" =>
					mii_rxdv <= '0';
				when others =>
					mii_rxdv <=  '1';
				end case;
				mii_rxd <= std_logic_vector(shr_rxd(0 to rmii_rxd'length-1));

				shr_rxd(0 to 2-1) := unsigned(rmii_rxd);
				shr_rxd   := rotate_left(shr_rxd, rmii_rxd'length);
				shr_dv(0) := rmii_crsdv;
				shr_dv    := rotate_left(shr_dv, 1);
			end if;
		else
			mii_rxdv <= rmii_crsdv;
			mii_rxd  <= rmii_rxd;
		end if;
	end process;

	rmii_txen <= mii_txen;
	rmii_txd  <= mii_txd;
end;
