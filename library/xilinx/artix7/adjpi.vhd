library ieee;
use ieee.std_logic_1164.all;

entity adjpi is
	generic (
		BITLANES              : bit_vector(12-1 downto 0) := b"1111_1111_1111";
		BITLANES_OUTONLY      : bit_vector(12-1 downto 0) := b"0000_0000_0000";
		PO_DATA_CTL           : string  := "FALSE";
		IDELAYE2_IDELAY_TYPE  : string  := "VARIABLE";
		IDELAYE2_IDELAY_VALUE : natural := 00;
		TCK                   : real    := 2500.0;
		BUS_WIDTH             : natural := 12;
		SYNTHESIS             : string  := "FALSE";
		-- PHASER_IN --
		MSB_BURST_PEND_PI  : natural;
		PI_BURST_MODE      : string  := "TRUE";
		PI_CLKOUT_DIV      : natural := 2;
		PI_FREQ_REF_DIV    : string  := "NONE";
		PI_FINE_DELAY      : natural := 1;
		PI_OUTPUT_CLK_SRC  : string  := "DELAYED_REF";
		PI_SEL_CLK_OFFSET  : natural := 0;
		PI_SYNC_IN_DIV_RST : string  := "FALSE");

	port (
		mem_dq_in           : in  std_logic_vector(9 downto 0);
		mem_dq_out          : out std_logic_vector(BUS_WIDTH-1 downto 0);
		mem_dq_ts           : out std_logic_vector(BUS_WIDTH-1 downto 0);
		mem_dqs_in          : in  std_logic;
		mem_dqs_out         : out std_logic;
		mem_dqs_ts          : out std_logic;
		iserdes_dout        : out std_logic_vector((4*10)-1 downto 0);
		dqs_to_phaser       : out std_logic;
		iserdes_clk         : in  std_logic;
		iserdes_clkb        : in  std_logic;
		iserdes_clkdiv      : in  std_logic;
		phy_clk             : in  std_logic;
		rst                 : in  std_logic;
		idelay_inc          : in  std_logic;
		idelay_ce           : in  std_logic;
		idelay_ld           : in  std_logic;
		idelayctrl_refclk   : in  std_logic;
		fine_delay          : in  std_logic_vector(29 downto 0);
		fine_delay_sel      : in  std_logic;
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

architecture mix of adjpi is
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

	xxi : iserdese2
	generic map (
		DATA_RATE         => ISERDES_DQ_DATA_RATE,
		DATA_WIDTH        => ISERDES_DQ_DATA_WIDTH,
		DYN_CLKDIV_INV_EN => ISERDES_DQ_DYN_CLKDIV_INV_EN,
		DYN_CLK_INV_EN    => ISERDES_DQ_DYN_CLK_INV_EN,
		INIT_Q1           => ISERDES_DQ_INIT_Q1,
		INIT_Q2           => ISERDES_DQ_INIT_Q2,
		INIT_Q3           => ISERDES_DQ_INIT_Q3,
		INIT_Q4           => ISERDES_DQ_INIT_Q4,
		INTERFACE_TYPE    => ISERDES_DQ_INTERFACE_TYPE,
		NUM_CE            => ISERDES_NUM_CE,
		IOBDELAY          => ISERDES_DQ_IOBDELAY,
		OFB_USED          => ISERDES_DQ_OFB_USED,
		SERDES_MODE       => ISERDES_DQ_SERDES_MODE,
		SRVAL_Q1          => ISERDES_DQ_SRVAL_Q1,
		SRVAL_Q2          => ISERDES_DQ_SRVAL_Q2,
		SRVAL_Q3          => ISERDES_DQ_SRVAL_Q3,
		SRVAL_Q4          => ISERDES_DQ_SRVAL_Q4)
	port map (
		O         => open,

		Q1        => iserdes_dout(3),
		Q2        => iserdes_dout(2),
		Q3        => iserdes_dout(1),
		Q4        => iserdes_dout(0),
		Q5        => open,
		Q6        => open,
		Q7        => open,
		Q8        => open,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,

		BITSLIP   => '0',
		CE1       => '1',
		CE2       => '1',
		CLK       => iserdes_clk_d,
		CLKB      => iserdes_clk_d, --!iserdes_clk_d,
		CLKDIVP   => iserdes_clkdiv,
		CLKDIV    => open,
		DDLY      => data_in_dly(i),
		D         => data_in(i),
		DYNCLKDIVSEL => '0',
		DYNCLKSEL    => '0',
		OCLK      => oserdes_clk,
		OCLKB     => open,
		OFB       => open,
		RST       => '0',
		SHIFTIN1  => '0',
		SHIFTIN2  => '0');

--localparam IDELAYE2_CINVCTRL_SEL          = "FALSE";
--localparam IDELAYE2_DELAY_SRC             = "IDATAIN";
--localparam IDELAYE2_HIGH_PERFORMANCE_MODE = "TRUE";
--localparam IDELAYE2_PIPE_SEL              = "FALSE";
--localparam IDELAYE2_ODELAY_TYPE           = "FIXED";
--localparam IDELAYE2_REFCLK_FREQUENCY      = ((FPGA_SPEED_GRADE == 2 || FPGA_SPEED_GRADE == 3) && TCK <= 1500) ? 400.0 :
--                                             (FPGA_SPEED_GRADE == 1 && TCK <= 1500) ?  300.0 : 200.0;
--localparam IDELAYE2_SIGNAL_PATTERN        = "DATA";
--localparam IDELAYE2_FINEDELAY_IN          = "ADD_DLY";

	xxii : idelaye2_finedelay
	generic map (
		CINVCTRL_SEL          => IDELAYE2_CINVCTRL_SEL,
		DELAY_SRC             => IDELAYE2_DELAY_SRC,
		HIGH_PERFORMANCE_MODE => IDELAYE2_HIGH_PERFORMANCE_MODE,
		IDELAY_TYPE           => IDELAYE2_IDELAY_TYPE,
		IDELAY_VALUE          => IDELAYE2_IDELAY_VALUE,
		PIPE_SEL              => IDELAYE2_PIPE_SEL,
		FINEDELAY             => IDELAYE2_FINEDELAY_IN,
		REFCLK_FREQUENCY      => IDELAYE2_REFCLK_FREQUENCY,
		SIGNAL_PATTERN        => IDELAYE2_SIGNAL_PATTERN)
	port map (
		CNTVALUEOUT           => open,
		DATAOUT               => data_in_dly(i),
		C                     => phy_clk, /--automatically wired by ISE
		CE                    => idelay_ce,
		CINVCTRL              => open,
		CNTVALUEIN            => 5'b00000,
		DATAIN                => 1'b0,
		IDATAIN               => data_in(i),
		IFDLY                 => fine_delay_r(i*3+:3),
		INC                   => idelay_inc,
		LD                    => idelay_ld | idelay_ld_rst),
		LDPIPEEN              => '0',
		REGRST                => rst);

end
