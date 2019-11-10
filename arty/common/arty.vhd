library ieee;
use ieee.std_logic_1164.all;

entity arty is
	port (
		gclk100     : in std_logic;

		ja          : inout std_logic_vector(1 to 10) := (others => 'Z');
		jc          : inout std_logic_vector(1 to 10) := (others => 'Z');
		jd          : inout std_logic_vector(1 to 10) := (others => 'Z');
		vaux_p      : in    std_logic_vector(16-1 downto 0) := (others => '-');
		vaux_n      : in    std_logic_vector(16-1 downto 0) := (others => '-');
		v_p         : in    std_logic_vector(0 to 1-1) := (others => '-'); 
		v_n         : in    std_logic_vector(0 to 1-1) := (others => '-'); 
		btn         : in    std_logic_vector(4-1 downto 0) := (others => '-');
		sw          : in    std_logic_vector(4-1 downto 0) := (others => '-');
		led         : out   std_logic_vector(4-1 downto 0);
		RGBled      : out   std_logic_vector(4*3-1 downto 0);

		eth_rstn    : out   std_logic;
		eth_ref_clk : out   std_logic;
		eth_mdio    : inout std_logic := '-';
		eth_mdc     : out   std_logic;
		eth_crs     : in    std_logic := '-';
		eth_col     : in    std_logic := '-';
		eth_tx_clk  : in    std_logic := '-';
		eth_tx_en   : out   std_logic;
		eth_txd     : out   std_logic_vector(0 to 4-1);
		eth_rx_clk  : in    std_logic := '-';
		eth_rxerr   : in    std_logic := '-';
		eth_rx_dv   : in    std_logic := '-';
		eth_rxd     : in    std_logic_vector(0 to 4-1) := (others => '-');
		
		ddr3_reset  : out   std_logic := '0';
		ddr3_clk_p  : out   std_logic := '0';
		ddr3_clk_n  : out   std_logic := '0';
		ddr3_cke    : out   std_logic := '0';
		ddr3_cs     : out   std_logic := '1';
		ddr3_ras    : out   std_logic := '1';
		ddr3_cas    : out   std_logic := '1';
		ddr3_we     : out   std_logic := '1';
		ddr3_ba     : out   std_logic_vector( 3-1 downto 0) := (others => '1');
		ddr3_a      : out   std_logic_vector(14-1 downto 0) := (others => '1');
		ddr3_dm     : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_p  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_n  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq     : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt    : out   std_logic := '1');

--! Bus signal doesnt work on Vivado !-

--	attribute loc : string;
--	attribute loc of btn : signal is "B8 B9 C9 D9";
--	attribute loc of sw  : signal is "D10 C10 C11 A8";
--	attribute loc of led : signal is "T10 T9 J5 H5";
--	attribute loc of RGBled : signal is "K1 H6 K2 J3 J2 H4 G3 J4 G4 G6 F6 E1";
--
--	attribute loc of gclk100  : signal is "E3";
--
--	attribute loc of eth_rstn  : signal is "C16";
--	attribute loc of eth_ref_clk : signal is "G18";
--	attribute loc of eth_mdc   : signal is "F16";
--	attribute loc of eth_crs   : signal is "G14";
--	attribute loc of eth_col   : signal is "D17";
--	attribute loc of eth_mdio  : signal is "K13";
--	attribute loc of eth_tx_clk: signal is "H16";
--	attribute loc of eth_tx_en : signal is "H15";
--	attribute loc of eth_rxd  : signal is "D18 E17 E18 G17";
--	attribute loc of eth_rx_clk: signal is "F15";
--	attribute loc of eth_rxerr : signal is "C17";
--	attribute loc of eth_rx_dv : signal is "G16";
--	attribute loc of eth_txd   : signal is "H14 J14 J13 H17";
--
--	attribute loc of ddr3_reset : signal is "K6";
--	attribute loc of ddr3_clk_p : signal is "U9";
--	attribute loc of ddr3_clk_n : signal is "V9";
--	attribute loc of ddr3_cke : signal is "N5";
--	attribute loc of ddr3_cs  : signal is "U8";
--	attribute loc of ddr3_ras : signal is "P3";
--	attribute loc of ddr3_cas : signal is "M4";
--	attribute loc of ddr3_we  : signal is "P5";
--  attribute loc of ddr3_odt : signal is "R5";
--	attribute loc of ddr3_ba  : signal is "P2 P4 R1";
--	attribute loc of ddr3_a   : signal is "T8 T6 U6 R6 V7 R8 U7 V6 R7 N6 T1 N4 M6 R2";
--	attribute loc of ddr3_dm  : signal is "U1 L1";
--	attribute loc of ddr3_dqs_p : signal is "U2 N2";
--	attribute loc of ddr3_dqs_n : signal is "V2 N1";
--	attribute loc of ddr3_dq  : signal is "R3 U3 T3 V1 U6 U4 T5 V4 M2 L4 M1 M3 L6 K3 L3 K5";

end;
