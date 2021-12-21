//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
// This file and all files delivered herewith are Micron Confidential Information.
// 
// 
// Disclaimer of Warranty:
// -----------------------
// This software code and all associated documentation, comments
// or other information (collectively "Software") is provided 
// "AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
// ("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
// RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
// FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
// SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
// THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
// MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
// RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
// ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
// OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
// EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
// LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
// SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
// OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
// ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
// EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// Because some jurisdictions prohibit the exclusion or limitation
// of liability for consequential or incidental damages, the above
// limitation may not apply to you.
// 
// Copyright 2013 Micron Technology, Inc. All rights reserved.
//





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STACK DECODERS INSTANTIATIONS               --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`ifdef Stack1024Mb
  `ifdef HOLD_pin
    N25Qxxx #(.rdeasystacken(0),.rdeasystacken2(deviceStack)) N25Q_die0 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(1),.rdeasystacken2(deviceStack)) N25Q_die1 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(2),.rdeasystacken2(deviceStack)) N25Q_die2 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(3),.rdeasystacken2(deviceStack)) N25Q_die3 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
  `else 
    N25Qxxx #(.rdeasystacken(0),.rdeasystacken2(deviceStack)) N25Q_die0 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(1),.rdeasystacken2(deviceStack)) N25Q_die1 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(2),.rdeasystacken2(deviceStack)) N25Q_die2 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(3),.rdeasystacken2(deviceStack)) N25Q_die3 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
  `endif
`endif

`ifdef Stack512Mb
  `ifdef HOLD_pin
    N25Qxxx #(.rdeasystacken(0)) N25Q_die0 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(1)) N25Q_die1 (S,C,HOLD_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
  `else
    N25Qxxx #(.rdeasystacken(0)) N25Q_die0 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
    N25Qxxx #(.rdeasystacken(1)) N25Q_die1 (S,C,RESET_DQ3,DQ0,DQ1,Vcc,Vpp_W_DQ2);
  `endif
`endif

`ifdef STACKED_MEDT_1G
    `ifdef Feature_8
        `ifdef HOLD_pin
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `else 
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `endif
    `else
        `ifdef HOLD_pin
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `else 
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `endif
    `endif // Feature_8
`endif // STACKED_MEDT_1G

`ifdef STACKED_MEDT_2G
    `ifdef Feature_8
        `ifdef HOLD_pin
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(2)) MT25Q_die2 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(3)) MT25Q_die3 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `else 
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(2)) MT25Q_die2 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
            N25Qxxx #(.rdeasystacken(3)) MT25Q_die3 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `endif
    `else
        `ifdef HOLD_pin
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(2)) MT25Q_die2 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(3)) MT25Q_die3 (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `else 
            N25Qxxx #(.rdeasystacken(0)) MT25Q_die0 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(1)) MT25Q_die1 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(2)) MT25Q_die2 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
            N25Qxxx #(.rdeasystacken(3)) MT25Q_die3 (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `endif
    `endif // Feature_8
`endif // STACKED_MEDT_2G
