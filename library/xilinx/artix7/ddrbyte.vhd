library ieee;
use ieee.std_logic_1164.all;

entity is
	generic (
		BITLANES              : bit_vector(12-1 downto 0) := 12'b1111_1111_1111;
		BITLANES_OUTONLY      : bit_vector(12-1 downto 0) := 12'b0000_0000_0000;
		PO_DATA_CTL           : string  := "FALSE";
		OSERDES_DATA_RATE     : string  := "DDR";
		OSERDES_DATA_WIDTH    : natural := 4;
		IDELAYE2_IDELAY_TYPE  : string  := "VARIABLE";
		IDELAYE2_IDELAY_VALUE : natural := 00;
		TCK                   : real    := 2500.0;
		BUS_WIDTH             : natural := 12;
		SYNTHESIS             : string  := "FALSE");
	port (
		mem_dq_in           : in  std_logic_vector(9 downto 0)
		mem_dq_out          : out std_logic_vector(BUS_WIDTH-1 downto 0)
		mem_dq_ts           : out std_logic_vector(BUS_WIDTH-1 downto 0)
		mem_dqs_in          : in  std_logic;
		mem_dqs_out         : out std_logic;
		mem_dqs_ts          : out std_logic;
		iserdes_dout        : out std_logic_vector((4*10)-1 downto 0)
		dqs_to_phaser       : out std_logic;
		iserdes_clk         : in  std_logic;
		iserdes_clkb        : in  std_logic;
		iserdes_clkdiv      : in  std_logic;
		phy_clk             : in  std_logic;
		rst                 : in  std_logic;
		oserdes_rst         : in  std_logic;
		iserdes_rst         : in  std_logic;
		oserdes_dqs         : in  std_logic_vector(1 downto 0)
		oserdes_dqsts       : in  std_logic_vector(1 downto 0)
		oserdes_dq          : in  std_logic_vector((4*BUS_WIDTH)-1 downto 0)
		oserdes_dqts        : in  std_logic_vector(1 downto 0)
		oserdes_clk         : in  std_logic;
		oserdes_clk_delayed : in  std_logic;
		oserdes_clkdiv      : in  std_logic;
		idelay_inc          : in  std_logic;
		idelay_ce           : in  std_logic;
		idelay_ld           : in  std_logic;
		idelayctrl_refclk   : in  std_logic;
		fine_delay          : in  std_logic_vector(29 downto 0);
		fine_delay_sel      : in  std_logic);
end;

architecture  of is
begin
	: iserdese2
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
         .O          => (),
         .Q1         => (iserdes_dout(4*i + 3)),
         .Q2         => (iserdes_dout(4*i + 2)),
         .Q3         => (iserdes_dout(4*i + 1)),
         .Q4         => (iserdes_dout(4*i + 0)),
         .Q5         => (),
         .Q6         => (),
         .Q7         => (),
         .Q8         => (),
         .SHIFTOUT1  => (),
         .SHIFTOUT2  => (),

         .BITSLIP    => (1'b0),
         .CE1        => (1'b1),
         .CE2        => (1'b1),
         .CLK        => (iserdes_clk_d),
         .CLKB       => (!iserdes_clk_d),
         .CLKDIVP    => (iserdes_clkdiv),
         .CLKDIV     => (),
         .DDLY       => (data_in_dly(i)),
         .D          => (data_in(i)), // dedicated route to iob for debugging
	                                           // or as needed, select with IOBDELAY
         .DYNCLKDIVSEL               (1'b0),
         .DYNCLKSEL                  (1'b0),
// NOTE: OCLK is not used in this design, but is required to meet
// a design rule check in map and bitgen. Do not disconnect it.
         .OCLK                       (oserdes_clk),
         .OCLKB                      (),
         .OFB                        (),
         .RST                        (1'b0),
//         .RST                        (iserdes_rst),
         .SHIFTIN1                   (1'b0),
         .SHIFTIN2                   (1'b0)
         );

localparam IDELAYE2_CINVCTRL_SEL          = "FALSE";
localparam IDELAYE2_DELAY_SRC             = "IDATAIN";
localparam IDELAYE2_HIGH_PERFORMANCE_MODE = "TRUE";
localparam IDELAYE2_PIPE_SEL              = "FALSE";
localparam IDELAYE2_ODELAY_TYPE           = "FIXED";
localparam IDELAYE2_REFCLK_FREQUENCY      = ((FPGA_SPEED_GRADE == 2 || FPGA_SPEED_GRADE == 3) && TCK <= 1500) ? 400.0 :
                                             (FPGA_SPEED_GRADE == 1 && TCK <= 1500) ?  300.0 : 200.0;
localparam IDELAYE2_SIGNAL_PATTERN        = "DATA";
localparam IDELAYE2_FINEDELAY_IN          = "ADD_DLY";

    if(IDELAY_FINEDELAY_USE == "TRUE") begin: idelay_finedelay_dq
      (* IODELAY_GROUP = IODELAY_GRP *)
        IDELAYE2_FINEDELAY #(
         .CINVCTRL_SEL             ( IDELAYE2_CINVCTRL_SEL),
         .DELAY_SRC                ( IDELAYE2_DELAY_SRC),
         .HIGH_PERFORMANCE_MODE    ( IDELAYE2_HIGH_PERFORMANCE_MODE),
         .IDELAY_TYPE              ( IDELAYE2_IDELAY_TYPE),
         .IDELAY_VALUE             ( IDELAYE2_IDELAY_VALUE),
         .PIPE_SEL                 ( IDELAYE2_PIPE_SEL),
         .FINEDELAY                ( IDELAYE2_FINEDELAY_IN),
         .REFCLK_FREQUENCY         ( IDELAYE2_REFCLK_FREQUENCY ),
         .SIGNAL_PATTERN           ( IDELAYE2_SIGNAL_PATTERN)
         )
         idelaye2
         (
         .CNTVALUEOUT              (),
         .DATAOUT                  (data_in_dly(i)),
         .C                        (phy_clk), // automatically wired by ISE
         .CE                       (idelay_ce),
         .CINVCTRL                 (),
         .CNTVALUEIN               (5'b00000),
         .DATAIN                   (1'b0),
         .IDATAIN                  (data_in(i)),
         .IFDLY                    (fine_delay_r(i*3+:3)),
         .INC                      (idelay_inc),
         .LD                       (idelay_ld | idelay_ld_rst),
         .LDPIPEEN                 (1'b0),
         .REGRST                   (rst)
     );
    end else begin : idelay_dq
      (* IODELAY_GROUP = IODELAY_GRP *)
        IDELAYE2 #(
         .CINVCTRL_SEL             ( IDELAYE2_CINVCTRL_SEL),
         .DELAY_SRC                ( IDELAYE2_DELAY_SRC),
         .HIGH_PERFORMANCE_MODE    ( IDELAYE2_HIGH_PERFORMANCE_MODE),
         .IDELAY_TYPE              ( IDELAYE2_IDELAY_TYPE),
         .IDELAY_VALUE             ( IDELAYE2_IDELAY_VALUE),
         .PIPE_SEL                 ( IDELAYE2_PIPE_SEL),
         .REFCLK_FREQUENCY         ( IDELAYE2_REFCLK_FREQUENCY ),
         .SIGNAL_PATTERN           ( IDELAYE2_SIGNAL_PATTERN)
         )
         idelaye2
         (
         .CNTVALUEOUT              (),
         .DATAOUT                  (data_in_dly(i)),
         .C                        (phy_clk), // automatically wired by ISE
         .CE                       (idelay_ce),
         .CINVCTRL                 (),
         .CNTVALUEIN               (5'b00000),
         .DATAIN                   (1'b0),
         .IDATAIN                  (data_in(i)),
         .INC                      (idelay_inc),
         .LD                       (idelay_ld | idelay_ld_rst),
         .LDPIPEEN                 (1'b0),
         .REGRST                   (rst)
     );

     end
    end // iserdes_dq
    else begin
        assign iserdes_dout(4*i + 3) = 0;
        assign iserdes_dout(4*i + 2) = 0;
        assign iserdes_dout(4*i + 1) = 0;
        assign iserdes_dout(4*i + 0) = 0;
    end
end // in_
endgenerate			// iserdes_dq_

localparam OSERDES_DQ_DATA_RATE_OQ    = OSERDES_DATA_RATE;
localparam OSERDES_DQ_DATA_RATE_TQ    = OSERDES_DQ_DATA_RATE_OQ;
localparam OSERDES_DQ_DATA_WIDTH      = OSERDES_DATA_WIDTH;
localparam OSERDES_DQ_INIT_OQ         = 1'b1;
localparam OSERDES_DQ_INIT_TQ         = 1'b1;
localparam OSERDES_DQ_INTERFACE_TYPE  = "DEFAULT";
localparam OSERDES_DQ_ODELAY_USED     = 0;
localparam OSERDES_DQ_SERDES_MODE     = "MASTER";
localparam OSERDES_DQ_SRVAL_OQ        = 1'b1;
localparam OSERDES_DQ_SRVAL_TQ        = 1'b1;
// note: obuf used in control path case, no ts in so width irrelevant
localparam OSERDES_DQ_TRISTATE_WIDTH  = (OSERDES_DQ_DATA_RATE_OQ == "DDR") ? 4 : 1;

localparam OSERDES_DQS_DATA_RATE_OQ   = "DDR";
localparam OSERDES_DQS_DATA_RATE_TQ   = "DDR";
localparam OSERDES_DQS_TRISTATE_WIDTH = 4;	// this is always ddr
localparam OSERDES_DQS_DATA_WIDTH     = 4;
localparam ODDR_CLK_EDGE              = "SAME_EDGE";
localparam OSERDES_TBYTE_CTL          = "TRUE";


generate

localparam NUM_BITLANES = PO_DATA_CTL == "TRUE" ? 10 : BUS_WIDTH;

     if ( PO_DATA_CTL == "TRUE" ) begin  : slave_ts
           OSERDESE2 #(
               .DATA_RATE_OQ         (OSERDES_DQ_DATA_RATE_OQ),
               .DATA_RATE_TQ         (OSERDES_DQ_DATA_RATE_TQ),
               .DATA_WIDTH           (OSERDES_DQ_DATA_WIDTH),
               .INIT_OQ              (OSERDES_DQ_INIT_OQ),
               .INIT_TQ              (OSERDES_DQ_INIT_TQ),
               .SERDES_MODE          (OSERDES_DQ_SERDES_MODE),
               .SRVAL_OQ             (OSERDES_DQ_SRVAL_OQ),
               .SRVAL_TQ             (OSERDES_DQ_SRVAL_TQ),
               .TRISTATE_WIDTH       (OSERDES_DQ_TRISTATE_WIDTH),
               .TBYTE_CTL            ("TRUE"),
               .TBYTE_SRC            ("TRUE")
            )
            oserdes_slave_ts
            (
                .OFB                 (),
                .OQ                  (),
                .SHIFTOUT1           (),	// not extended
                .SHIFTOUT2           (),	// not extended
                .TFB                 (),
                .TQ                  (),
                .CLK                 (oserdes_clk),
                .CLKDIV              (oserdes_clkdiv),
                .D1                  (),
                .D2                  (),
                .D3                  (),
                .D4                  (),
                .D5                  (),
                .D6                  (),
                .D7                  (),
                .D8                  (),
               .OCE                  (1'b1),
               .RST                  (oserdes_rst),
               .SHIFTIN1             (),     // not extended
               .SHIFTIN2             (),     // not extended
               .T1                   (oserdes_dqts(0)),
               .T2                   (oserdes_dqts(0)),
               .T3                   (oserdes_dqts(1)),
               .T4                   (oserdes_dqts(1)),
               .TCE                  (1'b1),
               .TBYTEOUT             (tbyte_out),
               .TBYTEIN              (tbyte_out)
             );
     end // slave_ts

  for (i = 0; i != NUM_BITLANES; i=i+1) begin : out_
     if ( BITLANES(i)) begin  : oserdes_dq_

        if ( PO_DATA_CTL == "TRUE" ) begin  : ddr

           OSERDESE2 #(
               .DATA_RATE_OQ         (OSERDES_DQ_DATA_RATE_OQ),
               .DATA_RATE_TQ         (OSERDES_DQ_DATA_RATE_TQ),
               .DATA_WIDTH           (OSERDES_DQ_DATA_WIDTH),
               .INIT_OQ              (OSERDES_DQ_INIT_OQ),
               .INIT_TQ              (OSERDES_DQ_INIT_TQ),
               .SERDES_MODE          (OSERDES_DQ_SERDES_MODE),
               .SRVAL_OQ             (OSERDES_DQ_SRVAL_OQ),
               .SRVAL_TQ             (OSERDES_DQ_SRVAL_TQ),
               .TRISTATE_WIDTH       (OSERDES_DQ_TRISTATE_WIDTH),
               .TBYTE_CTL            (OSERDES_TBYTE_CTL),
               .TBYTE_SRC            ("FALSE")
             )
              oserdes_dq_i
              (
                .OFB               (),
                .OQ                (oserdes_dq_buf(i)),
                .SHIFTOUT1         (),	// not extended
                .SHIFTOUT2         (),	// not extended
                .TBYTEOUT          (),
                .TFB               (),
                .TQ                (oserdes_dqts_buf(i)),
                .CLK               (oserdes_clk),
                .CLKDIV            (oserdes_clkdiv),
                .D1                (oserdes_dq(4 * i + 0)),
                .D2                (oserdes_dq(4 * i + 1)),
                .D3                (oserdes_dq(4 * i + 2)),
                .D4                (oserdes_dq(4 * i + 3)),
                .D5                (),
                .D6                (),
                .D7                (),
                .D8                (),
               .OCE                (1'b1),
               .RST                (oserdes_rst),
               .SHIFTIN1           (),     // not extended
               .SHIFTIN2           (),     // not extended
               .T1                 (/*oserdes_dqts(0)*/),
               .T2                 (/*oserdes_dqts(0)*/),
               .T3                 (/*oserdes_dqts(1)*/),
               .T4                 (/*oserdes_dqts(1)*/),
               .TCE                (1'b1),
               .TBYTEIN            (tbyte_out)
              );
           end
           else begin :  sdr
           OSERDESE2 #(
               .DATA_RATE_OQ         (OSERDES_DQ_DATA_RATE_OQ),
               .DATA_RATE_TQ         (OSERDES_DQ_DATA_RATE_TQ),
               .DATA_WIDTH           (OSERDES_DQ_DATA_WIDTH),
               .INIT_OQ              (1'b0 /*OSERDES_DQ_INIT_OQ*/),
               .INIT_TQ              (OSERDES_DQ_INIT_TQ),
               .SERDES_MODE          (OSERDES_DQ_SERDES_MODE),
               .SRVAL_OQ             (1'b0 /*OSERDES_DQ_SRVAL_OQ*/),
               .SRVAL_TQ             (OSERDES_DQ_SRVAL_TQ),
               .TRISTATE_WIDTH       (OSERDES_DQ_TRISTATE_WIDTH)
              )
              oserdes_dq_i
              (
                .OFB               (),
                .OQ                (oserdes_dq_buf(i)),
                .SHIFTOUT1         (),	// not extended
                .SHIFTOUT2         (),	// not extended
                .TBYTEOUT          (),
                .TFB               (),
                .TQ                (),
                .CLK               (oserdes_clk),
                .CLKDIV            (oserdes_clkdiv),
                .D1                (oserdes_dq(4 * i + 0)),
                .D2                (oserdes_dq(4 * i + 1)),
                .D3                (oserdes_dq(4 * i + 2)),
                .D4                (oserdes_dq(4 * i + 3)),
                .D5                (),
                .D6                (),
                .D7                (),
                .D8                (),
               .OCE                (1'b1),
               .RST                (oserdes_rst),
               .SHIFTIN1           (),     // not extended
               .SHIFTIN2           (),     // not extended
               .T1                 (),
               .T2                 (),
               .T3                 (),
               .T4                 (),
               .TCE                (1'b1),
               .TBYTEIN            ()
              );
           end // ddr
     end // oserdes_dq_
  end // out_

endgenerate

generate

 if ( PO_DATA_CTL == "TRUE" )  begin : dqs_gen

   ODDR
      #(.DDR_CLK_EDGE  (ODDR_CLK_EDGE))
      oddr_dqs
   (
       .Q   (oserdes_dqs_buf),
       .D1  (oserdes_dqs(0)),
       .D2  (oserdes_dqs(1)),
       .C   (oserdes_clk_delayed),
       .R   (1'b0),
       .S   (),
       .CE  (1'b1)
   );

   ODDR
     #(.DDR_CLK_EDGE  (ODDR_CLK_EDGE))
     oddr_dqsts
   (    .Q  (oserdes_dqsts_buf),
        .D1 (oserdes_dqsts(0)),
        .D2 (oserdes_dqsts(0)),
        .C  (oserdes_clk_delayed),
        .R  (),
        .S  (1'b0),
        .CE (1'b1)
   );

 end // sdr rate
 else begin:null_dqs
 end
endgenerate

endmodule			// byte_group_io
