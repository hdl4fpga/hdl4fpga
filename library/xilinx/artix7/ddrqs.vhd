library ieee;
use ieee.std_logic_1164.all;

entity phase_dqs is
	generic (
		L_FREQ_REF_PERIOD_NS  : real;
		L_MEM_REF_PERIOD_NS   : real;
		L_PHASE_REF_PERIOD_NS : real;
		PHASER_INDEX          : natural;
		BUS_WIDTH             : natural;
		PHASER_CTL_BUS_WIDTH  : natural;
		DQS_AUTO_RECAL        : bit;
		DQS_FIND_PATTERN      : bit_vector(0 to 3-1);
		-- PHASER_IN --
		MSB_BURST_PEND_PI  : natural;
		PI_BURST_MODE      : string  := "TRUE";
		PI_CLKOUT_DIV      : natural := 2;
		PI_FREQ_REF_DIV    : string  := "NONE";
		PI_FINE_DELAY      : natural := 1;
		PI_OUTPUT_CLK_SRC  : string  := "DELAYED_REF";
		PI_SEL_CLK_OFFSET  : natural := 0;
		PI_SYNC_IN_DIV_RST : string  := "FALSE";

		-- PHASER_OUT
		MSB_BURST_PEND_PO  : natural;
		PO_CLKOUT_DIV      : natural := 4;
		PO_FINE_DELAY      : natural := 0;
		PO_COARSE_BYPASS   : string  := "FALSE";
		PO_COARSE_DELAY    : natural := 0;
		PO_OCLK_DELAY      : natural := 0;
		PO_OCLKDELAY_INV   : string  := "TRUE";
		PO_OUTPUT_CLK_SRC  : string  := "DELAYED_REF";
		PO_SYNC_IN_DIV_RST : string  := "FALSE";
		PO_DATA_CTL        : string;
		PO_DCD_SETTING     : bit_vector(0 to 3-1);
		-- OSERDES
		OSERDES_DATA_RATE  : string  := "DDR";
		OSERDES_DATA_WIDTH : natural := 4;

		BANK_TYPE             : string  := "HR_IO";
		TCK                   : real    := 0.00;
		SYNTHESIS             : string  := "FALSE");

	port (
		freq_refclk            : in  std_logic;
		mem_refclk             : in  std_logic;
		idelayctrl_refclk      : in  std_logic;
		sync_pulse             : in  std_logic;
		mem_dq_out             : out std_logic_vector(BUS_WIDTH-1 downto 0);
		mem_dq_ts              : out std_logic_vector(BUS_WIDTH-1 downto 0);
		mem_dq_in              : in  std_logic_vector(9 downto 0);
		mem_dqs_out            : out std_logic;
		mem_dqs_ts             : out std_logic;
		mem_dqs_in             : in  std_logic;
		ddr_ck_out             : out std_logic_vector(11 downto 0);
		rclk                   : out std_logic;
		phy_din                : out std_logic_vector(79 downto 0);
		phy_dout               : in  std_logic_vector(79 downto 0);
		phy_cmd_wr_en          : in  std_logic;
		phy_data_wr_en         : in  std_logic;
		phy_rd_en              : in  std_logic;
		phaser_ctl_bus         : in  std_logic_vector(PHASER_CTL_BUS_WIDTH-1 downto 0);
		idelay_inc             : in  std_logic;
		idelay_ce              : in  std_logic;
		idelay_ld              : in  std_logic;
		byte_rd_en_oth_lanes   : in  std_logic_vector(2 downto 0);
		byte_rd_en_oth_banks   : in  std_logic_vector(1 downto 0);
		byte_rd_en             : out std_logic;

		po_rst                 : in  std_logic;
		po_phy_clk             : in  std_logic;
		po_coarse_overflow     : out std_logic;
		po_fine_overflow       : out std_logic;
		po_counter_read_val    : out std_logic_vector(8 downto 0);
		po_fine_enable         : in  std_logic;
		po_coarse_enable       : in  std_logic;
		po_en_calib            : in  std_logic_vector(1 downto 0);
		po_fine_inc            : in  std_logic;
		po_coarse_inc          : in  std_logic;
		po_counter_load_en     : in  std_logic;
		po_counter_read_en     : in  std_logic;
		po_sel_fine_oclk_delay : in  std_logic;
		po_counter_load_val    : in  std_logic_vector(8 downto 0);

		pi_rst                 : in  std_logic;
		pi_phy_clk             : in  std_logic;
		pi_en_calib            : in  std_logic_vector(1 downto 0);
		pi_rst_dqs_find        : in  std_logic;
		pi_fine_enable         : in  std_logic;
		pi_fine_inc            : in  std_logic;
		pi_counter_load_en     : in  std_logic;
		pi_counter_read_en     : in  std_logic;
		pi_counter_load_val    : in  std_logic_vector(5 downto 0);

		pi_iserdes_rst         : out std_logic;
		pi_phase_locked        : out std_logic;
		pi_fine_overflow       : out std_logic;
		pi_counter_read_val    : out std_logic_vector(5 downto 0);
		pi_dqs_found           : out std_logic;
		dqs_out_of_range       : out std_logic;
		fine_delay             : in  std_logic_vector(29 downto 0);
		fine_delay_sel         : in  std_logic);

end;

library unisim;
use unisim.vcomponents.all;

architecture xxx of phase_dqs is
	signal phase_ref : std_logic;
	signal pi_dqs_found_w : std_logic;
	signal pi_phase_locked_w : std_logic;
	signal iserdes_clkdiv : std_logic;
	signal iserdes_clk : std_logic;
	signal pi_counter_read_val_w : std_logic;
	signal ififo_wr_enable : std_logic;
	signal rank_sel_i : std_logic;
	signal dqs_to_phaser : std_logic;
	signal oserdes_dqs_ts : std_logic;
	signal oserdes_dqs : std_logic;
	signal oserdes_dq_ts : std_logic;
	signal oserdes_clkdiv : std_logic;
	signal oserdes_clk : std_logic;
	signal oserdes_clk_delayed : std_logic;
	signal po_rd_enable : std_logic;
	signal po_oserdes_rst : std_logic;
begin

	pi_phy_i : phaser_in_phy
	generic map (
		BURST_MODE         => PI_BURST_MODE,
		CLKOUT_DIV         => PI_CLKOUT_DIV,
		DQS_AUTO_RECAL     => DQS_AUTO_RECAL,
		DQS_FIND_PATTERN   => DQS_FIND_PATTERN,
		SEL_CLK_OFFSET     => PI_SEL_CLK_OFFSET,
		FINE_DELAY         => PI_FINE_DELAY,
		FREQ_REF_DIV       => PI_FREQ_REF_DIV,
		OUTPUT_CLK_SRC     => PI_OUTPUT_CLK_SRC,
		SYNC_IN_DIV_RST    => PI_SYNC_IN_DIV_RST,
		REFCLK_PERIOD      => L_FREQ_REF_PERIOD_NS,
		MEMREFCLK_PERIOD   => L_MEM_REF_PERIOD_NS,
		PHASEREFCLK_PERIOD => L_PHASE_REF_PERIOD_NS)
	port map (
		dqsfound           => pi_dqs_found_w,
		dqsoutofrange      => dqs_out_of_range,
		fineoverflow       => pi_fine_overflow,
		phaselocked        => pi_phase_locked_w,
		iserdesrst         => pi_iserdes_rst,
		iclkdiv            => iserdes_clkdiv,
		iclk               => iserdes_clk,
		counterreadval     => pi_counter_read_val_w,
		rclk               => rclk,
		wrenable           => ififo_wr_enable,
		burstpendingphy    => phaser_ctl_bus(MSB_BURST_PEND_PI - 3 + PHASER_INDEX),
		encalibphy         => pi_en_calib,
		fineenable         => pi_fine_enable,
		freqrefclk         => freq_refclk,
		memrefclk          => mem_refclk,
		rankselphy         => rank_sel_i,
		phaserefclk        => dqs_to_phaser, -- <-- mem_dqs_in
		rstdqsfind         => pi_rst_dqs_find,
		rst                => pi_rst,
		fineinc            => pi_fine_inc,
		counterloaden      => pi_counter_load_en,
		counterreaden      => pi_counter_read_en,
		counterloadval     => pi_counter_load_val,
		syncin             => sync_pulse,
		sysclk             => pi_phy_clk);

	po_phy_i : phaser_out_phy
	generic map (
		CLKOUT_DIV         => PO_CLKOUT_DIV,
		DATA_CTL_N         => PO_DATA_CTL,
		FINE_DELAY         => PO_FINE_DELAY,
		COARSE_BYPASS      => PO_COARSE_BYPASS,
		COARSE_DELAY       => PO_COARSE_DELAY,
		OCLK_DELAY         => PO_OCLK_DELAY,
		OCLKDELAY_INV      => PO_OCLKDELAY_INV,
		OUTPUT_CLK_SRC     => PO_OUTPUT_CLK_SRC,
		SYNC_IN_DIV_RST    => PO_SYNC_IN_DIV_RST,
		REFCLK_PERIOD      => L_FREQ_REF_PERIOD_NS,
		PHASEREFCLK_PERIOD => 1.0, -- dummy, not used
		PO                 => PO_DCD_SETTING,
		MEMREFCLK_PERIOD   => L_MEM_REF_PERIOD_NS)
	port map (
		coarseoverflow      => po_coarse_overflow,
		ctsbus              => oserdes_dqs_ts,
		dqsbus              => oserdes_dqs,
		dtsbus              => oserdes_dq_ts,
		fineoverflow        => po_fine_overflow,
		oclkdiv             => oserdes_clkdiv,
		oclk                => oserdes_clk,
		oclkdelayed         => oserdes_clk_delayed,
		counterreadval      => po_counter_read_val,
		burstpendingphy     => phaser_ctl_bus(MSB_BURST_PEND_PO -3 + PHASER_INDEX),
		encalibphy          => po_en_calib,
		rdenable            => po_rd_enable,
		freqrefclk          => freq_refclk,
		memrefclk           => mem_refclk,
		phaserefclk         => phase_ref,
		rst                 => po_rst,
		oserdesrst          => po_oserdes_rst,
		coarseenable        => po_coarse_enable,
		fineenable          => po_fine_enable,
		coarseinc           => po_coarse_inc,
		fineinc             => po_fine_inc,
		selfineoclkdelay    => po_sel_fine_oclk_delay,
		counterloaden       => po_counter_load_en,
		counterreaden       => po_counter_read_en,
		counterloadval      => po_counter_load_val,
		syncin              => sync_pulse,
		sysclk              => po_phy_clk);

end;
