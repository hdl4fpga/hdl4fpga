-- (c)EMARD
-- License=BSD

-- USB HID report decoder for Logitech mouse
-- converts Logitech USB mouse report events
-- to the PS/2 mouse compatible events.

-- this mouse sends XY as 12-bit but
-- we use here only lower 8-bit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library hdl4fpga;
use hdl4fpga.base.all;

entity usbh_report_decoder is
  port
  (
    clk: in std_logic; -- GUI clock not used here
    -- HID report (should be GUI clk synchronous)
    hid_report: in std_logic_vector;
    hid_valid: in std_logic; -- single CLK pulse
    -- decoded mouse REL events for GUI
    btn: out std_logic_vector(2 downto 0); -- 0: left, 1: right, 2: middle
    dx, dy, dz: out std_logic_vector(7 downto 0);
    update: out std_logic -- shuld be single CLK pulse
  );
end;

architecture Behavioral of usbh_report_decoder is
begin
  btn    <= hid_report(10 downto 8);
  dx     <= hid_report(23 downto 16);
  dy     <= std_logic_vector(-signed(hid_report(35 downto 28)));
  dz     <= std_logic_vector(-signed(hid_report(47 downto 40)));
  update <= hid_valid;
end Behavioral;
