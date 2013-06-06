architecture sa_test of testbench is
	signal rst   : std_logic;
	signal clk   : std_logic := '0';

	signal lcd_e  : std_logic;
	signal lcd_rs : std_logic;
	signal lcd_rw : std_logic;
	signal lcd_data : std_logic_vector(0 to 7);
	signal lcd_backlight : std_logic;

	component nuhs3dsp is
		port (
			xtal : in std_logic;
			sw1 : in std_logic := '1';

			hd_t_data  : inout std_logic := '1';
			hd_t_clock : in std_logic := '0';

			dip : in std_logic_vector(0 to 7) := (others => 'Z');
			led18 : out std_logic := 'Z';
			led16 : out std_logic := 'Z';
			led15 : out std_logic := 'Z';
			led13 : out std_logic := 'Z';
			led11 : out std_logic := 'Z';
			led9  : out std_logic := 'Z';
			led8  : out std_logic := 'Z';
			led7  : out std_logic := 'Z';

			---------------
			-- Video DAC --
			
			hsync : out std_logic := '0';
			vsync : out std_logic := '0';
			clk_videodac : out std_logic := 'Z';
			blank : out std_logic := 'Z';
			sync  : out std_logic := 'Z';
			psave : out std_logic := 'Z';
			red   : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			green : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			blue  : out std_logic_vector(8-1 downto 0) := (others => 'Z');

			---------
			-- ADC --

			adc_clkab : out std_logic := 'Z';
			adc_clkout : in std_logic := 'Z';
			adc_da : in std_logic_vector(14-1 downto 0) := (others => 'Z');
			adc_db : in std_logic_vector(14-1 downto 0) := (others => 'Z');

			-----------------------
			-- RS232 Transceiver --

			rs232_dcd : in std_logic := 'Z';
			rs232_dsr : in std_logic := 'Z';
			rs232_rd  : in std_logic := 'Z';
			rs232_rts : out std_logic := 'Z';
			rs232_td  : out std_logic := 'Z';
			rs232_cts : in std_logic := 'Z';
			rs232_dtr : out std_logic := 'Z';
			rs232_ri  : in std_logic := 'Z';

			--------------------------
			-- Ethernet Transceiver --

			mii_intrp : in std_logic := 'Z';
			mii_rst  : out std_logic := 'Z';
			mii_refclk : out std_logic := 'Z';

			mii_mdc  : out std_logic := 'Z';
			mii_mdio : inout std_logic := 'Z';

			mii_txc  : in  std_logic := 'Z';
			mii_txen : out std_logic := 'Z';
			mii_txd  : out std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxd  : out std_logic_vector(4-1 downto 0) := (others => 'Z');
			mii_rxer : in std_logic := 'Z';

			mii_crs  : in std_logic := 'Z';
			mii_col  : in std_logic := 'Z';

			-------------
			-- DDR RAM --

			ddr_ckp : out std_logic := 'Z';
			ddr_ckn : out std_logic := 'Z';
			ddr_lp_ckp : in std_logic := 'Z';
			ddr_lp_ckn : in std_logic := 'Z';
			ddr_st_lp_dqs : in std_logic := 'Z';
			ddr_lp_dqs : out std_logic := 'Z';
			ddr_cke : out std_logic := 'Z';
			ddr_cs  : out std_logic := 'Z';
			ddr_ras : out std_logic := 'Z';
			ddr_cas : out std_logic := 'Z';
			ddr_we  : out std_logic := 'Z';
			ddr_ba  : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => 'Z');
			ddr_a   : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => 'Z');
			ddr_dm  : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dqs : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dq  : inout std_logic_vector(16-1 downto 0) := (16-1 downto 0 => 'Z');

			---------
			-- LCD --

			lcd_e  : out std_logic;
			lcd_rs : out std_logic;
			lcd_rw : out std_logic;
			lcd_data : inout std_logic_vector(0 to 7);
			lcd_backlight : out std_logic);
	end component;

begin

	rst <= '0', '1' after 201 ns;
	clk <= not clk after 10 ns;

	nuhs3dsp_e : nuhs3dsp
	port map (
		sw1 => rst,
		xtal => clk,
		lcd_e  => lcd_e,
		lcd_rs => lcd_rs,
		lcd_rw => lcd_rw,
		lcd_data => lcd_data,
		lcd_backlight => lcd_backlight);

end;
