library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity usbphy_tx is
	generic (
		bit_stuffing : natural := 6);
	port (
		clk  : in  std_logic;
		cken : in std_logic := '1';
		txen : in  std_logic;
		txd  : in  std_logic;
		txbs : out std_logic;
		txdp : out std_logic;
		txdn : out std_logic);
end;

architecture def of usbphy_tx is
	alias tx_stuffedbit : std_logic is txbs;
begin

	process (txen, clk)
		type states is (s_idle, s_running, s_eop);
		variable state : states;

		variable cnt1 : natural range 0 to 7;
		variable data : unsigned(8-1 downto 0) := (others => '0');
		variable dp   : std_logic;
		variable dn   : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					data := x"80"; -- sync word
					cnt1 := 0;
					txbs <= '0';
					if txen='1' then
						dp   := data(0);
						dn   := not data(0);
						data(0) := txd;
						data := data ror 1;
						state := s_running;
					else
						dp   := 'Z';
						dn   := 'Z';
					end if;
				when s_running =>
					if txen='1' then
						dp := not (dp xor data(0));
						dn := not dp;
					else
						dp := '0';
						dn := '0';
						state := s_eop;
					end if;
					if data(0)='1' then
						stuffedbit_l : if cnt1 < bit_stuffing-1 then
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
				when s_eop =>
					dp := '0';
					dn := '0';
					state := s_idle;
				end case;
			end if;

			bitstuffing_l : if data(0)='0' then
				txbs <= '0';
			elsif cnt1 < bit_stuffing-1 then
				txbs <= '0';
			else
				txbs <= '1';
			end if;
		end if;
		txdp <= dp;
		txdn <= dn;
	end process;

end;