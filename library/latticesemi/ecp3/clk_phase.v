
//circuit to use sclk to sample eclk (tapped from eclk tree after eclksync)
//expect to stop at 2'b00 transition to 2'b01 (going back to 2'b00)
module clk_phase(eclk,eclksync,sclk,reset,align_status);
input        eclk;//short eclk directly from pll, for bit0
input        eclksync; //after eclksync, for bit 1

input        sclk;
input        reset;
output [1:0] align_status;

//clock eclk by sclk
//create div by 2 to mimic dqs circuit
wire         dqclk1bar_ff /* synthesis syn_keep =1 */;
//pragma attribute dqclk1bar_ff preserve_signal true
wire         phase_ff_1;
wire         phase_ff_0;

//register again to be mapped into io FFs
   

FD1S3DX dqclk1bar_ff_inst (.D(~dqclk1bar_ff),
                           .CK(eclksync), 
                           .CD(reset), 
                           .Q(dqclk1bar_ff))/*synthesis HGROUP="clk_phase1a" PBBOX="1,1" */;
//pragma attribute dqclk1bar_ff_inst HGROUP clk_phase1a
//pragma attribute dqclk1bar_ff_inst PBBOX 1,1
   
FD1S3DX phase_ff_0_inst (.D(eclk),
                         .CK(sclk), 
                         .CD(reset), 
                         .Q(phase_ff_0))/*synthesis HGROUP="clk_phase0" PBBOX="1,1" */;
//pragma attribute phase_ff_0_inst HGROUP clk_phase0
//pragma attribute phase_ff_0_inst PBBOX 1,1

FD1S3DX phase_ff_1_inst (.D(dqclk1bar_ff),
                         .CK(sclk),
                         .CD(reset),
                         .Q(phase_ff_1))/*synthesis HGROUP="clk_phase1b" PBBOX="1,1" */;
//pragma attribute phase_ff_1_inst HGROUP clk_phase1b
//pragma attribute phase_ff_1_inst PBBOX 1,1

assign align_status[0] = phase_ff_0;         
assign align_status[1] = phase_ff_1;         
   
endmodule
