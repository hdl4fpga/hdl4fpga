library hdl4fpga;
use hdl4fpga.std.all;

architecture scope of testbench is
	type ddrm_ids is (ddr1, ddr2, ddr3);
	constant ddrm_id  : ddrm_ids := ddr2;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst   : std_logic;
	signal clk   : std_logic := '0';
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (1 downto 0) := "00";
	signal addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal ba    : std_logic_vector (1 downto 0);
	signal clk_p : std_logic := '0';
	signal clk_n : std_logic := '0';
	signal cke   : std_logic := '1';
	signal cs_n  : std_logic := '1';
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(1 downto 0);

	signal x : std_logic;
	signal mii_refclk : std_logic;
	signal mii_treq : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : nibble;
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;
	signal mii_strt : std_logic;

	signal ddr3_rst : std_logic;
	signal ddr_lp_dqs : std_logic;

	component nuhs3dsp is
		port (
			xtal : in std_logic;
			sw1 : in std_logic;

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

			------------------------------
			-- MII ethernet Transceiver --

			mii_rst  : out std_logic := 'Z';
			mii_refclk : out std_logic := 'Z';
			mii_intrp  : in std_logic := 'Z';

			mii_mdc  : out std_logic := 'Z';
			mii_mdio : inout std_logic := 'Z';

			mii_txc  : in  std_logic := 'Z';
			mii_txen : out std_logic := 'Z';
			mii_txd  : out std_logic_vector(4-1 downto 0) := (others => 'Z');

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxer : in std_logic := 'Z';
			mii_rxd  : in std_logic_vector(4-1 downto 0) := (others => 'Z');

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
			ddr_dq  : inout std_logic_vector(16-1 downto 0) := (16-1 downto 0 => 'Z'));
	end component;

	component ddr_model is
		port (
			clk   : in std_logic;
			clk_n : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm    : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0));
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
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm_rdqs : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0);
			dqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			rdqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			odt   : in std_logic);
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
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm_tdqs : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0);
			dqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			tdqs_n : inout std_logic_vector(data_bytes - 1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;
begin

	clk <= not clk after 25 ns;
	process (clk)
		variable vrst : unsigned(1 to 16) := (others => '1');
	begin
		if rising_edge(clk) then
			vrst := vrst sll 1;
			rst <= not vrst(1);
		end if;
	end process;
	ddr3_rst <= not rst;

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
		mii_txd  => mii_rxd);

	mii_rxc <= mii_refclk after 5 ps;
	nuhs3dsp_e : nuhs3dsp
	port map (
		xtal => clk,
		sw1  => '1',
		led7 => led7,
		dip => b"0000_0001",

		---------
		-- ADC --

		adc_da => (others => '0'),
		adc_db => (others => '0'),

		adc_clkab  => x,
		adc_clkout => x,

		hd_t_clock => rst,

		mii_refclk => mii_refclk,
		mii_txc => mii_refclk,
		mii_rxc => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd => mii_rxd,
		mii_txen => mii_txen,
		-------------
		-- DDR RAM --

		ddr_ckp => clk_p,
		ddr_ckn => clk_n,
		ddr_lp_ckp => clk_p,
		ddr_lp_ckn => clk_n,
		ddr_st_lp_dqs => ddr_lp_dqs,
		ddr_lp_dqs => ddr_lp_dqs,
		ddr_cke => cke,
		ddr_cs  => cs_n,
		ddr_ras => ras_n,
		ddr_cas => cas_n,
		ddr_we  => we_n,
		ddr_ba  => ba,
		ddr_a   => addr,
		ddr_dm  => dm,
		ddr_dqs => dqs,
		ddr_dq  => dq);

	ddr_model_g: if ddrm_id=ddr1 generate
		mt_u : ddr_model
		port map (
			Clk   => clk_p,
			Clk_n => clk_n,
			Cke   => cke,
			Cs_n  => cs_n,
			Ras_n => ras_n,
			Cas_n => cas_n,
			We_n  => we_n,
			Ba    => ba,
			Addr  => addr,
			Dm    => dm,
			Dq    => dq,
			Dqs   => dqs);
	end generate;

	ddr2_model_g: if ddrm_id=ddr2 generate
		signal dqs_n  : std_logic_vector(dqs'range);
		signal rdqs_n : std_logic_vector(dqs'range);
		signal odt    : std_logic;
	begin
		dqs_n <= not dqs;
		mt_u : ddr2_model
		port map (
			Ck    => clk_p,
			Ck_n  => clk_n,
			Cke   => cke,
			Cs_n  => cs_n,
			Ras_n => ras_n,
			Cas_n => cas_n,
			We_n  => we_n,
			Ba    => ba,
			Addr  => addr,
			Dm_rdqs  => dm,
			Dq    => dq,
			Dqs   => dqs,
			Dqs_n => dqs_n,
			rdqs_n => rdqs_n,
			Odt   => odt);
	end generate;

	ddr3_model_g: if ddrm_id=ddr3 generate
		signal dqs_n  : std_logic_vector(dqs'range);
		signal tdqs_n : std_logic_vector(dqs'range);
		signal odt    : std_logic;
	begin
		dqs_n <= not dqs;
		mt_u : ddr3_model
		port map (
			Rst_n => ddr3_rst,
			Ck    => clk_p,
			Ck_n  => clk_n,
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
			Tdqs_n => tdqs_n,
			Odt   => odt);
	end generate;
end;

library micron;

configuration nuhs3dsp_structure_md of testbench is
	for scope 
		for all : nuhs3dsp 
			use entity hdl4fpga.nuhs3dsp(structure);
		end for;
		for ddr_model_g
			for all : ddr_model 
				use entity micron.ddr_model
				port map (
					Clk   => clk_p,
					Clk_n => clk_n,
					Cke   => cke,
					Cs_n  => cs_n,
					Ras_n => ras_n,
					Cas_n => cas_n,
					We_n  => we_n,
					Ba    => ba,
					Addr  => addr,
					Dm    => dm,
					Dq    => dq,
					Dqs   => dqs);
			end for;
		end for;

		for ddr2_model_g 
			for all : ddr2_model 
				use entity micron.ddr2
				port map (
					Ck    => clk_p,
					Ck_n  => clk_n,
					Cke   => cke,
					Cs_n  => cs_n,
					Ras_n => ras_n,
					Cas_n => cas_n,
					We_n  => we_n,
					Ba    => ba,
					Addr  => addr,
					Dm_rdqs  => dm,
					Dq    => dq,
					Dqs   => dqs,
					Dqs_n => dqs_n,
					rdqs_n => rdqs_n,
					Odt   => odt);
			end for;
		end for;

		for ddr3_model_g 
			for all : ddr3_model 
				use entity micron.ddr3
				port map (
					Rst_n => ddr3_rst,
					Ck    => clk_p,
					Ck_n  => clk_n,
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
					Tdqs_n => tdqs_n,
					Odt   => odt);
			end for;
		end for;
	end for;
end;

library micron;

configuration nuhs3dsp_scope_md of testbench is
	for scope 
		for all : nuhs3dsp 
			use entity hdl4fpga.nuhs3dsp(scope);
		end for;
		for ddr_model_g 
			for all : ddr_model 
				use entity micron.ddr_model
				port map (
					Clk   => clk_p,
					Clk_n => clk_n,
					Cke   => cke,
					Cs_n  => cs_n,
					Ras_n => ras_n,
					Cas_n => cas_n,
					We_n  => we_n,
					Ba    => ba,
					Addr  => addr,
					Dm    => dm,
					Dq    => dq,
					Dqs   => dqs);
			end for;
		end for;

		for ddr2_model_g 
			for all : ddr2_model 
				use entity micron.ddr2
				port map (
					Ck    => clk_p,
					Ck_n  => clk_n,
					Cke   => cke,
					Cs_n  => cs_n,
					Ras_n => ras_n,
					Cas_n => cas_n,
					We_n  => we_n,
					Ba    => ba,
					Addr  => addr,
					Dm_rdqs  => dm,
					Dq    => dq,
					Dqs   => dqs,
					Dqs_n => dqs_n,
					rdqs_n => rdqs_n,
					Odt   => odt);
			end for;
		end for;

		for ddr3_model_g 
			for all : ddr3_model 
				use entity micron.ddr3
				port map (
					Rst_n => ddr3_rst,
					Ck    => clk_p,
					Ck_n  => clk_n,
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
					Tdqs_n => tdqs_n,
					Odt   => odt);
			end for;
		end for;
	end for;
end;
