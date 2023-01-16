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
// ============================================================================
// Module     : rxdll_sync.v
// Description: 
//   - code to create the reset-stop procedure for RX
//   - needed to startup RX interfaces
//   - for details: Sapphire_DDR_Soft_IP.docx
// ============================================================================

`timescale 1ns/1ps

module rxdll_sync (
  // input
  rst,         // Asynchronous reset
  sync_clk,    // oscillator clk or other constant running low speed clk.
               // Note that this clk should not be coming from clk sources that 
               // this module will stop or reset (e.g. ECLKSYNC, CLKDIV, etc.)
  update,      // Restart the sync process
  dll_lock,    // 'lock' signal of DDRDLL module
   
  // output
  dll_reset,   // 'rst' signal of DDRDLL module
  uddcntln,    // 'uddnctln' signal of DDRDLL module
  freeze,      // 'freeze' signal of DDRDLL module
  stop,        // 'stop' signal of ECLKSYNC module
  ddr_reset,   // 'rst' signal of IDDR and CLKDIV
  ready        // Indicates startup is done; RX is ready to operate
);

//-----------------------------------------------------------------------------
// PORT DECLARATIONS
//-----------------------------------------------------------------------------
// Input ports
input         rst;
input         sync_clk;
input         update;
input         dll_lock;

// Output ports
output        uddcntln;
output        freeze;
output        stop;
output        ddr_reset;
output        ready;
output        dll_reset;

//-----------------------------------------------------------------------------
// WIRE AND REGISTER DECLARATIONS
//-----------------------------------------------------------------------------
wire          rst;
wire          sync_clk;
wire          dll_lock;
wire          update;
 
wire          uddcntln;
wire          freeze;
wire          stop;
wire          ddr_reset;
wire          ready;

reg           dll_reset   /*synthesis syn_preserve = 1*/;
reg           ddr_reset_d /*synthesis syn_preserve = 1*/;

reg [2:0]     ctrl_cnt;     // 4 clock cycles counter
reg [2:0]     dll_lock_cnt; // counter for lock and freeze timing
reg [2:0]     ready_cnt;    // counter for ready signal

reg [4:0]     cs_rx_sync;   // current state
reg [4:0]     ns_rx_sync;   // next state

reg           dll_lock_q1;
reg           dll_lock_q2;

reg           not_uddcntln;
reg           assert_stop;
reg           not_reset;
reg           not_stop;
reg           not_freeze;
reg           get_ready;

    
//-----------------------------------------------------------------------------
// PARAMETERS
//-----------------------------------------------------------------------------
//States
localparam UPDATE    = 5'b00010;
localparam FREEZE    = 5'b10010;
localparam UDDCNTLN  = 5'b10000;
localparam STOP      = 5'b11010;
localparam RESET     = 5'b11110;
localparam READY     = 5'b00011;


//-----------------------------------------------------------------------------
// ASSIGN STATEMENTS
//-----------------------------------------------------------------------------

// State assignments
assign freeze    = cs_rx_sync[4];
assign stop      = cs_rx_sync[3];
assign ddr_reset = cs_rx_sync[2] | ddr_reset_d;
assign uddcntln  = cs_rx_sync[1];
assign ready     = cs_rx_sync[0];

// State Machine Next State decoder
always @(*) begin
     
  case(cs_rx_sync) /* synthesis full_case parallel_case */
    UPDATE:
    begin 
      if (((dll_lock_cnt==5)&&!not_uddcntln))
      begin
        ns_rx_sync = FREEZE;
      end
      else if ((ready_cnt == 7)&&(get_ready == 1'b1))
      begin
        ns_rx_sync = READY;
      end
      else
      begin
        ns_rx_sync = UPDATE;
      end
    end // UPDATE
    
    FREEZE:
    begin 
      if (ctrl_cnt==3)
      begin
        if (assert_stop == 1'b1)
        begin
          ns_rx_sync = STOP;
        end
        else if (not_freeze == 1'b1)
        begin
          ns_rx_sync = UPDATE;
        end
        else
        begin
          ns_rx_sync = UDDCNTLN;
        end
      end
      else
      begin
        ns_rx_sync = FREEZE;
      end
    end // FREEZE
    
    UDDCNTLN:
    begin 
      if ((ctrl_cnt==3)&&(not_uddcntln == 1'b1))
      begin
        ns_rx_sync = FREEZE;
      end
      else
      begin
        ns_rx_sync = UDDCNTLN;
      end
    end // UDDCTLN
    
    STOP:
    begin 
      if (ctrl_cnt==3)
      begin
        if (not_stop == 1'b1)
        begin
           ns_rx_sync = FREEZE;
        end
        else
        begin
           ns_rx_sync = RESET;
        end
      end
      else
      begin
        ns_rx_sync = STOP;
      end
    end // STOP
    
    RESET:
    begin 
      if ((ctrl_cnt==3)&&(not_reset == 1'b1))
      begin
        ns_rx_sync = STOP;
      end
      else
      begin
        ns_rx_sync = RESET;
      end
    end // RESET
        
    READY:
    begin 
      if (!dll_lock_q2 || update)
      begin 
        ns_rx_sync = UPDATE; // If DLL unlocks, re-start sync process
      end
      else
      begin
        ns_rx_sync = READY;
      end
    end

    default:
    begin
      ns_rx_sync = cs_rx_sync;
    end

  endcase //case(cs_rx_sync)
end // always (*) FSM Next State Decoder


//-----------------------------------------------------------------------------
// REGISTER ASSIGNMENTS
//----------------------------------------------------------------------------

// Synchronize LOCK signal
always @(posedge sync_clk or posedge rst) begin
  if (rst) begin
    dll_lock_q1 <= 1'b0;
    dll_lock_q2 <= 1'b0;
  end
  else begin
    dll_lock_q1 <= dll_lock;
    dll_lock_q2 <= dll_lock_q1;
  end
end

always @(posedge sync_clk or posedge rst) begin
  if (rst) begin  
    cs_rx_sync    <= UPDATE;
    ctrl_cnt      <= 'd0;
    dll_lock_cnt  <= 'd0;
    ready_cnt     <= 'd0;
    ddr_reset_d   <= 1'b1;
    dll_reset     <= 1'b1;
    not_uddcntln  <= 1'b0;
    assert_stop   <= 1'b0;
    not_reset     <= 1'b0;
    not_stop      <= 1'b0;
    not_freeze    <= 1'b0;
    get_ready     <= 1'b0;
  end
  else begin
    cs_rx_sync    <= ns_rx_sync;
    ddr_reset_d   <= 1'b0;
    dll_reset     <= 1'b0;
    
    // DLL LOCK Counter 
    // Counter starts to increment when DLL lock signal goes high and stops
    // when it reaches 8T (8 clock cycles)  
    if ((dll_lock_q2 && dll_lock) && (dll_lock_cnt < 5)) 
    begin
      dll_lock_cnt <= dll_lock_cnt + 1; 
    end
      
    // Counter for 4 clock cycles (4T)
    // Sees to it that DLL stays locked for 8 clock cycles 
    if ((dll_lock_cnt!=5))
    begin
      ctrl_cnt <= 'd3;
    end
    else if ((ctrl_cnt==3)&&(cs_rx_sync!=READY)) 
    // Resets counter every 4T and when current state is not yet READY 
    begin
      ctrl_cnt <= 'd0;
    end
    else if (ctrl_cnt < 4) // Increments counter until 4T
    begin
      ctrl_cnt <= ctrl_cnt + 1;
    end

    // Counter for 'ready' signal
    // Count for 8 clock cycles before 'ready' signal is asserted
    if (get_ready && (ready_cnt < 7)) 
    // starts to increment when get_ready signal is asserted
    begin
      ready_cnt <= ready_cnt + 1;
    end
            
    // assert UDDCNTLN signal     
    if ((cs_rx_sync==FREEZE) && (ns_rx_sync==UDDCNTLN))
    begin
      not_uddcntln <= 1'b1;
    end

    // assert STOP signal     
    if ((cs_rx_sync==UDDCNTLN) && (ns_rx_sync==FREEZE))
    begin
      assert_stop <= 1'b1;
    end
    
    // de-assert RESET signal    
    if ((cs_rx_sync==STOP) && (ns_rx_sync==RESET))
    begin
      not_reset <= 1'b1;
    end

    // de-assert STOP signal
    if ((cs_rx_sync==RESET) && (ns_rx_sync==STOP))
    begin
      not_stop <= 1'b1;
    end
      
    // de-assert FREEZE signal  
    if ((cs_rx_sync==STOP) && (ns_rx_sync==FREEZE))
    begin
      not_freeze  <= 1'b1;
      assert_stop <= 1'b0;
    end
      
    // sync process is done; ready to assert READY signal  
    if ((cs_rx_sync==FREEZE) && (ns_rx_sync==UPDATE))
    begin 
      get_ready <= 1'b1;
    end
    
    // restart sync process when either the 'update' signal is 
    // asserted or DLL unlocks
    if ((cs_rx_sync==READY) && (ns_rx_sync==UPDATE))
    begin
        not_freeze   <= 1'b0;
        assert_stop  <= 1'b0;
        not_stop     <= 1'b0;
        not_reset    <= 1'b0;
        not_uddcntln <= 1'b0;
        get_ready    <= 1'b0;
        ready_cnt    <= 1'b0;
        dll_lock_cnt <= 1'b0;
        ctrl_cnt     <= 1'b0;
        dll_reset    <= 1'b1;
    end
    
  end // else begin
end // always @(posedge sync_clk or posedge rst) begin


//=============================================================================
//  Notes: RX_SYNC TIMING DIAGRAM                 
//=============================================================================
   
//  ____ rst
//      |__________________________________________________________________________________________
//
//  ____ DLL.RESET
//      |__________________________________________________________________________________________
//
//           ____DLL.LOCK goes high________________________________________________________________
//  ________|
//
//          |----8T----|
//                      ________________________________________________
//  __DLL.FREEZE_______|                                                |__________________________
//                           
//                     |--4T--|--4T--|                           |--4T--|----8T----|   
//  __DLL.UDDCNTLN____________        _____________________________________________________________
//                            |______|
//
//                                   |--4T--|
//                                           ____________________ 
//  __ECLKSYNC.STOP_________________________|                    |_________________________________
//
//                                          |--4T--|--4T--|--4T--|
//  ____ ddr_reset to CLKDIV & IDDR                 ______
//      |__________________________________________|      |________________________________________
//
//                                                                                   ______________
//  __READY_________________________________________________________________________|

endmodule // rxdll_sync
