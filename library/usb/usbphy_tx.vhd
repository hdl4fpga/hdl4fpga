library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity usbphy_tx is
	generic (
		bit_stuffing : natural := 5);
	port (
		txc  : in  std_logic;
		txen : in  std_logic;
		busy : out std_logic := '1';
		txd  : in  std_logic;
		txdp : out std_logic;
		txdn : out std_logic);
end;

architecture def of usbphy_tx is
	alias tx_stuffedbit : std_logic is busy;
begin

	process (txen, txc)
		variable cnt1 : natural range 0 to 7;
		variable data : unsigned(8-1 downto 0) := (others => '0');
		variable dp   : std_logic;
		variable dn   : std_logic;
	begin
		if rising_edge(txc) then
			if txen='0' then
				data := x"80"; -- sync word
				cnt1 := 0;
				busy <= '0';
				dp   := data(0);
				dn   := not data(0);
			else
				if data(0)='1' then
					stuffedbit_l : if cnt1 < bit_stuffing then
						data(0) := txd;
						data := data ror 1;
						cnt1 := cnt1 + 1;
					else
						data(0) := '0';
						cnt1 := 0;
					end if;
				else
					data(0) := txd;
					data := data ror 1;
					cnt1 := 0;
				end if;
				dp := not (dp xor data(0));
				dn := not dp;
			end if;

			bitstuffing_l : if data(0)='0' then
				busy <= '0';
			elsif cnt1 < 5 then
				busy <= '0';
			else
				busy <= '1';
			end if;
		end if;
		txdp <= dp and txen;
		txdn <= dn and txen;
	end process;

end;