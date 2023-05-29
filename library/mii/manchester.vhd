library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_manchester is
	port (
		txc  : in  std_logic;
		txen : in  std_logic;
		txd  : in  std_logic;
		tx   : out std_logic);
end;

architecture def of tx_manchester is
	signal clk_n : std_logic;
begin
	clk_n <= not txc;
	tx    <= txd xor clk_n when txen='1' else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_manchester is
	generic (
		oversampling : natural);
	port (
		rx   : in  std_logic;
		rxc  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of rx_manchester is
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