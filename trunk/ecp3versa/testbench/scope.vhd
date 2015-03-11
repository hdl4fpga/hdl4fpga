library hdl4fpga;
use hdl4fpga.std.all;

architecture scope of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 10;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal reset_n : std_logic;
	signal rst   : std_logic;
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs_p : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal addr  : std_logic_vector (addr_bits-1 downto 0) := (others => '0');
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal ddr_clk   : std_logic;
	signal ddr_clk_p : std_logic;
	signal ddr_clk_n : std_logic;
	signal cke   : std_logic;
	signal rst_n : std_logic;
	signal cs_n  : std_logic;
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal odt   : std_logic;
	signal scl   : std_logic;
	signal sda   : std_logic;
	signal tdqs_n : std_logic_vector(dqs_p'range);

	signal mii_refclk : std_logic := '0';
	signal mii_treq : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 8-1);
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_strt : std_logic;

	component ecp3versa is
		port (
			clk  : in std_logic := 'Z';
--			clk_n  : in std_logic := 'Z';
--			pclk : in std_logic;
--			pclk_n : in std_logic;
			
			led   : out std_logic_vector(0 to 7);
			seg  : out std_logic_vector(0 to 14);
			
			ddr3_clk : out std_logic := 'Z';
--			ddr3_vref : out std_logic := 'Z';
			ddr3_rst : out std_logic := 'Z';
			ddr3_cke : out std_logic := 'Z';
			ddr3_cs  : out std_logic := 'Z';
			ddr3_ras : out std_logic := 'Z';
			ddr3_cas : out std_logic := 'Z';
			ddr3_we  : out std_logic := 'Z';
			ddr3_b   : out std_logic_vector( 2 downto 0) := (others => 'Z');
			ddr3_a   : out std_logic_vector(12 downto 0) := (others => 'Z');
			ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddr3_odt : inout std_logic;


			phy1_125clk : in std_logic;
			phy1_rst : out std_logic;
			phy1_coma : out std_logic;
			phy1_mdio : inout std_logic;
			phy1_mdc : out std_logic;
			phy1_gtxclk : out std_logic := '1';
			phy1_crs : out std_logic;
			phy1_col : out std_logic;
			phy1_txc : in std_logic := '0';
			phy1_tx_d : out std_logic_vector(0 to 8-1);
			phy1_tx_en : out std_logic;
			phy1_rxc : in std_logic;
			phy1_rx_er : in std_logic;
			phy1_rx_dv : in std_logic;
			phy1_rx_d : in std_logic_vector(0 to 8-1);

--			phy2_125clk : in std_logic;
--			phy2_rst : out std_logic := '0';
--			phy2_coma : out std_logic;
--			phy2_mdio: inout std_logic;
--			phy2_mdc : out std_logic;
--			phy2_gtxclk : out std_logic := '1';
--			phy2_crs : out std_logic;
--			phy2_col : out std_logic;
--			phy2_txc : out std_logic;
--			phy2_tx_d : out std_logic_vector(0 to 8-1);
--			phy2_tx_en : out std_logic;
--			phy2_rxc : in std_logic;
--			phy2_rx_er : in std_logic;
--			phy2_rx_dv : in std_logic;
--			phy2_rx_d : in std_logic_vector(0 to 8-1)
			fpga_gsrn : in std_logic);
	end component;

	component ddr3_model is
		port (
			rst_n : in std_logic;
			ck    : in std_logic;
			ck_n  : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(3-1 downto 0);
			addr  : in std_logic_vector(addr_bits-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			tdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';
	signal phy1_125clk : std_logic := '0';

begin

	rst   <= '1', '0' after 1.1 us;
	reset_n <= not rst;

	xtal   <= not xtal after 5 ns;
	xtal_p <= not xtal after 5 ns;
	xtal_n <=     xtal after 5 ns;

	phy1_125clk <= not phy1_125clk after 4 ns;
	mii_rxc <= phy1_125clk;
	mii_refclk <= phy1_125clk;

	process (mii_strt, rst)
	begin
		if rst='1'then
			mii_strt <= '0', '1' after 12 us, '0' after 22 us;
		elsif falling_edge(mii_strt) then
			mii_strt <= '1', '0' after 10 us;
		end if;
	end process;
	process (mii_refclk, mii_strt)
		variable txen_edge : std_logic;
	begin
		if mii_strt='0' then
			mii_treq <= '1' after 20 us;
		elsif rising_edge(mii_refclk) then
			if mii_txen='1' then
				if txen_edge='0' then
					mii_treq <= '0';
				end if;
			elsif txen_edge='1' then
				mii_treq <= mii_strt;
			end if;
			txen_edge := mii_txen;
		end if;
	end process;

	eth_e: entity hdl4fpga.miitx_mem
	generic map (
		mem_data => x"5555_5555_5555_55d5_00_00_00_01_02_03_00000000_000000ff")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	ecp3versa_e : ecp3versa
	port map (
		clk    => xtal,
--		clk_n  => xtal_n,
--		pclk   => '-',
--		pclk_n => '-',

		fpga_gsrn => reset_n,

		phy1_125clk => phy1_125clk,
		phy1_rxc   => mii_rxc,
		phy1_rx_er => '-',
		phy1_rx_dv => mii_rxdv,
		phy1_rx_d  => mii_rxd,

		phy1_txc   => open,
		phy1_tx_en => mii_txen,

--		phy2_125clk => phy1_125clk,
--		phy2_rxc   => '-',
--		phy2_rx_d  => (others => '-'),
--		phy2_rx_er => '-',
--		phy2_rx_dv => '-',

		--         --
		-- DDR RAM --
		--         --

		ddr3_rst => rst_n,
		ddr3_clk => ddr_clk,
		ddr3_cs  => cs_n,
		ddr3_cke => cke,
		ddr3_ras => ras_n,
		ddr3_cas => cas_n,
		ddr3_we  => we_n,
		ddr3_b   => ba,
		ddr3_a   => addr(12 downto 0),
--		ddr3_dqs => dqs_p,
		ddr3_dq  => dq,
		ddr3_dm  => dm,
		ddr3_odt => odt);

	dqs_n <= not dqs_p;
	ddr_clk_p <=     ddr_clk;
	ddr_clk_n <= not ddr_clk;
	mt_u : ddr3_model
	port map (
		rst_n => rst_n,
		Ck    => ddr_clk_p,
		Ck_n  => ddr_clk_n,
		Cke   => cke,
		Cs_n  => cs_n,
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba,
		Addr  => addr,
		Dm_tdqs  => dm,
		Dq    => dq,
		Dqs   => dqs_p,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);
end;

library micron;

configuration ecp3versa_structure_md of testbench is
	for scope 
		for all: ecp3versa 
			use entity hdl4fpga.ecp3versa(structure);
		end for;

		for all : ddr3_model 
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;

library micron;

configuration ecp3versa_scope_md of testbench is
	for scope 
		for all: ecp3versa
			use entity hdl4fpga.ecp3versa(scope);
		end for;

		for all: ddr3_model 
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;
