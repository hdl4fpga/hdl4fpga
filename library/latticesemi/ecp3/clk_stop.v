module clk_stop(reset,lock,eclk,
		reset_datapath,reset_datapath_out, pll_stop, stop);
input         reset;
input         lock;
   
input         eclk;
input         reset_datapath;
   input pll_stop;
   
output        reset_datapath_out;
output        stop;

   
   reg 	  reset_datapath_ff;
   //use another ff to change stop_mem ealier
   reg 	  reset_datapath_ff2;
   reg 	  cnt_start;
   reg    pll_stop_ff;
   

reg [2:0]     stop_ff /* synthesis syn_preserve = 1 */ /*synthesis HGROUP="stop_ff" PBBOX="1,1" */ ;
//pragma attribute stop_ff preserve_driver true
//pragma attribute stop_ff HGROUP stop_ff
//pragma attribute stop_ff PBBOX 1,1
   
reg           stop_ref;
//stop even or odd reference, making this independent of the vco multiply ratio
//otherwise there is a chance that we stuck at odd (or even) cycles all the time, and status[1] cannot be flipped.
   
   //re-synchronize reset_datapath
   always @(negedge eclk or posedge reset) begin
      if(reset) begin
	reset_datapath_ff<=1'b1;
	reset_datapath_ff2<=1'b1;
   end
      else begin
	 reset_datapath_ff<= reset_datapath;
	 reset_datapath_ff2<= reset_datapath_ff;
      end
   end
      
   always @(negedge eclk or posedge reset) begin
      if(reset)
	pll_stop_ff<=1'b1;
      else 
	pll_stop_ff<= pll_stop;
end

   
   
   assign reset_datapath_out = reset_datapath_ff;   
   
reg [1:0] stop_mem;
//[0]: rise(0), fall (1)
//[1]: even/odd on stop_sig
//try even/odd, rise/fall, total 4 combination.
//one of them should stay away from setup/hold window and avoid stuck
//towards each end of stop_ff count down to 000
always @(negedge eclk or posedge reset) begin
   if(reset) begin
      stop_mem <= 2'b00;
   end
      //change on reset_datapath_ff falling edge
      else if(reset_datapath_ff==1'b0 && reset_datapath_ff2==1'b1 ) begin
	 //gray code here 
	 if(stop_mem==2'b00) stop_mem<=2'b01;
	 else if(stop_mem==2'b01) stop_mem<=2'b11;
	 else if(stop_mem==2'b11) stop_mem<=2'b10;
	 else if(stop_mem==2'b10) stop_mem<=2'b00;
   end
end

reg    stop_gate_ff;
always @(negedge eclk or posedge reset) begin
   if(reset) begin
      stop_gate_ff<=1'b0;
      stop_ref<=1'b0;   
   end
   else begin
      stop_ref<=~stop_ref;  

	 //even odd here
	 //after stop_ff goes low, wait for even/odd depending on stop_ref
	 if(pll_stop_ff)stop_gate_ff<=1'b1;
	 else begin
	    if(stop_mem[1]==1'b0 && stop_ref==1'b0)
	      stop_gate_ff<=1'b0;
	    else if (stop_mem[1]==1'b1 && stop_ref==1'b1)
	      stop_gate_ff<=1'b0;
	 end
	 
   end
end

reg    stop_gate_ff_pos;
//delay another half cycle.
always @(posedge eclk or posedge reset) begin
   if(reset) begin
      stop_gate_ff_pos<=1'b0;
   end
   else begin
      stop_gate_ff_pos<=stop_gate_ff;
   end
end

assign stop = stop_mem[0]? stop_gate_ff_pos : stop_gate_ff;

endmodule
