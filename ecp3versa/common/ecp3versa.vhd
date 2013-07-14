library ieee;
use ieee.std_logic_1164.all
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;

entity ecp3versa is
	port (
		pclk_p : in std_logic;
		pclk_n : in std_logic;
		leds   : out std_logic_vector(0 to  7);
		digit  : out std_logic_vector(0 to 14);
		
		ddr_clk_p : out std_logic := 'Z';
		ddr_clk_n : out std_logic := 'Z';
		ddr_cke : out std_logic := 'Z';
		ddr_cs  : out std_logic := 'Z';
		ddr_ras : out std_logic := 'Z';
		ddr_cas : out std_logic := 'Z';
		ddr_we  : out std_logic := 'Z';
		ddr_ba  : out std_logic_vector( 2 downto 0) := (others => 'Z');
		ddr_a   : out std_logic_vector(12 downto 0) := (others => 'Z');
		ddr_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr_dqs_p : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr_dq  : inout std_logic_vector(2-1 downto 0) := (others => 'Z'));

	attribute loc : string;
	
	attribute loc of pclk_p : signal is "F11";
	attribute loc of pclk_n : signal is "F12";
	attribute loc of leds   : signal is "U19 U18 AA21 Y20 W19 V19 AA20 AB20";
	attribute loc of digit  : signal is "V6 U7 Y6 AA6 U8 T8 R9 T9 AB3 AB4 W4 Y5 AA4 AA5 W5";
	
	attribute loc of ddr_clk_p : signal is "L5";
	attribute loc of ddr_clk_n : signal is "K6";
	attribute loc of ddr_cke   : signal is "G8";
	attribute loc of ddr_cs    : signal is "C6";
	attribute loc of ddr_ras   : signal is "A6";
	attribute loc of ddr_cas   : signal is "A4";
	attribute loc of ddr_we    : signal is "D6";
	attribute loc of ddr_ba    : signal is "D5 E6 B4";
	attribute loc of ddr_a     : signal is "K5 K4 C10 C9 B8 D7 A7 A3 E9 F9 D8 B7 C7 C8";

	attribute loc of ddr_dm    : signal is "F3 E3";
	attribute loc of ddr_dqs_p : signal is "H5 F5";
	attribute loc of ddr_dqs_n : signal is "H6 F4";
	attribute loc of ddr_dq    : signal is "G3 C1 B1 J4 E2 H4 F1 G2 G4 G5 B2 C2 D1 D2 E4 E5";

end;

architecture scope of ecp3versa is
begin
end;
