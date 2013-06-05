use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity miirx_pre is
    port (
		mii_rxc  : in std_logic;
        mii_rxdv : in std_logic;
        mii_rxd  : in nibble;

		mii_txc  : out std_logic;
		mii_txen : out std_logic;
		mii_txd  : out nibble);

end;

architecture def of miirx_pre is
	signal txen : std_logic;
begin

	mii_txc  <= mii_rxc;
	mii_txd  <= mii_rxd;
	mii_txen <= mii_rxdv and txen;

	process (mii_rxc)
		variable prdy : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if mii_rxdv='0' then
				prdy := '0';
				txen <= '0';
			elsif prdy='0' then
				if mii_rxd=x"5" then
					prdy := '0';
					txen <= '0';
				elsif mii_rxd=x"d" then
					prdy := '1';
					txen <= '1';
				else
					prdy := '1';
					txen <= '0';
				end if;
			end if;
		end if;
	end process;

end;
