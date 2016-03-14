library ieee;
use ieee.std_logic_1164.all;

entity arty is
	port (
		eth_rstn  : in std_logic;
		eth_ref_clk : in std_logic;
		eth_mdc   : in std_logic;
		eth_crs   : in std_logic;
		eth_col   : in std_logic;
		eth_mdio  : in std_logic;
		eth_tx_clk  : in std_logic;
		eth_tx_en : in std_logic;
		eth_txd   : in std_logic_vector(0 to 4-1);
		eth_rx_clk  : in std_logic;
		eth_rxerr : in std_logic;
		eth_rx_dv : in std_logic;
		eth_rxd   : in std_logic_vector(0 to 4-1);
		
		ddr3_clk : out std_logic := '0';
		ddr3_reset : out std_logic := '0';
		ddr3_cke : out std_logic := '0';
		ddr3_cs  : out std_logic := '1';
		ddr3_ras : out std_logic := '1';
		ddr3_cas : out std_logic := '1';
		ddr3_we  : out std_logic := '1';
		ddr3_ba  : out std_logic_vector( 3-1 downto 0) := (others => '1');
		ddr3_a   : out std_logic_vector(14-1 0) := (others => '1');
		ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_p : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt : out std_logic := '1';

	attribute loc : string;
	attribute loc of eth_rstn  : signal is "C16";
	attribute loc of eth_ref_clk : signal is "G18";
	attribute loc of eth_mdc   : signal is "F16";
	attribute loc of eth_crs   : signal is "G14";
	attribute loc of eth_col   : signal is "D17";
	attribute loc of eth_mdio  : signal is "K13";
	attribute loc of eth_tx_clk: signal is "H16";
	attribute loc of eth_tx_en : signal is "H15";
	attribute loc of eth_rxd  : signal is "D18 E17 E18 G17";
	attribute loc of eth_rx_clk: signal is "F15";
	attribute loc of eth_rxerr : signal is "C17";
	attribute loc of eth_rx_dv : signal is "G16";
	attribute loc of eth_txd   : signal is "H14 J14 J13 H17";

	attribute loc of ddr3_clk  : signal is "C16";
	attribute loc of ddr3_reset : signal is "G18";
	attribute loc of ddr3_cke  : signal is "F16";
	attribute loc of ddr3_cs   : signal is "G14";
	attribute loc of ddr3_ras  : signal is "D17";
	attribute loc of ddr3_cas  : signal is "K13";
	attribute loc of ddr3_we   : signal is "H16";
	attribute loc of ddr3_ba   : signal is "H15";
	attribute loc of ddr3_a    : signal is "D18 E17 E18 G17";
	attribute loc of ddr3_dm   : signal is "F15";
	attribute loc of ddr3_dqs_p : signal is "C17";
	attribute loc of ddr3_dqs_n : signal is "G16";
	attribute loc of ddr3_dq   : signal is "H14 J14 J13 H17";
    attribute loc of ddr3_odt  :  signal is "F15";
end;
