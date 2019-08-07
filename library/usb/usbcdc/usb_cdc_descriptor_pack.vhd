-- (c) EMARD
-- License=GPL

-- USB configuration descriptor
-- for usb_serial to work as either
-- USB-Serial or USB-Network

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

package usb_cdc_descriptor is

    -- Byte array type
    type t_byte_array is array(natural range <>) of std_logic_vector(7 downto 0);

    constant USBFS_CDC_config_serial: t_byte_array :=
    (
        -- 67 bytes full-speed configuration descriptor
        -- 9 bytes configuration header
        X"09",                  -- bLength = 9 bytes
        X"02",                  -- bDescriptorType = configuration descriptor
        X"43", X"00",           -- wTotalLength = 67 bytes
        X"02",                  -- bNumInterfaces = 2
        X"01",                  -- bConfigurationValue = 1
        X"00",                  -- iConfiguration = none
        X"80", -- choose_byte(SELFPOWERED, X"C0", X"80"), -- bmAttributes
        X"fa",                  -- bMaxPower = 500 mA
        -- 9 bytes interface descriptor (communication control class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"00",                  -- bInterfaceNumber = 0
        X"00",                  -- bAlternateSetting = 0
        X"01",                  -- bNumEndpoints = 1
        X"02",                  -- bInterfaceClass = Communication Interface
        X"02",                  -- bInterfaceSubClass = Abstract Control Model
        X"01",                  -- bInterfaceProtocol = V.25ter (required for Linux CDC-ACM driver)
        X"00",                  -- iInterface = none
        -- 5 bytes functional descriptor (header)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"00",                  -- bDescriptorSubtype = header
        X"10", X"01",           -- bcdCDC = 1.10
        -- 4 bytes functional descriptor (abstract control management)
        X"04",                  -- bLength = 4 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"02",                  -- bDescriptorSubtype = Abstract Control Mgmnt
        X"00",                  -- bmCapabilities = none
        -- X"04",                  -- bmCapabilities = sends break
        -- 5 bytes functional descriptor (union)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"06",                  -- bDescriptorSubtype = union
        X"00",                  -- bMasterInterface = 0
        X"01",                  -- bSlaveInterface0 = 1
        -- 5 bytes functional descriptor (call management)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"01",                  -- bDescriptorSubType = Call Management
        X"00",                  -- bmCapabilities = no call mgmnt
        X"01",                  -- bDataInterface = 1
        -- 7 bytes endpoint descriptor (notify IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"82",                  -- bEndpointAddress = IN 2
        X"03",                  -- bmAttributes = interrupt data
        X"08", X"00",           -- wMaxPacketSize = 8 bytes
        X"ff",                  -- bInterval = 255 frames
        -- 9 bytes interface descriptor (data class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"01",                  -- bInterfaceNumber = 1
        X"00",                  -- bAlternateSetting = 0
        X"02",                  -- bNumEndpoints = 2
        X"0a",                  -- bInterfaceClass = Data Interface
        X"00",                  -- bInterfaceSubClass = none
        X"00",                  -- bInterafceProtocol = none
        X"00",                  -- iInterface = none
	-- 7 bytes endpoint descriptor (data IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"81",                  -- bEndpointAddress = IN 1
        X"02",                  -- bmAttributes = bulk data
        X"40", X"00",           -- wMaxPacketSize = 64 bytes
        X"00",                  -- bInterval
        -- 7 bytes endpoint descriptor (data OUT)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"01",                  -- bEndpointAddress = OUT 1
        X"02",                  -- bmAttributes = bulk data
        X"40", X"00",           -- wMaxPacketSize = 64 bytes
        X"00"                   -- bInterval
    );

    constant USBHS_CDC_config_serial: t_byte_array :=
    (
        -- 67 bytes high-speed configuration descriptor
        -- 9 bytes configuration header
        X"09",                  -- bLength = 9 bytes
        X"02",                  -- bDescriptorType = configuration descriptor
        X"43", X"00",           -- wTotalLength = 67 bytes
        X"02",                  -- bNumInterfaces = 2
        X"01",                  -- bConfigurationValue = 1
        X"00",                  -- iConfiguration = none
        X"80", -- choose_byte(SELFPOWERED, X"C0", X"80"), -- bmAttributes
        X"fa",                  -- bMaxPower = 500 mA
        -- 9 bytes interface descriptor (communication control class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"00",                  -- bInterfaceNumber = 0
        X"00",                  -- bAlternateSetting = 0
        X"01",                  -- bNumEndpoints = 1
        X"02",                  -- bInterfaceClass = Communication Interface
        X"02",                  -- bInterfaceSubClass = Abstract Control Model
        X"01",                  -- bInterfaceProtocol = V.25ter (required for Linux CDC-ACM driver)
        X"00",                  -- iInterface = none
        -- 5 bytes functional descriptor (header)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"00",                  -- bDescriptorSubtype = header
        X"10", X"01",           -- bcdCDC = 1.10
        -- 4 bytes functional descriptor (abstract control management)
        X"04",                  -- bLength = 4 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"02",                  -- bDescriptorSubtype = Abstract Control Mgmnt
        X"00",                  -- bmCapabilities = none
        --X"04",                  -- bmCapabilities = sends break
        -- 5 bytes functional descriptor (union)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"06",                  -- bDescriptorSubtype = union
        X"00",                  -- bMasterInterface = 0
        X"01",                  -- bSlaveInterface0 = 1
        -- 5 bytes functional descriptor (call management)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"01",                  -- bDescriptorSubType = Call Management
        X"00",                  -- bmCapabilities = no call mgmnt
        X"01",                  -- bDataInterface = 1
        -- 7 bytes endpoint descriptor (notify IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"82",                  -- bEndpointAddress = IN 2
        X"03",                  -- bmAttributes = interrupt data
        X"08", X"00",           -- wMaxPacketSize = 8 bytes
        X"0f",                  -- bInterval = 2**14 frames
        -- 9 bytes interface descriptor (data class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"01",                  -- bInterfaceNumber = 1
        X"00",                  -- bAlternateSetting = 0
        X"02",                  -- bNumEndpoints = 2
        X"0a",                  -- bInterfaceClass = Data Interface
        X"00",                  -- bInterfaceSubClass = none
        X"00",                  -- bInterafceProtocol = none
        X"00",                  -- iInterface = none
	-- 7 bytes endpoint descriptor (data IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"81",                  -- bEndpointAddress = IN 1
        X"02",                  -- bmAttributes = bulk data
        X"00", X"02",           -- wMaxPacketSize = 512 bytes
        X"00",                  -- bInterval
        -- 7 bytes endpoint descriptor (data OUT)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"01",                  -- bEndpointAddress = OUT 1
        X"02",                  -- bmAttributes = bulk data
        X"00", X"02",           -- wMaxPacketSize = 512 bytes
        X"00"                   -- bInterval = never NAK
        );

    constant USBFS_CDC_config_ethernet: t_byte_array :=
    (
        -- 64 bytes full-speed configuration descriptor
        -- 9 bytes configuration header
        X"09",                  -- bLength = 9 bytes
        X"02",                  -- bDescriptorType = configuration descriptor
        X"40", X"00",           -- wTotalLength = 64 bytes
        X"02",                  -- bNumInterfaces = 2
        X"01",                  -- bConfigurationValue = 1
        X"00",                  -- iConfiguration = none - no string
        X"80", -- choose_byte(SELFPOWERED, X"C0", X"80"), -- bmAttributes
        X"FA",                  -- bMaxPower = 500 mA
        -- 9 bytes interface descriptor (communication control class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"00",                  -- bInterfaceNumber = 0
        X"00",                  -- bAlternateSetting = 0
        X"00",                  -- bNumEndpoints = 0
        X"02",                  -- bInterfaceClass = Communication Interface
        X"06",                  -- bInterfaceSubClass = Ethernet Control Model
        X"00",                  -- bInterfaceProtocol = no specific protocol
        X"00",                  -- iInterface = none - no string
        -- 5 bytes functional descriptor (header)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"00",                  -- bDescriptorSubtype = header
        X"10", X"01",           -- bcdCDC = 1.10
        -- 5 bytes functional descriptor (union)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"06",                  -- bDescriptorSubtype = union
        X"00",                  -- bMasterInterface = 0
        X"01",                  -- bSlaveInterface0 = 1
        -- 13 bytes functional descriptor (ethernet control management)
        X"0D",                  -- bLength = 13 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"0F",                  -- bDescriptorSubtype = Ethernet Control Mgmnt
        X"03",                  -- iMacAddress index of MAC address, same as SERIALSTR
        X"00", X"00", x"00", x"00", -- bmEthernetStatistics - none
        X"EA", X"05",           -- wMaxSegementSize (should be 1514)
        X"00", X"00",           -- wNumberMCFilters (0)
        X"00",                  -- wNumberPowerFilters
        -- 9 bytes interface descriptor (data class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"01",                  -- bInterfaceNumber = 1
        X"00",                  -- bAlternateSetting = 0
        X"02",                  -- bNumEndpoints = 2
        X"0A",                  -- bInterfaceClass = Data Interface
        X"00",                  -- bInterfaceSubClass = none
        X"00",                  -- bInterafceProtocol = none
        X"00",                  -- iInterface = none
	-- 7 bytes endpoint descriptor (data IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"81",                  -- bEndpointAddress = IN 1
        X"02",                  -- bmAttributes = bulk data
        X"40", X"00",           -- wMaxPacketSize = 64 bytes
        X"00",                  -- bInterval
        -- 7 bytes endpoint descriptor (data OUT)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"01",                  -- bEndpointAddress = OUT 1
        X"02",                  -- bmAttributes = bulk data
        X"40", X"00",           -- wMaxPacketSize = 64 bytes
        X"00"                   -- bInterval
  );

  -- "high speed": copy/paste of "full speed" from above,
  -- differs only in bcdCDC and wMaxPacketSize
  constant USBHS_CDC_config_ethernet: t_byte_array :=
  (
        -- 64 bytes high-speed configuration descriptor (not used)
        -- 9 bytes configuration header
        X"09",                  -- bLength = 9 bytes
        X"02",                  -- bDescriptorType = configuration descriptor
        X"40", X"00",           -- wTotalLength = 64 bytes
        X"02",                  -- bNumInterfaces = 2
        X"01",                  -- bConfigurationValue = 1
        X"00",                  -- iConfiguration = none - no string
        X"80", -- choose_byte(SELFPOWERED, X"C0", X"80"), -- bmAttributes
        X"FA",                  -- bMaxPower = 500 mA
        -- 9 bytes interface descriptor (communication control class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"00",                  -- bInterfaceNumber = 0
        X"00",                  -- bAlternateSetting = 0
        X"00",                  -- bNumEndpoints = 0
        X"02",                  -- bInterfaceClass = Communication Interface
        X"06",                  -- bInterfaceSubClass = Ethernet Control Model
        X"00",                  -- bInterfaceProtocol = no specific protocol
        X"00",                  -- iInterface = none - no string
        -- 5 bytes functional descriptor (header)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"00",                  -- bDescriptorSubtype = header
        X"00", X"02",           -- bcdCDC = 2.00
        -- 5 bytes functional descriptor (union)
        X"05",                  -- bLength = 5 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"06",                  -- bDescriptorSubtype = union
        X"00",                  -- bMasterInterface = 0
        X"01",                  -- bSlaveInterface0 = 1
        -- 13 bytes functional descriptor (ethernet control management)
        X"0D",                  -- bLength = 13 bytes
        X"24",                  -- bDescriptorType = CS_INTERFACE
        X"0F",                  -- bDescriptorSubtype = Ethernet Control Mgmnt
        X"03",                  -- iMacAddress index of MAC address, same as SERIALSTR
        X"00", X"00", x"00", x"00", -- bmEthernetStatistics - none
        X"EA", X"05",           -- wMaxSegementSize (should be 1514)
        X"00", X"00",           -- wNumberMCFilters (0)
        X"00",                  -- wNumberPowerFilters
        -- 9 bytes interface descriptor (data class)
        X"09",                  -- bLength = 9 bytes
        X"04",                  -- bDescriptorType = interface descriptor
        X"01",                  -- bInterfaceNumber = 1
        X"00",                  -- bAlternateSetting = 0
        X"02",                  -- bNumEndpoints = 2
        X"0A",                  -- bInterfaceClass = Data Interface
        X"00",                  -- bInterfaceSubClass = none
        X"00",                  -- bInterafceProtocol = none
        X"00",                  -- iInterface = none
	-- 7 bytes endpoint descriptor (data IN)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"81",                  -- bEndpointAddress = IN 1
        X"02",                  -- bmAttributes = bulk data
        X"00", X"02",           -- wMaxPacketSize = 512 bytes
        X"00",                  -- bInterval
        -- 7 bytes endpoint descriptor (data OUT)
        X"07",                  -- bLength = 7 bytes
        X"05",                  -- bDescriptorType = endpoint descriptor
        X"01",                  -- bEndpointAddress = OUT 1
        X"02",                  -- bmAttributes = bulk data
        X"00", X"02",           -- wMaxPacketSize = 512 bytes
        X"00"                   -- bInterval = never NAK
  );
end;
