library ieee;
use ieee.std_logic_1164.all;

entity phase_dqs is
	generic (
		DQS_AUTO_RECAL     : integer;
		DQS_FIND_PATTERN   : string;
		-- PHASER_IN --
		PI_BURST_MODE      : string  := "TRUE";
		PI_CLKOUT_DIV      : integer := 2;
		PI_FREQ_REF_DIV    : string  := "NONE",;
		PI_FINE_DELAY      : integer := 1;
		PI_OUTPUT_CLK_SRC  : string  := "DELAYED_REF";
		PI_SEL_CLK_OFFSET  : integer := 0;

		PI_SYNC_IN_DIV_RST : string  := "FALSE");

		-- PHASER_OUT
		PO_CLKOUT_DIV      : integer := 4;
		PO_FINE_DELAY      : integer := 0;
		PO_COARSE_BYPASS   : string  := "FALSE";
		PO_COARSE_DELAY    : integer := 0;
		PO_OCLK_DELAY      : integer := 0;
		PO_OCLKDELAY_INV   : string  := "TRUE";
		PO_OUTPUT_CLK_SRC  : string  := "DELAYED_REF";
		PO_SYNC_IN_DIV_RST : string  := "FALSE";

		-- OSERDES
		OSERDES_DATA_RATE  : string  := "DDR";
		OSERDES_DATA_WIDTH : integer := 4;

		-- IDELAY
		IDELAYE2_IDELAY_TYPE  : string  := "VARIABLE";
		IDELAYE2_IDELAY_VALUE : integer := 0;
		IODELAY_GRP           : string  := "IODELAY_MIG";
		FPGA_SPEED_GRADE      : integer := 1;
		BANK_TYPE             : string  := "HR_IO";
		TCK                   : real    := 0.00;
		SYNTHESIS             : string  := "FALSE");

	port (
		rst                    : in  std_logic;
		phy_clk                : in  std_logic;
		rst_pi_div2            : in  std_logic;
		clk_div2               : in  std_logic;
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
		if_rst                 : in  std_logic;
		byte_rd_en_oth_lanes   : in  std_logic_vector(2 downto 0);
		byte_rd_en_oth_banks   : in  std_logic_vector(1 downto 0);
		byte_rd_en             : out std_logic;
							   :
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
							   :
		pi_en_calib            : in  std_logic_vector(1 downto 0);
		pi_rst_dqs_find        : in  std_logic;
		pi_fine_enable         : in  std_logic;
		pi_fine_inc            : in  std_logic;
		pi_counter_load_en     : in  std_logic;
		pi_counter_read_en     : in  std_logic;
		pi_counter_load_val    : in  std_logic_vector(5 downto 0);
							   :
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

architecture of is
begin

generate
if ( PO_DATA_CTL == "FALSE" ) begin : if_empty_null
    assign if_empty = 0;
    assign if_a_empty = 0;
    assign if_full = 0;
    assign if_a_full = 0;
end
else begin : if_empty_gen
    assign if_empty   = empty_post_fifo;
    assign if_a_empty = if_a_empty_;
    assign if_full    = if_full_;
    assign if_a_full  = if_a_full_;
end
endgenerate

generate
if ( PO_DATA_CTL == "FALSE" ) begin : dq_gen_48
   assign of_dqbus(48-1:0) = {of_q6(7:4), of_q5(7:4), of_q9, of_q8, of_q7, of_q6(3:0), of_q5(3:0), of_q4, of_q3, of_q2, of_q1, of_q0};
   assign phy_din =  80'h0;
   assign byte_rd_en = 1'b1;
end
else begin : dq_gen_40

  assign of_dqbus(40-1:0) = {of_q9, of_q8, of_q7, of_q6(3:0), of_q5(3:0), of_q4, of_q3, of_q2, of_q1, of_q0};
  assign ififo_rd_en_in   = !if_empty_def ? ((&byte_rd_en_oth_banks) && (&byte_rd_en_oth_lanes) && byte_rd_en) :
                                            ((|byte_rd_en_oth_banks) || (|byte_rd_en_oth_lanes) || byte_rd_en);

  if (USE_PRE_POST_FIFO == "TRUE") begin : if_post_fifo_gen

   // IN_FIFO EMPTY->RDEN TIMING FIX:
   assign rd_data =  {if_q9, if_q8, if_q7, if_q6, if_q5, if_q4, if_q3, if_q2, if_q1, if_q0};

   always @(posedge phy_clk) begin
     rd_data_r      <= #(025) rd_data;
     if_empty_r(0)  <= #(025) if_empty_;
     if_empty_r(1)  <= #(025) if_empty_;
     if_empty_r(2)  <= #(025) if_empty_;
     if_empty_r(3)  <= #(025) if_empty_;
   end


   mig_7series_v4_0_ddr_if_post_fifo #
     (
      .TCQ   (25),    // simulation CK->Q delay
      .DEPTH (4), //2     // depth - account for up to 2 cycles of skew
      .WIDTH (80)     // width
      )
     u_ddr_if_post_fifo
       (
        .clk       (phy_clk),
        .rst       (ififo_rst),
        .empty_in  (if_empty_r),
        .rd_en_in  (ififo_rd_en_in),
        .d_in      (rd_data_r),
        .empty_out (empty_post_fifo),
        .byte_rd_en (byte_rd_en),
        .d_out     (phy_din)
        );

  end
  else begin :  phy_din_gen
     assign phy_din =  {if_q9, if_q8, if_q7, if_q6, if_q5, if_q4, if_q3, if_q2, if_q1, if_q0};
     assign empty_post_fifo = if_empty_;
  end

end
endgenerate


assign { if_d9, if_d8, if_d7, if_d6, if_d5, if_d4, if_d3, if_d2, if_d1, if_d0} = iserdes_dout;


wire (1:0)  rank_sel_i  = ((phaser_ctl_bus(MSB_RANK_SEL_I :MSB_RANK_SEL_I -7) >> (PHASER_INDEX << 1)) & 2'b11);




generate

///////////////////////////////////////////////////////////////////////////////
// Synchronize pi_phase_locked to phy_clk domain
///////////////////////////////////////////////////////////////////////////////
wire       pi_phase_locked_w;
wire       pi_dqs_found_w;
wire (5:0) pi_counter_read_val_w;
generate
  if (PI_DIV2_INCDEC == "TRUE") begin: phaser_in_div2_clk
    (* ASYNC_REG = "TRUE" *) reg  pi_phase_locked_r1;
    (* ASYNC_REG = "TRUE" *) reg  pi_phase_locked_r2;
    (* ASYNC_REG = "TRUE" *) reg  pi_phase_locked_r3;
    reg  pi_phase_locked_r4;

    (* ASYNC_REG = "TRUE" *) reg  pi_dqs_found_r1;
    (* ASYNC_REG = "TRUE" *) reg  pi_dqs_found_r2;
    (* ASYNC_REG = "TRUE" *) reg  pi_dqs_found_r3;
    reg  pi_dqs_found_r4;

    (* ASYNC_REG = "TRUE" *) reg (5:0) pi_counter_read_val_r1;
    (* ASYNC_REG = "TRUE" *) reg (5:0) pi_counter_read_val_r2;
    (* ASYNC_REG = "TRUE" *) reg (5:0) pi_counter_read_val_r3;
    reg (5:0) pi_counter_read_val_r4;

    always @ (posedge phy_clk) begin
      pi_phase_locked_r1 <= pi_phase_locked_w;
      pi_phase_locked_r2 <= pi_phase_locked_r1;
      pi_phase_locked_r3 <= pi_phase_locked_r2;
      pi_dqs_found_r1    <= pi_dqs_found_w;
      pi_dqs_found_r2    <= pi_dqs_found_r1;
      pi_dqs_found_r3    <= pi_dqs_found_r2;
      pi_counter_read_val_r1 <= pi_counter_read_val_w;
      pi_counter_read_val_r2 <= pi_counter_read_val_r1;
      pi_counter_read_val_r3 <= pi_counter_read_val_r2;
    end

    always @ (posedge phy_clk) begin
      if (rst)
        pi_phase_locked_r4 <= 1'b0;
      else if (pi_phase_locked_r2 == pi_phase_locked_r3)
        pi_phase_locked_r4 <= pi_phase_locked_r3;
    end

    always @ (posedge phy_clk) begin
      if (rst)
        pi_dqs_found_r4 <= 1'b0;
      else if (pi_dqs_found_r2 == pi_dqs_found_r3)
        pi_dqs_found_r4 <= pi_dqs_found_r3;
    end

    always @ (posedge phy_clk) begin
      if (rst)
        pi_counter_read_val_r4 <= 1'b0;
      else if (pi_counter_read_val_r2 == pi_counter_read_val_r3)
        pi_counter_read_val_r4 <= pi_counter_read_val_r3;
    end

    assign pi_phase_locked     = pi_phase_locked_r4;
    assign pi_dqs_found        = pi_dqs_found_r4;
    assign pi_counter_read_val = pi_counter_read_val_r4;

  end else begin: pahser_in_div4_clk
    assign pi_phase_locked     = pi_phase_locked_w;
    assign pi_dqs_found        = pi_dqs_found_w;
    assign pi_counter_read_val = pi_counter_read_val_w;
  end
endgenerate


generate

if ( PO_DATA_CTL == "TRUE" || ((RCLK_SELECT_LANE==ABCD) && (CKE_ODT_AUX =="TRUE")))  begin : phaser_in_gen

//if (PI_DIV2_INCDEC == "TRUE") begin: phaser_in_div2_sys_clk
if (PI_DIV2_INCDEC == "TRUE") begin

PHASER_IN_PHY #(
) phaser_in (
  .DQSFOUND                         (pi_dqs_found_w),
  .DQSOUTOFRANGE                    (dqs_out_of_range),
  .FINEOVERFLOW                     (pi_fine_overflow),
  .PHASELOCKED                      (pi_phase_locked_w),
  .ISERDESRST                       (pi_iserdes_rst),
  .ICLKDIV                          (iserdes_clkdiv),
  .ICLK                             (iserdes_clk),
  .COUNTERREADVAL                   (pi_counter_read_val_w),
  .RCLK                             (rclk),
  .WRENABLE                         (ififo_wr_enable),
  .BURSTPENDINGPHY                  (phaser_ctl_bus(MSB_BURST_PEND_PI - 3 + PHASER_INDEX)),
  .ENCALIBPHY                       (pi_en_calib),
  .FINEENABLE                       (pi_fine_enable),
  .FREQREFCLK                       (freq_refclk),
  .MEMREFCLK                        (mem_refclk),
  .RANKSELPHY                       (rank_sel_i),
  .PHASEREFCLK                      (dqs_to_phaser),
  .RSTDQSFIND                       (pi_rst_dqs_find),
  .RST                              (rst_pi_div2),
  .FINEINC                          (pi_fine_inc),
  .COUNTERLOADEN                    (pi_counter_load_en),
  .COUNTERREADEN                    (pi_counter_read_en),
  .COUNTERLOADVAL                   (pi_counter_load_val),
  .SYNCIN                           (sync_pulse),
  .SYSCLK                           (clk_div2)
);
end

else begin

PHASER_IN_PHY #(
  .BURST_MODE                       ( PI_BURST_MODE),
  .CLKOUT_DIV                       ( PI_CLKOUT_DIV),
  .DQS_AUTO_RECAL                   ( DQS_AUTO_RECAL),
  .DQS_FIND_PATTERN                 ( DQS_FIND_PATTERN),
  .SEL_CLK_OFFSET                   ( PI_SEL_CLK_OFFSET),
  .FINE_DELAY                       ( PI_FINE_DELAY),
  .FREQ_REF_DIV                     ( PI_FREQ_REF_DIV),
  .OUTPUT_CLK_SRC                   ( PI_OUTPUT_CLK_SRC),
  .SYNC_IN_DIV_RST                  ( PI_SYNC_IN_DIV_RST),
  .REFCLK_PERIOD                    ( L_FREQ_REF_PERIOD_NS),
  .MEMREFCLK_PERIOD                 ( L_MEM_REF_PERIOD_NS),
  .PHASEREFCLK_PERIOD               ( L_PHASE_REF_PERIOD_NS)

) phaser_in (
  .DQSFOUND                         (pi_dqs_found_w),
  .DQSOUTOFRANGE                    (dqs_out_of_range),
  .FINEOVERFLOW                     (pi_fine_overflow),
  .PHASELOCKED                      (pi_phase_locked_w),
  .ISERDESRST                       (pi_iserdes_rst),
  .ICLKDIV                          (iserdes_clkdiv),
  .ICLK                             (iserdes_clk),
  .COUNTERREADVAL                   (pi_counter_read_val_w),
  .RCLK                             (rclk),
  .WRENABLE                         (ififo_wr_enable),
  .BURSTPENDINGPHY                  (phaser_ctl_bus(MSB_BURST_PEND_PI - 3 + PHASER_INDEX)),
  .ENCALIBPHY                       (pi_en_calib),
  .FINEENABLE                       (pi_fine_enable),
  .FREQREFCLK                       (freq_refclk),
  .MEMREFCLK                        (mem_refclk),
  .RANKSELPHY                       (rank_sel_i),
  .PHASEREFCLK                      (dqs_to_phaser),
  .RSTDQSFIND                       (pi_rst_dqs_find),
  .RST                              (rst),
  .FINEINC                          (pi_fine_inc),
  .COUNTERLOADEN                    (pi_counter_load_en),
  .COUNTERREADEN                    (pi_counter_read_en),
  .COUNTERLOADVAL                   (pi_counter_load_val),
  .SYNCIN                           (sync_pulse),
  .SYSCLK                           (phy_clk)
);


	: phaser_out_phy
	generic_map (
		CLKOUT_DIV          => PO_CLKOUT_DIV,
		DATA_CTL_N          => PO_DATA_CTL,
		FINE_DELAY          => PO_FINE_DELAY,
		COARSE_BYPASS       => PO_COARSE_BYPASS,
		COARSE_DELAY        => PO_COARSE_DELAY,
		OCLK_DELAY          => PO_OCLK_DELAY
		OCLKDELAY_INV       => PO_OCLKDELAY_INV,
		OUTPUT_CLK_SRC      => PO_OUTPUT_CLK_SRC,
		SYNC_IN_DIV_RST     => PO_SYNC_IN_DIV_RST,
		REFCLK_PERIOD       => L_FREQ_REF_PERIOD_NS,
		PHASEREFCLK_PERIOD  => 1, -- dummy, not used
		PO                  => PO_DCD_SETTING,
		MEMREFCLK_PERIOD    => L_MEM_REF_PERIOD_NS)
	port map (
		COARSEOVERFLOW      => (po_coarse_overflow),
		CTSBUS              => (oserdes_dqs_ts),
		DQSBUS              => (oserdes_dqs),
		DTSBUS              => (oserdes_dq_ts),
		FINEOVERFLOW        => (po_fine_overflow),
		OCLKDIV             => (oserdes_clkdiv),
		OCLK                => (oserdes_clk),
		OCLKDELAYED         => (oserdes_clk_delayed),
		COUNTERREADVAL      => (po_counter_read_val),
		BURSTPENDINGPHY     => (phaser_ctl_bus(MSB_BURST_PEND_PO -3 + PHASER_INDEX)),
		ENCALIBPHY          => (po_en_calib),
		RDENABLE            => (po_rd_enable),
		FREQREFCLK          => (freq_refclk),
		MEMREFCLK           => (mem_refclk),
		PHASEREFCLK         => (/*phase_ref*/),
		RST                 => (rst),
		OSERDESRST          => (po_oserdes_rst),
		COARSEENABLE        => (po_coarse_enable),
		FINEENABLE          => (po_fine_enable),
		COARSEINC           => (po_coarse_inc),
		FINEINC             => (po_fine_inc),
		SELFINEOCLKDELAY    => (po_sel_fine_oclk_delay),
		COUNTERLOADEN       => (po_counter_load_en),
		COUNTERREADEN       => (po_counter_read_en),
		COUNTERLOADVAL      => (po_counter_load_val),
		SYNCIN              => (sync_pulse),
		SYSCLK              => (phy_clk));


generate

mig_7series_v4_0_ddr_byte_group_io   #
   (
   .PO_DATA_CTL             (PO_DATA_CTL),
   .BITLANES                (BITLANES),
   .BITLANES_OUTONLY        (BITLANES_OUTONLY),
   .OSERDES_DATA_RATE       (L_OSERDES_DATA_RATE),
   .OSERDES_DATA_WIDTH      (L_OSERDES_DATA_WIDTH),
   .IODELAY_GRP             (IODELAY_GRP),
   .FPGA_SPEED_GRADE        (FPGA_SPEED_GRADE),
   .IDELAYE2_IDELAY_TYPE    (IDELAYE2_IDELAY_TYPE),
   .IDELAYE2_IDELAY_VALUE   (IDELAYE2_IDELAY_VALUE),
   .TCK                     (TCK),
   .SYNTHESIS               (SYNTHESIS)
   )
   ddr_byte_group_io
   (
   .mem_dq_out               (mem_dq_out),
   .mem_dq_ts                (mem_dq_ts),
   .mem_dq_in                (mem_dq_in),
   .mem_dqs_in               (mem_dqs_in),
   .mem_dqs_out              (mem_dqs_out),
   .mem_dqs_ts               (mem_dqs_ts),
   .rst                      (rst),
   .oserdes_rst              (po_oserdes_rst),
   .iserdes_rst              (pi_iserdes_rst ),
   .iserdes_dout             (iserdes_dout),
   .dqs_to_phaser            (dqs_to_phaser),
   .phy_clk                  (phy_clk),
   .iserdes_clk              (iserdes_clk),
   .iserdes_clkb             (!iserdes_clk),
   .iserdes_clkdiv           (iserdes_clkdiv),
   .idelay_inc               (idelay_inc),
   .idelay_ce                (idelay_ce),
   .idelay_ld                (idelay_ld),
   .idelayctrl_refclk        (idelayctrl_refclk),
   .oserdes_clk              (oserdes_clk),
   .oserdes_clk_delayed      (oserdes_clk_delayed),
   .oserdes_clkdiv           (oserdes_clkdiv),
   .oserdes_dqs              ({oserdes_dqs(1), oserdes_dqs(0)}),
   .oserdes_dqsts            ({oserdes_dqs_ts(1), oserdes_dqs_ts(0)}),
   .oserdes_dq               (of_dqbus),
   .oserdes_dqts             ({oserdes_dq_ts(1), oserdes_dq_ts(0)}),
   .fine_delay               (fine_delay),
   .fine_delay_sel           (fine_delay_sel)
    );

genvar i;
generate
  for (i = 0; i <= 5; i = i+1) begin : ddr_ck_gen_loop
    if (PO_DATA_CTL== "FALSE" && (BYTELANES_DDR_CK(i*4+PHASER_INDEX))) begin : ddr_ck_gen
      ODDR #(.DDR_CLK_EDGE  (ODDR_CLK_EDGE))
        ddr_ck (
        .C    (oserdes_clk),
        .R    (1'b0),
        .S    (),
        .D1   (1'b0),
        .D2   (1'b1),
        .CE   (1'b1),
        .Q    (ddr_ck_out_q(i))
      );
      OBUFDS ddr_ck_obuf  (.I(ddr_ck_out_q(i)), .O(ddr_ck_out(i*2)), .OB(ddr_ck_out(i*2+1)));
    end // ddr_ck_gen
    else  begin : ddr_ck_null
      assign ddr_ck_out(i*2+1:i*2) = 2'b0;
    end
  end // ddr_ck_gen_loop
endgenerate

end;
