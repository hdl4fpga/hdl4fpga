`ifdef SIM
 `define TMR_WIDTH   4
 `define RTY_WIDTH   6
 `define TMR_MAX_CNT 4'hf
 `define RTY_MAX_CNT 6'h3f
`else
 `define TMR_WIDTH   8
 `define RTY_WIDTH   8
 `define TMR_MAX_CNT 8'hff
 `define RTY_MAX_CNT 8'hff
`endif

module pll_control (
	reset, 
	lock, 
	clk, 
	phase, 
	align_status, 
	reset_datapath,
	reset_datapath_out,
	stop_out,
`ifdef DEBUG_MARGIN
	margin_code,
`endif
	good_int,
	err);

	input        reset;
	input        lock;   
	input        clk;
	output [3:0] phase;
	input  [1:0] align_status;
`ifdef DEBUG_MARGIN
	input [5:0] margin_code;
`else
	 parameter margin_code=6'b111100;
`endif
	input  reset_datapath;
	output reset_datapath_out;
	output stop_out;
	output err;
	output good_int;
   
	reg[3:0]              phase;
	reg[2:0]              state;
	reg[1:0]              align_status_ff;
	reg[5:0]              last_align_status_0;
	reg[`RTY_WIDTH - 1:0] retry_cnt;
	reg[`TMR_WIDTH - 1:0] timer;   
	wire                  rst_dp_in;
	reg                   reset_datapath_ff;   
	wire 	              stop_out;   
	reg                   good_int /* synthesis syn_preserve = 1 */;
	//pragma attribute good_int preserve_driver true
	reg [2:0]             next_state;
	reg                   lock_reg;

	parameter state_idle             = 3'h0;
	parameter state_rotate           = 3'h1;
	parameter state_check_bit0       = 3'h2;
	parameter state_check_bit1       = 3'h3;
	parameter state_clear_retry_cnt  = 3'h4;
	parameter state_reset_datapath   = 3'h5;
	parameter state_good             = 3'h6;
	parameter state_err              = 3'h7;
      
	always @(posedge clk or posedge reset)
	begin
		if (reset)
			state <= state_idle;
		else
			state <= next_state;
	end

	always @(*) 
	begin
		case (state)/*synthesis full_case parallel_case*/

		state_idle: begin
			if (lock_reg ) 
				next_state = state_rotate;
			else
				next_state = state_idle;    
		end

		state_rotate: begin
			if (retry_cnt ==`RTY_MAX_CNT) 
				next_state = state_err;
			else if (timer==`TMR_MAX_CNT && lock_reg==1'b1) 
				next_state = state_check_bit0;
			else
				next_state = state_rotate;     
		end

		state_check_bit0: begin
			if(last_align_status_0==margin_code && align_status_ff[0] ==1'b0) 
				next_state = state_clear_retry_cnt;
			else 
				next_state = state_rotate;     
		end

		state_clear_retry_cnt: begin
			if (reset_datapath_ff==1'b0)
				next_state = state_reset_datapath;
			else
				next_state = state_clear_retry_cnt;       
		end

		state_check_bit1: begin
			if (align_status_ff[1] ==1'b0) 
				next_state = state_good;
			else 
				next_state = state_reset_datapath;
		end

		state_reset_datapath: begin
			if (retry_cnt==`RTY_MAX_CNT ) 
				next_state = state_err;
			else if(timer ==`TMR_MAX_CNT - 1 ) 
				next_state = state_check_bit1;
			else
				next_state = state_reset_datapath;    
		end

		state_good: begin
			if (~lock_reg) 
				next_state = state_good;    
			else if (align_status_ff[0] == 1'b1)
				next_state = state_idle;        
			else if((align_status_ff[1] == 1'b1))
				next_state = state_clear_retry_cnt;     
			else if (reset_datapath_ff)
				next_state = state_clear_retry_cnt;     
			else
				next_state = state_good;
		end

		state_err: begin
			if (reset_datapath_ff)
				next_state = state_clear_retry_cnt;     
			else
				next_state = state_err;     
		end 

		default: begin
			next_state = state_idle;
		end   

		endcase 
	end 

	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			lock_reg <=1'b0;  
		end
		else begin
			lock_reg<=lock;   
		end
	end

	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			align_status_ff<=2'b00;
		end
		else begin
			if (lock_reg==1'b1)
			align_status_ff<=align_status;  
		end
	end


	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			last_align_status_0 <= 6'b000000;	
		end
		else begin
			if (state==state_idle)
				last_align_status_0 <= 6'b000000;	

			else if (state == state_rotate && timer==2) begin
				last_align_status_0[0] <=  align_status_ff[0];
				last_align_status_0[1] <=  last_align_status_0[0];   
				last_align_status_0[2] <=  last_align_status_0[1];	 
				last_align_status_0[3] <=  last_align_status_0[2];	 
				last_align_status_0[4] <=  last_align_status_0[3];	 
				last_align_status_0[5] <=  last_align_status_0[4];	 
			end
		end
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			phase <= 4'b0000;
		end
		else if (state == state_rotate && timer==4) begin
			phase <= phase + 1;      
		end
	end


	always @(posedge clk or posedge reset)
	begin
		if(reset) begin  
			timer <= 'd0;
		end
		else begin
			if((state!=state_rotate && state!=state_reset_datapath && state != state_good) || (state==state_good && next_state ==state_reset_datapath))
				timer <='d0;
			else if(timer<`TMR_MAX_CNT)
				timer <=timer + 1;
		end
	end 

	always @(posedge clk or posedge reset) begin
		if (reset) begin  
			retry_cnt <= 'd0;
		end  
		else begin
			if(state==state_idle || state==state_clear_retry_cnt || state==state_good) begin
				retry_cnt <= 'd0;
			end

			else if((state == state_rotate || state==state_reset_datapath) && timer==1) begin	 
				if(retry_cnt<`RTY_MAX_CNT) 
					retry_cnt <= retry_cnt + 1;     
			end
		end
	end 

	assign rst_dp_in = (state == state_reset_datapath) && (timer <8);
	assign rst_dp_in_stop = (state == state_reset_datapath) && (timer <12);

	FD1S3DX rst_dp_out_inst (
		.D(rst_dp_in),
		.CK(clk), 
		.CD(reset), 
		.Q(reset_datapath_out)) /*synthesis HGROUP="rst_dp_out" PBBOX="1,1" */;
	//pragma attribute rst_dp_out_inst HGROUP rst_dp_out
	//pragma attribute rst_dp_out_inst PBBOX 1,1

	FD1S3DX rst_dp_stop_inst (
		.D(rst_dp_in_stop),
		.CK(clk), 
		.CD(reset), 
		.Q(stop_out));

	always @(posedge clk or posedge reset)
	begin
		if(reset) 
			reset_datapath_ff<=1'b0;
		else 
			reset_datapath_ff <=reset_datapath;     
	end

	always @(posedge clk or posedge reset)
	begin
		if(reset) 
			good_int <=1'b0;
		else begin
			good_int <=(state==state_good && timer ==`TMR_MAX_CNT)?1'b1:1'b0;   
		end
	end

	assign err = (state==state_err);

endmodule
