library ieee;
use ieee.std_logic_1164.all;

entity nexys2 is
	port (
		s3s_anodes     : out std_logic_vector(3 downto 0) := (3 downto 0 => '1');
		s3s_segment_a  : out std_logic := '1';
		s3s_segment_b  : out std_logic := '1';
		s3s_segment_c  : out std_logic := '1';
		s3s_segment_d  : out std_logic := '1';
		s3s_segment_e  : out std_logic := '1';
		s3s_segment_f  : out std_logic := '1';
		s3s_segment_g  : out std_logic := '1';
		s3s_segment_dp : out std_logic := '1';

		switches : in  std_logic_vector(7 downto 0) := (7 downto 0 => '1');
		buttons  : in  std_logic_vector(3 downto 0) := (3 downto 0 => '1');
		leds     : out std_logic_vector(7 downto 0) := (7 downto 0 => '1');

		xtal  : in  std_logic := '1';

		rs232_rxd : in std_logic := '1';
		rs232_txd : out std_logic := '1');

	attribute loc : string;
	attribute iostandard : string;
	
	------------------------------------
	-- Digilent/NEXYS2 SPARTAN-3E Kit --
	------------------------------------

	attribute loc of xtal : signal is "B8";
	attribute loc of leds : signal is "P4 E4 P16 E16 K14 K15 J15 J14";
	attribute loc of buttons : signal is "B18 D18 E18 H13";
	attribute loc of switches : signal is "R17 N17 L13 L14 K17 K18 H18 G18";
	attribute loc of s3s_anodes     : signal is  "F15 C18 H17 F17";
	attribute loc of s3s_segment_a  : signal is "L18";
	attribute loc of s3s_segment_b  : signal is "F18";
	attribute loc of s3s_segment_c  : signal is "D17";
	attribute loc of s3s_segment_d  : signal is "D16";
	attribute loc of s3s_segment_e  : signal is "G14";
	attribute loc of s3s_segment_f  : signal is "J17";
	attribute loc of s3s_segment_g  : signal is "H14";
	attribute loc of s3s_segment_dp : signal is "C17";

	attribute loc of rs232_rxd : signal is "U6";
	attribute loc of rs232_txd : signal is "P9";
end;