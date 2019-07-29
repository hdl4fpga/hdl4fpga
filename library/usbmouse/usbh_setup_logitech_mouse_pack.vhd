-- (c) EMARD
-- License=BSD

-- USB enumeration sequence sniffed with wireshark
-- For Logitech mouse and other similar USB low-speed HID devices.
-- After this minimal setup sequence is replayed to mouse,
-- mouse will answer IN transfers with HID reports.

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

package usbh_setup_pack is
  type T_setup_rom is array(natural range <>) of std_logic_vector(7 downto 0);
  constant C_setup_rom: T_setup_rom :=
  (
    -- set configuration 1 --
    x"00", x"09", x"01", x"00", x"00", x"00", x"00", x"00",
-- HOST:  < SYNC ><SETUP ><ADR0>EP0 CRC5
--  D+ ___-_-_-_---___--_-_-_-_-_-_-_--_-_____
--  D- ---_-_-_-___---__-_-_-_-_-_-_-__-_-__--
-- HOST:  < SYNC ><DATA0><  00  ><  09  ><  01  ><  00  ><  00  ><  00  ><  00  ><  00  ><    CRC16     >
--  D+ ___-_-_-_----_-_---_-_-_-_--_--_-_--_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-____-__-__--_--_-____
--  D- ---_-_-_-____-_-___-_-_-_-__-__-_-__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_----_--_--__-__-___--
-- MOUSE: < SYNC >< ACK >
--  D+ ___-_-_-_--__-__---_____
--  D- ---_-_-_-__--_--_____---
    -- again, first transmission after reset is usually unsuccessful
    -- set configuration 1 --
    x"00", x"09", x"01", x"00", x"00", x"00", x"00", x"00",
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
    x"21", x"0A", x"00", x"00", x"00", x"00", x"00", x"00",
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
    x"21", x"09", x"00", x"02", x"00", x"00", x"01", x"00"
-- HOST:  < SYNC ><SETUP ><ADR0>EP0 CRC5
--  D+ ___-_-_-_---___--_-_-_-_-_-_-_--_-_____
--  D- ---_-_-_-___---__-_-_-_-_-_-_-__-_-__--
-- HOST:  < SYNC ><DATA0><  21  ><  09  ><  00  ><  02  ><  00  ><  00  ><  01  ><  00  ><    CRC16     >
--  D+ ___-_-_-_----_-_----_-_--_--_--_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_--____-__-_-____-___
--  D- ---_-_-_-____-_-____-_-__-__-__-_-_-_-_-_-_--_-_-_-_-_-_-_-_-_-_-_--_-_-_-_-_-_-_-__----_--_-_----__--
-- MOUSE: < SYNC >< ACK >
--  D+ ___-_-_-_--__-__---_____
--  D- ---_-_-_-__--_--_____---
  );
  constant C_setup_interval  : integer := 12; -- 2**n clocks 0.7 ms interval between setup packets
  constant C_report_interval : integer := 12; -- 2**n clocks 0.7 ms interval between report packets
  constant C_report_endpoint : integer := 1;  -- endpoint which answers IN transfer with HID report
  constant C_report_length   : integer := 5;  -- bytes in the report
  constant C_device_address  : integer := 0;  -- default is 0 if set address is not used

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
end;
