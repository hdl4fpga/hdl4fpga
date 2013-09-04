library ieee;
use ieee.std_logic_1164.all;

entity ecp3versa is
	port (
		clk  : in std_logic := 'Z';
		clk_n  : in std_logic := 'Z';
		pclk : in std_logic;
		pclk_n : in std_logic;
		
		leds   : out std_logic_vector(0 to 7);
		digit  : out std_logic_vector(0 to 14);
		
		ddr3_clk : out std_logic := 'Z';
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
		ddr3_dqs : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt : inout std_logic;

		fpga_gsrn : in std_logic;

		phy1_125clk : in std_logic;
		phy1_rst : out std_logic;
		phy1_coma : out std_logic;
		phy1_mdio : inout std_logic;
		phy1_mdc : out std_logic;
		phy1_gtxclk : out std_logic;
		phy1_crs : out std_logic;
		phy1_col : out std_logic;
		phy1_txc : out std_logic;
		phy1_tx_d : out std_logic_vector(0 to 8-1);
		phy1_tx_en : out std_logic;
		phy1_rxc : in std_logic;
		phy1_rx_er : in std_logic;
		phy1_rx_dv : in std_logic;
		phy1_rx_d : in std_logic_vector(0 to 8-1);

		phy2_125clk : in std_logic;
		phy2_rst : out std_logic;
		phy2_coma : out std_logic;
		phy2_mdio: inout std_logic;
		phy2_mdc : out std_logic;
		phy2_gtxclk : out std_logic;
		phy2_crs : out std_logic;
		phy2_col : out std_logic;
		phy2_txc : out std_logic;
		phy2_tx_d : out std_logic_vector(0 to 8-1);
		phy2_tx_en : out std_logic;
		phy2_rxc : in std_logic;
		phy2_rx_er : in std_logic;
		phy2_rx_dv : in std_logic;
		phy2_rx_d : in std_logic_vector(0 to 8-1));

	attribute loc : string;
	attribute io_type : string;
	
	attribute loc of clk : signal is "L5";
	attribute io_type of clk : signal is "SSTL18D_II";
	
--	attribute loc of clk_n : signal is "K6";
--	attribute io_type of clk_n : signal is "SSTL15";
	
	attribute loc of pclk : signal is "F11";
--	attribute loc of pclk_n : signal is "F12";
	
	attribute loc of leds   : signal is "U19 U18 AA21 Y20 W19 V19 AA20 AB20";
	attribute loc of digit  : signal is "V6 U7 Y6 AA6 U8 T8 R9 T9 AB3 AB4 W4 Y5 AA4 AA5 W5";
	
	attribute loc of ddr3_clk : signal is "K4";
	attribute io_type of ddr3_clk : signal is "SSTL18D_II";

--	attribute loc of ddr3_clk_n : signal is "K5";

	attribute loc of ddr3_rst : signal is "D4";
	attribute loc of ddr3_cke : signal is "G8";
	attribute loc of ddr3_cs : signal is "C6";
	attribute loc of ddr3_ras : signal is "A6";
	attribute loc of ddr3_cas : signal is "A4";
	attribute loc of ddr3_we : signal is "D6";
	attribute loc of ddr3_ba : signal is "D5 E6 B4";
	attribute loc of ddr3_a  : signal is "F7 C10 C9 B8 A7 D7 A3 E9 F9 D8 B7 C7 C8";
	attribute loc of ddr3_dm : signal is "F3 E3";
	attribute loc of ddr3_dqs : signal is "H5 F5";
	attribute io_type of ddr3_dqs : signal is "SSTL18D_II";
	attribute loc of ddr3_dqs_n : signal is "H6 F4";
	attribute loc of ddr3_dq  : signal is "G3 C1 B1 J4 E2 H4 F1 G2 G4 G5 B2 C2 D1 D2 E4 E5";
	attribute loc of ddr3_odt : signal is "E7";

	attribute loc of fpga_gsrn : signal is "A21";

	attribute loc of phy1_125clk : signal is "T3";
	attribute loc of phy1_rst : signal is "L3";
	attribute loc of phy1_coma : signal is "R4";
	attribute loc of phy1_mdio : signal is "L2";
	attribute loc of phy1_mdc : signal is "V4";
	attribute loc of phy1_gtxclk : signal is "M2";
	attribute loc of phy1_crs : signal is "P4";
	attribute loc of phy1_col : signal is "R1";
	attribute loc of phy1_txc : signal is "C12";
	attribute loc of phy1_tx_d : signal is "V1 U1 R3 P1 N5 N3 N4 N2";
	attribute loc of phy1_tx_en : signal is "V3";
	attribute loc of phy1_rxc : signal is "L4";
	attribute loc of phy1_rx_er : signal is "M4";
	attribute loc of phy1_rx_dv : signal is "M1";
	attribute loc of phy1_rx_d  : signal is "M5 N1 N6 P6 T2 R2 P5 P3";

	attribute loc of phy2_125clk : signal is "R17";
	attribute loc of phy2_rst : signal is "R21";
	attribute loc of phy2_coma : signal is "T15";
	attribute loc of phy2_mdio : signal is "U16";
	attribute loc of phy2_mdc : signal is "Y18";
	attribute loc of phy2_gtxclk : signal is "M19";
	attribute loc of phy2_crs : signal is "P19";
	attribute loc of phy2_col : signal is "N18";
	attribute loc of phy2_txc : signal is "M21";
	attribute loc of phy2_tx_d : signal is "W22 R16 P17 Y22 T21 U22 P20 U20";
	attribute loc of phy2_tx_en : signal is "V22";
	attribute loc of phy2_rxc : signal is "N19";
	attribute loc of phy2_rx_er : signal is "V20";
	attribute loc of phy2_rx_dv : signal is "U15";
	attribute loc of phy2_rx_d  : signal is "AB17 AA17 R19 V21 T17 R18 W21 Y21";
end;
