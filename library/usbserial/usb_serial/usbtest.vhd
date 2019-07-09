--
--  USB test application
--
--  There are two test modes: text mode and binary mode.
--  The initial mode is text mode.
--
--  In text mode, the device reads bytes from the host until it receives
--  a carriage return character. It responds by sending the received byte
--  sequence in reverse order followed by carriage return and linefeed.
--  The device then goes back to reading data from the host.
--  If the host sends more than 1020 bytes between carriage returns, only
--  the first 1020 bytes are returned.
--
--  In text mode, the following byte values have a special meaning:
--    0x00 : ignored
--    0x01 : switch to binary mode
--    0x02 : reset device and reconnect to the USB bus
--    0x04 : enable TXCORK flag
--    0x05 : disable TXCORK flag (also done automatically if TX buffer full)
--    0x06 : send a synchronous stream
--    0x07 : send an asynchronous blast
--
--  In binary mode, the device reads a stream of requests from the host.
--  A request consists of two bytes: C and V.
--  If (C > 0), the device reponds by sending C bytes with values counting
--  up from V.
--  If (C == 0) and (V > 0), the device sleeps for ~ (V/60.0) seconds.
--  If (C == 0) and (V == 0), the device switches to text mode.
--
--  For example, given the request stream [ 3, 2, 0, 3, 1, 1 ],
--  the device responds by sending [ 2, 3, 4 ] then sleeping for 0.05 seconds,
--  then sending [ 1 ].
--
--  In stream mode, the device autonomously sends a sequence of 64*1024*1024
--  bytes. Flow control is applied by pausing the data sequence when the
--  transmit buffer is full. The payload is an incrementing sequence,
--  starting from 0 and wrapping at 253. The device switches back to text
--  mode at the end of the stream.
--
--  In blast mode, the device autonomously sends 64*1024*1024 bytes without
--  regard for flow control. If the transmit buffer is full, bytes are lost.
--  Data byte rate is 25 MHz.
--

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity usbtest is

    port(
        LED :             out std_logic;
        dsctyp :          out std_logic_vector(2 downto 0);
        BREAK :           out std_logic;
	CLK :             in  std_logic; -- application side clock, currently same as PHY_CLKOUT
	PHY_DATABUS16_8 : out std_logic;
	PHY_RESET :       out std_logic;
	PHY_XCVRSELECT :  out std_logic;
	PHY_TERMSELECT :  out std_logic;
	PHY_OPMODE :      out std_logic_vector(1 downto 0);
	PHY_LINESTATE :   in  std_logic_vector(1 downto 0);
	PHY_CLKOUT:       in  std_logic; -- clock from USB PHY 48 or 60 MHz
	PHY_TXVALID :     out std_logic;
	PHY_TXREADY :     in  std_logic;
	PHY_RXVALID :     in  std_logic;
	PHY_RXACTIVE :    in  std_logic;
	PHY_RXERROR :     in  std_logic;
	PHY_DATAIN :      in  std_logic_vector(7 downto 0);
	PHY_DATAOUT :     out std_logic_vector(7 downto 0) );

end entity usbtest;

architecture arch of usbtest is

    constant RXBUFSIZE_BITS : integer := 11;
    constant TXBUFSIZE_BITS : integer := 10;
    constant BLAST_DUTY_OFF : integer := 7;
    constant BLAST_DUTY_ON :  integer := 5;

    -- USB interface signals
    signal usb_devreset :   std_logic;
    signal usb_busreset :   std_logic;
    signal usb_highspeed :  std_logic;
    signal usb_suspend :    std_logic;
    signal usb_online :     std_logic;
    signal usb_rxval :      std_logic;
    signal usb_rxdat :      std_logic_vector(7 downto 0);
    signal usb_rxrdy :      std_logic;
    signal usb_rxlen :      std_logic_vector(RXBUFSIZE_BITS-1 downto 0);
    signal usb_txval :      std_logic;
    signal usb_txdat :      std_logic_vector(7 downto 0);
    signal usb_txrdy :      std_logic;
    signal usb_txroom :     std_logic_vector(TXBUFSIZE_BITS-1 downto 0);

    -- General purpose counter
    signal clkcnt : unsigned(24 downto 0);

    -- State machine
    type t_state is (
	ST_INIT, ST_RESET,
	ST_READTEXT, ST_WRITETEXT,
	ST_READCNT, ST_READVAL, ST_SLEEP, ST_WRITEBIN,
        ST_STREAM, ST_BLAST, ST_WRITEBLAST );
    signal s_state : t_state := ST_INIT;
    signal s_ptr : unsigned(9 downto 0) := to_unsigned(0, 10);
    signal s_bytecnt : unsigned(25 downto 0);
    signal s_byteval : unsigned(7 downto 0);
    signal s_txcork : std_logic := '0';
    signal s_blastctl : unsigned(5 downto 0);

    -- Block RAM
    type t_mem is array(0 to 1023) of std_logic_vector(7 downto 0);
    signal mem : t_mem;
    signal mem_rdat : std_logic_vector(7 downto 0) := "00000000";
    signal mem_rbuf : std_logic_vector(7 downto 0) := "00000000";
    signal mem_peek : std_logic := '0';
    signal mem_wdat : std_logic_vector(7 downto 0) := "00000000";
    signal mem_wr : std_logic := '1';

begin

    -- Direct interface to serial data transfer component
    usb_serial_inst : entity work.usb_serial
        generic map (
            VENDORID        => X"fb9a",
            PRODUCTID       => X"fb9a",
            VERSIONBCD      => X"0031",
            VENDORSTR       => "Vendor",
            PRODUCTSTR      => "Product",
            SERIALSTR       => "20181227",
            HSSUPPORT       => false,
            SELFPOWERED     => false,
            RXBUFSIZE_BITS  => RXBUFSIZE_BITS,
            TXBUFSIZE_BITS  => TXBUFSIZE_BITS )
        port map (
            CLK             => CLK,
            RESET           => usb_devreset,
            USBRST          => usb_busreset,
            HIGHSPEED       => usb_highspeed,
            SUSPEND         => usb_suspend,
            ONLINE          => usb_online,
            RXVAL           => usb_rxval,
            RXDAT           => usb_rxdat,
            RXRDY           => usb_rxrdy,
            RXLEN           => usb_rxlen,
            TXVAL           => usb_txval,
            TXDAT           => usb_txdat,
            TXRDY           => usb_txrdy,
            TXROOM          => usb_txroom,
            TXCORK          => s_txcork,
            BREAK           => BREAK,
            dsctyp          => dsctyp, -- debugging
            PHY_CLK         => PHY_CLKOUT,
            PHY_DATAIN      => PHY_DATAIN,
            PHY_DATAOUT     => PHY_DATAOUT,
            PHY_TXVALID     => PHY_TXVALID,
            PHY_TXREADY     => PHY_TXREADY,
            PHY_RXACTIVE    => PHY_RXACTIVE,
            PHY_RXVALID     => PHY_RXVALID,
            PHY_RXERROR     => PHY_RXERROR,
            PHY_LINESTATE   => PHY_LINESTATE,
            PHY_OPMODE      => PHY_OPMODE,
            PHY_XCVRSELECT  => PHY_XCVRSELECT,
            PHY_TERMSELECT  => PHY_TERMSELECT,
            PHY_RESET       => PHY_RESET );

    -- Configure USB PHY
    PHY_DATABUS16_8 <= '0';		-- 8 bit mode

    -- Show USB status on LED
    LED <= '0' when (
        -- suspended -> on
        (usb_suspend = '1') or
        -- offline -> blink 8%
        (usb_online = '0' and clkcnt(24 downto 22) = "000") or
        -- highspeed -> fast blink 50%
        (usb_online = '1' and usb_highspeed = '1' and clkcnt(22) = '0') or
        -- fullspeed -> slow blink 50%
        (usb_online = '1' and usb_highspeed = '0' and clkcnt(24) = '0') ) else '1';

    -- Assign signals to USB component
    usb_devreset <= '1' when (s_state = ST_RESET) else '0';
    usb_rxrdy <= '1' when (s_state = ST_READTEXT or s_state = ST_READCNT or s_state = ST_READVAL) else '0';
    usb_txval <= '1' when (s_state = ST_WRITETEXT or s_state = ST_WRITEBIN or
                           s_state = ST_STREAM or s_state = ST_WRITEBLAST) else '0';
    usb_txdat <= mem_rdat when (s_state = ST_WRITETEXT and mem_peek = '1') else
                 mem_rbuf when (s_state = ST_WRITETEXT and mem_peek = '0') else
                 std_logic_vector(s_byteval);

    process is
    begin
        wait until rising_edge(CLK);

        -- Clock counter
        clkcnt <= clkcnt + 1;

        -- Read/write block RAM
        if mem_wr = '1' then
            mem(to_integer(s_ptr)) <= mem_wdat;
            mem_rdat <= mem_wdat;
        else
            mem_rdat <= mem(to_integer(s_ptr));
        end if;
        mem_wr <= '0';

        -- State machine
        case s_state is

            when ST_INIT =>
                -- Initialize block RAM
                mem_wr <= '1';
                s_ptr <= s_ptr + 1;
                if s_ptr = 0 then
                    mem_wdat <= "00001010"; -- line feed
                elsif s_ptr = to_unsigned(1, s_ptr'length) then
                    mem_wdat <= "00001101"; -- carriage return
                    s_state <= ST_READTEXT;
                end if;

            when ST_RESET =>
                -- Reset USB component
                s_state <= ST_READTEXT;
                s_txcork <= '0';

            when ST_READTEXT =>
                -- (text mode) receiving data
                if usb_rxval = '1' then
                    if usb_rxdat = "00000000" then
                        -- ignore
                        s_state  <= ST_READTEXT;
                    elsif usb_rxdat = "00000001" then
                        -- switch to binary mode
                        s_state  <= ST_READCNT;
                        s_txcork <= '0';
                    elsif usb_rxdat = "00000010" then
                        -- reset USB component
                        s_state <= ST_RESET;
                    elsif usb_rxdat(7 downto 1) = "0000010" then
                        -- set TXCORK flag
                        s_txcork <= not usb_rxdat(0);
                    elsif usb_rxdat = "00000110" then
                        -- switch to synchronous stream mode
                        s_state <= ST_STREAM;
                        s_bytecnt <= to_unsigned(0, s_bytecnt'length) - 1;
                        s_byteval <= "00000000";
                        s_txcork <= '0';
                    elsif usb_rxdat = "00000111" then
                        -- switch to asynchronous blast mode
                        s_state <= ST_BLAST;
                        s_bytecnt <= to_unsigned(0, s_bytecnt'length) - 1;
                        s_byteval <= "00000000";
                        s_txcork <= '0';
                    elsif usb_rxdat = "00001101" then
                        -- carriage return
                        s_state <= ST_WRITETEXT;
                        s_ptr <= s_ptr - 1;
                        mem_peek <= '1';
                    elsif (s_ptr + 1) /= 0 then
                        -- store byte in buffer
                        mem_wr <= '1';
                        mem_wdat <= usb_rxdat;
                        s_ptr <= s_ptr + 1;
                    end if;
                end if;

            when ST_WRITETEXT =>
                -- (text mode) sending data
                if mem_peek = '1' then
                    mem_rbuf <= mem_rdat;
                end if;
                mem_peek <= usb_txrdy;
                if usb_txrdy = '1' then
                    if s_ptr = 0 then
                        -- done
                        s_state <= ST_READTEXT;
                        s_ptr <= to_unsigned(2, s_ptr'length);
                    else
                        s_ptr <= s_ptr - 1;
                    end if;
                else
                    s_txcork <= '0';
                end if;
 
            when ST_READCNT =>
                -- (bin mode) waiting for count byte
                if usb_rxval = '1' then
                    s_bytecnt <= resize(unsigned(usb_rxdat), s_bytecnt'length);
                    s_state <= ST_READVAL;
                end if;

            when ST_READVAL =>
                -- (bin mode) waiting for val byte
                if usb_rxval = '1' then
                    s_byteval <= unsigned(usb_rxdat);
                    if (s_bytecnt = 0) and (usb_rxdat = "00000000") then
                        -- switch to text mode
                        s_state <= ST_READTEXT;
                        s_ptr <= to_unsigned(2, s_ptr'length);
                    elsif s_bytecnt = 0 then
                        s_state <= ST_SLEEP;
                    else
                        s_state <= ST_WRITEBIN;
                    end if;
                end if;

            when ST_SLEEP =>
                -- (bin mode) sleeping
                if clkcnt(19 downto 0) = 0 then
                    if s_byteval = 0 then
                        -- done
                        s_state <= ST_READCNT;
                    end if;
                    s_byteval <= s_byteval - 1;
                end if;

            when ST_WRITEBIN =>
                -- (bin mode) sending bytes
                if usb_txrdy = '1' then
                    -- to next byte
                    if s_bytecnt = 1 then
                        -- done
                        s_state <= ST_READCNT;
                    end if;
                    s_bytecnt <= s_bytecnt - 1;
                    s_byteval <= s_byteval + 1;
                end if;

            when ST_STREAM =>
                -- (stream mode) sending incrementing byte stream
                if usb_txrdy = '1' then
                    if s_bytecnt = 0 then
                        -- switch to text mode
                        s_state <= ST_READTEXT;
                        s_ptr   <= to_unsigned(2, s_ptr'length);
                    end if;
                    s_bytecnt <= s_bytecnt - 1;
                    if s_byteval = 252 then
                        s_byteval <= to_unsigned(0, 8);
                    else
                        s_byteval <= s_byteval + 1;
                    end if;
                end if;

            when ST_BLAST =>
                -- (blast mode) sending incrementing byte stream
                if s_blastctl = BLAST_DUTY_OFF - 1 then
                    s_state <= ST_WRITEBLAST;
                    s_blastctl <= to_unsigned(0, s_blastctl'length);
                else
                    s_blastctl <= s_blastctl + 1;
                end if;

            when ST_WRITEBLAST =>
                -- (blast mode)
                if s_bytecnt = 0 then
                    -- switch to text mode
                    s_state <= ST_READTEXT;
                    s_ptr   <= to_unsigned(2, s_ptr'length);
                elsif s_blastctl = BLAST_DUTY_ON - 1 then
                    s_state <= ST_BLAST;
                    s_blastctl <= to_unsigned(0, s_blastctl'length);
                else
                    s_blastctl <= s_blastctl + 1;
                end if;
                s_bytecnt <= s_bytecnt - 1;
                if s_byteval = 252 then
                    s_byteval <= to_unsigned(0, 8);
                else
                    s_byteval <= s_byteval + 1;
                end if;

         end case;

    end process;

end architecture arch;

