`timescale 1ns/1ps

`ifndef SIM
`define status_filter_on
`endif

`uselib lib = ecp3

// component ecp3_csa
// 	generic (
// 		period_eclk        : real);
//     port  (
//         reset              : in  std_logic;
//         reset_datapath     : in  std_logic;
//         refclk             : in  std_logic;
//         clkop              : in  std_logic;
//         clkos              : in  std_logic;
//         clkok              : in  std_logic;
//         uddcntln           : in  std_logic;
//         pll_phase          : out std_logic_vector(4-1 downto 0);
//         pll_lock           : in std_logic;
//         eclk               : out std_logic;
//         sclk               : out std_logic;
//         sclk2x             : out std_logic;
//         reset_datapath_out : out std_logic;
//         dqsdel             : out std_logic;
//         all_lock           : out std_logic;
//         align_status       : out std_logic_vector(2-1 downto 0);
//         good               : out std_logic;
//         err                : out std_logic);
// end component;

module ecp3_csa(
	reset, 
	reset_datapath,
	refclk, 
	clkop,
	clkos, 
	clkok, 
	pll_phase, 
	uddcntln,
	pll_lock, 
	eclk,
	sclk,
	sclk2x, 
	all_lock,
	reset_datapath_out,
	align_status, 
	good, 
	err,
`ifdef DEBUG_MARGIN
	margin_code,
`endif
	dqsdel);

	input       reset; 
	input       reset_datapath; 
	input       refclk;   
	input       clkop;   
	input       clkos;   
	input       clkok;   
	input       pll_lock;   
	input       uddcntln;
`ifdef DEBUG_MARGIN
	input [5:0] margin_code;
`endif
	output      eclk; 
	output      sclk;    
	output      sclk2x; 
	output      all_lock; 
	output[3:0] pll_phase;
	output      reset_datapath_out;
	output[1:0] align_status;
	output      dqsdel;
	output      good;
	output      err;

	wire[3:0]   pll_phase /* synthesis syn_keep =1 */;
	//pragma attribute pll_phase preserve_signal true
	wire        reset_datapath_out;   
	wire[1:0]   align_status_sig;
	wire        good_out; 
	wire        clkos /* synthesis syn_keep = 1 */;
	//pragma attribute clkos preserve_signal true
	wire        stop /*synthesis syn_keep = 1 */;
	//pragma attribute stop preserve_signal true
	reg         good /* synthesis syn_preserve = 1 */;
	//pragma attribute good preserve_driver true

	parameter period_eclk = 2.50;

	always @(posedge sclk or posedge reset)
	begin
		if(reset)
			good <=1'b0;
		else
			good <= good_out;   
	end

	//defparam Inst4_DQSDLLB.LOCK_SENSITIVITY = "LOW" ;
	DQSDLLB Inst4_DQSDLLB (
		.RST(reset), 
		.CLK(sclk2x), 
		.UDDCNTLN(uddcntln), 
		.LOCK(ddrdll_lock),
		.DQSDEL(dqsdel));

	//move control to sclk to save a primary clock, it is not moving during rotation.
	pll_control pll_control (
		.reset(reset),
		.lock(all_lock), 
		.clk(refclk),
		.phase(pll_phase),
		.align_status(align_status), 
		.reset_datapath(reset_datapath), 
		.reset_datapath_out(pll_reset_datapath), 
		.stop_out(pll_stop), 
`ifdef DEBUG_MARGIN
		.margin_code(margin_code),
`endif
		.good_int(good_out), 
		.err(err));
	//pragma attribute pll_control hierarchy preserve 

	assign all_lock = pll_lock && ddrdll_lock;


	//move stop to use sclk2x instead of clkos, the improved code only needs frequency reference
	clk_stop clk_stop (
		.reset(reset),
		.lock(all_lock),
		.eclk(clkos),
		.reset_datapath(pll_reset_datapath),
		.reset_datapath_out(reset_datapath_out), 
		.pll_stop(pll_stop),
		.stop(stop))/*synthesis HGROUP="clk_stop" PBBOX="3,2" */;
		//pragma attribute clk_stop hierarchy preserve   
		//pragma attribute clk_stop HGROUP clk_stop
		//pragma attribute clk_stop PBBOX 3,2

	ECLKSYNCA sync (
		.ECLKI(clkos),
		.STOP(stop),
		.ECLKO(eclk_sync_net));

	assign #(period_eclk*2/16) eclk = eclk_sync_net;

	assign sclk2x = clkop;
	assign sclk = clkok;

	clk_phase clk_phase(
		.reset(reset_datapath_out), 
		.eclk(clkos),
		.eclksync(eclk),
		.sclk(sclk),
		.align_status(align_status_sig));
	//pragma attribute clk_phase hierarchy preserve

`ifdef status_filter_on
	wire [1:0] align_status_filtered;   
	//stable status, jitter noise is removed by the filter and large hysterisis
	jitter_filter filter_0 (
		.reset(reset), 
		.sclk(sclk), 
		.in(align_status_sig[0]), 
		.out_q(align_status_filtered[0]));
	wire reset_filter_1;
	//reset filter_1 to allow full 128 cycles before checking status 1;
	assign reset_filter_1 = reset || reset_datapath_out;
	jitter_filter filter_1 (
		.reset(reset_filter_1), 
		.sclk(sclk),
		.in(align_status_sig[1]),
		.out_q(align_status_filtered[1]));

	assign align_status[1:0] = align_status_filtered[1:0];
`else
	//original, the status bounces back and forth too much in jitter region, the state machine can have problems
	assign align_status[1:0] = align_status_sig[1:0];         
`endif

endmodule
