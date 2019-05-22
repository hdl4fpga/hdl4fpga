
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- to calculate log2 bit size

entity uart_rx_f32c is
    generic (
	C_clk_freq_hz: integer; -- Hz clock frequency
	C_baudrate: integer := 115200
    );
    port (
	clk: in std_logic;
	rxd: in std_logic;
	byte: out std_logic_vector(7 downto 0);
	dv: out std_logic
    );
end;

--
-- SIO -> CPU data word:
-- 31..11  unused
--     10  set if tx busy
--      9  reserved
--      8  set if rx_byte is unread, reset on read
--   7..0  rx_byte
--
-- CPU -> SIO data word:
-- 31..16  clock divisor (or unused)
--  15..8  unused
--   7..0  tx_byte
--
architecture Behavioral of uart_rx_f32c is
    constant C_baud_init: std_logic_vector(15 downto 0) :=
      std_logic_vector(to_unsigned(
	C_baudrate * 2**16 / (C_clk_freq_hz/1000) / 1000 * 2**4, 16));

    -- baud * 16 impulse generator
    signal R_baudgen: std_logic_vector(16 downto 0);

    -- receive logic
    signal R_rxd, R_break: std_logic;
    signal rx_tickcnt: std_logic_vector(3 downto 0);
    signal rx_des: std_logic_vector(7 downto 0);
    signal rx_phase: std_logic_vector(3 downto 0);
    signal rx_byte: std_logic_vector(7 downto 0);
    signal rx_full: std_logic;
begin
    -- rx / tx phases:
    --	"0000" idle
    --	"0001" start bit
    --	"0010".."1001" data bits
    --	"1010" stop bit
    process(clk)
    begin
	if rising_edge(clk) then
	    -- baud generator
	    R_baudgen <= ('0' & R_baudgen(15 downto 0)) + ('0' & C_baud_init);
	    -- rx logic
	    rx_full <= '0'; -- default '0', when new byte then 1 clock cycle becomes '1'
	    R_rxd <= rxd;
	    if R_baudgen(16) = '1' then
		if rx_phase = x"0" then
		    if R_rxd = '0' then
			-- start bit, delay further sampling for ~0.5 T
			if rx_tickcnt = x"8" then
			    rx_phase <= rx_phase + 1;
			    rx_tickcnt <= x"0";
			else
			    rx_tickcnt <= rx_tickcnt + 1;
			end if;
		    else
			rx_tickcnt <= x"0";
		    end if;
		else
		    rx_tickcnt <= rx_tickcnt + 1;
		    if rx_tickcnt = x"f" then
			rx_des <= R_rxd & rx_des(7 downto 1);
			rx_phase <= rx_phase + 1;
			if rx_phase = x"9" then
			    rx_phase <= x"0";
			    rx_full <= '1';
			    rx_byte <= rx_des;
			end if;
		    end if;
		end if;
	    end if;
	end if;
    end process;
    dv <= rx_full;
    byte <= rx_byte;
end Behavioral;
