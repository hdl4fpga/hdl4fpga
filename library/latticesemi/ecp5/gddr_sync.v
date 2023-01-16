// ============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2013 Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorized by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement 
// from Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation      TEL  : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                           408-826-6000 (other locations)
// Hillsboro, OR 97124                    web  : http://www.latticesemi.com/
// U.S.A                                  email: techsupport@latticesemi.com
// =============================================================================
// Module     : gddr_sync.v
// Description: 
//   - Code for bus synchronization
//   - Needed to tolerate large skew between stop and ddr and clkdiv reset
// =============================================================================

`timescale 1ns/1ps

module gddr_sync (
  // inputs
  rst,             // Asynchronous reset
  sync_clk,        // oscillator clk or other constant running low speed clk.
                   // note that this clk should not be coming from clk sources 
                   // that this module will stop or reset (e.g. ECLKSYNC, CLKDIV)
  start,           // Initialize the sync process

  // outputs
  stop,            // ECLKSYNC.stop signal
  ddr_reset,       // DDR and CLKDIV reset signal
  ready            // READY signal; clock sync is done.
);

//-----------------------------------------------------------------------------
// PORTS DECLARATIONS
//----------------------------------------------------------------------------- 
// input ports
input       rst;
input       sync_clk;
input       start;

// output ports
output      stop;
output      ddr_reset;
output      ready;

//-----------------------------------------------------------------------------
// PARAMETERS
//-----------------------------------------------------------------------------        
// Local parameters: States
localparam INIT   = 3'b000;
localparam STOP   = 3'b001;
localparam RESET  = 3'b011;
localparam READY  = 3'b100;

//----------------------------------------------------------------------------- 
// SIGNAL DECLARATIONS
//-----------------------------------------------------------------------------  
wire        rst;
wire        sync_clk;
wire        start;
wire        ddr_reset;     
wire        stop;
wire        ready;

reg         ddr_reset_d;
reg   [3:0] ctrl_cnt;                                    // control counter
reg   [2:0] stop_assert;                                 // stop signal counter
reg   [2:0] cs_gddr_sync /*synthesis syn_preserve=1*/ ;  // current state
reg   [2:0] ns_gddr_sync;                                // next state
reg         reset_flag;                                  // flag signal that 
                                                         // indicates that RESET 
                                                         // is already done
  
//----------------------------------------------------------------------------- 
//  WIRE ASSIGNMENTS
//-----------------------------------------------------------------------------       
assign stop      = cs_gddr_sync[0];              
assign ddr_reset = cs_gddr_sync[1] | ddr_reset_d;
assign ready     = cs_gddr_sync[2];

//----------------------------------------------------------------------------- 
//  REGISTER ASSIGNMENTS
//-----------------------------------------------------------------------------  
always @(posedge sync_clk or posedge rst) begin
  if (rst==1'b1)
  begin
    cs_gddr_sync  <= INIT;
    ctrl_cnt      <= 4'd0;
    stop_assert   <= 3'd0;
    reset_flag    <= 1'b0;
    ddr_reset_d   <= 1'b1;
  end
  else
  begin
    cs_gddr_sync  <= ns_gddr_sync;
    ddr_reset_d   <= 1'b0;

    // CTRL_CNT for state machines        
    if (((cs_gddr_sync==INIT)&&(reset_flag==1'b0))||((ctrl_cnt == 3)
         &&(cs_gddr_sync!=INIT)))    
    begin          
      ctrl_cnt <= 'd0;
    end
    else if (ctrl_cnt < 8)
    begin          
      ctrl_cnt <= ctrl_cnt + 1;
    end
        
    // STOP signal will then be asserted 4T after rstn
    if ((!rst)&&(start)&&(stop_assert<4)&&(reset_flag==1'b0))               
    begin            
      stop_assert <= stop_assert + 1;
    end

    // Asserts the reset_flag after RESET state
    if ((cs_gddr_sync==RESET)&&(ns_gddr_sync == STOP))    
    begin
      reset_flag <= 1'b1;            
    end

    // Deasserts the reset_flag after READY state            
    if ((cs_gddr_sync==READY)&&(ns_gddr_sync == INIT))    
    begin
      reset_flag <= 1'b0;            
    end                    
  end
end

// GDDR_SYNC State machine    
always @(*) begin
  
  case (cs_gddr_sync)  /* synthesis full_case parallel_case */
    INIT:  // INIT state 0
    begin
      if ((start)&&(stop_assert==3)&&(reset_flag==1'b0))
      begin
        ns_gddr_sync = STOP;
      end
      else if ((reset_flag==1'b1)&&(ctrl_cnt == 7)&&(start))
      begin
        ns_gddr_sync = READY;
      end
      else
      begin
        ns_gddr_sync = INIT;
      end
    end
    
    STOP:  //STOP state 1
    begin
      if (ctrl_cnt == 3)
      begin
        if (reset_flag ==1'b1)
        begin
          ns_gddr_sync  = INIT;
        end
        else
        begin
          ns_gddr_sync  = RESET;
        end
      end
      else
      begin
        ns_gddr_sync = STOP;
      end
    end    
    
    RESET:  // RESET state 2
    begin
      if (ctrl_cnt == 3)
      begin
        ns_gddr_sync = STOP;
      end
      else
      begin
        ns_gddr_sync = RESET;
      end
    end
    
    READY:  // READY state 5
    begin
      if ((!start))
      begin
        ns_gddr_sync = INIT;
      end
      else
      begin
        ns_gddr_sync = READY;
      end
    end
    
    default:
    begin
      ns_gddr_sync = cs_gddr_sync;
    end
    
  endcase
end
  
endmodule // gddr_sync
