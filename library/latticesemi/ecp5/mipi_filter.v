// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2013 Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation       TEL  : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================
// Module     : mipi_filter
// Description: 
//   - filters LOW-SPEED signals for MIPI RX
//   - MIPI D-PHY specification asks for 20ns filter but for practical reason 
//     this filter's default implementation is 40ns filter.
//   - digital filter implementation so filtering is based mainly on the clock
//     edge
//   - parameter "CUT_OFF" gives user capability to configure pulse width to
//     be filtered depending on the fltr_clk frequency
//
//     CUT_OFF = (pulse_width_in_ns/period_of_fltr_clk) - 1
//
//     For 40 ns filter with 100 MHz filter clock
//       CUT_OFF = (40 ns / 10 ns) - 1 = 3
// =============================================================================

`timescale 1 ns/ 1 ps

module mipi_filter (
  // INPUTS
  rst,          // Asynchronous reset
  fltr_clk,     // digital filter clock
  ls,           // Low-Speed signal input

  // OUTPUTS
  ls_out        // Filtered output signal
);

//------------------------------------------------------------------------------
// PORTS DECLRATIONS
//------------------------------------------------------------------------------
input wire    rst;
input wire    fltr_clk;
input wire    ls;

// output
output        ls_out;

//------------------------------------------------------------------------------
// SIGNAL DECLARATIONS
//------------------------------------------------------------------------------
reg           ls_out;

reg           ls_d1, ls_d2;
reg [4:0]     cnt;

//------------------------------------------------------------------------------
// PARAMETERS
//------------------------------------------------------------------------------
parameter     CUT_OFF = 3; // pass signal above 4 cycles

//          _____                       ___________          ___________________
// ls_d2         |_____________________|           |________|
//           :__   :__   :__   :__   :__   :__   :__   :__   :__   :__   :__   :
// fltr_clk _|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
//           :     :     :     :     :     :     :     :     :     :     :     :
//           :     :     :     :     :     :     :     :     :     :     :     :
// cnt       3     2     1     0     0     1     2     0     1     2     3     3
//          _________________________ 
// ls_out                            |_________________________________________|

// update value of cnt every posedge of fltr_clk
always @(posedge fltr_clk or posedge rst) begin
  if (rst)
  begin
    cnt <= 0;
  end
  else if (!ls_out)
  begin
    if (ls_d2)
    begin
      if (cnt < CUT_OFF)
      begin
        cnt <= cnt + 1;
      end
    end
    else
    begin
      cnt <= 0;
    end
  end
  else
  begin
    if (!ls_d2)
    begin
      if (cnt > 0)
      begin
        cnt <= cnt - 1;
      end
    end
    else
    begin
      cnt <= CUT_OFF;
    end
  end
end

// synchronize mipi filter input to fltr_clk
always @(posedge fltr_clk or posedge rst)
begin
  if (rst)
  begin
    ls_d1 <= 1'b0;
    ls_d2 <= 1'b0;
  end
  else
  begin
    ls_d1 <= ls;
    ls_d2 <= ls_d1;
  end
end

// update ls_out based on cnt and ls_d2
always @(posedge fltr_clk or posedge rst)
begin
  if (rst)
  begin
    ls_out <= 1'b0;
  end
  else
  begin
    if (!ls_out)
    begin
      if ((cnt==CUT_OFF) && ls_d2)
      begin
        ls_out <= 1'b1;
      end
    end
    else
    begin
      if ((cnt==0) && !ls_d2)
      begin
        ls_out <= 1'b0;
      end
    end
  end
end

endmodule // mipi_filter
