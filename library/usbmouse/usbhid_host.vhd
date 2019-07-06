library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

library hdl4fpga;
use hdl4fpga.usb_req_gen_func_pack.ALL; -- we need reverse_any_vector()
use hdl4fpga.hid_enum_pack.ALL;

entity usbhid_host is
Generic
(
  C_differential_mode: boolean := false; -- use differential input
  REPORT_LEN : integer := 8 -- bytes report len
);
Port
(
  clk        : in    std_logic; -- 7.5 MHz clock for USB1.0, 60 MHz for USB1.1
  reset      : in    std_logic := '0'; -- async reset
  USB_DATA   : inout std_logic_vector(1 downto 0); -- USB_DATA(1)=D+ USB_DATA(0)=D- both pull down 15k
  USB_DDATA  : in    std_logic; -- D+ from differential input
  HID_REPORT : out   std_logic_vector(8*REPORT_LEN-1 downto 0);
  HID_VALID  : out   std_logic;
  dbg_step_ps3 : out std_logic_vector(7 downto 0);
  dbg_step_cmd : out std_logic_vector(7 downto 0);
  LEDS       : out   std_logic_vector(7 downto 0)
);
end;

architecture Behavioral of usbhid_host is

constant EOP:std_logic_vector(1 downto 0):="00";

function bit2data(b:std_logic) return std_logic_vector is
begin
	if b='0' then
		return ZERO;
	else
		return UN;
	end if;
end function;

constant SYNCHRO:std_logic_vector(7 downto 0):="01010100";

constant ACK  :std_logic_vector(7 downto 0):="01001011";
constant NACK :std_logic_vector(7 downto 0):="01011010";
constant STALL:std_logic_vector(7 downto 0):="01110001";
constant DATA1:std_logic_vector(7 downto 0):="11010010";
constant DATA0:std_logic_vector(7 downto 0):="11000011";
constant SETUP:std_logic_vector(7 downto 0):="10110100";

-- old constants with already calculated supplied CRC,
-- good as examples for checking if CRC functions works correctly
--constant ADDR0_ENDP0:std_logic_vector(11+5-1 downto 0):="00000000000" & "01000";
--constant ADDR1_ENDP0:std_logic_vector(11+5-1 downto 0):="10000000000" & "10111";
--constant ADDR1_ENDP1:std_logic_vector(11+5-1 downto 0):="10000001000" & "11010";
--constant GET_DESCRIPTOR_DEVICE_40h   :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"10000000" & "00000000"&"00000000" & "00000010"&"00000000" & "1011101100101001";
--constant SET_ADDRESS_1		     :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000000" & "10100000" & "10000000"&"00000000" & "00000000"&"00000000" & "00000000"&"00000000" & "1101011110100100";
--constant GET_DESCRIPTOR_DEVICE_12h   :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"10000000" & "00000000"&"00000000" & "01001000"&"00000000" & "0000011100101111";
--constant GET_DESCRIPTOR_CONFIG_FFh   :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"01000000" & "00000000"&"00000000" & "11111111"&"00000000" & "1001011100100101";
--constant GET_DESCRIPTOR_STRING_0_FFh :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"11000000" & "00000000"&"00000000" & "11111111"&"00000000" & "0010101100100110";
--constant GET_DESCRIPTOR_STRING_2_FFh :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "01000000"&"11000000" & "10010000"&"00100000" & "11111111"&"00000000" & "1110100111011011";
--constant GET_DESCRIPTOR_CONFIG_09h   :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"01000000" & "00000000"&"00000000" & "10010000"&"00000000" & "0111010100100000";
--constant GET_DESCRIPTOR_CONFIG_29h   :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000001" & "01100000" & "00000000"&"01000000" & "00000000"&"00000000" & "10010100"&"00000000" & "1110110100100011";
--constant SET_CONFIGURATION_1	     :std_logic_vector(11*8-1 downto 0):=DATA0 & "00000000" & "10010000" & "10000000"&"00000000" & "00000000"&"00000000" & "00000000"&"00000000" & "1110010010100100";
--constant GET_INTERFACE_0	     :std_logic_vector(11*8-1 downto 0):=DATA0 & "10000100" & "01010000" & "00000000"&"00000000" & "00000000"&"00000000" & "00000000"&"00000000" & "0110101100000100";
--constant GET_DESCRIPTOR_REPORT_B7h   :std_logic_vector(11*8-1 downto 0):=DATA0 & "10000001" & "01100000" & "00000000"&"01000100" & "00000000"&"00000000" & "11101101"&"00000000" & "1111100111110101";

-- saitek cyborg joystick constants using packet generator function that
-- automatically appends CRC
-- defined in package usb_enum_<device>_pack.vhd
--constant C_ADDR0_ENDP0                : std_logic_vector(11+5-1 downto 0) := usb_token_gen("00000000000");
--constant C_ADDR0_ENDP1                : std_logic_vector(11+5-1 downto 0) := usb_token_gen("00010000000");
--constant C_ADDR1_ENDP0                : std_logic_vector(11+5-1 downto 0) := usb_token_gen("00000000001");
--constant C_ADDR1_ENDP1                : std_logic_vector(11+5-1 downto 0) := usb_token_gen("00010000001");
--constant C_DATA0: std_logic_vector(7 downto 0) := reverse_any_vector(DATA0); -- DATA0 is reversed bit order

-- modprobe usbmon
-- chown user:user /dev/usbmon*
-- wireshark
-- plug joystick and move it or replug few times in/out
-- to find out which usbmon device receives its traffic, then select it to capture
-- plug joystick in
-- find 8-byte data from sniffed "URB setup" source host
-- e.g. 80 06 00 01 00 00 12 00 and copy it here as x"80_06_00_01_00_00_12_00":
-- and at the end of this file, modify state machine to replay those packets to the joystick
--constant C_GET_DESCRIPTOR_DEVICE_40h  : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_00_01_00_00_40_00");
--constant C_URB_CONTROL_OUT_3_4h       : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"23_03_04_00_01_00_00_00");
--constant C_URB_CONTROL_IN_4h          : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"A3_00_00_00_01_00_04_00");
--constant C_URB_CONTROL_OUT_1_14h      : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"23_01_14_00_01_00_00_00");
--constant C_GET_DESCRIPTOR_DEVICE_12h  : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_00_01_00_00_12_00");
--constant C_GET_DESCRIPTOR_CONFIG_09h  : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_00_02_00_00_09_00");
--constant C_GET_DESCRIPTOR_CONFIG_29h  : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_00_02_00_00_29_00");
--constant C_GET_DESCRIPTOR_STRING_0_FFh: std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_00_03_00_00_FF_00");
--constant C_GET_DESCRIPTOR_STRING_1_FFh: std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_01_03_09_04_FF_00");
--constant C_GET_DESCRIPTOR_STRING_2_FFh: std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"80_06_02_03_09_04_FF_00");
--constant C_SET_CONFIGURATION_1        : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"00_09_01_00_00_00_00_00");
--constant C_SET_IDLE_0                 : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"21_0A_00_00_00_00_00_00");
--constant C_GET_DESCRIPTOR_REPORT_277h : std_logic_vector(11*8-1 downto 0) := usb_data_gen(C_DATA0 & x"81_06_00_22_00_00_77_02");
--

constant OUT_OUT:std_logic_vector(7 downto 0):="10000111";
constant OUT_DATA1:std_logic_vector(3*8-1 downto 0):=DATA1 & "0000000000000000";

--constant GET_DESCRIPTOR_CONFIG_SETUP:std_logic_vector(3*8-1 downto 0):="10110100" & "10000000"&"000" & "10111";
--constant GET_DESCRIPTOR_CONFIG_SETUP_DATA0:std_logic_vector(11*8-1 downto 0):="11000011" & "00000001"&"01100000" & "00000000"&"01000000" & "00000000"&"00000000" & "10010000"&"00000000" & "0111010100100000";
--constant GET_DESCRIPTOR_CONFIG_SETUP_DATA0:std_logic_vector(11*8-1 downto 0):="11000011" & "00000001"&"01100000" & "00000000"&"01000000" & "00000000"&"00000000" & "10010100"&"00000000" & "1110110100100011";

constant SOF:std_logic_vector(7 downto 0):="10100101"; -- non NRZI

constant IN_IN:std_logic_vector(7 downto 0):="10010110";

constant period_RESET:integer:=1486684; --100-200ms >1486684< + 96147; --

constant period_IDLE:integer:=409;
constant period_EOP:integer:=1;

constant period_SOF:integer:=12000; --11890+8+3*8+2; --11924

constant PAS:integer:=5;
constant DEMI_PAS:integer:=2;--5/2;

constant TIME_OUT:integer:=8; -- 7.5bit

signal step_cmd: integer range 0 to C_usb_enum_sequence'high := 0;

signal S_data2bit: std_logic;

signal R_valid: std_logic;

begin

dbg_step_cmd <= conv_std_logic_vector(step_cmd,8);
G_no_differential:
if not C_differential_mode generate
  S_data2bit <= '0' when USB_DATA=ZERO else '1';
end generate;
G_yes_differential:
if C_differential_mode generate
  S_data2bit <= '0' when USB_DDATA=ZERO(1) else '1';
end generate;

process(clk) is
	variable step_ps3:integer range 0 to 41:=0;
	variable next_cmd:boolean:=false;
	variable counter_RESET:integer range 0 to period_RESET*PAS:=0;
	variable counter_IDLE:integer range 0 to period_IDLE+period_EOP:=0;
	variable counter_PAS:integer range 0 to PAS:=0;
	variable counter_SOF_stuff:integer range 0 to period_SOF:=0;
	
	variable counter_TRAME:integer:=0;
	
	variable last_USB_DATA:std_logic_vector(1 downto 0):=EOP;
	variable mode_receive:boolean:=false;
	variable JOY_mem:std_logic_vector(8*REPORT_LEN-1 downto 0):=reverse_any_vector(C_IDLE_REPORT);
	variable JOY_CANDIDATE_mem:std_logic_vector(8*REPORT_LEN-1 downto 0):=(others=>'0');
	constant DATA_MAX_SIZE:integer:=8*REPORT_LEN;
	variable SIZE_mem:std_logic_vector(7 downto 0):=(others=>'0');
	variable PID_mem:std_logic_vector(7 downto 0):=(others=>'0');
	variable CRC16_mem:std_logic_vector(15 downto 0):=(others=>'0');
	
	variable frame_number:std_logic_vector(10 downto 0):=(others=>'0');
	
	variable crc5_value:std_logic_vector(4 downto 0);
	procedure crc5_init is
	begin
		crc5_value:=(others=>'1');
	end procedure;
	subtype crc5_result is std_logic_vector(4 downto 0);
	function crc5(d:std_logic;crc5:std_logic_vector(4 downto 0)) return crc5_result is
		variable a:std_logic;
		variable b:std_logic;
		variable crc:std_logic_vector(4 downto 0);
	begin
		crc:=crc5; -- frontière pour a=f(a);
		b:=d; -- frontière (parano ?)
		a:=crc(4) xor b;
		crc:=crc(3 downto 0) & a;
		crc(2):=crc(2) xor a;
		return crc;
	end function;
	
	
	--x^16+x^15+x^2+1
	variable crc16_value:std_logic_vector(15 downto 0);
	procedure crc16_init is
	begin
		crc16_value:=(others=>'1');
	end procedure;
	subtype crc16_result is std_logic_vector(15 downto 0);
	function crc16(d:std_logic;crc16:std_logic_vector(15 downto 0)) return crc16_result is
		variable a:std_logic;
		variable b:std_logic;
		variable crc:std_logic_vector(15 downto 0);
	begin
		crc:=crc16; -- frontière pour a=f(a);
		b:=d; -- frontière (parano ?)
		a:=crc(15) xor b;
		crc:=crc(14 downto 0) & a;
		crc(2):=crc(2) xor a;
		crc(15):=crc(15) xor a;
		return crc;
	end function;
	
	variable last_nrzi:std_logic;
	variable result:std_logic;
	procedure nrzi(d:std_logic;last_nrzi : inout std_logic;result: out std_logic) is
	begin
		if d='1' then
			--no change level
			result:=last_nrzi;
		else
			--change level
			last_nrzi:=not(last_nrzi);
			result:=last_nrzi;
		end if;
	end procedure;
	procedure nrzi_inv(d:std_logic;last_nrzi : inout std_logic;result: out std_logic) is
	begin
		if d=last_nrzi then
			--no change level
			result:='1';
		else
			--change level
			result:='0';
			last_nrzi:=d;
		end if;
	end procedure;
	
	
	
	variable zap:boolean:=false;
	variable counter6:integer range 0 to 5:=0;
	procedure stuff_init is
	begin
		counter6:=1;
	end procedure;
	procedure stuff(b:std_logic) is
	begin
		if b='1' then
			if counter6=5 then	
				counter6:=0;
				zap:=true;
			else
				counter6:=counter6+1;
			end if;
		else
			counter6:=0;
		end if;
	end procedure;
	
	variable sleep:boolean:=false;
	variable counter_sleep:integer:=0;
	procedure pause(p:integer) is
	begin
		sleep:=true;
		counter_sleep:=p;
	end procedure;
	
	variable time_out:boolean:=false;

	procedure startup_init is
	begin
	  step_ps3:=0;
	  next_cmd:=false;
	  counter_RESET:=0;
	  counter_IDLE:=0;
	  counter_PAS:=0;
	  counter_SOF_stuff:=0;
	  counter_TRAME:=0;
	end procedure;


	procedure sof_init is
	begin
		counter_RESET:=0;
--		counter_IDLE:=0;
		counter_SOF_stuff:=0;
		counter_TRAME:=0;
		counter_PAS:=0;
		mode_receive:=false;
	end procedure;
		
		
	procedure nrzi_init is
	begin
		last_nrzi:='0';
	end procedure;


	variable TRAME_GET_SETUP:std_logic_vector(8+11+5-1 downto 0):=SETUP & C_ADDR0_ENDP0;
	variable TRAME_GET_DATA0:std_logic_vector(11*8-1 downto 0):=C_GET_DESCRIPTOR_DEVICE_40h;
	variable IN_ADDR_ENDP:std_logic_vector(8+11+5-1 downto 0):=IN_IN & C_ADDR0_ENDP0;
	variable OUT_ADDR_ENDP:std_logic_vector(8+11+5-1 downto 0):=OUT_OUT & C_ADDR1_ENDP1;
	variable TRAME_OUT_DATA1:std_logic_vector(3*8-1 downto 0):=OUT_DATA1;
	variable TRAME_OUT_DATA1_length:integer range 0 to TRAME_OUT_DATA1'length:=0;
	procedure trame_read(ADDR_ENDP:std_logic_vector(11+5-1 downto 0); DATA:std_logic_vector(11*8-1 downto 0)) is
	begin
		TRAME_GET_SETUP:=SETUP & ADDR_ENDP;
		TRAME_GET_DATA0:=DATA;
		IN_ADDR_ENDP:=IN_IN & ADDR_ENDP;
		OUT_ADDR_ENDP:=OUT_OUT & ADDR_ENDP;
		TRAME_OUT_DATA1_length:=OUT_DATA1'length;
		TRAME_OUT_DATA1:=(others=>'0');
		TRAME_OUT_DATA1(TRAME_OUT_DATA1_length-1 downto 0):=OUT_DATA1;
		step_ps3:=18;
	end procedure;
	

	variable TRAME_SET_SETUP:std_logic_vector(8+11+5-1 downto 0):=SETUP & C_ADDR0_ENDP0;
	variable TRAME_SET_DATA0:std_logic_vector(11*8-1 downto 0):=C_SET_CONFIGURATION_1;
	procedure trame_set(ADDR_ENDP:std_logic_vector(11+5-1 downto 0); DATA:std_logic_vector(11*8-1 downto 0)) is
	begin
		TRAME_SET_SETUP:=SETUP & ADDR_ENDP;
		TRAME_SET_DATA0:=DATA;
		IN_ADDR_ENDP:=IN_IN & ADDR_ENDP;
		step_ps3:=7;
	end procedure;

	procedure plug(ADDR_ENDP:std_logic_vector(11+5-1 downto 0)) is
	begin
		IN_ADDR_ENDP:=IN_IN & ADDR_ENDP;
		
		step_ps3:=34;
	end procedure;

	variable interval:std_logic_vector(7 downto 0):=(others=>'0');
begin

dbg_step_ps3 <= conv_std_logic_vector(step_ps3,8);
HID_REPORT <= reverse_any_vector(JOY_mem);
HID_VALID <= R_valid; -- enable this and mouse stops working

if rising_edge(clk) then
  R_valid <= '0'; -- report valid for 1 cycle only

  if reset='1' then
    step_cmd <= 0;
    step_ps3 := 0;
    zap := false;
  end if; -- reset

  if reset='0' then
	--LEDS(3 downto 0)<=conv_std_logic_vector(step_cmd,8)(3 downto 0);
	--LEDS<=conv_std_logic_vector(step_ps3,8);

        --button_blink: if true then
	--for i in 4 to 7 loop
	--  LEDS(i)<= JOY_mem(i + 8*0)
	--        xor JOY_mem(i + 8*1)
	--        xor JOY_mem(i + 8*2)
	--        xor JOY_mem(i + 8*3)
	--        xor JOY_mem(i + 8*4)
	--        xor JOY_mem(i + 8*5)
	--        xor JOY_mem(i + 8*6)
	--        xor JOY_mem(i + 8*7);
	--end loop;
	--end if;

	if zap then
		if counter_PAS=DEMI_PAS then
			if mode_receive then
				--nrzi('0',last_nrzi,result);
				nrzi_inv(S_data2bit,last_nrzi,result);
				if result='0' then
					--cool
				else
					-- pas cool
					crc16_value:=(others=>'0');
					crc5_value:=(others=>'0');
					-- TRAMES TROP LONGUE POUR TOLERER FATAL ERROR step_ps3:=2;
				end if;
			else
				nrzi('0',last_nrzi,result);
				USB_DATA<=bit2data(result);
			end if;
			zap:=false;
		end if;
	elsif sleep then
		if counter_PAS=DEMI_PAS then
			USB_DATA<="ZZ";
			counter_sleep:=counter_sleep-1;
			if counter_sleep=0 then
				sleep:=false;
			end if;
		end if;
	elsif time_out then
		mode_receive:=false;
		if counter_IDLE=0 then
			USB_DATA<=EOP;
		else
			USB_DATA<=UN;
		end if;
		if counter_SOF_stuff=0 then
			time_out:=false;
			sof_init;
		end if;
	else
		case step_ps3 is
			--=========
			-- CONNECT
			--=========
			when 0=>
				USB_DATA<="ZZ";
				startup_init;
				step_ps3:=3;
				JOY_mem := reverse_any_vector(C_IDLE_REPORT);
			when 1=> -- test
			when 2=> -- erreur zap en mode_receive
			when 3=>
				if USB_DATA=UN then
					step_ps3:=4;
				end if;
			--=======
			-- RESET
			--=======
			when 4=>
				USB_DATA<=EOP;
				if counter_RESET=period_RESET*PAS-1 then
					counter_RESET:=0;
					step_ps3:=5;
					USB_DATA<="ZZ";
				else
					counter_RESET:=counter_RESET+1;
				end if;
			when 5=>
				-- end of reset
				if USB_DATA=UN then
					step_ps3:=6;
				end if;
			when 6=>
				USB_DATA<=UN;
				if counter_RESET=10*PAS-1 then
					step_ps3:=1;
					next_cmd:=true;
					sof_init;
				else
					counter_RESET:=counter_RESET+1;
				end if;
			--=====================================================
			-- TRAME SET (SOF,TRAME_SET_SETUP,TRAME_SET_DATA0,ACK)
			--=====================================================
			when 7=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						step_ps3:=8;
					end if;
					if step_ps3=7 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 8=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length then
						stuff(TRAME_SET_SETUP(8+TRAME_SET_SETUP'length -1-counter_TRAME));
						nrzi(TRAME_SET_SETUP(8+TRAME_SET_SETUP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 then -- on va dire 5 à la place de 3 IDLE
						USB_DATA<=UN;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8 then
						USB_DATA<=bit2data(SYNCHRO(8+TRAME_SET_SETUP'length+2+5 +8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length then
						stuff(TRAME_SET_DATA0(8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length -1-counter_TRAME));
						nrzi(TRAME_SET_DATA0(8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=9;
					else
						counter_TRAME:=0;
						time_out:=true;
						step_ps3:=7; -- next SOF
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 9=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+TRAME_SET_SETUP'length+2+5 +8+TRAME_SET_DATA0'length+2+1+1 +8 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=8;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=10;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 10=> -- reception ACK ????
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=11;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						if not(result=ACK(8+ACK'length -1-counter_TRAME)) then
							-- pas cool
							step_ps3:=11;counter_TRAME:=0;mode_receive:=false;
						end if;
					else
						pause(5);
						time_out:=true;
						step_ps3:=12; --next INSTRUCTION
					end if;
					if step_ps3=10 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 11=>
				-- wait EOP
				if counter_PAS=DEMI_PAS and USB_DATA=EOP then -- DEMI_PAS ? plus long ??? ne pas rendre un "entre deux états"
					pause(5);
					time_out:=true;
					step_ps3:=7; --next SOF
				end if;
			--==================================
			-- TRAME SET (SOF,IN_ADDR_ENDP,ACK)
			--==================================
			when 12=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						step_ps3:=13;
					end if;
					if step_ps3=12 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 13=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length then
						stuff(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME));
						nrzi(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=14;
					else
						step_ps3:=12;-- next SOF
						time_out:=true;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 14=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8*10 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=13;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=15;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 15=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=16;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						PID_mem(8+8 -1-counter_TRAME):=result;
						if counter_TRAME=8+8-1 then
							if PID_mem=DATA1 then
								-- cool
							elsif PID_mem=NACK then
								-- pas cool : attendre
								step_ps3:=16;counter_TRAME:=0;mode_receive:=false;
							else -- STALL or DATA0
								-- pas cool : reset cmd
								step_ps3:=11;counter_TRAME:=0;mode_receive:=false;
							end if;
						end if;
					elsif USB_DATA=EOP then
						SIZE_mem:=conv_std_logic_vector(counter_TRAME-16-16,8); -- NO_DATA=0
						counter_TRAME:=0;
						pause(5);
						mode_receive:=false;
						step_ps3:=17;
					else
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						-- DATA & CRC16
					end if;
					if step_ps3=15 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 16=>
				-- wait EOP
				if USB_DATA=EOP and counter_PAS=DEMI_PAS then
					pause(5);
					time_out:=true;
					step_ps3:=12; -- next SOF
				end if;
			when 17=>
				-- envoyer un ACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						stuff(ACK(8+ACK'length -1-counter_TRAME));
						nrzi(ACK(8+ACK'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+ACK'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+ACK'length+2+1 then
						USB_DATA<=UN;
					else
						pause(3);
						time_out:=true;
						step_ps3:=1;-- next SOF next INSTRUCTION
						next_cmd:=true;
					end if;
					if step_ps3=17 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			--========================================================
			-- TRAME_GET (SOF, TRAME_GET_SETUP, TRAME_GET_DATA0, ACK)
			--========================================================
			when 18=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						step_ps3:=19;
					end if;
					if step_ps3=18 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 19=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length then
						stuff(TRAME_GET_SETUP(8+TRAME_GET_SETUP'length -1-counter_TRAME));
						nrzi(TRAME_GET_SETUP(8+TRAME_GET_SETUP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 then -- on va dire 5 à la place de 3 IDLE
						USB_DATA<=UN;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8 then
						USB_DATA<=bit2data(SYNCHRO(8+TRAME_GET_SETUP'length+2+5 +8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length then
						stuff(TRAME_GET_DATA0(8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length -1-counter_TRAME));
						nrzi(TRAME_GET_DATA0(8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=20;
					else
						counter_TRAME:=0;
						time_out:=true;
						step_ps3:=18; -- next SOF
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 20=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+TRAME_GET_SETUP'length+2+5 +8+TRAME_GET_DATA0'length+2+1+1 +8 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=19;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=21;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 21=> -- reception ACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=22;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						if not(result=ACK(8+ACK'length -1-counter_TRAME)) then
							-- pas cool
							step_ps3:=22;counter_TRAME:=0;mode_receive:=false;
						end if;
					else
						pause(5);
						time_out:=true;
							step_ps3:=23; --24; next INSTRUCTION
					end if;
					if step_ps3=21 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 22=>
				-- wait EOP
				if USB_DATA=EOP and counter_PAS=DEMI_PAS then
					pause(5);
					time_out:=true;
					step_ps3:=18; -- next SOF
				end if;
			--========================
			-- TRAME_GET (SOF,IN_ADDR_ENDP,ACK)
			--========================
			when 23=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						step_ps3:=24;
					end if;
					if step_ps3=23 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 24=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length then
						stuff(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME));
						nrzi(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=25;
					else
						step_ps3:=23;-- next SOF
						time_out:=true;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 25=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8*10 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=24;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=26;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 26=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=27;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						PID_mem(8+8 -1-counter_TRAME):=result;
						if counter_TRAME=8+8-1 then
							crc16_init;
							if PID_mem=DATA1 or PID_mem=DATA0 then
								-- cool
							elsif PID_mem=NACK then
								-- pas cool : attendre
								step_ps3:=27;counter_TRAME:=0;mode_receive:=false;
							else -- STALL
								-- pas cool : reset cmd
								step_ps3:=22;counter_TRAME:=0;mode_receive:=false;
							end if;
						end if;
					elsif USB_DATA=EOP then
						SIZE_mem:=conv_std_logic_vector(counter_TRAME-16-16,8);
						counter_TRAME:=0;
						pause(5);
						mode_receive:=false;
						step_ps3:=28;
						if conv_integer(SIZE_mem)>0 then
							for i in 0 to 15 loop
								CRC16_mem(i):=not(CRC16_mem(i));
							end loop;
							if not(CRC16_mem=crc16_value) then
								step_ps3:=41; -- 40 IS NACK AND THEN TIME_OUT
							else
								--JOY_mem:=JOY_CANDIDATE_mem;
							end if;
						end if;
					else
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						if counter_TRAME>=8+8+16 then
							crc16_value:=crc16(CRC16_mem(15),crc16_value);
						end if;
						CRC16_mem:=CRC16_mem(14 downto 0) & result;
						-- DATA & CRC16


--						nrzi_inv(data2bit(USB_DATA),last_nrzi,result);
--						stuff(result);
						-- DATA & CRC16
					end if;
					if step_ps3=26 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 27=>
				-- wait EOP
				if USB_DATA=EOP and counter_PAS=DEMI_PAS then
					pause(5);
					time_out:=true;
					step_ps3:=23; -- next SOF
				end if;
			when 28=>
				-- envoyer un ACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						stuff(ACK(8+ACK'length -1-counter_TRAME));
						nrzi(ACK(8+ACK'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+ACK'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+ACK'length+2+1 then
						USB_DATA<=UN;
					else
						pause(3);
						time_out:=true;
						if conv_integer(SIZE_mem)=DATA_MAX_SIZE then
							--encore !
							step_ps3:=23; -- next SOF
						else
							--merci et au revoir
							--step_ps3:=1;
							step_ps3:=29; -- next SOF next INSTRUCTION
						end if;
					end if;
					if step_ps3=28 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;				
			when 41=>
				-- envoyer un NACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+NACK'length then
						stuff(NACK(8+NACK'length -1-counter_TRAME));
						nrzi(NACK(8+NACK'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+NACK'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+NACK'length+2+1 then
						USB_DATA<=UN;
					else
						pause(3);
						time_out:=true;
						--encore !
						step_ps3:=23; -- next SOF
					end if;
					if step_ps3=41 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			--========================
			-- TRAME_GET (SOF,OUT_ADDR_ENDP,OUT_DATA1,ACK)
			--========================
			when 29=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						step_ps3:=30;
					end if;
					if step_ps3=29 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 30=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length then
						stuff(OUT_ADDR_ENDP(8+OUT_ADDR_ENDP'length -1-counter_TRAME));
						nrzi(OUT_ADDR_ENDP(8+OUT_ADDR_ENDP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 then -- on va dire 5 à la place de 3 IDLE
						USB_DATA<=UN;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8 then
						USB_DATA<=bit2data(SYNCHRO(8+OUT_ADDR_ENDP'length+2+5 +8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length then
						stuff(TRAME_OUT_DATA1(8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length -1-counter_TRAME));
						nrzi(TRAME_OUT_DATA1(8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=31;
					else
						counter_TRAME:=0;
						time_out:=true;
						step_ps3:=29; -- next SOF
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 31=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+OUT_ADDR_ENDP'length+2+5 +8+TRAME_OUT_DATA1_length+2+1+1 +8 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=30;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=32;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 32=> -- reception ACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=33;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						if not(result=ACK(8+ACK'length -1-counter_TRAME)) then
							-- pas cool
							step_ps3:=33;counter_TRAME:=0;mode_receive:=false;
						end if;
					else
						pause(5);
						time_out:=true;
							step_ps3:=1; -- next INSTRUCTION
							next_cmd:=true;
					end if;
					if step_ps3=32 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 33=>
				-- wait EOP
				if USB_DATA=EOP and counter_PAS=DEMI_PAS then
					pause(5);
					time_out:=true;
					step_ps3:=29; -- next SOF
				end if;
			--=============================
			-- PLUG (SOF,IN_ADDR_ENDP,ACK)
			--=============================
			-- toujours vide, non lancé du coup
			when 34=>
			--PID_SOF
				--frame_number 0 to 11
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						stuff(SOF(8+8 -1-counter_TRAME));
						nrzi(SOF(8+8 -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_init;
					elsif counter_TRAME<8+8+11 then -- stuff osef (si ça passe pas, ça passe pas)
						stuff(frame_number(counter_TRAME-8-8));
						nrzi(frame_number(counter_TRAME-8-8),last_nrzi,result);
						USB_DATA<=bit2data(result);
						crc5_value:=crc5(frame_number(counter_TRAME-8-8),crc5_value);
					elsif counter_TRAME<8+8+11+5 then
						-- reverse and inverse
						stuff(not(crc5_value(8+8+11+5 -1-counter_TRAME)));
						nrzi(not(crc5_value(8+8+11+5 -1-counter_TRAME)),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+8+11+5+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+8+11+5+2+3 then
						USB_DATA<="ZZ";
					else
						counter_TRAME:=0;
						frame_number:=frame_number+1;
						
						if interval>bInterval+1 then
							interval:=x"00";
							step_ps3:=35;
						else
							interval:=interval+1;
							time_out:=true; -- wait next SOF
						end if;
						
					end if;
					if step_ps3=34 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 35=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length then
						stuff(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME));
						nrzi(IN_ADDR_ENDP(8+IN_ADDR_ENDP'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1 then
						USB_DATA<=UN;
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 then
						USB_DATA<="ZZ";
					elsif counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8 then
						-- TIME_OUT ?
						step_ps3:=36;
					else
						step_ps3:=34;-- next SOF
						time_out:=true;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
			when 36=> --
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8+IN_ADDR_ENDP'length+2+1+1 +8*10 then
						USB_DATA<="ZZ";
					else
						-- TIME_OUT
						step_ps3:=35;
					end if;
					counter_TRAME:=counter_TRAME+1;
				end if;
				
				if USB_DATA=ZERO then
					last_USB_DATA:=EOP;-- not(USB_DATA=ZERO)
					mode_receive:=true;
					step_ps3:=37;
					counter_TRAME:=0;
					counter_PAS:=0;
				end if;
			when 37=>
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						if not(SYNCHRO(8 -1-counter_TRAME)=S_data2bit) then
							-- pas cool
							step_ps3:=38;counter_TRAME:=0;mode_receive:=false;
						end if;
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+8 then
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						
						PID_mem(8+8 -1-counter_TRAME):=result;
						if counter_TRAME=8+8-1 then
							crc16_init;
							--JOY_mem:=PID_mem;
							if PID_mem=DATA0 or PID_mem=DATA1 then
								--cool
							elsif PID_mem=STALL then
							--	-- RESET ALL : mauvaise idée : un reset ça prend du temps, ce n'est donc pas une réaction normale du système
							--	counter_TRAME:=0;mode_receive:=false;	
							--	pause(5);
							--	time_out:=true;
							--	step_ps3:=0;-- next INSTRUCTION
							--	step_cmd:=0;
							--	next_cmd:=false;
								step_ps3:=2; -- death
							else
								-- pas cool : surement le NACK (ping failed)
								step_ps3:=38;counter_TRAME:=0;mode_receive:=false;	
							end if;
						end if;
					elsif USB_DATA=EOP then
							SIZE_mem:=conv_std_logic_vector(counter_TRAME-16-16,8);
							counter_TRAME:=0;
							pause(5);
							mode_receive:=false;
							step_ps3:=39;
							if conv_integer(SIZE_mem)>0 then
								for i in 0 to 15 loop
									CRC16_mem(i):=not(CRC16_mem(i));
								end loop;
								if not(CRC16_mem=crc16_value) then
									step_ps3:=40; -- envoyer un NACK
								else
									JOY_mem:=JOY_CANDIDATE_mem;
									R_valid <= '1';
								end if;
							end if;
					else
						nrzi_inv(S_data2bit,last_nrzi,result);
						stuff(result);
						if counter_TRAME>=8+8+16 then
							crc16_value:=crc16(CRC16_mem(15),crc16_value);
						end if;
						CRC16_mem:=CRC16_mem(14 downto 0) & result;
						-- DATA & CRC16
					end if;
					if counter_TRAME>=8+8 and counter_TRAME<8+8+8*REPORT_LEN then
						JOY_CANDIDATE_mem(8+8+8*REPORT_LEN -1-counter_TRAME):=result;
					end if;
					if counter_SOF_stuff*2>period_SOF then
						-- timeout !
						step_ps3:=38;counter_TRAME:=0;mode_receive:=false;
					end if;

					if step_ps3=37 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 38=>
				-- wait EOP
				if USB_DATA=EOP and counter_PAS=DEMI_PAS then
					pause(5);
					time_out:=true;
					step_ps3:=34; -- next SOF
				end if;
			when 39=>
				-- envoyer un ACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+ACK'length then
						stuff(ACK(8+ACK'length -1-counter_TRAME));
						nrzi(ACK(8+ACK'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+ACK'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+ACK'length+2+1 then
						USB_DATA<=UN;
					else
						pause(3);
						time_out:=true;
						step_ps3:=1;-- loop -- next SOF next INSTRUCTION
						next_cmd:=true;
					end if;
					if step_ps3=39 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
			when 40=>
				-- envoyer un NACK
				if counter_PAS=DEMI_PAS then
					if counter_TRAME<8 then
						USB_DATA<=bit2data(SYNCHRO(8 -1-counter_TRAME));
						stuff_init;
						nrzi_init;
					elsif counter_TRAME<8+NACK'length then
						stuff(NACK(8+NACK'length -1-counter_TRAME));
						nrzi(NACK(8+NACK'length -1-counter_TRAME),last_nrzi,result);
						USB_DATA<=bit2data(result);
					elsif counter_TRAME<8+NACK'length+2 then
						USB_DATA<=EOP;
					elsif counter_TRAME<8+NACK'length+2+1 then
						USB_DATA<=UN;
					else
						pause(3);
						time_out:=true;
						step_ps3:=1;-- loop -- next SOF next INSTRUCTION
						next_cmd:=true;
					end if;
					if step_ps3=40 then
						counter_TRAME:=counter_TRAME+1;
					end if;
				end if;
		end case;
	end if;
	
	counter_PAS:=counter_PAS+1;
	if mode_receive then
		if not(USB_DATA=last_USB_DATA) then
			if counter_PAS<DEMI_PAS then
				counter_PAS:=0;
			elsif counter_PAS>DEMI_PAS then
				counter_PAS:=PAS;
			end if;
		end if;
		last_USB_DATA:=USB_DATA;
	end if;
	if counter_PAS=PAS then
		counter_PAS:=0;
	end if;
	
	if counter_PAS=DEMI_PAS then
		counter_IDLE:=counter_IDLE+1;
		if counter_IDLE=period_IDLE+period_EOP then
			counter_IDLE:=0;
		end if;
		counter_SOF_stuff:=counter_SOF_stuff+1;
		if counter_SOF_stuff=period_SOF then
			counter_SOF_stuff:=0;
		end if;
	end if;

	if next_cmd then
		next_cmd:=false;
		if C_usb_enum_sequence(step_cmd).usbpacket = C_usbpacket_read then
			trame_read(C_usb_enum_sequence(step_cmd).token,C_usb_enum_sequence(step_cmd).data);
		elsif C_usb_enum_sequence(step_cmd).usbpacket = C_usbpacket_set then
			trame_set(C_usb_enum_sequence(step_cmd).token,C_usb_enum_sequence(step_cmd).data);
		else
			plug(C_usb_enum_sequence(step_cmd).token);
		end if;
		if step_cmd /= C_usb_enum_sequence'high then
			step_cmd <= step_cmd+1;
		end if;
	end if;

  end if; -- not reset
end if; -- rising edge clk
end process;

end Behavioral;

