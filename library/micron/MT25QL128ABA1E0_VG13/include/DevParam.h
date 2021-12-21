//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  Verilog Behavioral Model
//  Version 1.6
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
--           PARAMETERS OF DEVICES                       --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//-----------------------------
//  Customization Parameters
//-----------------------------
`include "include/UserData.h"
`define timingChecks


//-- Available devices 

//N25Q256A83E
//N25Q256A73E
//N25Q256A33E
//N25Q256A31E
//N25Q256A13E
//N25Q256A11E

//N25Q128A13E

//N25Q32A13E
//N25Q32A11E
//N25W32A13E
//N25W32A11E

//N25Q008A11E

 

//----------------------------
// Model configuration
//----------------------------


parameter dataDim = 8;
parameter dummyDim = 15;

`ifdef N25Q00AA13E
  `define N25Q256A13E
  `define Stack1024Mb
//  `define Stack512Mb
`elsif N25Q00AA33E
  `define N25Q256A33E
  `define Stack1024Mb
  `define Stack512Mb
`elsif N25Q00AA31E
  `define N25Q256A31E
  `define Stack1024Mb
  `define Stack512Mb
`elsif N25Q00AA11E
  `define N25Q256A11E
  `define Stack1024Mb
//  `define Stack512Mb
`elsif N25Q512A13E
  `define N25Q256A13E
  `define Stack512Mb
`elsif N25Q512A33E
  `define N25Q256A33E
  `define Stack512Mb
`elsif N25Q512A31E
  `define N25Q256A31E
  `define Stack512Mb
`elsif N25Q512A11E
  `define N25Q256A11E
  `define Stack512Mb
`elsif MT25QL01GBBA1E0
  `define MT25QL512ABA1E0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA1Exx1
  `define MT25QL512ABA1Exx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA8E0
  `define MT25QL512ABA8E0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA8Exx1
  `define MT25QL512ABA8Exx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA1F0
  `define MT25QL512ABA1F0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA1Fxx1
  `define MT25QL512ABA1Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA8F0
  `define MT25QL512ABA8F0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBA8Fxx1
  `define MT25QL512ABA8Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA1E0
  `define MT25QU512ABA1E0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA1Exx1
  `define MT25QU512ABA1Exx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA8E0
  `define MT25QU512ABA8E0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA8Exx1
  `define MT25QU512ABA8Exx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA1F0
  `define MT25QU512ABA1F0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA1Fxx1
  `define MT25QU512ABA1Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA8F0
  `define MT25QU512ABA8F0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBA8Fxx1
  `define MT25QU512ABA8Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB1E0
  `define MT25QL512ABB1E0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB1Exx1
  `define MT25QL512ABB1Exx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB8E0
  `define MT25QL512ABB8E0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB8Exx1
  `define MT25QL512ABB8Exx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB1F0
  `define MT25QL512ABB1F0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB1Fxx1
  `define MT25QL512ABB1Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB8F0
  `define MT25QL512ABB8F0
  `define STACKED_MEDT_1G
`elsif MT25QL01GBBB8Fxx1
  `define MT25QL512ABB8Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB1E0
  `define MT25QU512ABB1E0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB1Exx1
  `define MT25QU512ABB1Exx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB8E0
  `define MT25QU512ABB8E0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB8Exx1
  `define MT25QU512ABB8Exx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB1F0
  `define MT25QU512ABB1F0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB1Fxx1
  `define MT25QU512ABB1Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB8F0
  `define MT25QU512ABB8F0
  `define STACKED_MEDT_1G
`elsif MT25QU01GBBB8Fxx1
  `define MT25QU512ABB8Fxx1
  `define STACKED_MEDT_1G
`elsif MT25QL02GCBA1E0
  `define MT25QL512ABA1E0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA1Exx1
  `define MT25QL512ABA1Exx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA8E0
  `define MT25QL512ABA8E0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA8Exx1
  `define MT25QL512ABA8Exx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA1F0
  `define MT25QL512ABA1F0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA1Fxx1
  `define MT25QL512ABA1Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA8F0
  `define MT25QL512ABA8F0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBA8Fxx1
  `define MT25QL512ABA8Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA1E0
  `define MT25QU512ABA1E0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA1Exx1
  `define MT25QU512ABA1Exx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA8E0
  `define MT25QU512ABA8E0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA8Exx1
  `define MT25QU512ABA8Exx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA1F0
  `define MT25QU512ABA1F0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA1Fxx1
  `define MT25QU512ABA1Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA8F0
  `define MT25QU512ABA8F0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBA8Fxx1
  `define MT25QU512ABA8Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB1E0
  `define MT25QL512ABB1E0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB1Exx1
  `define MT25QL512ABB1Exx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB8E0
  `define MT25QL512ABB8E0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB8Exx1
  `define MT25QL512ABB8Exx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB1F0
  `define MT25QL512ABB1F0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB1Fxx1
  `define MT25QL512ABB1Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB8F0
  `define MT25QL512ABB8F0
  `define STACKED_MEDT_2G
`elsif MT25QL02GCBB8Fxx1
  `define MT25QL512ABB8Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB1E0
  `define MT25QU512ABB1E0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB1Exx1
  `define MT25QU512ABB1Exx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB8E0
  `define MT25QU512ABB8E0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB8Exx1
  `define MT25QU512ABB8Exx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB1F0
  `define MT25QU512ABB1F0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB1Fxx1
  `define MT25QU512ABB1Fxx1
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB8F0
  `define MT25QU512ABB8F0
  `define STACKED_MEDT_2G
`elsif MT25QU02GCBB8Fxx1
  `define MT25QU512ABB8Fxx1
  `define STACKED_MEDT_2G
`elsif MT25TU256HBA8Exx_0xxx
  `define MT25QU128ABA8E0
  `define MT25T_H
  `define MT25T_1_8V
  `define MT25T_256
`elsif MT25TU256BBA8Exx_0xxx
  `define MT25QU128ABA8E0
  `define MT25T_B
  `define MT25T_1_8V
  `define MT25T_256
`elsif MT25TL256HBA8Exx_0xxx
  `define MT25QL128ABA8E0
  `define MT25T_H
  `define MT25T_3V
  `define MT25T_256
`elsif MT25TL256BBA8Exx_0xxx
  `define MT25QL128ABA8E0
  `define MT25T_B
  `define MT25T_3V
  `define MT25T_256
`elsif MT25TU512HBA8Exx_0xxx
  `define MT25QU256ABA8E0
  `define MT25T_H
  `define MT25T_1_8V
  `define MT25T_512
`elsif MT25TL512HBA8Exx_0xxx
  `define MT25QL256ABA8E0
  `define MT25T_H
  `define MT25T_3V
  `define MT25T_512
`elsif MT25TL512BBA8Exx_0xxx
  `define MT25QL256ABA8E0
  `define MT25T_B
  `define MT25T_3V
  `define MT25T_512
`elsif MT25TL01GHBA8Exx_0xxx
  `define MT25QL512ABA8E0
  `define MT25T_H
  `define MT25T_3V
  `define MT25T_01G
`elsif MT25TL01GBBA8Exx_0xxx
  `define MT25QL512ABA8E0
  `define MT25T_B
  `define MT25T_3V
  `define MT25T_01G
`endif


`ifdef MT25QL512ABA8E0

    parameter [15*8:1] devName = "MT25QL512ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QL512ABB8E0

    parameter [15*8:1] devName = "MT25QL512ABB8E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA8Exx1

    parameter [17*8:1] devName = "MT25QL512ABA8Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QL512ABB8Exx1

    parameter [17*8:1] devName = "MT25QL512ABB8Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABA8E0

    parameter [15*8:1] devName = "MT25QU512ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU512ABA8Exx1

    parameter [17*8:1] devName = "MT25QU512ABA8Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define SR7_OTP
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU512ABB8E0

    parameter [15*8:1] devName = "MT25QU512ABB8E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABB8Exx1

    parameter [17*8:1] devName = "MT25QU512ABB8Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define SR7_OTP
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA1E0

    parameter [15*8:1] devName = "MT25QL512ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QL512ABB1E0

    parameter [15*8:1] devName = "MT25QL512ABB1E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA1Exx1

    parameter [17*8:1] devName = "MT25QL512ABA1Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QL512ABB1Exx1

    parameter [17*8:1] devName = "MT25QL512ABB1Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABA1E0

    parameter [15*8:1] devName = "MT25QU512ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1E0

    parameter [15*8:1] devName = "MT25QU512ABB1E0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABA1Exx1

    parameter [17*8:1] devName = "MT25QU512ABA1Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1Exx1

    parameter [17*8:1] devName = "MT25QU512ABB1Exx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL128ABA1E0

    parameter [15*8:1] devName = "MT25QL128ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
//    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE

    parameter RESET_PIN=0;

`elsif MT25QL256ABA1E0

    parameter [15*8:1] devName = "MT25QL256ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE

    parameter RESET_PIN=0;

`elsif MT25QL128ABA8E0

    parameter [15*8:1] devName = "MT25QL128ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
//    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE

    parameter RESET_PIN=0;

`elsif MT25QL256ABA8E0

    parameter [15*8:1] devName = "MT25QL256ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE

    parameter RESET_PIN=0;

`elsif MT25QL128ABA8Exx1

    parameter [17*8:1] devName = "MT25QL128ABA8Exx1";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
//    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QL128ABA1Exx1

    parameter [17*8:1] devName = "MT25QL128ABA1Exx1";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
//    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define NVCR_1_0_RESERVED
    `define MEDT_MSE
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QU128ABA1E0

    parameter [15*8:1] devName = "MT25QU128ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU256ABA1E0

    parameter [15*8:1] devName = "MT25QU256ABA1E0";
    `define MEDITERANEO

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU128ABA1EM

    parameter [15*8:1] devName = "MT25QU128ABA1EM";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown
    `define MTC_ENABLED

    parameter RESET_PIN=0;

`elsif MT25QL128ABA1EM

    parameter [15*8:1] devName = "MT25QL128ABA1EM";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown
    `define MTC_ENABLED

    parameter RESET_PIN=0;

`elsif MT25QU128ABA1Exx1

    parameter [15*8:1] devName = "MT25QU128ABA1Exx1";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown
    `define SR7_OTPMT25QU128ABA1E


    parameter RESET_PIN=0;

`elsif MT25QU128ABA8Exx1

    parameter [17*8:1] devName = "MT25QU128ABA8Exx1";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QU128ABA8E0

    parameter [15*8:1] devName = "MT25QU128ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    //`define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    //`define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    //`define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU256ABA8E0

    parameter [15*8:1] devName = "MT25QU256ABA8E0";
    `define MEDITERANEO

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
    parameter [127:0] TDP_PAT0 = 128'hFF0F_FF00_FFCC_C3CC_C33C_CCFF_FEFF_FEEF;
    parameter [127:0] TDP_PAT1 = 128'hFFDF_FFDD_FFFB_FFFB_BFFF_7FFF_77F7_BDEF;
    parameter [127:0] TDP_PAT2 = 128'hFFF0_FFF0_0FFC_CC3C_CC33_CCCF_FEFF_FFEE;
    parameter [127:0] TDP_PAT3 = 128'hFFFD_FFFD_DFFF_BFFF_BBFF_F7FF_F77F_7BDE;
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define MEDT_TDP
    `define MEDT_MSE
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QL512ABA8F0

    parameter [15*8:1] devName = "MT25QL512ABA8F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QL512ABB8F0

    parameter [15*8:1] devName = "MT25QL512ABB8F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA8Fxx1

    parameter [17*8:1] devName = "MT25QL512ABA8Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QL512ABB8Fxx1

    parameter [17*8:1] devName = "MT25QL512ABB8Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABA8F0

    parameter [15*8:1] devName = "MT25QU512ABA8F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU512ABA8Fxx1

    parameter [17*8:1] devName = "MT25QU512ABA8Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QU512ABB8F0

    parameter [15*8:1] devName = "MT25QU512ABB8F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABB8Fxx1

    parameter [17*8:1] devName = "MT25QU512ABB8Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h44; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA1F0

    parameter [15*8:1] devName = "MT25QL512ABA1F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QL512ABB1F0

    parameter [15*8:1] devName = "MT25QL512ABB1F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QL512ABA1Fxx1

    parameter [17*8:1] devName = "MT25QL512ABA1Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QL512ABB1Fxx1

    parameter [17*8:1] devName = "MT25QL512ABB1Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABA1F0

    parameter [15*8:1] devName = "MT25QU512ABA1F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown

    parameter RESET_PIN=0;

`elsif MT25QU512ABA1Fxx1

    parameter [17*8:1] devName = "MT25QU512ABA1Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1F0

    parameter [15*8:1] devName = "MT25QU512ABB1F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1Fxx1

    parameter [17*8:1] devName = "MT25QU512ABB1Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1F0

    parameter [15*8:1] devName = "MT25QU512ABB1F0";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif MT25QU512ABB1Fxx1

    parameter [17*8:1] devName = "MT25QU512ABB1Fxx1";
    `define MEDITERANEO

    parameter addrDim = 26; 
    parameter sectorAddrDim = 10;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef STACKED_MEDT_1G
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `else
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h40; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h76; 
    parameter [dataDim-1:0] CFD_1 = 'h98; 
    parameter [dataDim-1:0] CFD_2 = 'hBA; 
    parameter [dataDim-1:0] CFD_3 = 'hDC; 
    parameter [dataDim-1:0] CFD_4 = 'hFE; 
    parameter [dataDim-1:0] CFD_5 = 'h1F; 
    parameter [dataDim-1:0] CFD_6 = 'h32; 
    parameter [dataDim-1:0] CFD_7 = 'h54; 
    parameter [dataDim-1:0] CFD_8 = 'h76; 
    parameter [dataDim-1:0] CFD_9 = 'h98;
    parameter [dataDim-1:0] CFD_10 = 'hBA; 
    parameter [dataDim-1:0] CFD_11 = 'hDC; 
    parameter [dataDim-1:0] CFD_12 = 'hFE; 
    parameter [dataDim-1:0] CFD_13 = 'h10; 
   
    `define HOLD_pin
    `define SubSect
    `define SubSect_256K
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    //`define Feature_8 
    `define ENRSTQIO
    `define QIEFP_38
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define MEDT_4READ4D
    `define MEDT_QIEFP_4byte
    `define MEDT_DYB_4byte
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define MEDT_4KBLocking
    `define MEDT_PPB
    `define MEDT_DUMMY_CYCLES
    `define MEDT_PASSWORD
    `define MEDT_ADVANCED_SECTOR
    `define PowDown
    `define SR7_OTP
    `define MEDT_SubSect32K4byte 

    parameter RESET_PIN=0;

`elsif N25Q256A83E

    parameter [12*8:1] devName = "N25Q256A83E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h04; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define ENRSTQIO
    `define QIEFP_38

    parameter RESET_PIN=0;

`elsif N25Q256A83Exxx1y

    parameter [17*8:1] devName = "N25Q256A83Exxx1y";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h04; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define Feature_8 
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define ENRSTQIO
    `define QIEFP_38
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif N25Q256A81E

    parameter [12*8:1] devName = "N25Q256A81E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h04; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define Feature_8 
    `define PP_4byte
    `define SE_4byte
    `define SSE_4byte
    `define QIFP_4byte
    `define ENRSTQIO
    `define QIEFP_38
    `define PowDown

    parameter RESET_PIN=0;

`elsif N25Q256A73E

    parameter [12*8:1] devName = "N25Q256A73E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define start_in_byte_4  //powerup in 4 byte addressing mode
    `define disEN4BYTE       //disable enter 4-byte addressing mode command
    `define disEX4BYTE       //disable exit 4-byte addressing mode command

    parameter RESET_PIN=0;

`elsif N25Q256A33E

    parameter [12*8:1] devName = "N25Q256A33E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h08; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define RESET_software
    `define VCC_3V 

    parameter RESET_PIN=1;

`elsif N25Q256A33Exxx1y

    parameter [17*8:1] devName = "N25Q256A33Exxx1y";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h08; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define RESET_software
    `define VCC_3V 
    `define SR7_OTP

    parameter RESET_PIN=1;

`elsif N25Q256A23E

    parameter [12*8:1] devName = "N25Q256A23E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_basic
    `define byte_4
    `define VCC_3V 
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q256A13E

    parameter [12*8:1] devName = "N25Q256A13E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q256A13Exxx1y

    parameter [17*8:1] devName = "N25Q256A13Exxx1y";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_3V 
    `define RESET_software
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif N25Q256A11E

    parameter [12*8:1] devName = "N25Q256A11E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define PP_4byte

    parameter RESET_PIN=0;

`elsif N25Q256A11Exxx1y

    parameter [17*8:1] devName = "N25Q256A11Exxx1y";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define VCC_1e8V 
    `define RESET_software
    `define SR7_OTP
    `define not_line_item_8

    parameter RESET_PIN=0;

`elsif N25Q256A31E
    
    parameter [12*8:1] devName = "N25Q256A31E";

    parameter addrDim = 25; 
    parameter sectorAddrDim = 9;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    `ifdef Stack1024Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h21; 
    `elsif Stack512Mb
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h20; 
    `else    
        parameter [dataDim-1:0] MemoryCapacity_ID = 'h19; 
    `endif
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h08; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define byte_4
    `define RESET_software
    `define PowDown
    `define VCC_1e8V 

    parameter RESET_PIN=1;

`elsif N25Q128A11E

    parameter [12*8:1] devName = "N25Q128A11E";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q128A11Exxx1y

    parameter [17*8:1] devName = "N25Q128A11Exxx1y";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif N25Q128A11B

    parameter [12*8:1] devName = "N25Q128A11B";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software
    `define bottom

    parameter RESET_PIN=0;

`elsif N25Q128A13E

    parameter [12*8:1] devName = "N25Q128A13E";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V 
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q128A13Exxx1y

    parameter [17*8:1] devName = "N25Q128A13Exxx1y";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h73; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V 
    `define RESET_software
    `define SR7_OTP

    parameter RESET_PIN=0;

`elsif N25Q128A13B

    parameter [12*8:1] devName = "N25Q128A13B";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V 
    `define RESET_software
    `define bottom

    parameter RESET_PIN=0;

`elsif N25W128A11E

    parameter [12*8:1] devName = "N25W128A11E";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h2C;
    parameter [dataDim-1:0] MemoryType_ID = 'hCB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25W128A11B

    parameter [12*8:1] devName = "N25W128A11B";

    parameter addrDim = 24; 
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] Manufacturer_ID = 'h2C;
    parameter [dataDim-1:0] MemoryType_ID = 'hCB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h13; 
    parameter [dataDim-1:0] CFD_1 = 'h51; 
    parameter [dataDim-1:0] CFD_2 = 'h2c; 
    parameter [dataDim-1:0] CFD_3 = 'h3b; 
    parameter [dataDim-1:0] CFD_4 = 'h01; 
    parameter [dataDim-1:0] CFD_5 = 'h4a; 
    parameter [dataDim-1:0] CFD_6 = 'h89; 
    parameter [dataDim-1:0] CFD_7 = 'haa; 
    parameter [dataDim-1:0] CFD_8 = 'hc4; 
    parameter [dataDim-1:0] CFD_9 = 'he1;
    parameter [dataDim-1:0] CFD_10 = 'h84; 
    parameter [dataDim-1:0] CFD_11 = 'hdd; 
    parameter [dataDim-1:0] CFD_12 = 'hd2; 
    parameter [dataDim-1:0] CFD_13 = 'hed; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software
    `define bottom

    parameter RESET_PIN=0;

`elsif N25Q064A13Exx4My

    parameter [17*8:1] devName = "N25Q064A13Exx4My";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h90; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V
    `define MTC_ENABLED
    `define MEDT_GPRR
    `define MEDT_SubSect32K
    `define DISABLE_ME

    parameter RESET_PIN=0;

`elsif N25Q064A13E

    parameter [12*8:1] devName = "N25Q064A13E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V
    `define PP_4byte
    `define NOT_SUPPORTED_IN_N25Q_64

    parameter RESET_PIN=0;

`elsif N25Q064B11E

    parameter [12*8:1] devName = "N25Q064B11E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software
    `define ENRSTQIO
    `define QIEFP_38
    `define MEDT_SubSect32K

    parameter RESET_PIN=0;

`elsif N25Q064B13E

    parameter [12*8:1] devName = "N25Q064B13E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V
    `define RESET_software
    `define ENRSTQIO
    `define QIEFP_38
    `define MEDT_SubSect32K

    parameter RESET_PIN=0;

`elsif N25Q064B31E

    parameter [12*8:1] devName = "N25Q064B31E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_1e8V
    `define RESET_software
    `define ENRSTQIO
    `define QIEFP_38
    `define MEDT_SubSect32K

    parameter RESET_PIN=0;

`elsif N25Q064B33E

    parameter [12*8:1] devName = "N25Q064B33E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define RESET_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V
    `define RESET_software
    `define ENRSTQIO
    `define QIEFP_38
    `define MEDT_SubSect32K

    parameter RESET_PIN=0;

`elsif N25Q064A11E

    parameter [12*8:1] devName = "N25Q064A11E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25W064A11E

    parameter [12*8:1] devName = "N25W064A11E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h2C;
    parameter [dataDim-1:0] MemoryType_ID = 'hCB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h17; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q032A13E

    parameter [12*8:1] devName = "N25Q032A13E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h16; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V

    parameter RESET_PIN=0;

`elsif N25Q032A11E

    parameter [12*8:1] devName = "N25Q032A11E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h16; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25W032A13E

    parameter [12*8:1] devName = "N25W032A13E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h2C;
    parameter [dataDim-1:0] MemoryType_ID = 'hCB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h16; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define VCC_3V

    parameter RESET_PIN=0;

`elsif N25W032A11E

    parameter [12*8:1] devName = "N25W032A11E";

    parameter addrDim = 22; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h2C;
    parameter [dataDim-1:0] MemoryType_ID = 'hCB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h16; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q016A11E

    parameter [12*8:1] devName = "N25Q016A11E";

    parameter addrDim = 21; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h15; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q016A13E

    parameter [12*8:1] devName = "N25Q016A13E";

    parameter addrDim = 21; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h15; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_3V
    `define RESET_software

    parameter RESET_PIN=0;

`elsif N25Q008A11E

    parameter [12*8:1] devName = "N25Q008A11E";

    parameter addrDim = 20; 
    parameter sectorAddrDim = 6;
    parameter [dataDim-1:0] Manufacturer_ID = 'h20;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB; 
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h14; 
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h00; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define XIP_Numonyx
    `define PowDown
    `define VCC_1e8V
    `define RESET_software

    parameter RESET_PIN=0;

`endif



//----------------------------
// Include TimingData file 
//----------------------------


`include "include/TimingData.h"





//----------------------------------------
// Parameters constants for all devices
//----------------------------------------

`define VoltageRange 31:0




//---------------------------
// stimuli clock period
//---------------------------
// for a correct behavior of the stimuli, clock period should
// be multiple of 4

`ifdef N25Q256A73E
  parameter time T = 40;
`elsif N25Q256A33E
  parameter time T = 40;
`elsif N25Q256A31E
  parameter time T = 40;
`elsif N25Q256A13E
  parameter time T = 40;
`elsif N25Q256A11E
  parameter time T = 40;
`elsif N25Q064A13E
  parameter time T = 40;
`elsif N25Q064A11E
  parameter time T = 40;
`elsif N25Q032A13E
  parameter time T = 40;
`elsif N25Q032A11E
  parameter time T = 40;
`elsif N25W032A13E
  parameter time T = 40;
`elsif N25W032A11E
  parameter time T = 40;
`elsif TIMING_133
  parameter time T = 7.5; //133MHz
`elsif TIMING_166
  parameter time T = 6; //166MHz
`else
  parameter time T = 40;
`endif




//-----------------------------------
// Devices Parameters 
//-----------------------------------


// data & address dimensions

parameter cmdDim = 8;
parameter addrDimLatch = 24; //da verificare se va bene

//`ifdef byte_4
    parameter addrDimLatch4 = 32; //da verificare
//`endif

// memory organization


parameter colAddrDim = 8;
parameter colAddr_sup = colAddrDim-1;
parameter pageDim = 2 ** colAddrDim;

`ifdef Stack1024Mb
  parameter nSector = 4 * (2 ** sectorAddrDim);
  parameter memDim = 4 * (2 ** addrDim); 
`elsif Stack512Mb
  parameter nSector = 2 * (2 ** sectorAddrDim);
  parameter memDim = 2* (2 ** addrDim); 
`else
  parameter nSector = 2 ** sectorAddrDim;
  parameter memDim = 2 ** addrDim; 
`endif
parameter sectorAddr_inf = addrDim-sectorAddrDim; 
parameter EARvalidDim = 2; // number of valid EAR bits


parameter sectorAddr_sup = addrDim-1;
parameter sectorSize = 2 ** (addrDim-sectorAddrDim);

 `ifdef bottom
   parameter bootSec_num = 8;
 `endif
 `ifdef top
   parameter bootSec_num = 8;
 `endif
 `ifdef uniform
   parameter bootSec_num = 0;
 `endif

`ifdef SubSect
    `ifdef SubSect_256K
        parameter subsecAddrDim = 4+sectorAddrDim+2;
        parameter subsecAddr_inf = 12;
        parameter subsecAddr_sup = addrDim-1;
        parameter subsecSize = 2 ** (addrDim-subsecAddrDim);
        parameter nSSector = 2 ** subsecAddrDim;
    `else
        parameter subsecAddrDim = 4+sectorAddrDim;
        parameter subsecAddr_inf = 12;
        parameter subsecAddr_sup = addrDim-1;
        parameter subsecSize = 2 ** (addrDim-subsecAddrDim);
        parameter nSSector = 2 ** subsecAddrDim;
    `endif
`endif

`ifdef MEDT_SubSect32K
    `ifdef SubSect_256K
        parameter subsec32AddrDim = 1+sectorAddrDim+2;
        parameter subsec32Addr_inf = 15;
        parameter subsec32Addr_sup = addrDim-1;
        parameter subsec32Size = 2 ** (addrDim-subsec32AddrDim);
    `else
        parameter subsec32AddrDim = 1+sectorAddrDim;
        parameter subsec32Addr_inf = 15;
        parameter subsec32Addr_sup = addrDim-1;
        parameter subsec32Size = 2 ** (addrDim-subsec32AddrDim);
    `endif
`endif

`ifdef MEDT_4KBLocking
parameter TOP_sector = 'h0;
parameter BOTTOM_sector = 'h0; 
`endif


parameter pageAddrDim = addrDim-colAddrDim;
parameter pageAddr_inf = colAddr_sup+1;
parameter pageAddr_sup = addrDim-1;




// OTP section

 parameter OTP_dim = 65;
 parameter OTP_addrDim = 7;

// FDP section

parameter FDP_dim = 16384; //2048 byte
parameter FDP_addrDim = 11; // 2048 address


// others constants

parameter [dataDim-1:0] data_NP = 'hFF;


`ifdef VCC_3V
parameter [`VoltageRange] Vcc_wi = 'd2500; //write inhibit 
parameter [`VoltageRange] Vcc_min = 'd2700;
parameter [`VoltageRange] Vcc_max = 'd3600;

`else

parameter [`VoltageRange] Vcc_wi = 'd1500; //write inhibit 
parameter [`VoltageRange] Vcc_min = 'd1700;
parameter [`VoltageRange] Vcc_max = 'd2000;
`endif
//-------------------------
// Alias used in the code
//-------------------------


// status register code

`define WIP N25Qxxx.stat.SR[0]

`define WEL N25Qxxx.stat.SR[1]

`define BP0 N25Qxxx.stat.SR[2]

`define BP1 N25Qxxx.stat.SR[3]

`define BP2 N25Qxxx.stat.SR[4]

`define TB N25Qxxx.stat.SR[5]

`define BP3 N25Qxxx.stat.SR[6]

`define SRWD N25Qxxx.stat.SR[7]

// PLR Sequence cycles
parameter PLRS_1st_x4_byte3 = 7;
parameter PLRS_1st_x4_byte4 = 9;
parameter PLRS_1st_x2_byte3 = 13;
parameter PLRS_1st_x2_byte4 = 17;
parameter PLRS_1st_x1_byte3 = 25;
parameter PLRS_1st_x1_byte4 = 33;

parameter PLRS_2nd = 8;

//--Non Array Commands---------
`define CMD_CLRFSR         'h50
`define CMD_DPD            'hB9
`define CMD_EN4BYTE        'hB7
`define CMD_EX4BYTE        'hE9
`define CMD_POTP           'h42
`define CMD_PPMR           'h68
`define CMD_RDFSR          'h70
`define CMD_RDID1          'h9E
`define CMD_RDID2          'h9F
`define CMD_MIORDID1       'hAF
`define CMD_MIORDID2       'h9E
`define CMD_RDPD           'hAB
`define CMD_RDSFDP         'h5A
`define CMD_RDSR           'h05
`define CMD_ROTP           'h4B
`define CMD_RSTEN          'h66
`define CMD_RST            'h99
`define CMD_WRDI           'h04
`define CMD_WREAR          'hC5
`define CMD_WREN           'h06
`define CMD_WRNVCR         'hB1
`define CMD_WRSR           'h01
`define CMD_WRVCR          'h81
`define CMD_WRVECR         'h61
`define CMD_RDNVCR         'hB5
`define CMD_RDVCR          'h85
`define CMD_RDVECR         'h65
`define CMD_EQIO           'h35 //EQPI
`define CMD_RSTQIO         'hF5 //RSTQPI
`define CMD_ASPRD          'h2D
`define CMD_ASPP           'h2C
`define CMD_RDVLB          'hE8
`define CMD_WRVLB          'hE5
`define CMD_RDVLB4BYTE     'hE0
`define CMD_WRVLB4BYTE     'hE1
`define CMD_RDNVLB         'hE2
`define CMD_WRNVLB         'hE3
`define CMD_ERNVLB         'hE4
`define CMD_RDGFB          'hA7
`define CMD_WRGFB          'hA6
`define CMD_PASSRD         'h27
`define CMD_PASSP          'h28
`define CMD_PASSU          'h29
`define CMD_RDEAR          'hC8
//--Array Read Commands--------
`define CMD_READ           'h03
`define CMD_FAST_READ      'h0B
`define CMD_FAST_READ4BYTE 'h0C
`define CMD_READ4BYTE      'h13
`define CMD_DOFR           'h3B
`define CMD_DOFR4BYTE      'h3C
`define CMD_QOFR           'h6B
`define CMD_QOFR4BYTE      'h6C
`define CMD_DIOFR          'hBB
`define CMD_DIOFR4BYTE     'hBC
`define CMD_4READ4D        'hE7
`define CMD_QIOFR          'hEB
`define CMD_QIOFR4BYTE     'hEC
`define CMD_FAST_READDTR   'h0D
`define CMD_DOFRDTR        'h3D
`define CMD_DIOFRDTR       'hBD
`define CMD_QOFRDTR        'h6D
`define CMD_QIOFRDTR       'hED
`define CMD_FAST_READ4BYTEDTR 'h0E
`define CMD_DIOFR4BYTEDTR  'hBE
`define CMD_QIOFR4BYTEDTR  'hEE
//--Erase Array Commands-------
`define CMD_SSE            'h20 
`define CMD_SSE4BYTE       'h21
`define CMD_SSE32K         'h52
`define CMD_PES            'h75
`define CMD_PER            'h7A
`define CMD_DIEER          'hC4
`define CMD_BE             'hC7
`define CMD_SE             'hD8
`define CMD_SE4BYTE        'hDC
`define CMD_SSE32K4BYTE    'h5C
//--Array Write Commands-------
`define CMD_PP             'h02
`define CMD_DIFP           'hA2
`define CMD_DIEFP          'hD2
`define CMD_QIFP           'h32
`define CMD_QIEFP          'h38
`define CMD_PP4BYTE        'h12
`define CMD_QIFP4BYTE      'h34
`define CMD_QIEFP4BYTE     'h3E
//--EFI Commands --------------
`define CMD_MSE_OP1        'h9B
`define CMD_MSE_OP2        'h26
`define CMD_MSE_FD         'hFF
`define CMD_MSE_LSBF       'hFE
`define CMD_MSE_MSBF       'hFC
//--Special -------------------
`define CMD_TDP            'h48
//-----------------------------


`define DIE0_SECTOR_00_B     'h0000000
`define DIE0_SECTOR_00_L     'h000FFFE

`define DIE0_4KB_SUBSECTOR_0E_B     'h000E000
`define DIE0_4KB_SUBSECTOR_0E_L     'h000EFFE

`define DIE0_4KB_SUBSECTOR_04_B     'h0004000
`define DIE0_4KB_SUBSECTOR_04_L     'h0004FFE

`define DIE0_SECTOR_01_B     'h0010000
`define DIE0_SECTOR_01_L     'h001FFFE

`define DIE0_SECTOR_02_B     'h0020000
`define DIE0_SECTOR_02_L     'h002FFFE

`define DIE0_SECTOR_254_B    'h0FE0000
`define DIE0_SECTOR_254_L    'h0FEFFFE

`define DIE0_SECTOR_255_B    'h0FF0000
`define DIE0_SECTOR_255_L    'h0FFFFFE

`define DIE0_SECTOR_255_B_2  'h0FF2000
`define DIE0_SECTOR_255_L_8  'h0FF8FFE

`define DIE0_SECTOR_08_B     'h0080000
`define DIE0_SECTOR_08_L     'h008FFFE
`define DIE0_SECTOR_08_SS4   'h0084FFE

`define DIE0_SECTOR_24_B     'h0180000
`define DIE0_SECTOR_24_L     'h018FFFE
`define DIE0_SECTOR_24_SS5   'h0185FFE

`define DIE0_SECTOR_1023_B   'h3FF0000
`define DIE0_SECTOR_1023_L   'h3FFFFFE

`define DIE0_SECTOR_07_SS0_B 'h007F000
`define DIE0_SECTOR_07_SS1_L 'h007FFFE

`define DIE1_SECTOR_00_B     'h4000000
`define DIE1_SECTOR_00_L     'h400FFFE

`define DIE1_SECTOR_08_B     'h4080000
`define DIE1_SECTOR_08_L     'h408FFFE

`define DIE2_SECTOR_00_B     'h8000000
`define DIE2_SECTOR_00_L     'h800FFFE

`define DIE2_SECTOR_08_B     'h8080000
`define DIE2_SECTOR_08_L     'h808FFFE

`define DIE3_SECTOR_00_B     'hC000000
`define DIE3_SECTOR_00_L     'hC00FFFE

`define DIE3_SECTOR_08_B     'hC080000
`define DIE3_SECTOR_08_L     'hC08FFFE


`define ON 'b1
`define OFF 'b0

`define SIO 'b00
`define DIO 'b01
`define QIO 'b10
`define XIPon  'h0000
`define XIPoff 'h4000
`define _ 'b0
`define LOWBYTE "7:0"
//`define > 1
//`define < 0

