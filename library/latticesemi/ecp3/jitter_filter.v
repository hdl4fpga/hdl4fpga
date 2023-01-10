//filter status_0
//it detects eclk using sclk.                                  
//due to clock jitter, it can bounce back and forth.
//the back and forth can potentially confuse the state machine 
//in pll_control.v
//a filter here should remove jitter induced noise.            

//it is basically a up/down counter                            
//start at 0
//if 1, count up
//if 0, count down
//if count to pre-defined value (15), send out 1.
//once is 1, stay 1 till count down to 0
//once 0, stay there till count up to 15
//this large 15 gap should avoid the jitter region completely.

//11/09/2010, resolve a weakness in jitter filter
//the filter output goes to 0 too quickly in jitter region
//this makes the filter very sensitive to the distribution of jitter.
//needs to count 128 cycles (half of each rotation and wait operation)
//if any 1, stay at 1.
//if all 0, goes to 0.
//this way status will never go to 0 unless it is 100% out of jitter region.
module jitter_filter(reset, in,sclk,out_q);
input     reset;
input     in;
input     sclk;
output    out_q;
   reg [6:0] counter;
   reg 	     any1;

reg       out_q;



always @(posedge sclk or posedge reset) begin
   if(reset) begin
	 counter<=7'h00;
	 any1<=1'b0;	 
      out_q<=0;
   end

   else begin


	 //counter continues to roll over per 128 cycles.
          counter<=counter+1;
	 //0-126, check if any 1's
	 //127, latch results and start over again.
	 if(counter!=127 && in==1) any1<=1'b1;
	 if(counter==127) begin
	    out_q<=any1;
	    any1<=1'b0;
	 end

  end

end
   
endmodule
