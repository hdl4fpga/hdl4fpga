-- (c) EMARD
-- License=GPL

-- USB setup (enumeration) sequence
-- for common USB low-speed HID devices.

-- Works for:
-- Mouse:    Logitech: M-BT58, LX3, RX250, Microsoft: IntelliMouse
-- Keyboard: Logitech: NetPlay Y-UC29, Openhardware: V-USB
-- Gamepad:  Saitek: P3600, Darfon

-- Doesn't work for:
-- Keyboard: Logitech: UltraX Y-BL49A

-- After this minimal setup sequence is replayed to mouse,
-- mouse will answer each IN transfer with HID report
-- or with NAK if report data is not available.

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

library hdl4fpga;

package usbh_setup_pack is

  constant C_setup_retry       : integer := 4;  -- 2**n retries 3:8 setup retries and then detach
  constant C_setup_interval    : integer := 17; -- 2**n clocks 15:5.46 ms wait before sending next setup request
  constant C_report_interval   : integer := 16; -- 2**n clocks 15:5.46 ms wait before sending next request for report
  constant C_report_endpoint   : integer := 1;  -- default=1 endpoint which answers IN transfer with HID report
  constant C_report_length     : integer := 20; -- report buffer length: 4:M-BT58, 5:LX3, 8:keyboard, 20:XBOX360

  constant C_keepalive_setup   : std_logic := '1';  -- enable keepalive during setup
  constant C_keepalive_status  : std_logic := '1';  -- enable keepalive during setup status OUT 0-length
  constant C_keepalive_report  : std_logic := '1';  -- enable keepalive during report IN
  constant C_keepalive_type    : std_logic := '1';  -- '0':SOF '1':K-pulse
  constant C_keepalive_phase   : std_logic_vector(11 downto 0) := x"F00"; -- near the end of 0.68 ms interval

  type T_setup_rom is array(natural range <>) of std_logic_vector(7 downto 0);
  constant C_setup_rom: T_setup_rom :=
  (
    -- set configuration 1 --
--    x"00", x"09", x"01", x"00", x"00", x"00", x"00", x"00",
-- HOST:  < SYNC ><SETUP ><ADR0>EP0 CRC5
--  D+ ___-_-_-_---___--_-_-_-_-_-_-_--_-_____
--  D- ---_-_-_-___---__-_-_-_-_-_-_-__-_-__--
-- HOST:  < SYNC ><DATA0><  00  ><  09  ><  01  ><  00  ><  00  ><  00  ><  00  ><  00  ><    CRC16     >
--  D+ ___-_-_-_----_-_---_-_-_-_--_--_-_--_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-____-__-__--_--_-____
--  D- ---_-_-_-____-_-___-_-_-_-__-__-_-__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_----_--_--__-__-___--
-- MOUSE: < SYNC >< ACK >
--  D+ ___-_-_-_--__-__---_____
--  D- ---_-_-_-__--_--_____---
    -- set idle 0 --
--    x"21", x"0A", x"00", x"00", x"00", x"00", x"00", x"00"
-- HOST:  < SYNC ><SETUP ><ADR0>EP0 CRC5
--  D+ ___-_-_-_---___--_-_-_-_-_-_-_--_-_____
--  D- ---_-_-_-___---__-_-_-_-_-_-_-__-_-__--
-- HOST:  < SYNC ><DATA0><  21  ><  0A  ><  00  ><  00  ><  00  ><  00  ><  00  ><  00  ><    CRC16     >
--  D+ ___-_-_-_----_-_----_-_--_-__--_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-___--___-_-_--_-____
--  D- ---_-_-_-____-_-____-_-__-_--__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_---__---_-_-__-___--
-- MOUSE: < SYNC >< ACK >
--  D+ ___-_-_-_--__-__---_____
--  D- ---_-_-_-__--_--_____---
    -- set report request 0x200 --
--    x"21", x"09", x"00", x"02", x"00", x"00", x"01", x"00"
-- HOST:  < SYNC ><SETUP ><ADR0>EP0 CRC5
--  D+ ___-_-_-_---___--_-_-_-_-_-_-_--_-_____
--  D- ---_-_-_-___---__-_-_-_-_-_-_-__-_-__--
-- HOST:  < SYNC ><DATA0><  21  ><  09  ><  00  ><  02  ><  00  ><  00  ><  01  ><  00  ><    CRC16     >
--  D+ ___-_-_-_----_-_----_-_--_--_--_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_--____-__-_-____-___
--  D- ---_-_-_-____-_-____-_-__-__-__-_-_-_-_-_-_--_-_-_-_-_-_-_-_-_-_-_--_-_-_-_-_-_-_-__----_--_-_----__--
-- MOUSE: < SYNC >< ACK >
--  D+ ___-_-_-_--__-__---_____
--  D- ---_-_-_-__--_--_____---
    -- set_address 1, Microsoft IntelliMouse needs address > 0 to activate reports --
    x"00", x"05", x"01", x"00", x"00", x"00", x"00", x"00",
    -- get_device_descriptor, requested length 0x12 = 18 bytes, no known device needs this --
--    x"80", x"06", x"00", x"01", x"00", x"00", x"12", x"00",
    -- set report request 0x200 with 1 byte data 0x00, no known device needs this --
--    x"21", x"09", x"00", x"02", x"00", x"00", x"01", x"00", x"00",
    -- set_configuration 1, most devices need configuration = 1 to activate reports --
    x"00", x"09", x"01", x"00", x"00", x"00", x"00", x"00"
    -- NOTE: last setup packet currently must be a non-data phase packet
    -- like set configuration, there's a bug that skips data phase at last packet
  );

-- to generate this package:
-- modprobe usbmon
-- chown user:user /dev/usbmon*
-- wireshark
-- plug USB device and press buttons, move it or replug few times
-- to find out which usbmon device receives its traffic,
-- then select it to capture
-- plug USB device
-- find 8-byte data from sniffed "URB setup" source host
-- e.g. 80 06 00 01 00 00 12 00 and copy it here as x"80", x"06", ...

-- USB hid descriptor describes data format of the report:
-- apt-get install usbutils
-- usbhid-dump
-- copy hex output to online USB descriptor parser
-- https://eleccelerator.com/usbdescreqparser/

end;
