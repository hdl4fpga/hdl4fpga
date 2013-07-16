library hdl4fpga;
use hdl4fpga.std.all;

architecture scope of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 14;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 8;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst   : std_logic;
	signal clk   : std_logic := '0';
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (data_bytes-1 downto 0) := (others => '1');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => '1');
	signal addr  : std_logic_vector (addr_bits-1 downto 0);
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal clk_p : std_logic_vector(2-1 downto 0) := (others => '1');
	signal clk_n : std_logic_vector(2-1 downto 0) := (others => '1');
	signal cke   : std_logic_vector (2-1 downto 0) := (others => '1');
	signal cs_n  : std_logic_vector (2-1 downto 0) := (others => '1');
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal odt   : std_logic_vector(2-1 downto 0);
	signal scl   : std_logic;
	signal sda   : std_logic;
	signal rdqs_n : std_logic_vector(dqs'range);

	signal mii_refclk : std_logic := '0';
	signal mii_treq : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 8-1);
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_strt : std_logic;
	signal lp : std_logic;

	component ml509 is
		port (
			bus_error : out std_logic_vector(2 downto 1);

--			cfg_addr_out : in std_logic_vector(2-1 downto 0);
--			cpld_io_1 : in std_logic;

			clk_27mhz_fpga : in std_logic := '-';
			clk_33mhz_fpga : in std_logic := '-';
			clk_fpga_n : in std_logic := '-';
			clk_fpga_p : in std_logic := '-';

			ddr2_clk_p : out std_logic_vector(2-1 downto 0) := (others => '-');
			ddr2_clk_n : out std_logic_vector(2-1 downto 0) := (others => '-');
			ddr2_cs  : out std_logic_vector( 2-1 downto 0);	
			ddr2_cke : out std_logic_vector( 2-1 downto 0);
			ddr2_ras : out std_logic;
			ddr2_cas : out std_logic;
			ddr2_we  : out std_logic;
			ddr2_a   : out std_logic_vector(14-1 downto 0);
			ddr2_ba  : out std_logic_vector( 3-1 downto 0);
			ddr2_dqs_p : inout std_logic_vector(8-1 downto 0);
			ddr2_dqs_n : inout std_logic_vector(8-1 downto 0);
			ddr2_d   : inout std_logic_vector(64-1 downto 0);
			ddr2_dm  : inout std_logic_vector( 8-1 downto 0);
			ddr2_odt : out std_logic_vector( 2-1 downto 0);
--			ddr2_scl  : out std_logic;
--			ddr2_sda  : in  std_logic;

			dvi_xclk_n : out std_logic;
			dvi_xclk_p : out std_logic;
			dvi_reset  : out std_logic;
--			dvi_gpio1  : inout std_logic;
			dvi_de : out std_logic;
			dvi_d  : out std_logic_vector(12-1 downto 0);
			dvi_v  : inout std_logic;
			dvi_h  : inout std_logic;

--			fan_alert : out std_logic;

			fpga_diff_clk_out_p : out std_logic;
			fpga_diff_clk_out_n : out std_logic;
--			fpga_rotary_inca : in std_logic;
--			fpga_rotary_incb : in std_logic;
--			fpga_rotary_push : in std_logic;
			fpga_serial_rx : std_logic_vector(1 to 2) := (others => '-');
			fpga_serial_tx : std_logic_vector(1 to 2) := (others => '-');

--			gpio_dip_sw : in std_logic_vector(8 downto 1);
			gpio_led : out std_logic_vector(8-1 downto 0);
			gpio_led_c  : out std_logic;
			gpio_led_e  : out std_logic;
			gpio_led_n  : out std_logic;
			gpio_led_s  : out std_logic;
			gpio_led_w  : out std_logic;
			gpio_sw_c  : in std_logic := '-';
			gpio_sw_e  : in std_logic := '-';
			gpio_sw_n  : in std_logic := '-';
			gpio_sw_s  : in std_logic := '-';
			gpio_sw_w  : in std_logic := '-';

			hdr1 : std_logic_vector(1 to 32) := (others => '-');
			hdr2_diff_p : std_logic_vector(0 to 4-1) := (others => '-');
			hdr2_diff_n : std_logic_vector(0 to 4-1) := (others => '-');
			hdr2_sm_p : std_logic_vector(4 to 16-1) := (others => '-');
			hdr2_sm_n : std_logic_vector(4 to 16-1) := (others => '-');

--			lcd_fpga_db : std_logic_vector(8-1 downto 4);

			phy_reset : out std_logic;
			phy_col : in std_logic := '-';
			phy_crs : in std_logic := '-';
			phy_int : in std_logic := '-';		-- open drain
			phy_mdc : out std_logic := '-';
			phy_mdio : inout std_logic := '-';

			phy_rxclk : in std_logic;
			phy_rxctl_rxdv : in std_logic;
			phy_rxd  : in std_logic_vector(0 to 8-1);
			phy_rxer : in std_logic := '-';

			phy_txc_gtxclk : in std_logic := '-';
			phy_txclk : in std_logic;
			phy_txctl_txen : out std_logic;
			phy_txd  : out std_logic_vector(0 to 8-1);
			phy_txer : out std_logic;

--			sram_bw : std_logic_vector(4-1 downto 0);
--			sram_d  : std_logic_vector(32-1 downto 16);
--			sram_dqp : std_logic_vector(4-1 downto 0);
--			sram_flash_a : std_logic_vector(22-1 downto 0);
--			sram_flash_d : std_logic_vector(16-1 downto 0);
--
--			sysace_mpa   : std_logic_vector(7-1 downto 0);
--			sysace_usb_d : std_logic_vector(16-1 downto 0);
--
--			trc_ts : std_logic_vector(6 downto 3);
			user_clk : in std_logic
--
--			vga_in_blue  : std_logic_vector(8-1 downto 0);
--			vga_in_green : std_logic_vector(8-1 downto 0);
--			vga_in_red   : std_logic_vector(8-1 downto 0)
			);
	end component;

	component ddr2_model is
		port (
			ck    : in std_logic;
			ck_n  : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits-1 downto 0);
			dm_rdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			rdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;
begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 30.1 ns;

	mii_strt <= '0', '1' after 240 us;
	process (mii_refclk, mii_strt)
		variable txen_edge : std_logic;
	begin
		if mii_strt='0' then
			mii_treq <= '1' after 240 us;
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
		mii_txd  => mii_rxd(0 to 4-1));

	mii_refclk <= not mii_refclk after 20 ns;
	ml509_e : ml509
	port map (
		user_clk => clk,

		gpio_sw_c => rst,
		gpio_sw_e => lp,
		gpio_led_e => lp,
		phy_rxclk => mii_refclk,
		phy_rxctl_rxdv => mii_rxdv,
		phy_rxd => mii_rxd,

		phy_txclk => mii_refclk,
		phy_txctl_txen => mii_txen,

		--         --
		-- DDR RAM --
		--         --

		ddr2_clk_p => clk_p,
		ddr2_clk_n => clk_n,
		ddr2_cs  => cs_n,
		ddr2_cke => cke,
		ddr2_ras => ras_n,
		ddr2_cas => cas_n,
		ddr2_we  => we_n,
		ddr2_ba  => ba,
		ddr2_a   => addr,
		ddr2_dqs_p => dqs,
		ddr2_dqs_n => dqs_n,
		ddr2_d   => dq,
		ddr2_dm  => dm,
		ddr2_odt => odt
--		ddr2_scl  => scl,
--		ddr2_sda  => sda
	);

	mt_u : ddr2_model
	port map (
		Ck    => clk_p(0),
		Ck_n  => clk_n(0),
		Cke   => cke(0),
		Cs_n  => cs_n(0),
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba(2-1 downto 0),
		Addr  => addr,
		Dm_rdqs  => dm(2-1 downto 0),
		Dq    => dq(16-1 downto 0),
		Dqs   => dqs(2-1 downto 0),
		Dqs_n => dqs_n(2-1 downto 0),
		rdqs_n => rdqs_n(2-1 downto 0),
		Odt   => odt(0));
end;

library micron;

configuration ml509_structure_md of testbench is
	for scope 
		for all: ml509 
			use entity hdl4fpga.ml509(structure);
		end for;

		for all : ddr2_model 
			use entity micron.ddr2
			port map (
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr(12 downto 0),
				Dm_rdqs  => dm(2-1 downto 0),
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				rdqs_n => rdqs_n,
				Odt   => odt);
		end for;
	end for;
end;

library micron;

configuration ml509_scope_md of testbench is
	for scope 
		for all: ml509 
			use entity hdl4fpga.ml509(scope);
		end for;

		for all: ddr2_model 
			use entity micron.ddr2
			port map (
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr(12 downto 0),
				Dm_rdqs  => dm(2-1 downto 0),
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				rdqs_n => rdqs_n,
				Odt   => odt);
		end for;
	end for;
end;
