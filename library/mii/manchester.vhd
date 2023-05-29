library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_manchester is
	port (
		clk  : in  std_logic;
		txen : in  std_logic;
		txd  : in  std_logic;
		tx   : out std_logic);
end;

architecture def of tx_manchester is
	signal clk_n : std_logic;
begin
	clk_n <= not clk;
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
		clk  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of rx_manchester is
begin
	process (clk)
		variable cntr : natural range 0 to oversampling-1;
	begin
		if rising_edge(clk) then
			if cntr > 0 then
				if cntr=1 then
					rxd <= rx;
				end if;
				cntr := cntr - 1;
			elsif (rx xor rxd)='1' then
				cntr := (oversampling*3)/4;
			end if;
		end if;
	end process;
end;