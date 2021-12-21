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
--           TIMING CONSTANTS                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/




    //--------------------------------------
    // Max clock frequency (minimum period)
    //--------------------------------------
`ifdef TIMING_133    
    parameter fC = 133; //max frequency in Mhz
    parameter time TC = 7.5; //9ns=111.1Mhz
    parameter fC_dtr = 80;      // max frequency in Mhz in Double Transfer Rate
    parameter TC_dtr = 12.5;      // 15ns = 66.7Mhz

    
    parameter fR = 66.5; //max frequency in Mhz during standard Read operation
    parameter time TR = 15; //18ns=55.55Mhz
    parameter fR_dtr = 33;      // max frequency in Mhz during standard Read operation in Double Transfer Rate
    parameter TR_dtr = 30;      // 37ns = 27.03Mhz

    //NB: in special read operations 
    // (fast read, dual output fast read, read SR, 
    // read lock register, read ID, read OTP)
    // max clock frequency is fC 
    
    //---------------------------
    // Input signals constraints
    //---------------------------

    // Clock signal constraints
    parameter time tCH = 3.375;
    parameter time tCL = 3.375;
    parameter time tSLCH = 4;
    //parameter time tDVCH = 2;
    //parameter time tDVCH = 11.75;
    parameter time tSHCH = 3.375;
    parameter time tHLCH = 3.375;
    parameter time tHHCH = 3.375;
    parameter tCH_dtr = 5.62;
    parameter tCL_dtr = 5.62;

    // Chip select constraints
    parameter time tCHSL = 3.375;
    parameter time tCHSH = 3.375;
    parameter time tSHSL = 20; 
    parameter time tVPPHSL = 200; //not implemented
    parameter time tWHSL = 20;  
    parameter tSLCH_dtr = 3.75;
    parameter tSHCH_dtr = 5.62;
    parameter tCHSL_dtr = 3.75;
    parameter tCHSH_dtr = 5.62;
    parameter tCLSH = 3.375; // DTR only

    
    // Data in constraints
    parameter time tCHDX = 2.5;

    // W signal constraints
    parameter time tSHWL = 100;  


    // HOLD signal constraints
    parameter time tCHHH = 3.375;
    parameter time tCHHL = 3.375;

    // RESET signal constraints
    parameter time tRLRH = 50; // da sistemare
    parameter time tSHRH = 2; 
    parameter time tRHSL_1 = 40; //during decoding
    parameter time tRHSL_2 = 30000; //during program-erase operation (except subsector erase and WRSR)
    parameter time tRHSL_3 = 500e6;  //during subsector erase operation=tSSE
    parameter time tRHSL_4 = 15e6; //during WRSR operation=tW
    parameter time tRHSL_5 = 15e6; //during WRNVCR operation=tWNVCR

    parameter time tRHSL_6 = 40; //when S is high in XIP mode and in standby mode

    //-----------------------
    // Output signal timings
    //-----------------------

    parameter time tSHQZ = 7;
    parameter time tCLQV = 6; // 8 under 30 pF - 6 under 10 pF
    parameter time tCLQX = 1; // min value
    `ifdef MEDITERANEO
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `else
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `endif
    parameter tCHQV = 6; // 6 under 30 pF - 5 under 10 pF - DTR only
    parameter tCHQX = 1; // min value- DTR only

`elsif TIMING_166 
    parameter fC = 166; //max frequency in Mhz
    parameter time TC = 6; //6ns = 166.0Mhz
    parameter fC_dtr = 80;      // max frequency in Mhz in Double Transfer Rate
    parameter TC_dtr = 12;      // 12ns = 80Mhz

    
    parameter fR = 54; //max frequency in Mhz during standard Read operation
    parameter time TR = 18; //18ns=55.55Mhz
    parameter fR_dtr = 27;      // max frequency in Mhz during standard Read operation in Double Transfer Rate
    parameter TR_dtr = 37;      // 37ns = 27.03Mhz

    //NB: in special read operations 
    // (fast read, dual output fast read, read SR, 
    // read lock register, read ID, read OTP)
    // max clock frequency is fC 
    
    //---------------------------
    // Input signals constraints
    //---------------------------

    // Clock signal constraints
    parameter time tCH = 2.7;
    parameter time tCL = 2.7;
    parameter time tSLCH = 2.7;
    //parameter time tDVCH = 2;
    //parameter time tDVCH = 11.75;
    parameter time tSHCH = 2.7;
    parameter time tHLCH = 2.7;
    parameter time tHHCH = 2.7;
    parameter tCH_dtr = 2.7;
    parameter tCL_dtr = 2.7;

    // Chip select constraints
    parameter time tCHSL = 2.7;
    parameter time tCHSH = 2.7;
    parameter time tSHSL = 6; 
    parameter time tSHSL1 = 6;  //not implemented 
    parameter time tSHSL2 = 30; //not implemented
    parameter time tVPPHSL = 200; //not implemented
    parameter time tWHSL = 20;  
    parameter tSLCH_dtr = 2.7;
    parameter tSHCH_dtr = 2.7;
    parameter tCHSL_dtr = 2.7;
    parameter tCHSH_dtr = 2.7;
    parameter tCLSH = 3.375; // DTR only

    
    // Data in constraints
    parameter time tCHDX = 2;

    // W signal constraints
    parameter time tSHWL = 100;  


    // HOLD signal constraints
    parameter time tCHHH = 2.7;
    parameter time tCHHL = 2.7;

    // RESET signal constraints
    parameter time tRLRH = 50; // da sistemare
    parameter time tSHRH = 10; 
    parameter time tRHSL_1 = 40; //during decoding
    parameter time tRHSL_2 = 30000; //during program-erase operation (except subsector erase and WRSR)
    parameter time tRHSL_3 = 500e6; //during subsector erase operation=tSSE
    parameter time tRHSL_4 = 15e6;  //during WRSR operation=tW
    parameter time tRHSL_5 = 15e6;  //during WRNVCR operation=tWNVCR
    parameter time tRHSL_6 = 40;    //when S is high in XIP mode and in standby mode

    //-----------------------
    // Output signal timings
    //-----------------------

    parameter time tSHQZ = 6;
    parameter time tCLQV = 5; // 8 under 30 pF - 6 under 10 pF
    parameter time tCLQX = 1; // min value
    `ifdef MEDITERANEO
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `else
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `endif
    parameter tCHQV = 5; // 6 under 30 pF - 5 under 10 pF - DTR only
    parameter tCHQX = 1; // min value- DTR only

`else // end of TIMING_166 and start of default
    parameter fC = 108; //max frequency in Mhz
    parameter time TC = 9; //9ns=111.1Mhz
    parameter fC_dtr = 66;      // max frequency in Mhz in Double Transfer Rate
    parameter TC_dtr = 15;      // 15ns = 66.7Mhz

    
    parameter fR = 54; //max frequency in Mhz during standard Read operation
    parameter time TR = 18; //18ns=55.55Mhz
    parameter fR_dtr = 27;      // max frequency in Mhz during standard Read operation in Double Transfer Rate
    parameter TR_dtr = 37;      // 37ns = 27.03Mhz

    //NB: in special read operations 
    // (fast read, dual output fast read, read SR, 
    // read lock register, read ID, read OTP)
    // max clock frequency is fC 
    
    //---------------------------
    // Input signals constraints
    //---------------------------

    // Clock signal constraints
    parameter time tCH = 4;
    parameter time tCL = 4;
    parameter time tSLCH = 4;
    //parameter time tDVCH = 2;
    //parameter time tDVCH = 11.75;
    parameter time tSHCH = 4;
    parameter time tHLCH = 4;
    parameter time tHHCH = 4;
    parameter tCH_dtr = 6.75;
    parameter tCL_dtr = 6.75;

    // Chip select constraints
    parameter time tCHSL = 4;
    parameter time tCHSH = 4;
    parameter time tSHSL = 20; 
    parameter time tVPPHSL = 200; //not implemented
    parameter time tWHSL = 20;  
    parameter tSLCH_dtr = 6.75;
    parameter tSHCH_dtr = 6.75;
    parameter tCHSL_dtr = 6.75;
    parameter tCHSH_dtr = 6.75;
    parameter tCLSH = 3.375; // DTR only

    
    // Data in constraints
    parameter time tCHDX = 3;

    // W signal constraints
    parameter time tSHWL = 100;  


    // HOLD signal constraints
    parameter time tCHHH = 4;
    parameter time tCHHL = 4;

    // RESET signal constraints
    parameter time tRLRH = 50; // da sistemare
    parameter time tSHRH = 2; 
    parameter time tRHSL_1 = 40; //during decoding
    parameter time tRHSL_2 = 30000; //during program-erase operation (except subsector erase and WRSR)
    parameter time tRHSL_3 = 500e6;  //during subsector erase operation=tSSE
    parameter time tRHSL_4 = 15e6; //during WRSR operation=tW
    parameter time tRHSL_5 = 15e6; //during WRNVCR operation=tWNVCR

    parameter time tRHSL_6 = 40; //when S is high in XIP mode and in standby mode

    //-----------------------
    // Output signal timings
    //-----------------------

    parameter time tSHQZ = 8;
    parameter time tCLQV = 5; // 8 under 30 pF - 6 under 10 pF
    parameter time tCLQX = 1; // min value
    `ifdef MEDITERANEO
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `else
        parameter time tHHQX = 8;  
        parameter time tHLQZ = 8;
    `endif
    parameter tCHQV = 6; // 6 under 30 pF - 5 under 10 pF - DTR only
    parameter tCHQX = 1; // min value- DTR only
`endif //


    //--------------------
    // Operation delays
    //--------------------
   
   `ifdef PowDown
    parameter time tDP  = 3e0;
    parameter time tRDP = 30e0; 
    `endif

`ifdef N25Q064A13xx4My
    parameter time tPP  = 1e6;
    parameter time tSSE = 60e6;
    parameter time t32SSE = 220e6;
    parameter time tSE  = 460e6;
    parameter time tBE  = 45e9; 
`else
    parameter time tPP  = 1e6;
    parameter time tSSE = 3e9;
    parameter time t32SSE = 3e9;
    parameter time tSE  = 700e6;
    parameter time tBE  = 240e9; 
`endif   
    parameter time tDE  = 80e6; // Needs to change 
    //aggiunta
    `ifdef MEDITERANEO
    parameter time tWNVCR = 200e3; //real value should be 200e9 (200ms), we use short value for simulation length
    parameter time tWRASP = 200e6; //real value should be 200e9 (200ms), we use short value for simulation length
    parameter time tW   = 1.3e6;
    `else
    parameter time tWNVCR   = 3e6;
    parameter time tWRASP = 1;
    parameter time tW   = 1.3e3;
    `endif
    parameter time tWVCR  = 40;
    parameter time tWRVECR = 40;
    parameter time tCFSR = 40;
    parameter time tPOTP = 800000;
    
    `ifdef byte_4
    parameter time tWREAR = 40; // probable value
    parameter time tEN4AD = 40; // probable value
    parameter time tEX4AD = 40; // probable value
    `endif
    
    parameter tP_latency = 7e0;
    parameter tSE_latency = 15e0;
    parameter tSSE_latency = 15e0;

    parameter write_PMR_delay = 5e5;

    parameter progSusp_latencyTime = 25e3;
    parameter eraseSusp_latencyTime = 25e3;

    // Startup delays
//!    parameter time tPUW = 10e6;
    parameter time tVTR = 150e0;
    parameter time tVTW = 150e0;
//---------------------------------
// Alias of timing constants above
//---------------------------------

parameter time program_delay = tPP;
parameter time program_OTP_delay = tPOTP;
parameter time program_latency = tP_latency;
parameter time write_SR_delay = tW;
parameter time clear_FSR_delay = tCFSR;
parameter time write_NVCR_delay = tWNVCR;
`ifdef MEDITERANEO
parameter time write_ASP_delay = tWRASP;
`endif
parameter time write_VCR_delay = tWVCR;
parameter time write_VECR_delay = tWRVECR;

`ifdef byte_4
parameter time write_EAR_delay = tWREAR;
parameter time enable4_address_delay = tEN4AD;
parameter time exit4_address_delay = tEX4AD;
`endif

parameter time erase_delay = tSE;
parameter time erase_latency = tSE_latency;

parameter time erase_bulk_delay = tBE;
parameter time erase_die_delay = tDE;
parameter time full_access_power_up_delay = tVTW;
parameter time read_access_power_up_delay = tVTR;

`ifdef SubSect 
  parameter time erase_ss_delay = tSSE;
  parameter time erase_ss_latency = tSSE_latency;
`endif

`ifdef MEDT_SubSect32K
  parameter time erase_ss32k_delay = t32SSE; 
`endif

`ifdef PowDown 
  parameter time deep_power_down_delay = tDP; 
  parameter time release_power_down_delay = tRDP;
`endif

`ifdef MEDT_PPB
  parameter time tPPBP = 1e5;
  //parameter time tPPBP = 1;
  parameter time tPPBE = 2e6;
  parameter time write_PPB_delay = tPPBP;
  parameter time erase_PPB_delay = tPPBE;
  //parameter time write_PLB_delay = 1e5;
  parameter time write_PLB_delay = 1;
`endif

  parameter time write_PASSP_delay = 1e6;
`ifdef MEDITERANEO
    parameter time tDVCH = 1.75;
`else    
    parameter time tDVCH = 1.75;
`endif

