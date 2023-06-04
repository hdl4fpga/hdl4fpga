library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity usbphy_tx is
	port (
		txc  : in  std_logic;
		txen : in  std_logic;
		busy : out std_logic := '1';
		txd  : in  std_logic;
		txdp : buffer std_logic;
		txdn : buffer std_logic);
end;

architecture def of usbphy_tx is
begin

	process (txc)
		variable cnt1 : natural range 0 to 7;
		variable data : unsigned(8-1 downto 0) := (others => '0');
	begin
		if rising_edge(txc) then
			if txen='0' then
				data := x"80"; -- sync word
				cnt1 := 0;
				busy <= '0';
				txdp <= data(0);
				txdn <= data(0);
			else
				if data(0)='1' then
					stuffed_bit : if cnt1 < 5 then
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
				txdp <= not (txdp xor data(0));
				txdn <=     (txdp xor data(0));
			end if;

			stuffing_bit : if data(0)='0' then
				busy <= '0';
			elsif cnt1 < 5 then
				busy <= '0';
			else
				busy <= '1';
			end if;
		end if;
	end process;

end;