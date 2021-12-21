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
--           CUI DECODERS ISTANTIATIONS                  --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//
// Here are istantiated CUIdecoders
// for commands recognition
//  (this file must be included in "Core.v"
//   file)
//
`include "include/UserData.h"

CUIdecoder   

    #(.cmdName("Write Enable"), .cmdCode('h06), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeEnable (!busy && !deep_power_down && WriteAccessOn);


CUIdecoder   

    #(.cmdName("Write Disable"), .cmdCode('h04), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeDisable (!busy  && !deep_power_down  && WriteAccessOn);


CUIdecoder   

    #(.cmdName("Read ID"), .cmdCode('h9F), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_ID_1 (!busy && !deep_power_down  && ReadAccessOn && protocol=="extended");


CUIdecoder   

    #(.cmdName("Multiple I/O Read ID"), .cmdCode('hAF), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    //CUIDEC_multipleIO_read_ID (!busy && !deep_power_down   && ReadAccessOn && protocol!="extended");
    CUIDEC_multipleIO_read_ID (!busy && !deep_power_down   && ReadAccessOn );

CUIdecoder   

    #(.cmdName("Read ID"), .cmdCode('h9E), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_read_ID_2_dual (!busy && !deep_power_down  && ReadAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Read ID"), .cmdCode('h9E), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_read_ID_2 (!busy && !deep_power_down  && ReadAccessOn && protocol=="dual");

CUIdecoder   

    #(.cmdName("Read ID"), .cmdCode('h9E), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_read_ID_2_quad (!busy && !deep_power_down  && ReadAccessOn && protocol=="quad");

CUIdecoder   

    #(.cmdName("Read SR"), .cmdCode('h05), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_SR (PollingAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write SR"), .cmdCode('h01), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_write_SR (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Flag SR"), .cmdCode('h70), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_FSR (PollingAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Clear Flag SR"), .cmdCode('h50), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_clear_FSR (!busy && WriteAccessOn && !deep_power_down);

//extended protocol
CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_writeLockReg (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readLockReg (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


//dual protocol

CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_writeLockRegDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_readLockRegDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);


//quad protocol
CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_writeLockRegQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_readLockRegQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

`ifdef MEDT_DYB_4byte
//extended protocol
CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE1), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_writeLockReg4byte (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE0), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readLockReg4byte (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


//dual protocol

CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE1), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_writeLockReg4byteDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE0), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_readLockReg4byteDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);


//quad protocol
CUIdecoder   

    #(.cmdName("Write Lock Reg"), .cmdCode('hE1), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_writeLockReg4byteQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Lock Reg"), .cmdCode('hE0), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_readLockReg4byteQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);
`endif
    
`ifdef MEDT_PPB

//extended protocol
CUIdecoder   

    #(.cmdName("Erase PPB Reg"), .cmdCode('hE4), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_erasePPBReg (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write PPB Reg"), .cmdCode('hE3), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_writePPBReg (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read PPB Reg"), .cmdCode('hE2), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readPPBReg (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


//dual protocol
CUIdecoder   

    #(.cmdName("Erase PPB Reg"), .cmdCode('hE4), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_erasePPBRegDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write PPB Reg"), .cmdCode('hE3), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_writePPBRegDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read PPB Reg"), .cmdCode('hE2), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_readPPBRegDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);


//quad protocol
CUIdecoder   

    #(.cmdName("Erase PPB Reg"), .cmdCode('hE4), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_erasePPBRegQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write PPB Reg"), .cmdCode('hE3), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_writePPBRegQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read PPB Reg"), .cmdCode('hE2), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_readPPBRegQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

//extended protocol
CUIdecoder   

    #(.cmdName("PPB Lock Bit Write"), .cmdCode('hA6), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_writePpbLockBit (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read PPB Lock Bit"), .cmdCode('hA7), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readPpbLockBit (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


//dual protocol

CUIdecoder   

    #(.cmdName("PPB Lock Bit Write"), .cmdCode('hA6), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writePpbLockBitDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

//quad protocol
CUIdecoder   

    #(.cmdName("PPB Lock Bit Write"), .cmdCode('hA6), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writePpbLockBitQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

`endif //MEDT_PPB
    

 CUIdecoder   

      #(.cmdName("Write Protection Management Reg"), .cmdCode('h68), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writePMReg (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Protection Management Reg"), .cmdCode('h2B), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readPMReg (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

      #(.cmdName("Write Protection Management Reg"), .cmdCode('h68), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writePMRegDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Protection Management Reg"), .cmdCode('h2B), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readPMRegDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

      #(.cmdName("Write Protection Management Reg"), .cmdCode('h68), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writePMRegQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Protection Management Reg"), .cmdCode('h2B), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readPMRegQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write NV Configuration Reg"), .cmdCode('hB1), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writeNVReg (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read NV Configuration Reg"), .cmdCode('hB5), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readNVReg (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write Volatile Configuration Reg"), .cmdCode('h81), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writeVCReg (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Volatile Configuration Reg"), .cmdCode('h85), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readVCReg (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read GPRR Reg"), .cmdCode('h96), .withAddr(0), .with2Addr(0), .with4Addr(0))

    CUIDEC_readGPRRReg (!busy && ReadAccessOn  && !deep_power_down);

`ifdef MEDT_PASSWORD
CUIdecoder   

    #(.cmdName("Password Read"), .cmdCode('h27), .withAddr(0), .with2Addr(0), .with4Addr(0))

    CUIDEC_readPasswordReg (!busy && ReadAccessOn  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Password Write"), .cmdCode('h28), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writePasswordReg (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Password Unlock"), .cmdCode('h29), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writePasswordUnlockReg (!busy && WriteAccessOn && !deep_power_down);

`endif

`ifdef MEDT_ADVANCED_SECTOR

CUIdecoder   

    #(.cmdName("ASP Read"), .cmdCode('h2d), .withAddr(0), .with2Addr(0), .with4Addr(0))

    CUIDEC_readASPReg (!busy && ReadAccessOn  && !deep_power_down);

CUIdecoder   

    #(.cmdName("ASP Write"), .cmdCode('h2c), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writeASPReg (!busy && WriteAccessOn && !deep_power_down);

`endif

// CUIdecoder   

//     #(.cmdName("Read GPRR Reg"), .cmdCode('h96), .withAddr(0), .with2Addr(1), .with4Addr(0))
//   
//     CUIDEC_readGPRRRegDual (!busy && ReadAccessOn && protocol=="dual"  && !deep_power_down);

// CUIdecoder   

//     #(.cmdName("Read GPRR Reg"), .cmdCode('h96), .withAddr(0), .with2Addr(0), .with4Addr(1))
//   
//     CUIDEC_readGPRRRegQuad (!busy && ReadAccessOn && protocol=="quad"  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Write VE Configuration Reg"), .cmdCode('h61), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_writeVEReg (!busy && WriteAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read VE Configuration Reg"), .cmdCode('h65), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readVEReg (!busy && ReadAccessOn && !deep_power_down);


`ifdef byte_4

CUIdecoder   

    #(.cmdName("Read EAR"), .cmdCode('hC8), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_readEAR (!busy && ReadAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Write EAR"), .cmdCode('hC5), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeEAR (!busy && WriteAccessOn && !deep_power_down);
      
`endif
//



CUIdecoder   

    #(.cmdName("Read"), .cmdCode('h03), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read Fast"), .cmdCode('h0B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_readFast (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h0B), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readFastdual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Quad Command Fast Read"), .cmdCode('h0B), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_readFastquad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read Serial Flash Discovery Parameter"), .cmdCode('h5A), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_readSFDP (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read Serial Flash Discovery Parameter"), .cmdCode('h5A), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readSFDPdual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Serial Flash Discovery Parameter"), .cmdCode('h5A), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_readSFDPquad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Page Program"), .cmdCode('h02), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_pageProgram (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('h02), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_pageProgramdual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h02), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_pageProgramquad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

//`ifdef Feature_8    
`ifdef PP_4byte    
CUIdecoder   

    #(.cmdName("Page Program"), .cmdCode('h12), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_pageProgram4Byte (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

`ifndef NOT_SUPPORTED_IN_N25Q_64    
CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('h12), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_pageProgramdual4Byte (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);
`endif

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h12), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_pageProgramquad4Byte (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

`endif
//`endif



`ifdef SubSect

CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_subsectorErase (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_subsectorEraseDual (!busy && WriteAccessOn  && protocol=="dual" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_subsectorEraseQuad (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);    

//`ifdef Feature_8
`ifdef SSE_4byte
CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h21), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_subsectorErase4Byte (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h21), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_subsectorEraseDual4Byte (!busy && WriteAccessOn  && protocol=="dual" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase"), .cmdCode('h21), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_subsectorEraseQuad4Byte (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);    
//`endif
`endif
`endif

`ifdef MEDT_SubSect32K

CUIdecoder   

    #(.cmdName("Subsector Erase 32K"), .cmdCode('h52), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_subsectorErase32k (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase 32K"), .cmdCode('h52), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_subsectorErase32kDual (!busy && WriteAccessOn  && protocol=="dual" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase 32K"), .cmdCode('h52), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_subsectorErase32kQuad (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);    

`endif //MEDT_SubSect32K    

`ifdef MEDT_SubSect32K4byte

CUIdecoder   

    #(.cmdName("Subsector Erase 32K 4Byte"), .cmdCode('h5C), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_subsectorErase32k4Byte (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase 32K 4Byte"), .cmdCode('h5C), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_subsectorErase32k4ByteDual (!busy && WriteAccessOn  && protocol=="dual" && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Subsector Erase 32K 4Byte"), .cmdCode('h5C), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_subsectorErase32k4ByteQuad (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);    

`endif //MEDT_SubSect32K4byte    

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_sectorErase (!busy && WriteAccessOn && protocol=="extended"  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_sectorEraseDual (!busy && WriteAccessOn && protocol=="dual"  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_sectorEraseQuad (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);

//`ifdef Feature_8
`ifdef SE_4byte
CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hDC), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_sectorErase4Byte (!busy && WriteAccessOn && protocol=="extended"  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hDC), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_sectorEraseDual4Byte (!busy && WriteAccessOn && protocol=="dual"  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hDC), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_sectorEraseQuad4Byte (!busy && WriteAccessOn  && protocol=="quad" && !deep_power_down);

`endif    
//`endif    

CUIdecoder   

    #(.cmdName("Bulk Erase"), .cmdCode('hC7), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_bulkErase (!busy && WriteAccessOn && !deep_power_down);


`ifdef PowDown

CUIdecoder   

    #(.cmdName("Deep Power Down"), .cmdCode('hB9), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_deepPowerDown (!busy && !deep_power_down && ReadAccessOn);  

CUIdecoder   

    #(.cmdName("Release Deep Power Down"), .cmdCode('hAB), .withAddr(0), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_releaseDeepPowerDown (!busy && ReadAccessOn);    

`endif


`ifdef RESET_software 

CUIdecoder 

    #(.cmdName("Reset Enable"), .cmdCode('h66), .withAddr(0), .with2Addr(0), .with4Addr(0))
   
    CUIDEC_resetEnable(!XIP && WriteAccessOn);


 CUIdecoder    

    #(.cmdName("Reset"), .cmdCode('h99), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_reset (!XIP && WriteAccessOn);

`endif
    


CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_read_OTP (!busy && ReadAccessOn && protocol=="extended" );

CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_prog_OTP (!busy && WriteAccessOn && protocol=="extended");   

CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(0), .with2Addr(1), .with4Addr(0))
   
    CUIDEC_read_OTPDual (!busy && ReadAccessOn && protocol=="dual" );

CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_prog_OTPDual (!busy && WriteAccessOn && protocol=="dual");   

CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(0), .with2Addr(0), .with4Addr(1))
   
    CUIDEC_read_OTPQuad (!busy && ReadAccessOn && protocol=="quad" );

CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(0), .with2Addr(0), .with4Addr(1))
  
    CUIDEC_prog_OTPQuad (!busy && WriteAccessOn && protocol=="quad");   




CUIdecoder   

    #(.cmdName("Dual Output Fast Read"), .cmdCode('h3B), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_readDual (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h3B), .withAddr(0), .with2Addr(2), .with4Addr(0))
   
    CUIDEC_readDualDual (!busy && ReadAccessOn && protocol=="dual");


CUIdecoder   

    #(.cmdName("Dual Program"), .cmdCode('hA2), .withAddr(1), .with2Addr(0), .with4Addr(0))
  
    CUIDEC_programDual (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('hA2), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_programDualDual (!busy && WriteAccessOn && protocol=="dual");


    


CUIdecoder   

    #(.cmdName("Dual I/O Fast Read"), .cmdCode('hBB), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_readDualIo (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('hBB), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readDualIoDual (!busy && ReadAccessOn && protocol=="dual");


CUIdecoder   

    #(.cmdName("Dual Extended Program"), .cmdCode('hD2), .withAddr(0), .with2Addr(1), .with4Addr(0))
  
    CUIDEC_programDualExtended (!busy && WriteAccessOn  && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('hD2), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_programDualExtendedDual (!busy && WriteAccessOn  && protocol=="dual");

 


CUIdecoder   

    #(.cmdName("Quad Output Read"), .cmdCode('h6B), .withAddr(1), .with2Addr(0), .with4Addr(0))
        
    CUIDEC_readQuad (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Fast Read"), .cmdCode('h6B), .withAddr(0), .with2Addr(0), .with4Addr(1))
          
    CUIDEC_readQuadQuad (!busy && ReadAccessOn && protocol=="quad");


CUIdecoder   

    #(.cmdName("Quad I/O Fast Read"), .cmdCode('hEB), .withAddr(0), .with2Addr(0), .with4Addr(1))
                
    CUIDEC_readQuadIo (!busy && ReadAccessOn && protocol=="extended");
                                

CUIdecoder   

    #(.cmdName("Quad Command Fast Read"), .cmdCode('hEB), .withAddr(0), .with2Addr(0), .with4Addr(1))
          
    CUIDEC_readQuadIoQuad (!busy && ReadAccessOn && protocol=="quad");



CUIdecoder   

    #(.cmdName("Quad Program"), .cmdCode('h32), .withAddr(1), .with2Addr(0), .with4Addr(0))
                      
    CUIDEC_programQuad (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h32), .withAddr(0), .with2Addr(0), .with4Addr(1))
                      
    CUIDEC_programQuadQuad (!busy && WriteAccessOn && protocol=="quad");

//`ifdef Feature_8
`ifdef QIFP_4byte
CUIdecoder   

    #(.cmdName("Quad Program"), .cmdCode('h34), .withAddr(1), .with2Addr(0), .with4Addr(0))
                      
    CUIDEC_programQuad4Byte (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h34), .withAddr(0), .with2Addr(0), .with4Addr(1))
                      
    CUIDEC_programQuadQuad4Byte (!busy && WriteAccessOn && protocol=="quad");

`endif
`ifdef MEDT_QIEFP_4byte    
CUIdecoder   

    #(.cmdName("Quad Extended Program"), .cmdCode('h3e), .withAddr(0), .with2Addr(0), .with4Addr(1))
                      
    CUIDEC_programQuadExtended4Byte (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h3e), .withAddr(0), .with2Addr(0), .with4Addr(1))
                       
    CUIDEC_programQuadExtendedQuad4Byte (!busy && WriteAccessOn && protocol=="quad");
`endif
//`endif


`ifdef not_line_item_8
CUIdecoder   

    #(.cmdName("Quad Extended Program"), .cmdCode('h12), .withAddr(0), .with2Addr(0), .with4Addr(1))
                      
    CUIDEC_programQuadExtended (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h12), .withAddr(0), .with2Addr(0), .with4Addr(1))
                       
    CUIDEC_programQuadExtendedQuad (!busy && WriteAccessOn && protocol=="quad");

`endif

CUIdecoder   

    #(.cmdName("Program Erase Resume"), .cmdCode('h7A), .withAddr(0), .with2Addr(0), .with4Addr(0))
                              
    CUIDEC_programEraseResume (WriteAccessOn);
                                        


CUIdecoder   

    #(.cmdName("Program Erase Suspend"), .cmdCode('h75), .withAddr(0), .with2Addr(0), .with4Addr(0))
                                        
    CUIDEC_programEraseSuspend (WriteAccessOn);
                                                                                         
//`ifdef Feature_8
`ifdef ENRSTQIO
CUIdecoder   

    #(.cmdName("Enable QPI Mode"), .cmdCode('h35), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_enableQPI (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Reset QPI Mode"), .cmdCode('hF5), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_exitQPI (!busy && WriteAccessOn && !deep_power_down);
`endif

//`endif

`ifdef QIEFP_38
CUIdecoder   

    #(.cmdName("Quad Extended Program"), .cmdCode('h38), .withAddr(0), .with2Addr(0), .with4Addr(1))
                      
    CUIDEC_programQuadExtended38 (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h38), .withAddr(0), .with2Addr(0), .with4Addr(1))
                       
    CUIDEC_programQuadExtendedQuad38 (!busy && WriteAccessOn && protocol=="quad");


`endif


`ifdef byte_4
`ifndef disEN4BYTE
CUIdecoder   

    #(.cmdName("Enable 4 Byte Address"), .cmdCode('hB7), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_enable4 (!busy && ReadAccessOn && !deep_power_down);
`endif
`ifndef disEX4BYTE
CUIdecoder   

    #(.cmdName("Exit 4 Byte Address"), .cmdCode('hE9), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_exit4 (!busy && WriteAccessOn && !deep_power_down);
`endif
`endif

`ifdef MEDT_4READ4D

//CUIdecoder   
//
//    #(.cmdName("Quad Extended Program"), .cmdCode('h38), .withAddr(0), .with2Addr(0), .with4Addr(1))
//                      
//    CUIDEC_programQuadExtended38 (!busy && WriteAccessOn && protocol=="extended");
//
//CUIdecoder   
//
//    #(.cmdName("Quad Command Page Program"), .cmdCode('h38), .withAddr(0), .with2Addr(0), .with4Addr(1))
//                       
//    CUIDEC_programQuadExtendedQuad38 (!busy && WriteAccessOn && protocol=="quad");


CUIdecoder

    #(.cmdName("Word Read Quad I/O"), .cmdCode('hE7), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_wordReadQuadIO (!busy && ReadAccessOn && protocol=="extended" && N25Qxxx.DoubleTransferRate == 0);

CUIdecoder

    #(.cmdName("Word Read Quad Command Fast Read"), .cmdCode('hE7), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_wordReadQueadIOQuad (!busy && ReadAccessOn && protocol=="quad" && N25Qxxx.DoubleTransferRate == 0);

`endif


// DTR commands
CUIdecoder

    #(.cmdName("Read Fast DTR"), .cmdCode('h0D), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readFastDTR (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder

    #(.cmdName("Dual Command Fast Read DTR"), .cmdCode('h0D), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readFastdualDTR (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder

    #(.cmdName("Quad Command Fast Read DTR"), .cmdCode('h0D), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readFastquadDTR (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);


CUIdecoder

    #(.cmdName("Extended command DOFRDTR"), .cmdCode('h3D), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readDualDTR (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command DOFRDTR"), .cmdCode('h3D), .withAddr(0), .with2Addr(2), .with4Addr(0))

    CUIDEC_readDualDualDTR (!busy && ReadAccessOn && protocol=="dual");


CUIdecoder

    #(.cmdName("Extended command DIOFRDTR"), .cmdCode('hBD), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIoDTR (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command DIOFRDTR"), .cmdCode('hBD), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIoDualDTR (!busy && ReadAccessOn && protocol=="dual");


CUIdecoder

    #(.cmdName("Extended command QOFRDTR"), .cmdCode('h6D), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readQuadDTR (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command QOFRDTR"), .cmdCode('h6D), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadQuadDTR (!busy && ReadAccessOn && protocol=="quad");

CUIdecoder

    #(.cmdName("Extended command QIOFRDTR"), .cmdCode('hED), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIoDTR (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command QIOFRDTR"), .cmdCode('hED), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIoQuadDTR (!busy && ReadAccessOn && protocol=="quad");

// 4BYTE commands
CUIdecoder   

    #(.cmdName("Read"), .cmdCode('h13), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_read4addr (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read Fast"), .cmdCode('h0C), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readFast4addr (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h0C), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readFastdual4addr (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder

    #(.cmdName("Quad Command Fast Read"), .cmdCode('h0C), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readFastquad4addr (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);


CUIdecoder

    #(.cmdName("Dual Output Fast Read"), .cmdCode('h3C), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readDual4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h3C), .withAddr(0), .with2Addr(2), .with4Addr(0))

    CUIDEC_readDualDual4addr (!busy && ReadAccessOn && protocol=="dual");


CUIdecoder

    #(.cmdName("Dual I/O Fast Read"), .cmdCode('hBC), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIo4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command Fast Read"), .cmdCode('hBC), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIoDual4addr (!busy && ReadAccessOn && protocol=="dual");

CUIdecoder

    #(.cmdName("Quad Output Read"), .cmdCode('h6C), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readQuad4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command Fast Read"), .cmdCode('h6C), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadQuad4addr (!busy && ReadAccessOn && protocol=="quad");


CUIdecoder

    #(.cmdName("Quad I/O Fast Read"), .cmdCode('hEC), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIo4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command Fast Read"), .cmdCode('hEC), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIoQuad4addr (!busy && ReadAccessOn && protocol=="quad");

CUIdecoder

    #(.cmdName("Read Fast DTR"), .cmdCode('h0E), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readFastDTR4addr (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder

    #(.cmdName("Dual Command Fast Read DTR"), .cmdCode('h0E), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readFastdualDTR4addr (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder

    #(.cmdName("Quad Command Fast Read DTR"), .cmdCode('h0E), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readFastquadDTR4addr (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);

// CUIdecoder
// 
//     #(.cmdName("Extended command DOFRDTR"), .cmdCode('h3E), .withAddr(1), .with2Addr(0), .with4Addr(0))
// 
//     CUIDEC_readDualDTR4addr (!busy && ReadAccessOn && protocol=="extended");
// 
// CUIdecoder
// 
//     #(.cmdName("Dual Command DOFRDTR"), .cmdCode('h3E), .withAddr(0), .with2Addr(2), .with4Addr(0))
// 
//     CUIDEC_readDualDualDTR4addr (!busy && ReadAccessOn && protocol=="dual");

CUIdecoder

    #(.cmdName("Extended command DOFRDTR"), .cmdCode('h39), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readDualDTR4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command DOFRDTR"), .cmdCode('h39), .withAddr(0), .with2Addr(2), .with4Addr(0))

    CUIDEC_readDualDualDTR4addr (!busy && ReadAccessOn && protocol=="dual");

CUIdecoder

    #(.cmdName("Extended command DIOFRDTR"), .cmdCode('hBE), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIoDTR4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Dual Command DIOFRDTR"), .cmdCode('hBE), .withAddr(0), .with2Addr(1), .with4Addr(0))

    CUIDEC_readDualIoDualDTR4addr (!busy && ReadAccessOn && protocol=="dual");

// CUIdecoder
// 
//     #(.cmdName("Extended command QOFRDTR"), .cmdCode('h6E), .withAddr(1), .with2Addr(0), .with4Addr(0))
// 
//     CUIDEC_readQuadDTR4addr (!busy && ReadAccessOn && protocol=="extended");
// 
// CUIdecoder
// 
//     #(.cmdName("Quad Command QOFRDTR"), .cmdCode('h6E), .withAddr(0), .with2Addr(0), .with4Addr(1))
// 
//     CUIDEC_readQuadQuadDTR4addr (!busy && ReadAccessOn && protocol=="quad");

CUIdecoder

    #(.cmdName("Extended command QOFRDTR"), .cmdCode('h3A), .withAddr(1), .with2Addr(0), .with4Addr(0))

    CUIDEC_readQuadDTR4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command QOFRDTR"), .cmdCode('h3A), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadQuadDTR4addr (!busy && ReadAccessOn && protocol=="quad");

CUIdecoder

    #(.cmdName("Extended command QIOFRDTR"), .cmdCode('hEE), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIoDTR4addr (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder

    #(.cmdName("Quad Command QIOFRDTR"), .cmdCode('hEE), .withAddr(0), .with2Addr(0), .with4Addr(1))

    CUIDEC_readQuadIoQuadDTR4addr (!busy && ReadAccessOn && protocol=="quad");

`ifdef Stack512Mb
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(1), .with2Addr(0), .with4Addr(0))
                                          
      CUIDEC_dieErase (!busy && WriteAccessOn && protocol=="extended");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(1), .with4Addr(0))
                                          
      CUIDEC_dieEraseDio (!busy && WriteAccessOn && protocol=="dual");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(0), .with4Addr(1))
                                          
      CUIDEC_dieEraseQio (!busy && WriteAccessOn&& protocol=="quad");
`endif // Stack512Mb

`ifdef STACKED_MEDT_1G 
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(1), .with2Addr(0), .with4Addr(0))
                                          
      CUIDEC_dieErase (!busy && WriteAccessOn && protocol=="extended");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(1), .with4Addr(0))
                                          
      CUIDEC_dieEraseDio (!busy && WriteAccessOn && protocol=="dual");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(0), .with4Addr(1))
                                          
      CUIDEC_dieEraseQio (!busy && WriteAccessOn&& protocol=="quad");
`endif // STACKED_MEDT_1G

`ifdef STACKED_MEDT_2G 
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(1), .with2Addr(0), .with4Addr(0))
                                          
      CUIDEC_dieErase (!busy && WriteAccessOn && protocol=="extended");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(1), .with4Addr(0))
                                          
      CUIDEC_dieEraseDio (!busy && WriteAccessOn && protocol=="dual");
  CUIdecoder   
  
      #(.cmdName("Die Erase"), .cmdCode('hC4), .withAddr(0), .with2Addr(0), .with4Addr(1))
                                          
      CUIDEC_dieEraseQio (!busy && WriteAccessOn&& protocol=="quad");
`endif // STACKED_MEDT_2G



`ifdef MEDT_TDP
CUIdecoder_TDP
    #(.cmdName("Tuning Data Pattern Operation"), .cmdCode('h48), .withAddr(1), .with2Addr(0), .with4Addr(0))
    CUIDECEFI_tuningDataPattern (!busy && WriteAccessOn);        
`endif // MEDT_TDP
    
`ifdef MTC_ENABLED
CUIdecoderEFI
    #(.cmdName("EFI operation"), .cmdCode1('h9B), .cmdCode2('h00), .withAddr(1), .with2Addr(0), .with4Addr(0))
    CUIDECEFI (!busy && WriteAccessOn && protocol=="extended");

    TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);    

CUIdecoderEFI_MTC
    #(.cmdName("MTC operation"), .cmdCode1('h00), .cmdCode2('h00), .withAddr(1), .with2Addr(0), .with4Addr(0))
    CUIDECEFI_MTC (!busy && WriteAccessOn && protocol=="extended");

    //TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);    
`endif // MTC_ENABLED

`ifdef MEDT_MSE
CUIdecoderEFI_MSE
    #(.cmdName("Multi-Sector Erase"), .cmdCode1('h9B), .cmdCode2('h26), .withAddr(1), .with2Addr(0), .with4Addr(0))
    CUIDECEFI_multiSectorErase (!busy && WriteAccessOn);        

//CUIdecoderEFI_MSE
//    #(.cmdName("Multi-Sector Erase"), .cmdCode1('h9B), .cmdCode2('h26), .withAddr(1), .with2Addr(0), .with4Addr(0))
//    CUIDECEFI_multiSectorErase (!busy && WriteAccessOn && protocol=="extended");        
//
//CUIdecoderEFI_MSE
//    #(.cmdName("Multi-Sector Erase"), .cmdCode1('h9B), .cmdCode2('h26), .withAddr(0), .with2Addr(1), .with4Addr(0))
//    CUIDECEFI_multiSectorEraseDio (!busy && WriteAccessOn && protocol=="dual");        
//
//CUIdecoderEFI_MSE
//    #(.cmdName("Multi-Sector Erase"), .cmdCode1('h9B), .cmdCode2('h26), .withAddr(0), .with2Addr(0), .with4Addr(1))
//    CUIDECEFI_multiSectorEraseQio (!busy && WriteAccessOn && protocol=="quad");        

`endif // MEDT_MSE   
// CUIdecoder   
// 
//     #(.cmdName("Page Program"), .cmdCode('h14), .withAddr(1), .with2Addr(0), .with4Addr(0))
//     
//     CUIDEC_pageProgram4addr (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);
// 
// CUIdecoder   
// 
//     #(.cmdName("Dual Command Page Program"), .cmdCode('h14), .withAddr(0), .with2Addr(1), .with4Addr(0))
//     
//     CUIDEC_pageProgramdual4addr (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);
// 
// CUIdecoder   
// 
//     #(.cmdName("Quad Command Page Program"), .cmdCode('h14), .withAddr(0), .with2Addr(0), .with4Addr(1))
//     
//     CUIDEC_pageProgramquad4addr (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);
// 
// CUIdecoder   
// 
//     #(.cmdName("Dual Program"), .cmdCode('hA3), .withAddr(1), .with2Addr(0), .with4Addr(0))
//   
//     CUIDEC_programDual4addr (!busy && WriteAccessOn && protocol=="extended");
// 
// CUIdecoder   
// 
//     #(.cmdName("Dual Command Page Program"), .cmdCode('hA3), .withAddr(0), .with2Addr(1), .with4Addr(0))
//     
//     CUIDEC_programDualDual4addr (!busy && WriteAccessOn && protocol=="dual");
// 
// CUIdecoder   
// 
//     #(.cmdName("Dual Extended Program"), .cmdCode('hD3), .withAddr(0), .with2Addr(1), .with4Addr(0))
//   
//     CUIDEC_programDualExtended4addr (!busy && WriteAccessOn  && protocol=="extended");
// 
// CUIdecoder   
// 
//     #(.cmdName("Dual Command Page Program"), .cmdCode('hD3), .withAddr(0), .with2Addr(1), .with4Addr(0))
// 
//     CUIDEC_programDualExtendedDual4addr (!busy && WriteAccessOn  && protocol=="dual");
// 
