library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity usbphy_rx is
	generic (
		oversampling : natural);
	port (
		clk  : in  std_logic;
		rxd  : in  std_logic;
		rxdp : in  std_logic;
		rxdn : in  std_logic;
		rxc  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of usbphy_rx is
begin
	process (rxc)
		variable cntr : natural range 0 to oversampling-1;
	begin
		if rising_edge(rxc) then
			if cntr > 0 then
				if cntr=1 then
					rxd <= rx;
				end if;
				cntr := cntr - 1;
			elsif (to_bit(rx) xor to_bit(rxd))='1' then
				cntr := oversampling-1;
			end if;
		end if;
	end process;
end;