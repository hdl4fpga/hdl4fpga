library ieee;
use ieee.std_logic_1164.all;

entity ecp3versa is
	port (
		clk_p  : in std_logic := 'Z';
		clk_n  : in std_logic := 'Z';
		pclk_p : in std_logic;
		pclk_n : in std_logic;
		
		leds   : out std_logic_vector(0 to  7);
		digit  : out std_logic_vector(0 to 14);
		
		ddr3_clk_p : out std_logic := 'Z';
		ddr3_clk_n : out std_logic := 'Z';
		ddr3_vref  : out std_logic := 'Z';
		ddr3_rst : out std_logic := 'Z';
		ddr3_cke : out std_logic := 'Z';
		ddr3_cs  : out std_logic := 'Z';
		ddr3_ras : out std_logic := 'Z';
		ddr3_cas : out std_logic := 'Z';
		ddr3_we  : out std_logic := 'Z';
		ddr3_ba  : out std_logic_vector( 2 downto 0) := (others => 'Z');
		ddr3_a   : out std_logic_vector(12 downto 0) := (others => 'Z');
		ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_p : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt : inout std_logic;

		phy1_txd : out std_logic_vector(),
		phy1_rxd : in  std_logic_vector(),
		phy1_gtx
	);

	attribute loc : string;
	
	attribute loc of clk_p  : signal is "L5";
	attribute loc of clk_n  : signal is "K6";
	attribute loc of pclk_p : signal is "F11";
	attribute loc of pclk_n : signal is "F12";
	
	attribute loc of leds   : signal is "U19 U18 AA21 Y20 W19 V19 AA20 AB20";
	attribute loc of digit  : signal is "V6 U7 Y6 AA6 U8 T8 R9 T9 AB3 AB4 W4 Y5 AA4 AA5 W5";
	
	attribute loc of ddr3_clk_p : signal is "K4";
	attribute loc of ddr3_clk_n : signal is "K5";
	attribute loc of ddr3_rst   : signal is "D4";
	attribute loc of ddr3_cke   : signal is "G8";
	attribute loc of ddr3_cs    : signal is "C6";
	attribute loc of ddr3_ras   : signal is "A6";
	attribute loc of ddr3_cas   : signal is "A4";
	attribute loc of ddr3_we    : signal is "D6";
	attribute loc of ddr3_ba    : signal is "D5 E6 B4";
	attribute loc of ddr3_a     : signal is "F7 C10 C9 B8 A7 D7 A3 E9 F9 D8 B7 C7 C8";
	attribute loc of ddr3_dm    : signal is "F3 E3";
	attribute loc of ddr3_dqs_p : signal is "H5 F5";
	attribute loc of ddr3_dqs_n : signal is "H6 F4";
	attribute loc of ddr3_dq    : signal is "G3 C1 B1 J4 E2 H4 F1 G2 G4 G5 B2 C2 D1 D2 E4 E5";
	attribute loc of ddr3_odt   : signal is "E7";

end;
