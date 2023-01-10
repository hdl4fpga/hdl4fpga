`timescale 1ns/1ps

`ifndef SIM
`define status_filter_on
`endif
module ddr3_clks(reset, reset_datapath, refclk, 
		 eclk,sclk,sclk2x, all_lock,
     reset_datapath_out,
     align_status, good, err,
`ifdef DEBUG_MARGIN
		margin_code,
`endif
     uddcntln,dqsdel);
   
input        reset; 
input        reset_datapath; 
input        refclk;   
`ifdef DEBUG_MARGIN
   input [5:0] margin_code;
`endif
   output eclk; 
   output sclk;    
   output sclk2x; 
output       all_lock; 
output       reset_datapath_out;
output [1:0] align_status;
output       good;
output       err;

input        uddcntln;
output       dqsdel;
   
   
wire [3:0]   pll_phase /* synthesis syn_keep =1 */;
//pragma attribute pll_phase preserve_signal true
wire         reset_datapath_out;   
wire [1:0]   align_status_sig;
wire         good_out; 
wire         clkos /* synthesis syn_keep = 1 */;
//pragma attribute clkos preserve_signal true
wire         stop /*synthesis syn_keep = 1 */;
//pragma attribute stop preserve_signal true
reg          good /* synthesis syn_preserve = 1 */;
//pragma attribute good preserve_driver true


parameter period_eclk = 2.50;

   always @(posedge sclk or posedge reset) begin
   if(reset)
      good <=1'b0;
   else
      good <= good_out;   
end
   
ddr3_pll pll (.CLK(refclk), .RESET(reset), .DPHASE0(pll_phase[0]), .DPHASE1(pll_phase[1]), 
              .DPHASE2(pll_phase[2]), .DPHASE3(pll_phase[3]), 
              .CLKOP(clkop), .CLKOS(clkos), .CLKOK(clkok), .LOCK(pll_lock));

defparam Inst4_DQSDLLB.LOCK_SENSITIVITY = "LOW" ;
   DQSDLLB Inst4_DQSDLLB (.CLK(sclk2x), .RST(reset), .UDDCNTLN(uddcntln), 
                       .LOCK(ddrdll_lock), .DQSDEL(dqsdel));
   
   //move control to sclk to save a primary clock, it is not moving during rotation.
pll_control pll_control (.reset(reset),.lock(all_lock), .clk(refclk), .phase(pll_phase),
                         .align_status(align_status), 
                         .reset_datapath(reset_datapath), 
                         .reset_datapath_out(pll_reset_datapath), 
			    .stop_out(pll_stop), 
`ifdef DEBUG_MARGIN
				.margin_code(margin_code),
`endif
                         .good_int(good_out), .err(err));
//pragma attribute pll_control hierarchy preserve 

assign all_lock = pll_lock && ddrdll_lock;
   

   //move stop to use sclk2x instead of clkos, the improved code only needs frequency reference
clk_stop clk_stop (.reset(reset),.lock(all_lock),.eclk(clkos),
                   .reset_datapath(pll_reset_datapath),
		      .reset_datapath_out(reset_datapath_out), 
			  .pll_stop(pll_stop),
			  .stop(stop))/*synthesis HGROUP="clk_stop" PBBOX="3,2" */;
//pragma attribute clk_stop hierarchy preserve   
//pragma attribute clk_stop HGROUP clk_stop
//pragma attribute clk_stop PBBOX 3,2
   
ECLKSYNCA sync (.ECLKI(clkos), .STOP(stop), .ECLKO(eclk_sync_net));

   assign #(period_eclk*2/16) eclk = eclk_sync_net;

   assign sclk2x = clkop;
   assign sclk = clkok;

   clk_phase clk_phase(.eclk(clkos), .eclksync(eclk),.sclk(sclk),.reset(reset_datapath_out), .align_status(align_status_sig));
 //pragma attribute clk_phase hierarchy preserve
 
`ifdef status_filter_on
    wire [1:0] align_status_filtered;   
    //stable status, jitter noise is removed by the filter and large hysterisis
   jitter_filter filter_0 (.reset(reset), .sclk(sclk), .in(align_status_sig[0]), .out_q(align_status_filtered[0]));
   wire reset_filter_1;
   //reset filter_1 to allow full 128 cycles before checking status 1;
   assign reset_filter_1 = reset || reset_datapath_out;
   jitter_filter filter_1 (.reset(reset_filter_1), .sclk(sclk), .in(align_status_sig[1]), .out_q(align_status_filtered[1]));
   
    assign     align_status[1:0] = align_status_filtered[1:0];
`else
    //original, the status bounces back and forth too much in jitter region, the state machine can have problems
    assign     align_status[1:0] = align_status_sig[1:0];         
`endif

endmodule
