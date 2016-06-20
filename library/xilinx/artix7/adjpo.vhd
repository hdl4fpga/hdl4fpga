library ieee;
use ieee.std_logic_1164.all;

entity adjpo is
	generic (
		L_FREQ_REF_PERIOD_NS  : real;
		L_MEM_REF_PERIOD_NS   : real;
		L_PHASE_REF_PERIOD_NS : real;
		PHASER_INDEX          : natural;
		BUS_WIDTH             : natural;
		PHASER_CTL_BUS_WIDTH  : natural;
		DQS_AUTO_RECAL        : bit;
		DQS_FIND_PATTERN      : bit_vector(0 to 3-1);
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

		oserdes_rst         : in  std_logic;
		iserdes_rst         : in  std_logic;
		oserdes_dqs         : in  std_logic_vector(1 downto 0);
		oserdes_dqsts       : in  std_logic_vector(1 downto 0);
		oserdes_dq          : in  std_logic_vector((4*BUS_WIDTH)-1 downto 0);
		oserdes_dqts        : in  std_logic_vector(1 downto 0);
		oserdes_clk         : in  std_logic;
		oserdes_clk_delayed : in  std_logic;
		oserdes_clkdiv      : in  std_logic;

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

	);

end;

library unisim;
use unisim.vcomponents.all;

architecture xxx of adjpo is
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

--localparam OSERDES_DQ_DATA_RATE_OQ    = OSERDES_DATA_RATE;
--localparam OSERDES_DQ_DATA_RATE_TQ    = OSERDES_DQ_DATA_RATE_OQ;
--localparam OSERDES_DQ_DATA_WIDTH      = OSERDES_DATA_WIDTH;
--localparam OSERDES_DQ_INIT_OQ         = 1'b1;
--localparam OSERDES_DQ_INIT_TQ         = 1'b1;
--localparam OSERDES_DQ_INTERFACE_TYPE  = "DEFAULT";
--localparam OSERDES_DQ_ODELAY_USED     = 0;
--localparam OSERDES_DQ_SERDES_MODE     = "MASTER";
--localparam OSERDES_DQ_SRVAL_OQ        = 1'b1;
--localparam OSERDES_DQ_SRVAL_TQ        = 1'b1;
--// note: obuf used in control path case, no ts in so width irrelevant
--localparam OSERDES_DQ_TRISTATE_WIDTH  = (OSERDES_DQ_DATA_RATE_OQ == "DDR") ? 4 : 1;
--
--localparam OSERDES_DQS_DATA_RATE_OQ   = "DDR";
--localparam OSERDES_DQS_DATA_RATE_TQ   = "DDR";
--localparam OSERDES_DQS_TRISTATE_WIDTH = 4;	// this is always ddr
--localparam OSERDES_DQS_DATA_WIDTH     = 4;
--localparam ODDR_CLK_EDGE              = "SAME_EDGE";
--localparam OSERDES_TBYTE_CTL          = "TRUE";

	xxiii : oserdese2 
	generic map (
		DATA_RATE_OQ    => OSERDES_DQ_DATA_RATE_OQ,
		DATA_RATE_TQ    => OSERDES_DQ_DATA_RATE_TQ,
		DATA_WIDTH      => OSERDES_DQ_DATA_WIDTH,
		INIT_OQ         => OSERDES_DQ_INIT_OQ,
		INIT_TQ         => OSERDES_DQ_INIT_TQ,
		SERDES_MODE     => OSERDES_DQ_SERDES_MODE,
		SRVAL_OQ        => OSERDES_DQ_SRVAL_OQ,
		SRVAL_TQ        => OSERDES_DQ_SRVAL_TQ,
		TRISTATE_WIDTH  => OSERDES_DQ_TRISTATE_WIDTH,
		TBYTE_CTL       => "TRUE",
		TBYTE_SRC       => "TRUE")
	port map (
		OFB       => open,
		OQ        => open,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		TFB       => open,
		TQ        => open,
		CLK       => oserdes_clk,
		CLKDIV    => oserdes_clkdiv,
		D1        => open,
		D2        => open,
		D3        => open,
		D4        => open,
		D5        => open,
		D6        => open,
		D7        => open,
		D8        => open,
		OCE       => '1',
		RST       => oserdes_rst,
		SHIFTIN1  => open
		SHIFTIN2  => open
		T1        => oserdes_dqts(0),
		T2        => oserdes_dqts(0),
		T3        => oserdes_dqts(1),
		T4        => oserdes_dqts(1),
		TCE       => '1',
		TBYTEOUT  => tbyte_out,
		TBYTEIN   => tbyte_out);

	xxiv : oserdese2 
	generic map (
		DATA_RATE_OQ    => OSERDES_DQ_DATA_RATE_OQ,
		DATA_RATE_TQ    => OSERDES_DQ_DATA_RATE_TQ,
		DATA_WIDTH      => OSERDES_DQ_DATA_WIDTH,
		INIT_OQ         => OSERDES_DQ_INIT_OQ,
		INIT_TQ         => OSERDES_DQ_INIT_TQ,
		SERDES_MODE     => OSERDES_DQ_SERDES_MODE,
		SRVAL_OQ        => OSERDES_DQ_SRVAL_OQ,
		SRVAL_TQ        => OSERDES_DQ_SRVAL_TQ,
		TRISTATE_WIDTH  => OSERDES_DQ_TRISTATE_WIDTH,
		TBYTE_CTL       => OSERDES_TBYTE_CTL,
		TBYTE_SRC       => "FALSE")
	port map (
		OFB               open,
		OQ                oserdes_dq_buf(i),
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		TFB       => open,
		TQ        => open,
		TQ        => oserdes_dqts_buf(i),
		CLK       => oserdes_clk,
		CLKDIV    => oserdes_clkdiv,
		D1        => oserdes_dq(4 * i + 0),
		D2        => oserdes_dq(4 * i + 1),
		D3        => oserdes_dq(4 * i + 2),
		D4        => oserdes_dq(4 * i + 3),
		D5        => open,
		D6        => open,
		D7        => open,
		D8        => open,
		OCE       => '1',
		RST       => oserdes_rst,
		SHIFTIN1  => open
		SHIFTIN2  => open
		T1        => open,
		T2        => open,
		T3        => open,
		T4        => open,
		TCE       => '1',
		TBYTEIN   => tbyte_out);

	oddr_dqs : oddr
	generic map (
		DDR_CLK_EDGE => ODDR_CLK_EDGE)
	port map (
       .Q  => oserdes_dqs_buf,
       .D1 => oserdes_dqs(0),
       .D2 => oserdes_dqs(1),
       .C  => oserdes_clk_delayed,
       .R  => '0',
       .S  => '0',
       .CE => '1');

	oddr_dqsts : oddr
	generic map (
		DDR_CLK_EDGE => ODDR_CLK_EDGE)
	port map (
		Q  => oserdes_dqsts_buf,
		D1 => oserdes_dqsts(0),
		D2 => oserdes_dqsts(0),
		C  => oserdes_clk_delayed,
		R  => '0',
		S  => '0',
		CE => '1');
end;
