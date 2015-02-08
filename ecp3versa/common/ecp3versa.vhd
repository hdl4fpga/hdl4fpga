library ieee;
use ieee.std_logic_1164.all;

entity ecp3versa is
	port (
		clk  : in std_logic := 'Z';
--		pclk : in std_logic := 'Z';
		
		led : out std_logic_vector(0 to 6) := (others => 'Z');
		seg : out std_logic_vector(0 to 14) := (others => 'Z');
		
		ddr3_clk : out std_logic := '0';
		ddr3_rst : out std_logic := '0';
		ddr3_cke : out std_logic := '0';
		ddr3_cs  : out std_logic := '1';
		ddr3_ras : out std_logic := '1';
		ddr3_cas : out std_logic := '1';
		ddr3_we  : out std_logic := '1';
		ddr3_b   : out std_logic_vector( 2 downto 0) := (others => '1');
		ddr3_a   : out std_logic_vector(12 downto 0) := (others => '1');
		ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dqs : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
		ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
		ddr3_odt : out std_logic := '1';


		phy1_125clk : in std_logic;
		phy1_rst : out std_logic;
		phy1_coma : out std_logic := 'Z';
		phy1_mdio : inout std_logic;
		phy1_mdc : out std_logic;
		phy1_gtxclk : out std_logic;
		phy1_crs : out std_logic;
		phy1_col : out std_logic;
		phy1_txc : in std_logic;
		phy1_tx_d : out std_logic_vector(0 to 8-1);
		phy1_tx_en : out std_logic;
		phy1_rxc : in std_logic;
		phy1_rx_er : in std_logic;
		phy1_rx_dv : in std_logic;
		phy1_rx_d : in std_logic_vector(0 to 8-1);
--
--		phy2_125clk : in std_logic;
--		phy2_rst : out std_logic;
--		phy2_coma : out std_logic;
--		phy2_mdio: inout std_logic;
--		phy2_mdc : out std_logic;
--		phy2_gtxclk : out std_logic;
--		phy2_crs : out std_logic;
--		phy2_col : out std_logic;
--		phy2_txc : out std_logic;
--		phy2_tx_d : out std_logic_vector(0 to 8-1);
--		phy2_tx_en : out std_logic;
--		phy2_rxc : in std_logic;
--		phy2_rx_er : in std_logic;
--		phy2_rx_dv : in std_logic;
--		phy2_rx_d : in std_logic_vector(0 to 8-1);

--		expansion : inout std_logic_vector(0 to 46-1)
		fpga_gsrn : in std_logic);
end;
