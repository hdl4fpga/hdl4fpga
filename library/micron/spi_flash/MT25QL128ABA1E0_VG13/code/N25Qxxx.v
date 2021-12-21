//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  N25Qxxx
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
// Confidential:
// -------------
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
`timescale 1ns / 1ps

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TOP LEVEL MODULE                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



`include "include/UserData.h"

module paramConfig();
`include "include/DevParam.h"

endmodule


//***********************************************************************
//***********************************************************************
//    N25Q device as stand alone
//***********************************************************************
//***********************************************************************

`ifdef Feature_8
    `ifdef HOLD_pin
        module N25Qxxx (S, C_, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
    `elsif RESET_pin 
        module N25Qxxx (S, C_, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
    `endif
`else    
    `ifdef HOLD_pin
        module N25Qxxx (S, C_, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
    `elsif RESET_pin 
        module N25Qxxx (S, C_, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
    `endif
`endif

`include "include/DevParam.h"
 parameter [1:0] rdeasystacken = 0;
 parameter [1:0] rdeasystacken2 = 0;
 parameter [15:0] NVConfigReg_default = `NVCR_DEFAULT_VALUE;
 
`ifdef MEDITERANEO
    `define defaultDummy 6
    `define defaultiDummy 5
`else
    `define defaultDummy 8
    `define defaultiDummy 7
`endif    

input S;
input C_;
input [`VoltageRange] Vcc;

inout DQ0; 
inout DQ1;
wire RESET;

`ifdef Feature_8
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `endif
`else
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
    `endif
`endif


inout Vpp_W_DQ2; //input Vpp_W, inout DQ2 (VPPH not implemented)


//parameter [40*8:1] memory_file = "mem_Q016.vmf";
parameter [40*8:1] memory_file = `FILENAME_mem;

// parameter [2048*8:1] fdp_file = "sfdp.vmf";
parameter [48*8:1] fdp_file = `FILENAME_sfdp;


reg PollingAccessOn = 0;
reg ReadAccessOn = 0;
wire WriteAccessOn; 

// indicate type of data that will be latched by the model:
//  C=command, A=address, I= address on two pins; E= address on four pins; D=data, N=none, Y=dummy, F=dual_input(F=fast),Q=Quad_io 
reg [8:1] latchingMode = "N";

reg [8*8:1] protocol="extended";

reg [cmdDim-1:0] cmd='h0;
`ifdef byte_4
  reg [addrDimLatch4-1:0] addrLatch='h0;
`else
  reg [addrDimLatch-1:0] addrLatch='h0;
`endif
reg [addrDim-1:0] addr='h0;
reg [dataDim-1:0] data='h0;
reg [dummyDim-1:0] dummy='h0;
reg [dataDim-1:0] LSdata='h0;
reg [dataDim-1:0] dataOut='h0;

integer dummyDimEff;

reg [40*8:1] cmdRecName;

reg quadMode ='h0;

reg die_active = 'h1;  // Indicates that this die is active
                       // Used for stacked die


buf (strong1, strong0) b0(C, C_);


//----------------------
// Report Model Info 
//----------------------
initial begin
    $display ("==============================================");
    $display ("===INFO=== Model Configuration Info");
    determineDevName;
    `ifdef RESET_pin
        $display ("===INFO=== DQ3 = RESET pin");
    `endif   
    `ifdef HOLD_pin
        $display ("===INFO=== DQ3 = HOLD pin");
    `endif   
    `ifdef XIP_Numonyx 
        $display ("===INFO=== XIP type = Numonyx");
    `endif   
    `ifdef XIP_basic 
        $display ("===INFO=== XIP type = Basic");
    `endif   
    `ifdef VCC_1e8V
        $display ("===INFO=== VCC 1.8V");
    `endif    
    `ifdef VCC_3V
        $display ("===INFO=== VCC 3V");
    `endif   
    $display ("==============================================");
end


//----------------------
// HOLD signal
//----------------------
//dovrebbe essere abilitato attraverso il bit 4 del VECR o anche attraverso il bit 4 del NVECR
reg NVCR_HoldResetEnable;

`ifdef HOLD_pin

    reg intHOLD=1;

//aggiunta verificare
   //latchingMode=="E"                                                                                                                                                                 
    assign HOLD = (read.enable_quad || 
                   quadMode == 1 || 
                   latchingMode=="Q"  || 
                   latchingMode=="E" || 
                   protocol=="quad" || 
                   VolatileEnhReg.VECR[4]==0 || 
                   cmd == 'h32 || 
                   cmd == 'h12 || 
                   (NVCR_HoldResetEnable==0 && prog.dummySetByVECR==0))  ? 1 : HOLD_DQ3; //serve per disabilitare la funzione di hold nel caso di quad read


    always @(HOLD) if (S==0 && C==0) 
        intHOLD = HOLD;
    
    always @(negedge C) if(S==0 && intHOLD!=HOLD) 
        intHOLD = HOLD;

    always @(posedge HOLD , posedge S) if(S==1)
        intHOLD = 1;
    
    always @intHOLD if (Vcc>=Vcc_min) begin
        if(intHOLD==0)
            $display("[%0t ns] ==INFO== Hold condition enabled: communication with the device has been paused.", $time);
        else if(intHOLD==1)
            $display("[%0t ns] ==INFO== Hold condition disabled: communication with the device has been activated.", $time);  
   end
`endif



//-------------------------
// Internal signals
//-------------------------

reg busy=0;

reg [2:0] ck_count = 0; //clock counter (modulo 8) 

reg reset_by_powerOn = 1; //reset_by_powerOn is updated in "Power Up & Voltage check" section


`ifdef Feature_8
        assign RESET = ((read.enable_quad || latchingMode=="Q" || quadMode == 1 ||
                        cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" ||
                        latchingMode=="E" || protocol=="quad" || VolatileEnhReg.VECR[4]==0 ||
                        NVCR_HoldResetEnable==0 || cmdRecName=="Extended command DOFRDTR" || 
                        cmdRecName=="Extended command DIOFRDTR" || cmdRecName=="Extended command QOFRDTR" ||
                        cmdRecName=="Extended command QIOFRDTR" || cmdRecName=="Quad Command Fast Read" ||
                        cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" ) &&  S == 0)? 1 : RESET2;  //|| cmdRecName=="Quad I/O Fast Read")  ? 1 : RESET_DQ3; //serve per disabilitare la funzione di reset nel caso di quad read

        assign int_reset = (RESET===0 || RESET===1 && protocol!="quad") ? !RESET || reset_by_powerOn : reset_by_powerOn;

    `ifdef HOLD_pin
        assign logicOn = !int_reset && !S && intHOLD; 
    `else
        assign logicOn = !int_reset && !S;
    `endif  
`else    
    `ifdef RESET_pin

        assign RESET = (read.enable_quad || latchingMode=="Q" || quadMode == 1 ||
                        cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" ||
                        latchingMode=="E" || protocol=="quad" || VolatileEnhReg.VECR[4]==0 ||
                        NVCR_HoldResetEnable==0 || cmdRecName=="Extended command DOFRDTR" || 
                        cmdRecName=="Extended command DIOFRDTR" || cmdRecName=="Extended command QOFRDTR" ||
                        cmdRecName=="Extended command QIOFRDTR" || cmdRecName=="Quad Command Fast Read" ||
                        //cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" ) &&  S == 0)? 1 : RESET_DQ3;  //|| cmdRecName=="Quad I/O Fast Read")  ? 1 : RESET_DQ3; //serve per disabilitare la funzione di reset nel caso di quad read
                        cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" )? 1 : RESET_DQ3;  //|| cmdRecName=="Quad I/O Fast Read")  ? 1 : RESET_DQ3; //serve per disabilitare la funzione di reset nel caso di quad read

        assign int_reset = (RESET===0 || (RESET===1 && protocol!="quad")) ? !RESET || reset_by_powerOn : reset_by_powerOn;

    `else
        assign int_reset = reset_by_powerOn;
    `endif  

    `ifdef HOLD_pin
        assign logicOn = !int_reset && !S && intHOLD; 
    `else
        assign logicOn = !int_reset && !S;
    `endif  
`endif  



reg deep_power_down = 0; //updated in "Deep power down" processes

//XIP mode status (XIP=0 XIP mode not selected, XIP=1 XIP mode selected)
reg XIP=0; 
// driven high on XIP_reset sequence, this is the first part of PLRS
reg XIP_rst = 0; 
// driven high on Power reset sequence this is the second part of PLRS
reg power_rst = 0; 
// Power Loss Recovery Sequence required flag 
reg plrs_required = 0; 


reg DoubleTransferRate = 0;
wire read_enable = read.enable || 
                   read.enable_dual || 
                   read.enable_quad || 
                   read.enable_fast || 
                   VolatileReg.enable_VCR_read || 
                   VolatileEnhReg.enable_VECR_read ||
                   stat.enable_SR_read ||
                   PMReg.enable_PMR_read ||
                   `ifdef byte_4
                   ExtAddReg.enable_EAR_read ||
                   `endif
                   `ifdef MEDITERANEO
                   ASP_Reg.enable_ASP_read ||
                   PSWORD_Reg.enable_PSWORD_read || //Nov13
                   ppb.enable_PPBReg_read ||
                   plb.enable_PLBReg_read ||
                   lock.enable_lockReg_read ||
                   lock4kb.enable_lockReg_read ||
                   `endif
                   NonVolatileReg.enable_NVCR_read ||
                   read.enable_ID; 
                

//---------------------------------------
//  Vpp_W signal : write protect feature
//---------------------------------------

assign W_int = Vpp_W_DQ2;

//----------------------------
// CUI decoders istantiation
//----------------------------

`include "include/Decoders.h"




//---------------------------
// Modules instantiations
//---------------------------

Memory          mem (memory_file);

UtilFunctions   f ();

`ifdef MEDT_GPRR
GeneralPurposeRegister GPRR_Reg ();
`endif

Program         prog ();

StatusRegister  stat ();

FlagStatusRegister flag ();

NonVolatileConfigurationRegister  NonVolatileReg (NVConfigReg_default);

VolatileEnhancedConfigurationRegister VolatileEnhReg ();

VolatileConfigurationRegister VolatileReg ();

`ifdef byte_4

    ExtendedAddressRegister ExtAddReg ();

`endif

FlashDiscoveryParameter FlashDiscPar (fdp_file);

Read            read ();        

LockManager     lock (); //DYB

`ifdef MEDT_4KBLocking
    LockManager4KB  lock4kb();
`endif

`ifdef MEDT_PPB
    PPBManager ppb();
    PPBLockBitRegister plb();
`endif

`ifdef MEDT_PASSWORD
    PasswordRegister PSWORD_Reg();
`endif

`ifdef MEDT_ADVANCED_SECTOR
    ASPRegister ASP_Reg();
`endif

ProtectionManagementRegister PMReg(); // instantiated the protection management register -- 

`ifdef timingChecks
 
    `ifdef N25Q256A33E 
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, RESET);
    `elsif N25Q256A33Exxx1y 
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, RESET);
    `elsif  N25Q256A31E 
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, RESET);
    `elsif  N25Q256A13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q256A13Exxx1y
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q256A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q256A11Exxx1y
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q064A13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q064B11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q064B13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q064B31E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, RESET);
    `elsif  N25Q064B33E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, RESET);
    `elsif N25Q064A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25W064A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif  N25Q032A13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q032A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif MEDITERANEO_1_8v    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif MEDITERANEO    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q256A83E    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q256A81E    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q256A83Exxx1y    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q256A73E    
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A11Exxx1y
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A11B
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25W128A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25W128A11B
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A13Exxx1y
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q128A13B
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q016A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q016A13E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `elsif N25Q008A11E
        TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
    `endif

`endif  

`ifdef HOLD_pin

    DualQuadOps     dualQuad (S, C, ck_count,DoubleTransferRate, DQ0, DQ1, Vpp_W_DQ2, HOLD_DQ3); 

`elsif RESET_pin
 
    DualQuadOps     dualQuad (S, C, ck_count,DoubleTransferRate, DQ0, DQ1, Vpp_W_DQ2, RESET_DQ3); 
 
`endif

OTP_memory      OTP (); 


`include "include/PLRSDetectors.h"

DebugModule Debug ();


//----------------------------------
//  Signals for latching control
//----------------------------------
reg rescue_seq_flag = 0;
integer iCmd, iAddr, iData, iDummy, iXIP_count, iPow_res;
reg dtr_dout_started; // it is set after negedge C where 1st bit was outputted (used to prevent DUT from starting data output on posedge C)

always @(negedge S) begin : CP_latchInit

    disable VolatileReg.READ_VCR;//test Jan17

    if (!XIP) latchingMode = "C";  
    
    ck_count = 0;
    iCmd = cmdDim - 1;
    addrLatch = 'h0;  //etv
    `ifdef byte_4
    //if (prog.enable_4Byte_address || cmd=='h0E || cmd=='hBE || cmd=='hEE) 
    if (prog.enable_4Byte_address || cmd=='h0E || cmd=='hE3) 
        iAddr = addrDimLatch4 - 1;
    else 
        iAddr = addrDimLatch - 1;
    `else
    if (cmd=='hE2)
        iAddr = addrDimLatch4 - 1;
    else
     iAddr = addrDimLatch - 1; 
    `endif
    if (XIP && (cmd==8'h13 || cmd==8'h0C || cmd==8'h3C || cmd==8'hBC || cmd==8'h6C || cmd==8'hEC)) begin // XIP activated by 4byte addressing commands
      iAddr = addrDimLatch4 - 1;
    end
    iData = dataDim - 1;

    iDummy = dummyDimEff - 1;
    dtr_dout_started = 0;   //DTR
end


always @(posedge C) if(logicOn) begin
    ck_count <= ck_count + 1;

end

always @(posedge read_enable) begin
  ck_count = 0;
end


//-------------------------
// Latching commands
//-------------------------


event cmdLatched;


always @(C) if(logicOn && latchingMode=="C" && protocol=="extended") begin : CP_latchCmd
  `ifdef MEDITERANEO
  if (((C==0) && (VolatileEnhReg.VECR[5] == 0) && (iCmd != 7)) || (C == 1)) begin 
  `else
  if (C==1) begin  
  `endif
    cmd[iCmd] = DQ0;

    if (iCmd>0)
        iCmd = iCmd - 1;
    else if(iCmd==0) begin
        latchingMode = "N";
        `ifdef MEDITERANEO
            if (prog.enable_4Byte_address || cmd=='h0E || cmd=='hE3 || cmd=='hE2) 
                iAddr = addrDimLatch4 - 1;
            else 
                iAddr = addrDimLatch - 1;
        `endif
        -> cmdLatched;
    end    
 end        
end

always @(C) if(logicOn && latchingMode=="C" && protocol=="dual") begin : CP_latchCmdDual
      `ifdef MEDITERANEO
   if (((C==0) && (VolatileEnhReg.VECR[5] == 0) && (iCmd != 7)) || (C == 1)) begin 
   `else
  if (C==1) begin  
   `endif

    cmd[iCmd] = DQ1;
    cmd[iCmd-1] = DQ0;

    if (iCmd>=3)
        iCmd = iCmd - 2;
    else if(iCmd==1) begin
        latchingMode = "N";
        `ifdef MEDITERANEO
            if (prog.enable_4Byte_address || cmd=='h0E || cmd=='hE3 || cmd=='hE2) 
                iAddr = addrDimLatch4 - 1;
            else 
                iAddr = addrDimLatch - 1;
        `endif
        -> cmdLatched;
         end
     //end     
  end       
end


`ifdef HOLD_pin
always @(C) if(logicOn && latchingMode=="C" && protocol=="quad") begin : CP_latchCmdQuad
  `ifdef MEDITERANEO
  if (((C==0) && (VolatileEnhReg.VECR[5] == 0) && (iCmd != 7)) || (C == 1)) begin 
  `else
  if (C==1) begin  
  `endif
    cmd[iCmd] = HOLD_DQ3;
    cmd[iCmd-1] = Vpp_W_DQ2;
    cmd[iCmd-2] = DQ1;
    cmd[iCmd-3] = DQ0;

    if (iCmd>=7)
        iCmd = iCmd - 4;
    else if(iCmd==3) begin
        latchingMode = "N";
        `ifdef MEDITERANEO
            if (prog.enable_4Byte_address || cmd=='h0E || cmd=='hE3 || cmd=='hE2) 
                iAddr = addrDimLatch4 - 1;
            else 
                iAddr = addrDimLatch - 1;
        `endif
        -> cmdLatched;
    end    
  end      
end

`elsif RESET_pin

always @(C) if(logicOn && latchingMode=="C" && protocol=="quad") begin : CP_latchCmdQuad
  if (C==1) begin 
  // if (((C==0) && (VolatileEnhReg.VECR[5] == 0) && (iCmd != 7)) || (C == 1)) begin 

    cmd[iCmd] = RESET_DQ3;
    cmd[iCmd-1] = Vpp_W_DQ2;
    cmd[iCmd-2] = DQ1;
    cmd[iCmd-3] = DQ0;

    if (iCmd>=7)
        iCmd = iCmd - 4;
    else if(iCmd==3) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
  end        
end

`endif
//-------------------------
// Latching address
//-------------------------


event addrLatched;


always @(C) if (logicOn && latchingMode=="A") begin : CP_latchAddr
  if (C==1 || DoubleTransferRate==1 || 
    (C==0 && (cmd=='h0D || cmd=='h3D || cmd=='hBD || cmd=='h6D || cmd=='hED || cmd=='h0E || cmd=='h39 || cmd=='hBE || cmd=='h3A || cmd=='hEE)
    // (C==0 && (cmd=='h0D || cmd=='h3D || cmd=='hBD || cmd=='h6D || cmd=='hED || cmd=='h0E || cmd=='h3E || cmd=='hBE || cmd=='h6E || cmd=='hEE)
    && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately following negedge S in XIP mode and also in negedge of DTR mode and when the command is (address and data in DTR mode ('h0D,'h3D,'h6D) 

    addrLatch[iAddr] = DQ0;
    if (iAddr>0)
        iAddr = iAddr - 1;
    else if(iAddr==0) begin
        latchingMode = "N";
        `ifdef byte_4
        if ((!prog.enable_4Byte_address) && (cmd != 'h13) && (cmd != 'h0C) && (cmd != 'h3C) && (cmd != 'h6C) && (cmd != 'h0E) && (cmd != 'hE0) && (cmd !='h12) && (cmd != 'hE3) &&
             //cmd != 'hE1 && cmd != 'hE2 ) 
             cmd != 'hE1 && cmd != 'hE2  && cmd != 'hDC && cmd != 'h21)   
            begin  
            addr = {ExtAddReg.EAR[EARvalidDim-1:0],addrLatch[addrDimLatch-1:0]};
                    -> Debug.x0;
            end
          //else if(prog.enable_4Byte_address==1) 
          else if(prog.enable_4Byte_address==1 || cmd != 'h13) 
            begin
                addr = addrLatch[addrDimLatch4-1:0];
            -> Debug.x1;
            end
          else begin
              addr = addrLatch[addrDim-1:0];
                            ->Debug.x2;
              end
        `else
        addr = addrLatch[addrDim-1:0];
        `endif
        -> addrLatched;
    end
  end
end



always @(C) if (logicOn && latchingMode=="I") begin : CP_latchAddrDual
  if (C==1 ||DoubleTransferRate==1 || (C==0 && (cmd=='h0D || cmd=='h3D ||
    cmd=='hBD || cmd=='h0E || cmd=='h39 || cmd=='hBE) && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately follwing negedge S in XIP mode and also in negedge of DTR mode and when the command is (address and data in DTR mode ('hBD) 
    // cmd=='hBD || cmd=='h0E || cmd=='h3E || cmd=='hBE) && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately follwing negedge S in XIP mode and also in negedge of DTR mode and when the command is (address and data in DTR mode ('hBD) 

    addrLatch[iAddr] = DQ1;
    addrLatch[iAddr-1]= DQ0;
    if (iAddr>=3)
        iAddr = iAddr - 2;
    else if(iAddr==1) begin
        latchingMode = "N";
        `ifdef byte_4
            if (!prog.enable_4Byte_address && (cmd != 'hBC && cmd != 'hBE && cmd != 'h3C && cmd != 'h0C && cmd != 'h0E)) begin 
                addr = {ExtAddReg.EAR[EARvalidDim-1:0],addrLatch[addrDimLatch-1:0]};
            end
            else addr = addrLatch[addrDimLatch4-1:0];
        `else
        addr = addrLatch[addrDim-1:0];
        `endif

        -> addrLatched;

    end
  end
end

`ifdef HOLD_pin
always @(C) if (logicOn && latchingMode=="E") begin : CP_latchAddrQuad
  if (C==1 ||DoubleTransferRate==1 || (C==0 && (cmd=='h0D || cmd=='h6D
    ||cmd=='hED || cmd=='h0E || cmd=='h3A ||cmd=='hEE) && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately following negedge S in XIP mode and also in negedge of DTR mode and when the command is (address and data in DTR mode ('hED)
    // ||cmd=='hED || cmd=='h0E || cmd=='h6E ||cmd=='hEE) && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately following negedge S in XIP mode and also in negedge of DTR mode and when the command is (address and data in DTR mode ('hED)

    addrLatch[iAddr] = HOLD_DQ3;
    addrLatch[iAddr-1]= Vpp_W_DQ2;
    addrLatch[iAddr-2]= DQ1;
    addrLatch[iAddr-3]= DQ0;
   
    if (iAddr>=7)
        iAddr = iAddr - 4;

    else if(iAddr==3) begin
        latchingMode = "N";
        `ifdef byte_4
            if (!prog.enable_4Byte_address && (cmd != 'hEC && cmd != 'hEE && cmd != 'h0E && cmd != 'h6C  && cmd != 'h0C  && cmd != 'hE0)) begin 
            addr = {ExtAddReg.EAR[EARvalidDim-1:0],addrLatch[addrDimLatch-1:0]};
                        end
            else begin
            addr = addrLatch[addrDimLatch4-1:0];
            end
        `else
        addr = addrLatch[addrDim-1:0];
        `endif


        -> addrLatched;
    end
  end
end

`elsif RESET_pin
always @(C) if (logicOn && latchingMode=="E") begin : CP_latchAddrQuad
  if (C==1 ||DoubleTransferRate==1 || (C==0 && (cmd=='h0D || cmd=='h6D ||cmd=='hED || cmd=='h0E || cmd=='h6E ||cmd=='hEE) && iAddr!=23 && iAddr!=31)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode, except for negedge C immediately following negedge S in XIP mode

    addrLatch[iAddr] = RESET_DQ3;
    addrLatch[iAddr-1]= Vpp_W_DQ2;
    addrLatch[iAddr-2]= DQ1;
    addrLatch[iAddr-3]= DQ0;
   
    if (iAddr>=7)
        iAddr = iAddr - 4;

    else if(iAddr==3) begin
        latchingMode = "N";
        `ifdef byte_4
        if (!prog.enable_4Byte_address && (cmd != 'hEC)) 
            addr = {ExtAddReg.EAR[EARvalidDim-1:0],addrLatch[addrDimLatch-1:0]};
        else  
            addr = addrLatch[addrDim-1:0];
        `else
        addr = addrLatch[addrDim-1:0];
        `endif

        -> addrLatched;
    end
  end
end

`endif
//-----------------
// Latching data
//-----------------


event dataLatched;
reg dataLatchedr=0;

always @(C) if (logicOn && latchingMode=="D") begin : CP_latchData
    `ifdef MEDITERANEO
  if (((C==0) && (VolatileEnhReg.VECR[5] == 0)) || (C == 1)) begin 
  `else
  if (C==1) begin // ENABLE if posedge C in all modes 
  `endif
    data[iData] = DQ0;

    if (iData>0)begin
        iData = iData-1;
        prog.bitCounter=prog.bitCounter+1;
    end else begin
     if ((cmdRecName=="Write NV Configuration Reg" || cmdRecName=="ASP Write")&& prog.LSByte) begin
        LSdata=data;
         prog.LSByte=0;
     end   
        -> dataLatched;
        dataLatchedr=1;
        $display("  [%0t ns] Data latched: %h", $time, data);
        iData=dataDim-1;
    end    
  end
end






//-----------------
// Latching dummy
//-----------------


event dummyLatched;
event checkProtocol;
event checkProtocolAfterXIPexit;

always @(posedge C) if (logicOn && latchingMode=="Y") begin : CP_latchDummy
#0;
    dummy[iDummy] = DQ0;

    //XIP mode setting
`ifdef XIP_basic

    if(iDummy==dummyDimEff-1 &&  dummy[iDummy]==0) begin

        XIP=1;


    end else if (iDummy==dummyDimEff-1 &&  dummy[iDummy]==1) begin

        if (XIP) begin 
            $display("  [%0t ns] XIP mode exit.", $time);
            -> checkProtocolAfterXIPexit;
        end
    end

//!    end     

 `elsif XIP_Numonyx
 
    if(iDummy==dummyDimEff-1 &&  dummy[iDummy]==0 && VolatileReg.VCR[3]==0) begin
    
        XIP=1; 
       

    end else if (iDummy==dummyDimEff-1 &&  dummy[iDummy]==1) begin
       
        if (XIP) begin 
            $display("  [%0t ns] XIP mode exit.", $time);
            -> checkProtocolAfterXIPexit;
            VolatileReg.VCR[3] = 1;
        end

        XIP=0;
    end    

 `endif  

    if (iDummy>0) begin 
       // if(cmdRecName != "Read Serial Flash Discovery Parameter")
       //     begin
                iDummy = iDummy-1;
       //     end
        end  
        else begin
        -> dummyLatched;
        $display("  [%0t ns] Dummy clock cycles latched .", $time);
        iDummy=dummyDimEff-1;
        ck_count <= #1 0; // avoid race condition with ck_count auto-incrementer @(posedge C)
    end    

end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

event XIP_reset; // Activated XIP memory reset after a controller reset;

event power_reset; // rescue sequence during  power loss when attempting to write Non Volatile configuration Register
///////////////////////////////////////////////////////////////////////////////
// sequence to check for rescue sequence for XIP Memory reset;
///////////////////////////////////////////////////////////////////////////////

always @(power_reset) begin
    plrs_required = 1;
    XIP_rst = 1;
end

time S_high_plrs = 1000;
time S_low_plrs = 1000;
time delta_plrs = 0;

//---------------------------------------------------------------
always
    @S if(S==0) //posedge
    @S if(S==1)
    begin
        S_high_plrs = $time;
    end

always
    @S if(S==1) //negedge
    @S if(S==0)
    begin
        S_low_plrs = $time;
        delta_plrs = $time - S_high_plrs;
        if(rescue_seq_flag==1 && delta_plrs < 50) begin
            $display(" [%0t ps] ==TIMING ERROR== PLRS: tSHSL constraint violated during Power Loss Rescue Sequence ", $time);
        end
    end    
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 

// check dummy clock cycles 
`ifdef MEDT_DUMMY_CYCLES
    `ifdef TIMING_166
time CDeltaBy2;
integer fO; //calculated operating frequency upon latching of dummy cycles
always @(dummyLatched) begin
    CDeltaBy2 = timeCheck.C_high - timeCheck.C_low;
    fO = 1000 / (CDeltaBy2 * 2);
    $display("[%0t]---DEBUG--- 4byte_aligned cmd = %0s fO = %0d, dummy = %0d", $time, cmdRecName, fO, dummyDimEff);
    if (N25Qxxx.addr[1:0] == 2'b00) begin : max_f_chk_4b_aligned
        case(dummyDimEff)
        1: begin
            if (((fO>94) && (cmdRecName == "Read Fast")) ||
                ((fO>94) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>60) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>60) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>94) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>94) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>43) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //1 dummy cycles
        2: begin
            if (((fO>112) && (cmdRecName == "Read Fast")) ||
                ((fO>112) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>77) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>77) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>112) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>112) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>60) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //2 dummy cycles
        3: begin
            if (((fO>129) && (cmdRecName == "Read Fast")) ||
                ((fO>129) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>94) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>94) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>129) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>129) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>77) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //3 dummy cycles
        4: begin
            if (((fO>146) && (cmdRecName == "Read Fast")) ||
                ((fO>146) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>112) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>112) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>146) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>146) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>94) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //4 dummy cycles
        5: begin
            if (((fO>163) && (cmdRecName == "Read Fast")) ||
                ((fO>163) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>129) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>129) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>112) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //5 dummy cycles
        6: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>146) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>146) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>129) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //6 dummy cycles
        7: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>163) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>163) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>146) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //7 dummy cycles
        8: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //8 dummy cycles
        9: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //9 dummy cycles
        default: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //default dummy cycles
        endcase
    end //max_f_chk_4b_aligned
    else begin : max_f_chk_non4b_aligned
        case(dummyDimEff)
        1: begin
            if (((fO>94) && (cmdRecName == "Read Fast")) ||
                ((fO>79) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>60) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>60) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>44) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>44) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>39) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //1 dummy cycles
        2: begin
            if (((fO>112) && (cmdRecName == "Read Fast")) ||
                ((fO>97) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>77) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>77) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>61) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>61) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>48) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //2 dummy cycles
        3: begin
            if (((fO>129) && (cmdRecName == "Read Fast")) ||
                ((fO>106) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>86) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>86) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>78) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>78) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>58) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //3 dummy cycles
        4: begin
            if (((fO>146) && (cmdRecName == "Read Fast")) ||
                ((fO>115) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>97) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>97) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>97) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>97) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>69) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //4 dummy cycles
        5: begin
            if (((fO>162) && (cmdRecName == "Read Fast")) ||
                ((fO>125) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>106) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>106) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>106) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>106) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>78) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //5 dummy cycles
        6: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>134) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>115) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>115) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>115) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>115) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>86) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //6 dummy cycles
        7: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>143) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>125) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>125) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>125) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>125) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>97) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //7 dummy cycles
        8: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>152) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>134) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>134) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>134) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>134) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>106) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //8 dummy cycles
        9: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>162) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>143) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>143) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>143) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>143) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>115) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //9 dummy cycles
        10: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>152) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>152) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>152) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>152) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>125) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //10 dummy cycles
        11: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>162) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>162) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>134) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //11 dummy cycles
        12: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>143) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //12 dummy cycles
        13: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>152) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //13 dummy cycles
        14: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>162) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //14 dummy cycles
        default: begin
            if (((fO>166) && (cmdRecName == "Read Fast")) ||
                ((fO>166) && (cmdRecName == "Dual Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Dual Command Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Output Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad I/O Fast Read")) ||
                ((fO>166) && (cmdRecName == "Quad Command Fast Read")))
                    $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        end //default dummy cycles
        endcase
    end //max_f_chk_non4b_aligned
end
    `else //TIMING_133
    time CDeltaBy2;
    integer fO; //calculated operating frequency upon latching of dummy cycles
    always @(dummyLatched) begin
        CDeltaBy2 = timeCheck.C_high - timeCheck.C_low;
        fO = 1000 / (CDeltaBy2 * 2);
        //$display("---fO--- %d @ %0t", fO, $time); 
        case (dummyDimEff)

            1: begin

                if(((fO>94) && (cmdRecName=="Read Fast")) || 
                  ((fO>88) &&  (cmdRecName=="Dual Output Fast Read")) ||
                  ((fO>60) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
                  ((fO>69) && (cmdRecName=="Quad Output Fast Read")) ||
                  ((fO>41) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns]  ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
            
               end

            2: begin

                if(((fO>112) && (cmdRecName=="Read Fast")) ||
                  ((fO>97) && (cmdRecName=="Dual Output Fast Read")) ||
                  ((fO>77) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
                  ((fO>78) && (cmdRecName=="Quad Output Fast Read")) ||
                  ((fO>50) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
            
               end

            3: begin
                 
                   if(((fO>129) && (cmdRecName=="Read Fast")) ||
                     ((fO>106) && (cmdRecName=="Dual Output Fast Read")) ||
                     ((fO>88) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) || 
                     ((fO>88) && (cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>60) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
               end

            4 : begin
                 
                   if(((fO>133) && (cmdRecName=="Read Fast")) ||
                     ((fO>115) && (cmdRecName=="Dual Output Fast Read")) ||
                     ((fO>97) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>69) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
               end

            
            5 : begin
                 
                   if(((fO>133) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read")) ||
                     ((fO>125) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>106) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
               end
            
            6 : begin
                   if(((fO>133) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read")) ||
                     ((fO>105) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>80) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
                end
            
            7 : begin

                   if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>86) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
                end
            8 : begin
                   if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>95) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
                end
            9 : begin
                   if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                     ((fO>105) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
                end
            10 : begin
                   if((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read" ||
                     cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read"))
                   $display("  [%0t ns] ==WARNING== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
                end
                
            default : begin end
        endcase
    end
    `endif //TIMING_166
`else
time CDeltaBy2;
integer fO; //calculated operating frequency upon latching of dummy cycles
always @(dummyLatched) begin
    CDeltaBy2 = timeCheck.C_high - timeCheck.C_low;
    fO = 1000 / (CDeltaBy2 * 2);
    //$display("---fO--- %d @ %0t", fO, $time); 
    case (dummyDimEff)

        1: begin

            if(((fO>90) && (cmdRecName=="Read Fast")) || 
              ((fO>80) &&  (cmdRecName=="Dual Output Fast Read")) ||
              ((fO>50) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
              ((fO>43) && (cmdRecName=="Quad Output Fast Read")) ||
              ((fO>30) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns]  ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
        
           end

        2: begin

            if(((fO>100) && (cmdRecName=="Read Fast")) ||
              ((fO>90) && (cmdRecName=="Dual Output Fast Read")) ||
              ((fO>70) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
              ((fO>60) && (cmdRecName=="Quad Output Fast Read")) ||
              ((fO>40) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
        
           end

        3: begin
             
               if(((fO>108) && (cmdRecName=="Read Fast")) ||
                 ((fO>100) && (cmdRecName=="Dual Output Fast Read")) ||
                 ((fO>80) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) || 
                 ((fO>75) && (cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>50) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
           end

        4 : begin
             
               if(((fO>108) && (cmdRecName=="Read Fast")) ||
                 ((fO>105) && (cmdRecName=="Dual Output Fast Read")) ||
                 ((fO>90) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>60) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
           end

        
        5 : begin
             
               if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read")) ||
                 ((fO>100) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>70) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
           end
        
        6 : begin
               if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read")) ||
                 ((fO>105) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>80) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
            end
        
        7 : begin

               if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>86) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
            end
        8 : begin
               if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>95) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
            end
        9 : begin
               if(((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fO>105) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
            end
        10 : begin
               if((fO>108) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read" || cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read" ||
                 cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read"))
               $display("  [%0t ns] ==WARNING== Dummy clock number %d is not sufficient for the operating frequency %d. The memory reads wrong data",$time,dummyDimEff,fO);
            end
            
        default : begin end
    endcase
end
`endif

 `ifdef Stack512Mb
 //------------------------------
 // Calculating device select during stacked die
 // die active indicates the die selected
 //------------------------------
 
 always@(addrLatched) begin
   if((prog.enable_4Byte_address == 1) || (NonVolatileReg.NVCR[0] == 0)) begin
     if(rdeasystacken == addrLatch[addrDim +1: addrDim]) begin
       die_active = 1;
     end
     else begin
       die_active = 0;
     end
   end
   else begin
     if(rdeasystacken == ExtAddReg.EAR[1:0]) begin
       die_active = 1;
     end
     else begin
       die_active = 0;
     end
   end
 end
 
 `endif


//------------------------------
// Commands recognition control
//------------------------------


event codeRecognized, seqRecognized, startCUIdec;








always @(cmdLatched) fork : CP_cmdRecControl

    -> startCUIdec; // i CUI decoders si devono attivare solo dopo
                    // che e' partito il presente processo
                    // NB: l'attivazione dell'evento startCUIdec fa partire i CUIdec
                    // immediatamente (nello stesso delta time in cui si attiva l'evento),
                    // e non nel delta time successivo


    begin : ok
        @(codeRecognized or seqRecognized) 
          disable error;
    end

    ///////////////////////////////////////////////////////  
     // adding to fix the 4 byte address problem
     // if the cmd is 4 byte address,the counter for address
     // is reinitialised to 32 bit. // added  
     ///////////////////////////////////////////////////////
 
    begin
         
         if (cmd == 'h13 || cmd  == 'h0C || cmd == 'h3C || cmd == 'hBC || 
           // cmd == 'h6C ||  cmd == 'h0E ||  cmd == 'h3E || cmd == 'hBE || 
           cmd == 'h6C ||  cmd == 'h0E ||  cmd == 'h39 || cmd == 'hBE || 
           // cmd == 'h6E || cmd == 'hEE || cmd == 'hEC || cmd == 'h10 || 
           cmd == 'h3A || cmd == 'hEE || cmd == 'hEC || cmd == 'h10 ||
           `ifdef MEDT_4READ4D
//               cmd=='hE7 ||
           `endif
           `ifdef MEDT_SubSect32K4byte
               cmd=='h5C ||
           `endif
           `ifdef MEDT_QIEFP_4byte
               cmd=='h3E ||
           `endif
           `ifdef PP_4byte
               cmd=='h12 ||
           `endif        
           `ifdef SE_4byte 
               cmd=='hDC ||
           `endif     
           `ifdef SSE_4byte 
               cmd=='h21 ||
           `endif     
           `ifdef QIFP_4byte 
               cmd=='h34 ||
           `endif     
           `ifdef QIEFP_38
            //   cmd=='h38 ||
           `endif        
           `ifdef MEDT_DYB_4byte
               cmd=='hE0 || cmd=='hE1 || cmd=='hE2 || cmd=='hE3 ||
           `endif
           cmd=='h11 || cmd=='h27 )
           `ifdef byte_4
           begin
            iAddr = addrDimLatch4 - 1;
           end
            `else
            iAddr = addrDimLatch - 1;
        `endif
          else if(cmd == 'h5A) begin
            iAddr = addrDimLatch - 1;
          end
    end 
     
    ///////////////////////////////////////////////////////    
     

    
    
    begin : error
        #0; 
        #1; //wait until CUI decoders execute recognition process (2 delta time maximum)
            //questo secondo ritardo si puo' anche togliere (perche' il ritardo max e' 1 delta)
            if (busy)  begin 
            $display("[%0t ns] **WARNING** Device is busy. Command not accepted.", $time);
                        end
            `ifdef PowDown
         else if (deep_power_down)
            $display("[%0t ns] **WARNING** Deep power down mode. Command not accepted.", $time);
            `endif 
        else if (!ReadAccessOn || !WriteAccessOn || !PollingAccessOn) 
            $display("[%0t ns] **WARNING** Power up is ongoing. Command not accepted.", $time);    
        else if (!busy)  
                //$display("[%0t ns] **ERROR** Command Not Recognized.", $time);
                $display("[%0t ns] **WARNING** Command Not Recognized. %0h %d %d", $time, cmd, rdeasystacken, rdeasystacken2);
        disable ok;
    end    

join



//------------------------------------
// Power Up, Fast POR & Voltage check
//------------------------------------



//--- Reset internal logic (latching disabled when Vcc<Vcc_wi)

assign Vcc_L1 = (Vcc>=Vcc_wi) ?  1 : 0 ;

always @Vcc_L1 
  if (reset_by_powerOn && Vcc_L1)
    reset_by_powerOn = 0;
  else if (!reset_by_powerOn && !Vcc_L1) 
    reset_by_powerOn = 1;
    


assign Vcc_L2 = (Vcc>=Vcc_min) ?  1 : 0 ;

assign Vcc_L3 = (Vcc >= Vcc_min) ? 0 : 1;


//event checkProtocol;

event checkHoldResetEnable;

event checkAddressMode;

event checkAddressSegment;

event checkDummyClockCycle;

//--- Write access

reg WriteAccessCondition = 0;
reg dummySetByNVCR = 0;


//----------------------------
// Power Up  
//----------------------------


always @Vcc_L2 if(Vcc_L2 && PollingAccessOn==0 && ReadAccessOn==0 && WriteAccessCondition==0) fork : CP_powUp_FullAccess
    
    begin : p1
      $display("[%0t ns] ==INFO== Power up: polling allowed.",$time );
      PollingAccessOn=1;
      
      #full_access_power_up_delay;
      $display("[%0t ns] ==INFO== Power up: device fully accessible.",$time );
      ReadAccessOn=1;
      WriteAccessCondition=1;
      // starting protocol defined by NVCR
      -> checkProtocol; 
      //checking hold_enable defined by NVCR
      -> checkHoldResetEnable;
      -> checkDummyClockCycle;
      //checking address mode
      `ifdef byte_4
      -> checkAddressMode;
      //checking address segment
      -> checkAddressSegment;
      `endif
        prog.disableOperations;
      if (rescue_seq_flag == 1)
          -> power_reset;
      disable p2;
    end 

    begin : p2
      @Vcc_L2 if(!Vcc_L2)
        disable p1;
    end

join    

always @(checkDummyClockCycle) begin
    // if(NonVolatileReg.NVCR[15:12]=='b0000) dummyDimEff=15;
//    if(NonVolatileReg.NVCR[15:12]=='b0000) dummyDimEff=8;
//    else if(NonVolatileReg.NVCR[15:12]=='b1111) dummyDimEff=8;
//    else  dummyDimEff=NonVolatileReg.NVCR[15:12];
        if(NonVolatileReg.NVCR[15:12]=='b0000 || NonVolatileReg.NVCR[15:12]=='b1111) begin
            dummySetByNVCR=0;
            dummyDimEff=8;
        end 
        else begin
            dummySetByNVCR=1;
            dummyDimEff=NonVolatileReg.NVCR[15:12];
        end
end

always @(checkHoldResetEnable) begin

 if (NonVolatileReg.NVCR[4]==1) NVCR_HoldResetEnable=1;
 else NVCR_HoldResetEnable=0;

end

`ifdef byte_4

always @(checkAddressMode) begin

 `ifdef start_in_byte_4   
     prog.enable_4Byte_address=1;
 `else    
 if (NonVolatileReg.NVCR[0]==0)  begin
      prog.enable_4Byte_address=1;
      $display("[%0t ns] ==INFO== 4-byte address mode selected",$time);
 end else begin 
       prog.enable_4Byte_address=0;
       $display("[%0t ns] ==INFO== 3-byte address mode selected",$time);
 end
 `endif

end

//always @(checkAddressSegment) if (prog.enable_4Byte_address==0) begin
always @(checkAddressSegment) begin

 if (NonVolatileReg.NVCR[1]==0) begin
 
    ExtAddReg.EAR[EARvalidDim-1:0]={EARvalidDim{1'b1}};
    if(prog.enable_4Byte_address==0) $display("[%0t ns] ==INFO== Top 128M selected",$time);
 
 end else begin
    
    ExtAddReg.EAR[EARvalidDim-1:0]=0;
    if(prog.enable_4Byte_address==0) $display("[%0t ns] ==INFO== Bottom 128M selected",$time);
    
 end
 
end 

`endif
assign WriteAccessOn =PollingAccessOn && ReadAccessOn && WriteAccessCondition;


always @(checkProtocol) begin
if (NonVolatileReg.NVCR[3]==0) protocol="quad";
      else if (NonVolatileReg.NVCR[2]==0) protocol="dual";
      else if(NonVolatileReg.NVCR[3]==1 && NonVolatileReg.NVCR[2]==1) protocol="extended";
      $display("[%0t ns] ==INFO== Protocol selected is %0s",$time, protocol);
      

 

       case (NonVolatileReg.NVCR[11:9])
       'b000 : begin
                XIP=1;
                protocol="extended";
                cmdRecName="Read Fast";
               end
        
       'b001 : begin 
                 XIP=1;
                 cmdRecName="Dual Output Fast Read"; 
                 protocol="extended";
               end
       'b010 : begin
                 XIP=1;
                 cmdRecName="Dual I/O Fast Read";
                 protocol="dual";
               end
 
       'b011 : begin
                 XIP=1;
                 cmdRecName="Quad Output Read"; 
                 protocol="extended";
               end

       'b100 :  begin
                 XIP=1;
                 cmdRecName="Quad I/O Fast Read"; 
                 protocol="quad";
               end

       'b111: XIP=0;
         default : XIP=0;
       endcase  
       
       `ifdef MEDITERANEO
       DoubleTransferRate = !NonVolatileReg.NVCR[5];
  `endif
      $display("[%0t ps] ==INFO== %0s Transfer Rate selected", $time, (DoubleTransferRate ? "Double" : "Single"));
      
end

// When we exit XIP we should check what protocol we should fall to
always @(checkProtocolAfterXIPexit) begin
    if(VolatileEnhReg.VECR[7] == 0)
        protocol="quad";
    else if(VolatileEnhReg.VECR[6] == 0)
        protocol="dual";
    else if(NonVolatileReg.NVCR[3]==0)
        protocol="quad";
    else if(NonVolatileReg.NVCR[2]==0)
        protocol="dual";
    else if(NonVolatileReg.NVCR[3:2] == 'b11)
        protocol="extended";
    $display("[%0t ns] ==INFO== Protocol selected is %0s",$time, protocol);
end

//`ifdef MEDT_4READ4D
//    always @(checkProtocol) begin
//        if(VolatileReg.VCR[3] == 0)
//        begin
//            XIP=1;
//            cmdRecName="Word Read Quad I/O";
//            protocol="extended";
//        end
//        else
//        begin
//            XIP=0;
//            cmdRecName="Word Read Quad I/O";
//            protocol="extended";
//        end
//    end    
//`endif

//---Dummy clock cycle

always @VolatileReg.VCR begin
    if (VolatileReg.VCR[7:4]=='b0000) dummyDimEff=8;
    else if (VolatileReg.VCR[7:4]=='b1111) dummyDimEff=8;
    else dummyDimEff=VolatileReg.VCR[7:4];

end


//--- Voltage drop (power down)

always @Vcc_L1 if (!Vcc_L1 && (PollingAccessOn|| ReadAccessOn || WriteAccessCondition)) begin : CP_powerDown
    $display("[%0t ns] ==INFO== Voltage below the threshold value: device not accessible.", $time);
    ReadAccessOn=0;
    WriteAccessCondition=0;
    PollingAccessOn=0;
    prog.Suspended=0; //the suspended state is reset  
    
end    




//--- Voltage fault (used during program and erase operations)

event voltageFault; //used in Program and erase dynamic check (see also "CP_voltageCheck" process)

assign VccOk = (Vcc>=Vcc_min && Vcc<=Vcc_max) ?  1 : 0 ;

always @VccOk if (!VccOk) ->voltageFault; //check is active when device is not reset
                                          //(this is a dynamic check used during program and erase operations)
        






//---------------------------------
// Vpp (auxiliary voltage) checks
//---------------------------------

//VPP pin Enhanced Supply Voltage feature not implemented



                   

//-----------------
// Read execution
//-----------------


reg [addrDim-1:0] readAddr;
reg bitOut='hZ;
reg [1:0] firstNVCR = 1;
reg [1:0] firstASP = 1;
reg [1:0] firstPSWORD = 0;

event sendToBus;
event sendToBus_stack;


// values assumed by DQ0 and DQ1, when they are not forced
assign DQ0 = 1'bZ;
assign DQ1 = 1'bZ;


//  DQ1 : release of values assigned with "force statement"
always @(posedge S) begin
        quadMode  = 0; // reset the quadmode on every posedge of S
        `ifdef MEDITERANEO
      //      cmd = 'hFF;
            firstPSWORD = 0;
        `endif    

        #tSHQZ release DQ1; 
        if (protocol=="dual" || read.enable_dual) release Vpp_W_DQ2;
        if (protocol=="quad" || read.enable_quad) begin 
            
                        release Vpp_W_DQ2;
                        `ifdef RESET_pin
                        release RESET_DQ3;
                        `elsif HOLD_pin
                        release HOLD_DQ3;
                        `endif
        end
        if(DoubleTransferRate == 1) release DQ0;

        firstNVCR = 1; // resets to default value
    `ifdef MEDT_ADVANCED_SECTOR
        firstASP = 1;
    `endif

end        
// effect on DQ1 by HOLD signal
`ifdef HOLD_pin
    
    reg temp;
    reg temp1;
    //need to recode this 
//    always @(intHOLD) if(intHOLD===0) begin : CP_HOLD_out_effect 
//        begin : out_effect
//            if(cmdRecName=="Dual Output Fast Read") begin
//            temp = DQ0;
//            temp1 = DQ1;
//            #tHLQZ;
//            disable guardian;
//            release DQ1;
//            release DQ0;
//            @(posedge intHOLD) #tHHQX begin 
//                force DQ1=temp1;
//                force DQ0=temp;
//            end
//            ->Debug.x7;
//            end else begin
//            temp = DQ1;
//            #tHLQZ;
//            disable guardian;
//            release DQ1;
//             @(posedge intHOLD) #tHHQX force DQ1=temp;
//            end
//
//        end  
//
//        begin : guardian 
//            @(posedge intHOLD)
//            ->Debug.x8;
//            disable out_effect;
//        end
//    end //CP_HOLD_out_effect   

    always @(negedge intHOLD) begin : CP_HOLD_out_effect_n
    begin : out_effect_n
        if(cmdRecName=="Dual Output Fast Read") begin
            temp1=DQ1;
            temp=DQ0;
            #tHLQZ;
            disable guardian_n;
           // release DQ1;
           // release DQ0;
        end else begin
            temp = DQ1;
            #tHLQZ;
            disable guardian_n;
        end
    end    
    begin: guardian_n
    end
end

    always @(posedge intHOLD) begin : CP_HOLD_out_effect_p
    begin : out_effect_p
        if(cmdRecName=="Dual Output Fast Read") begin
            force DQ1 = temp1;
            force DQ0 = temp;
        end
    end    
end     

`endif    



// read with DQ1 out bit

always @(negedge C) if(logicOn && protocol=="extended") begin : CP_read
#1;
    singleIO_output(ck_count * ((DoubleTransferRate || ((cmd == 'h0D || cmd == 'h0E) ? 1:0))+1)); // 2*ck_count if DTR and cmd is 0D, O.W. 1*ck_count
end

always @(posedge C) if(logicOn) begin
#1;
    if ((DoubleTransferRate || ((cmd == 'h0D || cmd == 'h0E) ? 1:0)) && protocol=="extended" && dtr_dout_started) begin
	singleIO_output(2*(ck_count -1) + 1);
    end
    if ((DoubleTransferRate || ((cmd == 'h0D || cmd == 'h0E) ? 1:0)) && !dtr_dout_started && latchingMode == "N") begin
	// Difference is caused by fact that in DTR, last instr/addr/data bit is latched on negedge clk, but last dummy bit is latched on posedge clk
	// So, in read instr that do not need dummy cycles, data output starts on the negedge following this posedge clk -> do not increment counter
    end else begin
	//RK ck_count = ck_count + 1; // combined 2 always blks to avoid race conditions
    end
end


reg goReadId = 0;
reg [7:0] dataOut_temp;

task singleIO_output;
input [2:0] bit_count;
begin
  #1;
    // $display("In singleIO_output: ck_count=%h", bit_count, $time);
    if(read.enable==1) begin    
        `ifdef MEDITERANEO
        //if((N25Qxxx.DoubleTransferRate == 1 && ((bit_count == 1 && read.succeedingReads == 0) || (bit_count == 0 && read.succeedingReads == 1)))
        if((N25Qxxx.DoubleTransferRate == 1 && ((bit_count == 0 && read.succeedingReads == 0) || (bit_count == 0 && read.succeedingReads == 1)))
            || (N25Qxxx.DoubleTransferRate == 0 && bit_count == 0)) begin
            read.succeedingReads = 1;
        `else
        if(bit_count==0) begin
        `endif
            readAddr = mem.memAddr;
            mem.readData(dataOut); //read data and increments address
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

    end else if(read.enable_fast==1) begin    
        if(bit_count==0) begin
            readAddr = mem.memAddr;
            mem.readData(dataOut); //read data and increments address
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;
    
    end else if (read.enable_rsfdp==1) begin
       
        if(bit_count==0) begin
                readAddr = FlashDiscPar.fdpAddr;
                FlashDiscPar.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
        end
          
         #tCLQX
          bitOut = dataOut[dataDim-1-bit_count];
          -> sendToBus;


    end else if (stat.enable_SR_read==1) begin
   //    `ifdef MEDITERANEO
     //   if((bit_count==2 && DoubleTransferRate == 1) || (bit_count==0 && DoubleTransferRate==0)) begin
     //  `else
        if(bit_count==0) begin
     //  `endif
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
       
       #tCLQX
     //  `ifdef MEDITERANEO
     //   if(DoubleTransferRate == 1) begin
     //   bitOut = dataOut[dataDim-1-bit_count-2];
  //  end else 
    //`endif
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

     end else if (flag.enable_FSR_read==1) begin
        
        if(bit_count==0) begin

            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
       
       #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
       if(bit_count==0) begin

            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
       end    
       
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

    // added   to check for PMR register read
     end else if (PMReg.enable_PMR_read==1) begin
        
        if(bit_count==0) begin
            dataOut = PMReg.PMR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

     end else if (flag.enable_FSR_read==1) begin
        
        if(bit_count==0) begin
            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;    
     end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
       if(bit_count==0) begin

            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        // $display("In VECR Read: dataOut=%h, bitOut=%h ", dataOut, bitOut, $time);
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;
    

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
     
 
        if(bit_count==0 && firstNVCR == 1) begin
            
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            firstNVCR=0;
          
        end else if(bit_count==0 && firstNVCR == 0) begin
         
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           firstNVCR=2;
        end
        else if(bit_count==0  && firstNVCR == 2)begin
           dataOut = 0;
           f.out_info(readAddr, dataOut);
        end
       
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

`ifdef MEDT_GPRR
     end else if (GPRR_Reg.enable_GPRR_read==1) begin
        if (bit_count == 0) begin
          if (GPRR_Reg.GPRR_location != 0 && GPRR_Reg.GPRR_location >= 64) begin
            dataOut = 8'h00;
            f.out_info(readAddr, dataOut);
          end else begin   
            dataOut = GPRR_Reg.GPRR[(GPRR_Reg.GPRR_location*8) +: 8];
            f.out_info(readAddr, dataOut);
          end
          if(GPRR_Reg.GPRR_location < 65) begin
            GPRR_Reg.GPRR_location = GPRR_Reg.GPRR_location + 1; 
          end
        end
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;
    `endif        

`ifdef MEDT_PASSWORD
     end else if (PSWORD_Reg.enable_PSWORD_read==1) begin
        if (bit_count == 0 && firstPSWORD == 1) begin
          if(PSWORD_Reg.PSWORD_location < 9) begin
            PSWORD_Reg.PSWORD_location = PSWORD_Reg.PSWORD_location + 1; 
          end
          if (PSWORD_Reg.PSWORD_location != 0 && PSWORD_Reg.PSWORD_location >= 8) begin
            dataOut = 8'h00;
            f.out_info(readAddr, dataOut);
          end else begin   
            dataOut = PSWORD_Reg.PSWORD[(PSWORD_Reg.PSWORD_location*8) +: 8];
            f.out_info(readAddr, dataOut);
          end
          if(ASP_Reg.ASP[2] == 0) dataOut = 'hff;
        end else if(bit_count == 0 && firstPSWORD == 0) begin
          firstPSWORD = 1;
          dataOut = PSWORD_Reg.PSWORD[(PSWORD_Reg.PSWORD_location*8) +: 8];
          f.out_info(readAddr, dataOut);
        end  

        if(PSWORD_Reg.passwordReadNotAllowed==1) begin
            dataOut = 'hzz;
        end

        #tCLQX
        
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;
    `endif        

`ifdef MEDT_ADVANCED_SECTOR
     end else if (ASP_Reg.enable_ASP_read==1) begin
 
        if(bit_count==0 && firstASP == 1) begin
            
            dataOut = ASP_Reg.ASP[7:0];
            f.out_info(readAddr, dataOut);
            firstASP=0;
          
        end else if(bit_count==0 && firstASP == 0) begin
         
           dataOut = ASP_Reg.ASP[15:8];
           f.out_info(readAddr, dataOut);
           firstASP=2;
        end
        else if(bit_count==0  && firstASP == 2)begin
           dataOut = 0;
           f.out_info(readAddr, dataOut);
        end
       
        #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;
`endif
 

  `ifdef byte_4

  //modificare 
   end else if (ExtAddReg.enable_EAR_read==1) begin
        
        if(ck_count==0) begin
        
            dataOut = ExtAddReg.EAR[7:0];
            f.out_info(readAddr, dataOut);
            
        end
       
        #tCLQX
        //bitOut = dataOut[dataDim-1-ck_count];
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

   `endif   
   `ifdef MEDT_4KBLocking
   end else if (lock.enable_lockReg_read==1 || lock4kb.enable_lockReg_read==1) begin
   `else    
   end else if (lock.enable_lockReg_read==1) begin
   `endif
          if((bit_count==0 && N25Qxxx.DoubleTransferRate==0) ||
             (bit_count==2 && N25Qxxx.DoubleTransferRate==1)) begin 
              readAddr = f.sec(addr);
              `ifdef MEDT_4KBLocking
                  if(readAddr == 'h0 || readAddr == 'h1ff) begin
                      readAddr = f.sub(addr);
                      dataOut = {6'b0, lock4kb.LockReg_LD[readAddr], lock4kb.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end else begin
                      dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end
              `else    
                dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                f.out_info(readAddr, dataOut);
              `endif 
          end
          
          #tCLQX
          bitOut = dataOut[dataDim-1-bit_count];
          -> sendToBus;

   `ifdef MEDT_PPB 
   end else if (ppb.enable_PPBReg_read == 1) begin
       if(bit_count==0) begin
           readAddr = f.sec(addr);
           if(ppb.PPBReg[readAddr] == 1) dataOut = 8'hff;
           else dataOut = 8'h00;
       end
       #tCLQX
       bitOut = dataOut[dataDim-1-bit_count];
       -> sendToBus;

   end else if (plb.enable_PLBReg_read == 1) begin
       if(bit_count==0) begin
           dataOut = plb.PLB;
           f.out_info(readAddr, dataOut);
       end
       #tCLQX
       bitOut = dataOut[dataDim-1-bit_count];
       -> sendToBus;
   `endif
    
   end else if (read.enable_OTP==1) begin 

          if(bit_count==0) begin
              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              dataOut_temp = dataOut;
              if(readAddr >= 'h40)begin
                  dataOut[0] = OTP.mem[readAddr][0] & PMReg.PMR[3];
                  OTP.addr = 'h40;
              end
              f.out_info(readAddr, dataOut);
          end
          
          if(N25Qxxx.deep_power_down==1) dataOut = 'hzz;
          #tCLQX
          bitOut = dataOut[dataDim-1-bit_count];
          -> sendToBus;

   
   
    end else if (read.enable_ID==1) begin // && protocol=="extended") begin 
        // $display("In READ_ID : bit_count=%h , rdaddr=%h ", bit_count, readAddr, $time);
        `ifdef MEDITERANEO
        if(bit_count==2 && N25Qxxx.DoubleTransferRate == 1 && read.ID_index == 0 ) begin
            goReadId = 1;
        end else if(bit_count==0 && N25Qxxx.DoubleTransferRate == 1 && read.ID_index >= 0) begin
            goReadId = 1;
        end else if (bit_count == 0 && N25Qxxx.DoubleTransferRate == 0) begin
            goReadId = 1;
        end else begin
            goReadId = 0;
        end
        `else
        if(bit_count==0) begin
            goReadId = 1;
        `endif
            if(goReadId == 1) begin //
            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            else if (read.ID_index==3) dataOut=UID;
            else if (read.ID_index==4) dataOut=EDID_0;
            else if (read.ID_index==5) dataOut=EDID_1;
            else if (read.ID_index==6) dataOut=CFD_0;
            else if (read.ID_index==7) dataOut=CFD_1;
            else if (read.ID_index==8) dataOut=CFD_2;
            else if (read.ID_index==9) dataOut=CFD_3;
            else if (read.ID_index==10) dataOut=CFD_4;
            else if (read.ID_index==11) dataOut=CFD_5;
            else if (read.ID_index==12) dataOut=CFD_6;
            else if (read.ID_index==13) dataOut=CFD_7;
            else if (read.ID_index==14) dataOut=CFD_8;
            else if (read.ID_index==15) dataOut=CFD_9;
            else if (read.ID_index==16) dataOut=CFD_10;
            else if (read.ID_index==17) dataOut=CFD_11;
            else if (read.ID_index==18) dataOut=CFD_12;
            else if (read.ID_index==19) dataOut=CFD_13;
            else if (read.ID_index>19) dataOut=0;
            
            //RK if (read.ID_index<=18) read.ID_index=read.ID_index+1;
            if (read.ID_index<=19) read.ID_index=read.ID_index+1;
            //RK else read.ID_index=0;


            f.out_info(readAddr, dataOut);
            `ifndef MEDITERANEO
            end //
        `endif
        end
       
       #tCLQX
        bitOut = dataOut[dataDim-1-bit_count];
        -> sendToBus;

    end   

end


endtask




`ifdef HOLD_pin
//always @(sendToBus or posedge intHOLD) begin
always @(sendToBus) begin
`endif

`ifdef RESET_pin
always @(sendToBus) begin
`endif
    -> sendToBus_stack;
  #0;
  if(die_active == 1 ) begin
    fork : CP_sendToBus


      dtr_dout_started = 1'b1;
      force DQ1 = 1'bX;
      if(N25Qxxx.DoubleTransferRate == 1) force DQ0 = 1'bz;
      if((cmdRecName == "Read Fast") || 
        (cmdRecName == "Dual Command Fast Read") || 
        (cmdRecName == "Quad Command Fast Read") || 
        (cmdRecName == "Dual Output Fast Read") ||
        (cmdRecName == "Dual I/O Fast Read") ||
        (cmdRecName == "Quad I/O Fast Read") 
        ) begin 
      // #(tCLQV - tCLQX) 
        #(tCLQV/2 - tCLQX - 1); 
      end 
      else begin
        #(tCLQV - tCLQX - 1) ;
      end
      // if(DoubleTransferRate == 1) begin
      //   force DQ0 = bitOut;
      // end
      // else begin
        force DQ1 = bitOut;
      // end

    join
  end
end





 event resumeSSEfromHwReset;


//-----------------------
//  Reset Signal
//-----------------------
//dovrebbe essere abilitato attraverso il bit 4 del VECR


event resetEvent; //Activated only in devices with RESET pin.
event SSEresumeHwDone;

reg resetDuringDecoding=0; //These two boolean variables are used in TimingCheck 
reg resetDuringBusy=0;     //entity to check tRHSL timing constraint

    always @reset_by_powerOn if (reset_by_powerOn) begin : PON_reset

        ->resetEvent;
        

        release DQ1; //verificare
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='h0;

        `ifdef byte_4 
            ExtAddReg.EAR = 'b00000000;
            -> checkAddressMode;
            -> checkAddressSegment;
        `endif
        VolatileReg.VCR[7:4] = NonVolatileReg.NVCR[15:12];
        VolatileReg.VCR[3:0] = 'b1011;
        `ifdef MEDITERANEO
        //VolatileEnhReg.VECR[7:5] = 'b111;
        VolatileEnhReg.VECR[7] = NonVolatileReg.NVCR[3];
        VolatileEnhReg.VECR[6] = NonVolatileReg.NVCR[2];
        VolatileEnhReg.VECR[5] = NonVolatileReg.NVCR[5];
        prog.writePass_en = 0;
        `else
        VolatileEnhReg.VECR[7:5] = 'b110;
        `endif
        VolatileEnhReg.VECR[4] = NonVolatileReg.NVCR[4];
        VolatileEnhReg.VECR[3] = 'b1;
        VolatileEnhReg.VECR[2:0] = NonVolatileReg.NVCR[8:6];
        prog.dummySetByVECR = 0;
        prog.dummySetByVCR = 0;
        flag.FSR[7:1] = 'b1000000;
        `ifdef MEDITERANEO
        plb.PLB = 'h01;
        `endif
        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        iDummy = dummyDimEff -1;
        dataLatchedr=0;
        deep_power_down=0;

        if(prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte") begin
            stat.SR[0] = 0; // WIP - write in progress
            stat.SR[1] = 0; // WEL - write enable latch
        end
        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        #0 $display("[%0t ns] ==INFO== VCC has been driven below threshold : internal logic will be reset.", $time);
        -> checkProtocol;
        prog.disableOperations;
    end
        
//`ifdef RESET_pin 

    always @RESET if (!RESET) begin : CP_reset

        if(prog.subsec_erase_susp == 1) begin
            ->resumeSSEfromHwReset;
            prog.resumedFromHWReset = 1;
            @SSEresumeHwDone;
            end 
        else if(prog.operation =="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte")
            prog.HwResetDuringSSE = 1;

        ->resetEvent;
        
        
        if(S===0 && !busy) 
            resetDuringDecoding=1; 
        else if (busy && prog.operation!="Subsector Erase" && prog.operation!="Subsector Erase 32K" || prog.operation!="Subsector Erase 32K 4Byte")
            resetDuringBusy=1; 
        
        if(prog.operation=="Subsector Erase" || prog.oldOperation=="Subsector Erase" ||
           prog.operation=="Subsector Erase 32K" || prog.oldOperation=="Subsector Erase 32K 4Byte") @prog.noError2;
        release DQ1; //verificare
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='h0;

        `ifdef byte_4 
            ExtAddReg.EAR = 'b00000000;
            -> checkAddressMode;
            -> checkAddressSegment;
        `endif
        VolatileReg.VCR[7:4] = NonVolatileReg.NVCR[15:12];
        VolatileReg.VCR[3:0] = 'b1011;
        `ifdef MEDITERANEO
        VolatileEnhReg.VECR[7:5] = 'b111;
        prog.writePass_en = 0;
        `else
        VolatileEnhReg.VECR[7:5] = 'b110;
        `endif
        VolatileEnhReg.VECR[4] = NonVolatileReg.NVCR[4];
        VolatileEnhReg.VECR[3] = 'b1;
        VolatileEnhReg.VECR[2:0] = NonVolatileReg.NVCR[8:6];
        prog.dummySetByVECR = 0;
        prog.dummySetByVCR = 0;
        flag.FSR[7:1] = 'b1000000;
        dataLatchedr=0;
        deep_power_down=0;

`ifdef MEDT_GPRR
        GPRR_Reg.GPRR[(64*8)-1:0] = 512'b0;
        //GPRR_Reg.GPRR[7] = 'b1;
`endif

        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        iDummy = dummyDimEff -1;

        if(prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte") begin
            stat.SR[0] = 0; // WIP - write in progress
            stat.SR[1] = 0; // WEL - write enable latch
        end
        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        #0 $display("[%0t ns] ==INFO== Reset Signal has been driven low : internal logic will be reset.", $time);
        -> checkProtocol;
        prog.disableOperations;

    end
`ifdef Feature_8
    always @(posedge RESET2) begin
        if(!prog.subsec_erase_susp && prog.operation!="Subsector Erase" && prog.oldOperation!="Subsector Erase")begin 
            -> checkProtocol;
            flag.FSR[7:1] = 'b1000000;
        end
    end
`endif    
`ifdef RESET_pin
    always @(posedge RESET_DQ3) begin
        if(!prog.subsec_erase_susp && prog.operation!="Subsector Erase" && prog.oldOperation!="Subsector Erase")begin 
            -> checkProtocol;
            flag.FSR[7:1] = 'b1000000;
        end
    end
`endif    

//`endif    

 event resumeSSEfromSwReset;
 event SSEresumeDone;
`ifdef RESET_software
//-----------------------
// Software Reset 
//-----------------------

   reg  Reset_enable= 0;
    always @(seqRecognized) if (cmdRecName=="Reset Enable") fork : REN 
        
        begin : exe
          @(posedge N25Qxxx.S); 
          disable reset;
          Reset_enable= 1;
          $display("  [%0t ns] Command execution: Reset Enable.", $time);
        end

        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
    
    join


 always @(seqRecognized) if (cmdRecName=="Reset") begin : SW_reset
        
    if(Reset_enable==1) begin
        if(prog.subsec_erase_susp == 1) begin
            ->resumeSSEfromSwReset;
            prog.resumedFromSWReset = 1;
            @SSEresumeDone;
            end
        else if(prog.operation =="Subsector Erase" || prog.operation == "Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte")
            prog.SwResetDuringSSE = 1;

        ->resetEvent;
        
        Reset_enable=0;//verificare se va bene
        if(S===0 && !busy) 
            resetDuringDecoding=1; 
        else if (busy)
            resetDuringBusy=1; 
        
        //if(prog.operation=="Subsector Erase" || prog.oldOperation=="Subsector Erase" ||
        //   prog.operation=="Subsector Erase 32K" || prog.oldOperation=="Subsector Erase 32K") @prog.noError2;

        release DQ1; //verificare
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='hff;//Jan3
        
        `ifdef byte_4
            ExtAddReg.EAR = 'b00000000; 
            -> checkAddressMode;
            -> checkAddressSegment;
        `endif
        VolatileReg.VCR[7:4] = NonVolatileReg.NVCR[15:12];
        VolatileReg.VCR[3:0] = 'b1011;
        `ifdef MEDITERANEO
        //VolatileEnhReg.VECR[7:5] = 'b111;
        VolatileEnhReg.VECR[7] = NonVolatileReg.NVCR[3];
        VolatileEnhReg.VECR[6] = NonVolatileReg.NVCR[2];
        VolatileEnhReg.VECR[5] = NonVolatileReg.NVCR[5];
        prog.writePass_en = 0;
        `else
        VolatileEnhReg.VECR[7:5] = 'b110;
        `endif
        VolatileEnhReg.VECR[4] = NonVolatileReg.NVCR[4];
        VolatileEnhReg.VECR[3] = 'b1;
        VolatileEnhReg.VECR[2:0] = NonVolatileReg.NVCR[8:6];
        prog.dummySetByVECR = 0;
        prog.dummySetByVCR = 0;
        //flag.FSR = 'b10000000;
        flag.FSR[7:1] = 'b1000000;
        dataLatchedr=0;
        deep_power_down=0;

`ifdef MEDT_GPRR
        GPRR_Reg.GPRR[(64*8)-1:0] = 512'b0;
        //GPRR_Reg.GPRR[7] = 'b1;
`endif

        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        iDummy =dummyDimEff -1;

        if(prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte") begin
            stat.SR[0] = 0; // WIP - write in progress
            stat.SR[1] = 0; // WEL - write enable latch
        end
        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        #0 $display("[%0t ns] ==INFO== Software reset : internal logic will be reset.", $time);
        -> checkProtocol;
        //prog.SR_data = stat.SR;
        prog.disableOperations;

     end else $display("  [%0t ns] **WARNING** A reset-enable command is required before the Reset command: operation aborted!", $time);

 end


always @(seqRecognized) if (cmdRecName!="Reset" && Reset_enable==1) begin 
        Reset_enable=0;
end

`endif
//-----------------------
//  Deep power down 
//-----------------------


`ifdef PowDown


    always @seqRecognized if (cmdRecName=="Deep Power Down") fork : CP_deepPowerDown

        begin : exe
          @(posedge S);
          disable reset;
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - Deep Power Down aborted due to Prog/Erase Suspend",$time);
            disable CP_deepPowerDown;
          end  

          busy=1;
          $display("  [%0t ns] Device is entering in deep power down mode...",$time);
          #deep_power_down_delay;
          $display("  [%0t ns] ...power down mode activated.",$time);
          busy=0;
          deep_power_down=1;
        end

        begin : reset
          @resetEvent;
          disable exe;
        end

    join


    always @seqRecognized if (cmdRecName=="Release Deep Power Down") fork : CP_releaseDeepPowerDown

        begin : exe
          @(posedge S);
          disable reset;
          busy=1;
          $display("  [%0t ns] Release from deep power down is ongoing...",$time);
          #release_power_down_delay;
          $display("  [%0t ns] ...release from power down mode completed.",$time);
          busy=0;
          deep_power_down=0;
        end 

        begin : reset
          @resetEvent;
          disable exe;
        end

    join


`endif


     
//-----------------
//   XIP mode
//-----------------


//-----------------
// Latching address 
//-----------------


always @(negedge S) if (XIP) begin : XIP_latchInit

    $display("[%0t ns] The device is entered in XIP mode.", $time);

    if (protocol=="extended") begin
       if (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Extended command DIOFRDTR") begin
           latchingMode = "I";
       end else if (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Extended command QIOFRDTR") begin
           latchingMode = "E";
       `ifdef MEDT_4READ4D    
       end else if (cmdRecName=="Word Read Quad I/O" || cmdRecName=="Word Read Quad Command Fast Read") begin
           latchingMode = "E";
       `endif    
       end else begin
           latchingMode = "A";
       end
       $display("[%0t ns] %0s. Address expected ...", $time,cmdRecName);
            
            fork : XipProc1 

                @(addrLatched) begin
                    
                    $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                    -> seqRecognized;
                    disable XipProc1;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc1;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc1;
                end
            
            join

    end else  if (protocol=="dual") begin

       latchingMode = "I";
       $display("[%0t ns] %0s. Address expected ...", $time,cmdRecName);
        
              fork : XipProc2 

                @(addrLatched) begin
                     $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                     -> seqRecognized;
                     disable XipProc2;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc2;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc2;
                end
            
            join

    end else  if (protocol=="quad") begin

       latchingMode = "E";
       $display("[%0t ns]  %0s. Address expected ...", $time,cmdRecName);
        
              fork : XipProc3 

                @(addrLatched) begin
                     $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                    -> seqRecognized;
                    disable XipProc3;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc3;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc3;
                end
            
            join
    
    end
 
end 

task determineDevName;
    begin
        `ifdef STACKED_MEDT_1G
            $display ("===INFO=== Device Name: %s 1G (2 die stacked) die%d %d",devName,rdeasystacken,rdeasystacken2)    ; 
        `elsif Stack1024Mb
            $display ("===INFO=== Device Name: %s 1G (4 die stacked) die%d %d",devName,rdeasystacken,rdeasystacken2)    ; 
        `elsif Stack512Mb
            $display ("===INFO=== Device Name: %s 512Mb (2 die stacked) die%d %d",devName, rdeasystacken,rdeasystacken2)    ; 
        `elsif STACKED_MEDT_2G
            $display ("===INFO=== Device Name: %s 2G (4 die stacked) die%d %d",devName,rdeasystacken,rdeasystacken2)    ; 
        `else
            $display ("===INFO=== Device Name: %s",devName)    ; 
        `endif

    end
endtask //determineDevName
            



endmodule //N25Qxxx















/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           CUI DECODER                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps 

module CUIdecoder (cmdAllowed);


    `include "include/DevParam.h" 

    input cmdAllowed;

    parameter [40*8:1] cmdName = "Write Enable";
    parameter [cmdDim-1:0] cmdCode = 'h06;
    parameter withAddr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with2Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with4Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
     
    //debug events
    event cui0;
    event cui1;
    event cui2;

    always @N25Qxxx.startCUIdec begin
        -> cui0;
        if (cmdAllowed && cmdCode==N25Qxxx.cmd) begin
        $display("[%0t ns] COMMAND DECODED: %0s , withAddr=%h, with2Addr=%h, with4Addr=%h, cmdcode=%h ", $time, cmdName, withAddr, with2Addr, with4Addr, cmdCode);

        if(!withAddr && !with2Addr && !with4Addr) begin
            
            N25Qxxx.cmdRecName = cmdName;
            $display("[%0t ns] COMMAND RECOGNIZED: %0s.", $time, cmdName);
            -> N25Qxxx.seqRecognized; 
        
        end else if (withAddr) begin
            
            N25Qxxx.quadMode = 0;
            N25Qxxx.latchingMode = "A";
             $display("[%0t ns] 1.COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
            -> N25Qxxx.codeRecognized;
            
            fork : proc1 

                @(N25Qxxx.addrLatched) begin
                    if (cmdName!="Read OTP" && cmdName!="Program OTP")
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                    else
                        $display("  [%0t ns] Address latched: column %0h", $time, N25Qxxx.addr);
                    N25Qxxx.cmdRecName = cmdName;
                    -> N25Qxxx.seqRecognized;
                    disable proc1;
                end

                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable proc1;
                end

                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable proc1;
                end
            
            join


         end else if (with2Addr) begin
            
            N25Qxxx.quadMode = 0;
            N25Qxxx.latchingMode = "I";
            $display("[%0t ns] 2.COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
            -> N25Qxxx.codeRecognized;
            
            fork : proc2 

                @(N25Qxxx.addrLatched) begin
                    if (cmdName!="Read OTP" && cmdName!="Program OTP")
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                    else
                        $display("  [%0t ns] Address latched: column %0h cmdName %s", $time, N25Qxxx.addr, cmdName);
                    N25Qxxx.cmdRecName = cmdName;
                    -> N25Qxxx.seqRecognized;
                    disable proc2;
                end

                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable proc2;
                end

                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable proc2;
                end
            join
        end  else if (with4Addr) begin
                    
                                N25Qxxx.quadMode = 1;
                                N25Qxxx.latchingMode = "E";
                                $display("[%0t ns] 4.COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
                                -> N25Qxxx.codeRecognized;
                                            
                                fork : proc3 
                                   
                                   @(N25Qxxx.addrLatched) begin
                                       if (cmdName!="Read OTP" && cmdName!="Program OTP")
                                           $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                           N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                                       else
                                           $display("  [%0t ns] Address latched: column %0h", $time, N25Qxxx.addr);
                                       N25Qxxx.cmdRecName = cmdName;
                                       -> N25Qxxx.seqRecognized;
                                       disable proc3;
                                   end

                                   @(posedge N25Qxxx.S) begin
                                       $display("  - [%0t ns] S high: command aborted", $time);
                                       disable proc3;
                                   end

                                   @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                                       disable proc3;
                                   end
                                join
      end    
    end
end
endmodule //CUIdecoder    

`ifdef MEDT_MSE
//CUIdecoderEFI captures 
module CUIdecoderEFI_MSE (cmdAllowed);
    `include "include/DevParam.h" 

    input cmdAllowed;

    parameter [40*8:1] cmdName = "Write Enable";
    parameter [cmdDim-1:0] cmdCode1 = 'h9B;
    parameter [cmdDim-1:0] cmdCode2 = 'h26;
    parameter withAddr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with2Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with4Addr = 1'b0; // 1 -> command with address  /  0 -> without address 

    reg [cmdDim-1:0] cmd;
    reg [cmdDim-1:0] attr;
    reg [addrDimLatch4 -1 :0] start_address;
    reg [addrDimLatch4 -1 :0] stop_address;
    reg [addrDimLatch4 -1 :0] destAddr;

    integer iCmd2 = cmdDim -1;
    integer iStartAddr;
    integer iStopAddr;

    event abortEFI;
    event efiSeqRecognized; //indicates successfull sequence received
    event efiErrorCheck;
    event efiError; //indicates error in efi (ex. one of ss or s is locked)
    event efiNoError; //

    time mse_delay = 100;
    reg [7:0] latchingMode;

//    always @N25Qxxx.startCUIdec begin
//        if (cmdAllowed && cmdCode1==N25Qxxx.cmd) begin
//            $display("[%0t ns] COMMAND DECODED: %0s , withAddr=%h, with2Addr=%h, with4Addr=%h, cmdcode=%h ", $time, cmdName, withAddr, with2Addr, with4Addr, cmdCode1);
//            N25Qxxx.latchingMode="2";
//            iCmd2 = cmdDim - 1;
//            -> N25Qxxx.codeRecognized;
//        end
//    end

    // latch sub-opcode
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="extended") begin : CP_latchCmd2
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        cmd[iCmd2] = N25Qxxx.DQ0;

        if (iCmd2>0)
            iCmd2 = iCmd2 - 1;
        else if(iCmd2==0) begin
            iCmd2 = cmdDim - 1;
            if(cmd != cmdCode2) begin
                $display("[%0t ns] Sub-opcode: %h not recognized, aborting operation", $time, cmd);
                -> abortEFI;
                //N25Qxxx.latchingMode = "N";
            end else begin
                N25Qxxx.cmdRecName = cmdName;
            $display("[%0t ns] Sub-opcode DECODED: %0s , cmdcode=%h ", $time, cmdName, cmd);
#1;
`ifdef MTC_ENABLED
                disable N25Qxxx.CUIDECEFI_MTC.CP_latchCmd2_MTC;
            `endif
                N25Qxxx.latchingMode = "3";
            end
        end    
     end        
    end //CP_latchCmd2
    
    //latch attribute (extended)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && N25Qxxx.protocol=="extended") begin : CP_latchAttr
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        attr[iCmd2] = N25Qxxx.DQ0;

        if (iCmd2>0)
            iCmd2 = iCmd2 - 1;
        else if(iCmd2==0) begin
            if(attr == 'hFF) begin
                iCmd2 = cmdDim;
                N25Qxxx.latchingMode = "N";
                -> efiSeqRecognized;
                disable disableEFI;
            end else begin
                N25Qxxx.latchingMode = "4";
                iStartAddr = addrDimLatch4;
            end    
            $display("[%0t ns] Attribute Latched: %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttr

    //latch STARTING ADDRESS (extended)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="4" && N25Qxxx.protocol=="extended") begin : CP_latchStartingAddress
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iStartAddr != addrDimLatch4 - 1)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        start_address[iStartAddr] = N25Qxxx.DQ0;

        if (iStartAddr>0)
            iStartAddr = iStartAddr - 1;
        else if(iStartAddr==0) begin
            N25Qxxx.latchingMode = "5";
            iStopAddr = addrDimLatch4;
            $display("[%0t ns] Starting Address Latched: %0h ", $time, start_address);
        end    
     end        
    end //CP_latchStartingAddress

    //latch STOPING ADDRESS (extended)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="5" && N25Qxxx.protocol=="extended") begin : CP_latchStopingAddress
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iStopAddr != addrDimLatch4 - 1)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        stop_address[iStopAddr] = N25Qxxx.DQ0;

        if (iStopAddr>0)
            iStopAddr = iStopAddr - 1;
        else if(iStopAddr==0) begin
            N25Qxxx.latchingMode = "N";
            -> efiSeqRecognized;
            $display("[%0t ns] Stopping Address Latched: %0h ", $time, stop_address);
            disable disableEFI;
        end    
     end        
    end //CP_latchStopingAddress

    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="dual") begin : CP_latchCmd2Dual
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        cmd[iCmd2] = N25Qxxx.DQ1;
        cmd[iCmd2-1] = N25Qxxx.DQ0;

        if (iCmd2>=3)
            iCmd2 = iCmd2 - 2;
        else if(iCmd2==1) begin
            N25Qxxx.latchingMode = "3";
            iCmd2 = cmdDim +1;
            $display("[%0t ns] Sub-opcode DECODED (dual): %0s , cmdcode=%h ", $time, cmdName, cmd);
            N25Qxxx.cmdRecName = cmdName;
        end    
     end        
    end //CP_latchCmd2Dual

    //latch attribute (dual)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && N25Qxxx.protocol=="dual") begin : CP_latchAttrDual
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        attr[iCmd2] = N25Qxxx.DQ1;
        attr[iCmd2-1] = N25Qxxx.DQ0;

        if (iCmd2>=3)
            iCmd2 = iCmd2 - 2;
        else if(iCmd2==1) begin
            N25Qxxx.latchingMode = "4";
            iStartAddr = addrDimLatch4+1;
            $display("[%0t ns] Attribute Latched (dual) : %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttrDual

    //latch STARTING ADDRESS (dual)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="4" && N25Qxxx.protocol=="dual") begin : CP_latchStartAddrDual
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iStartAddr != addrDimLatch4 - 1)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        start_address[iStartAddr] = N25Qxxx.DQ1;
        start_address[iStartAddr-1] = N25Qxxx.DQ0;

        if (iStartAddr>=2)
            iStartAddr = iStartAddr - 2;
        else if(iStartAddr==1) begin
            N25Qxxx.latchingMode = "5";
            iStopAddr = addrDimLatch4+1;
            $display("[%0t ns] Start Address Latched (dual) : %0h ", $time, start_address);
        end    
     end        
    end //CP_latchStartAddrDual

    //latch STOPING ADDRESS (dual)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="5" && N25Qxxx.protocol=="dual") begin : CP_latchStopAddrDual
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iStopAddr != addrDimLatch4 - 1)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        stop_address[iStopAddr] = N25Qxxx.DQ1;
        stop_address[iStopAddr-1] = N25Qxxx.DQ0;

        if (iStopAddr>=3)
            iStopAddr = iStopAddr - 2;
        else if(iStopAddr==1) begin
            N25Qxxx.latchingMode = "N";
            -> efiSeqRecognized;
            $display("[%0t ns] Stop Address Latched (dual) : %0h ", $time, stop_address);
            disable disableEFI;
        end    
     end        
    end //CP_latchStopAddrDual


    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="quad") begin : CP_latchCmd2Quad
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        `ifdef HOLD_pin
        cmd[iCmd2] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        cmd[iCmd2] = N25Qxxx.RESET_DQ3;
        `endif
        cmd[iCmd2-1] = N25Qxxx.Vpp_W_DQ2;
        cmd[iCmd2-2] = N25Qxxx.DQ1;
        cmd[iCmd2-3] = N25Qxxx.DQ0;

        if (iCmd2>3)
            iCmd2 = iCmd2 - 4;
        //else if(iCmd2<=0) begin
        else if(iCmd2==3) begin
            N25Qxxx.latchingMode = "3";
            iCmd2 = cmdDim+3;
            $display("[%0t ns] Sub-opcode DECODED: %0s , cmdcode=%h ", $time, cmdName, cmd);
            N25Qxxx.cmdRecName = cmdName;
        end    
     end        
    end //CP_latchCmd2Quad

    //latch attribute (quad)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && N25Qxxx.protocol=="quad") begin : CP_latchAttrQuad
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        `ifdef HOLD_pin
        attr[iCmd2] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        attr[iCmd2] = N25Qxxx.RESET_DQ3;
        `endif
        attr[iCmd2-1] = N25Qxxx.Vpp_W_DQ2;
        attr[iCmd2-2] = N25Qxxx.DQ1;
        attr[iCmd2-3] = N25Qxxx.DQ0;

        if (iCmd2>3)
            iCmd2 = iCmd2 - 4;
        else if(iCmd2==3) begin
            N25Qxxx.latchingMode = "4";
            iStartAddr = addrDimLatch4+3;
            $display("[%0t ns] Attribute Latched: %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttrQuad

    //latch STARTING ADDRESS (quad)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="4" && N25Qxxx.protocol=="quad") begin : CP_latchStartAddrQuad
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        `ifdef HOLD_pin
        start_address[iStartAddr] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        start_address[iStartAddr] = N25Qxxx.RESET_DQ3;
        `endif
        start_address[iStartAddr-1] = N25Qxxx.Vpp_W_DQ2;
        start_address[iStartAddr-2] = N25Qxxx.DQ1;
        start_address[iStartAddr-3] = N25Qxxx.DQ0;

        if (iStartAddr>3)
            iStartAddr = iStartAddr - 4;
        else if(iStartAddr==3) begin
            N25Qxxx.latchingMode = "5";
            iStopAddr = addrDimLatch4+3;
            $display("[%0t ns] Start Address Latched: %0h ", $time, start_address);
        end    
     end        
    end //CP_latchStartAddrQuad

    //latch STOPING ADDRESS (quad)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="5" && N25Qxxx.protocol=="quad") begin : CP_latchStopAddrQuad
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        `ifdef HOLD_pin
        stop_address[iStopAddr] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        stop_address[iStopAddr] = N25Qxxx.RESET_DQ3;
        `endif
        stop_address[iStopAddr-1] = N25Qxxx.Vpp_W_DQ2;
        stop_address[iStopAddr-2] = N25Qxxx.DQ1;
        stop_address[iStopAddr-3] = N25Qxxx.DQ0;

        if (iStopAddr>3)
            iStopAddr = iStopAddr - 4;
        else if(iStopAddr==3) begin
            N25Qxxx.latchingMode = "N";
            -> efiSeqRecognized;
            $display("[%0t ns] Stop Address Latched: %0h ", $time, stop_address);
            disable disableEFI;
        end    
     end        
    end //CP_latchStopAddrQuad


    always @(N25Qxxx.latchingMode or N25Qxxx.S) begin 
        if(N25Qxxx.latchingMode == 2 ||
           N25Qxxx.latchingMode == 3 ||
           N25Qxxx.latchingMode == 4 ||
           N25Qxxx.latchingMode == 5 )
        fork : disableEFI
                @abortEFI begin
                    disable CP_latchCmd2;
                    disable CP_latchAttr;
                    disable CP_latchStartingAddress;
                    disable CP_latchStopingAddress;
                    disable disableEFI;
                end
                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable CP_latchCmd2;
                    disable CP_latchAttr;
                    disable CP_latchStartingAddress;
                    disable CP_latchStopingAddress;
                    disable disableEFI;
                end
                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable CP_latchCmd2;
                    disable CP_latchAttr;
                    disable CP_latchStartingAddress;
                    disable CP_latchStopingAddress;
                    disable disableEFI;
                end
        join
    end

    reg [3:0] ssCount_start; //Subsector count
    reg [3:0] ssCount_stop; //Subsector count
    reg [31:0] ssCount_total;
    reg [8:0] sCount_total;
    //sector address holders for 
    reg [7:0] sector_start_addr;
    reg [7:0] sector_stop_addr;
    reg [3:0] subsector_start_addr;
    reg [3:0] subsector_stop_addr;
    reg [11:0] ss_start_4Kb_address;
    reg [11:0] ss_stop_4Kb_address;
    
    reg [32:0] ssEraseable [0:31]; //[erase me flag][address to be erased]

    reg [7:0] sector_start;
    reg [7:0] sector_stop;
    reg sector_locked_by_V; 
    reg sector_locked_by_NV_b; 
    reg sector_locked_by_SR; 
    reg ssector_locked_by_V;
    integer i;
    integer y;
    integer ss_address_tracker = 0;
    integer init_val;
    integer sector_temp;
    integer ssCount_total_temp;
    integer myTemp;

    always @(efiSeqRecognized) begin
        if(N25Qxxx.cmdRecName == cmdName) 
            fork : MSE_ops
                begin : exe
                    @(posedge N25Qxxx.S)
                    disable reset;
                    N25Qxxx.prog.operation = N25Qxxx.cmdRecName;
                    N25Qxxx.busy = 1;
                    //mse_delay = 1000;
                    $display("  [%0t ns] Command execution begins: %0s.", $time, N25Qxxx.prog.operation);
                    
                    sector_start_addr = start_address[23:16];
                    subsector_start_addr = start_address[15:12];
                    sector_stop_addr = stop_address[23:16];
                    subsector_stop_addr = stop_address[15:12];

                    //4Kb granularity addressing
                    ss_start_4Kb_address = start_address[23:12]; 
                    ss_stop_4Kb_address = stop_address[23:12]; 

                    sector_temp = sector_stop_addr - sector_start_addr;

                    if(start_address > stop_address) begin //not allowed by spec
                        $display("\n [%0t ns] -----ERROR---- Start address > Stop address : %0h > %0h\n", $time, start_address, stop_address);
                        ->efiError;
                    end else if(start_address == stop_address) begin //implies same sector and subsector
                            sCount_total = 0;
                            ssCount_total = 1;
                            checkSubSectorLocksInRange(ssCount_total,start_address);  
                    end else begin //A <= B 
                        //start and stop between top and bottom sectors
                        if(ss_start_4Kb_address > 'hF && ss_stop_4Kb_address < 'hFF0) begin 
                            ssCount_total = ss_start_4Kb_address % 'd16;
                            if(ssCount_total != 0) begin
                                ssCount_total = 'd16 - ssCount_total;
                            end else begin
                                sCount_total = 1;
                            end
                            ssCount_total = ssCount_total + ((ss_stop_4Kb_address + 1) % 'd16);
                            sCount_total = sCount_total + sector_temp;
                        //start and stop at bottom or top
                        end else if((ss_start_4Kb_address < 'h10 && ss_stop_4Kb_address < 'h10) ||
                                    (ss_start_4Kb_address > 'hFEF && ss_stop_4Kb_address > 'hFEF)) begin 
                            ssCount_total = (ss_stop_4Kb_address - ss_start_4Kb_address) +1;
                            sCount_total = 0;
                            checkSubSectorLocksInRange(ssCount_total,start_address);  
                        //start at bottom and stop anywhere but bottom and top
                        end else if(ss_start_4Kb_address <= 'hF && (ss_stop_4Kb_address > 'hF && ss_stop_4Kb_address < 'hFF0)) begin 
                            ssCount_total = 'd16 - subsector_start_addr; 
                            checkSubSectorLocksInRange(ssCount_total,start_address);  
                            ssCount_total = ssCount_total + ((ss_stop_4Kb_address + 1) % 'd16);
                            checkSubSectorLocksInRange((ss_stop_4Kb_address + 1) %'d16,{ss_stop_4Kb_address,12'h0});  
                            //sCount_total = sector_temp - 'h1;
                            sCount_total = sector_temp ;
                        //start anywhere between top and bottom and stop at top
                        end else if((ss_start_4Kb_address > 'hF && ss_start_4Kb_address < 'hFF0) && ss_stop_4Kb_address >= 'hFF0) begin 
                            ssCount_total = subsector_stop_addr + 'h1;
                            checkSubSectorLocksInRange(ssCount_total,{12'hFF0,12'h0});  
                            ssCount_total_temp = ss_start_4Kb_address % 'd16;
                            if(ssCount_total_temp != 0) begin
                                ssCount_total_temp = 'd16 - ssCount_total_temp;
                                checkSubSectorLocksInRange(ssCount_total_temp,{ss_start_4Kb_address,12'h0});  
                                ssCount_total = ssCount_total + ssCount_total_temp;
                                sCount_total = -1;
                            end else begin
                                sCount_total = 1;
                            end
                            sCount_total = sCount_total + sector_temp;
                            ->N25Qxxx.Debug.x3;
                        end else begin //start at bottom while stop at top
                            ssCount_total = 'd16 - subsector_start_addr;
                            checkSubSectorLocksInRange(ssCount_total,start_address);  
                            ssCount_total_temp = subsector_stop_addr + 'h1;
                            checkSubSectorLocksInRange(ssCount_total_temp,{12'hFF0,12'h0});  
                            ssCount_total = ssCount_total + ssCount_total_temp;
                            sCount_total = 'd254;
                            ->N25Qxxx.Debug.x4;
                        end
                    end

                    if(sCount_total != 'd0) begin
                        checkSectorLocksInRange(sCount_total, sector_start_addr);
                    end

                    mse_delay = mseDelay(sCount_total,ssCount_total, erase_delay,erase_ss_delay);

                    -> efiErrorCheck;

                    //-> N25Qxxx.prog.errorCheck;
                    disable N25Qxxx.prog.errorCheck_ops.dynamicCheck.main_ops;

                    @(efiNoError) begin
                        //we do actual erase here
                        if(sCount_total != 'd0) begin
                            eraseSectorsInRange(sCount_total, sector_start_addr);
                        end
                        eraseSubSectorsInRange; 
                        $display("  [%0t ns] Command execution completed: %0s.", $time, N25Qxxx.prog.operation);
                        for(y=0; y<32; y=y+1) begin
                            ssEraseable[y] = 33'h0_0000_0000;
                        end
                    end

                end //exe
                begin : reset
                    @N25Qxxx.resetEvent;
                    N25Qxxx.prog.operation = "None";
                    disable exe;
                end // reset
            join //MSE_ops
    end
    

    always @(efiErrorCheck) fork : efiErrorCheck_ops 
        begin : static_check
            //check if any of the sectors is locked
            if(sCount_total > 0) begin

            end
        end //static_check

        fork : dynamic_check
            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> efiError; 
            end
            begin
                -> efiNoError;
                #mse_delay;
                resetForMSE;
            end
        join //dynamic_check
    join //efiErrorCheck_ops   
 
    always @(efiError) begin
        //clear ssEraseable
        for(y=0; y<32; y=y+1) begin
            ssEraseable[y] = 33'h0_0000_0000;
        end
        resetForMSE;
        disable MSE_ops;
        ->abortEFI;
    end

    function time mseDelay;
        input [31:0] ssC_total;
        input [31:0] sC_total;
        input time erase_delay;
        input time erase_ss_delay;
        integer i;
        begin
             mseDelay = 0;
             for (i = 0; i < sC_total; i=i+1) begin
                 mseDelay = mseDelay + erase_delay;
             end
             for (i = 0; i < ssC_total; i=i+1) begin
                 mseDelay = mseDelay + erase_ss_delay;
             end
        end
    endfunction //mseDelay
    
    task resetForMSE;
        begin
            N25Qxxx.busy = 0;
            //we initialize everything efi
            start_address = 32'h0000_0000; 
            stop_address = 32'h0000_0000; 
            sector_start_addr = 0;
            sector_stop_addr = 0;
            sector_temp = 0;
            subsector_start_addr = 0;
            subsector_start_addr = 0;
            ss_start_4Kb_address = 0;
            ss_stop_4Kb_address = 0;
            sector_start = 0;
            sector_stop  = 0;
            ssCount_stop = 0;
            ssCount_total = 0;
            ssCount_total_temp = 0;
            sCount_total = 0;
            iCmd2 = cmdDim-1;
            iStartAddr = 0;
            iStopAddr = 0;
            cmd = 0;
            attr = 0;
            mse_delay = 0;
            destAddr = 0;
            ss_address_tracker = 0; 
            disable efiErrorCheck_ops.dynamic_check;
            disable efiErrorCheck_ops;
        end
    endtask //resetForMSE

    task checkSectorLocksInRange;
        input [8:0] nSectors;
        input [7:0] start_address;
        begin
            destAddr = {start_address,16'h0000};
            //for (y=0; y<sCount_total; y=y+1) begin
            for (y=0; y<nSectors; y=y+1) begin
                sector_locked_by_V = N25Qxxx.lock.isProtected_by_lockReg(destAddr);
                sector_locked_by_NV_b = N25Qxxx.ppb.isProtected_by_PPBReg(destAddr);
                sector_locked_by_SR = N25Qxxx.lock.isProtected_by_SR(destAddr);
                if(!sector_locked_by_V && !sector_locked_by_SR && sector_locked_by_NV_b) begin
                    $display("------------DEBUG-------- SUCCESS, Sector not locked %0h %0b %0b\n",destAddr,sector_locked_by_V, sector_locked_by_NV_b, sector_locked_by_SR);
                    destAddr[23:16] = destAddr[23:16] + 1'b1;
                end else begin
                    $display("------------DEBUG-------- FAIL due to locked sector\n");
                    ->efiError;
                end
            end
        end
    endtask //checkSectorLocksInRange
    
    task eraseSectorsInRange;
        input [8:0] nSectors;
        input [7:0] start_address;
        begin
            destAddr = {start_address,16'h0000};
            $display("====DEBUG eraseSectorsInRange \n");
            for (y=0; y<=nSectors-1; y=y+1) begin
                if(destAddr[23:16] != 'h00 && destAddr[23:16] != 'hFF) begin
                    N25Qxxx.mem.eraseSector(destAddr);
                    $display("[INFO] -DEBUG eraseSectorsInRange- %0t Sector %0h is erased %0d\n", $time, destAddr,y);
                end
                destAddr[23:16] = destAddr[23:16] + 1'b1;
            end
        end
    endtask //eraseSectorsInRange
    
    task checkSubSectorLocksInRange;
        input [4:0] nSubSectors;
        input [addrDimLatch4 -1:0] start_address;
        begin
            //$display("We are in checkSubSectorLocksInRange %0d %0h\n", nSubSectors, start_address);
            destAddr = start_address;
            //for (y=init_val;y<(nSubSectors+init_val);y=y+1) begin  
            for (y=0;y<nSubSectors;y=y+1) begin  
                if(destAddr[23:16] == 'h00 || destAddr[23:16] == 'hFF) begin //we only check ss locks when s is at bottom or top sector
                    ssector_locked_by_V = N25Qxxx.lock4kb.isProtected_by_lockReg(destAddr);    
                end else begin
                    ssector_locked_by_V = 0;
                end
                if(!ssector_locked_by_V) begin
                    $display("------------DEBUG-------- SUCCESS Subsector not locked %0h %0b\n",destAddr,ssector_locked_by_V);
                    ssEraseable[ss_address_tracker] = {1'b1,destAddr}; #1;
                    ss_address_tracker = ss_address_tracker + 1;
                    destAddr[15:12] = destAddr[15:12] + 1'b1;
                end else begin
                    $display("------------DEBUG-------- FAIL due to locked sub sector %0h %0b\n", destAddr, ssector_locked_by_V);
                    ->efiError;
                    y = 'h1F; //this terminates the for loop
                end
            end 
        end
    endtask //checkSubSectorLocksInRange
    
    task cacheSSaddressForErase;
        begin
        end
    endtask //cacheSSaddressForErase

    task eraseSubSectorsInRange;
        reg [32:00] temp_addr;
        reg erase_me;
        begin
            //loop through ssErasable, we only erase the address flagged as 1
            for (y=0;y<32;y=y+1) begin  
                //each element of ssEraseable contains the address and the flag
                //that tells the BFM to erase that address.  The flag is needed
                //to be able to erase address 0 or not.
                temp_addr = ssEraseable[y];
                destAddr = temp_addr[31:0];
                erase_me = temp_addr[32];
                if(erase_me == 1'b1) begin
                    N25Qxxx.mem.eraseSubsector(destAddr);
                    $display("[INFO] -DEBUG- %0t 4Kb subsector %0h is erased", $time, destAddr);
                end
            end
        end
    endtask //eraseSubSectorsInRange

endmodule //CUIdecoderEFI_MSE
`endif //MEDT_MSE

`ifdef MEDT_TDP
module CUIdecoder_TDP (cmdAllowed);
    `include "include/DevParam.h" 

    input cmdAllowed;

    parameter [40*8:1] cmdName = "Write Enable";
    parameter [cmdDim-1:0] cmdCode = 'h48;
    parameter withAddr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with2Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with4Addr = 1'b0; // 1 -> command with address  /  0 -> without address 

    integer iCmd2;
    integer iData;
    integer i;
    integer tdp_counter = 0;

    reg [cmdDim-1:0] cmd;
    reg [cmdDim-1:0] attr;
    reg [dataDim-1:0] dataOut;
    reg [127:0] bytePattern0;
    reg [127:0] bytePattern1;
    reg [127:0] bytePattern2;
    reg [127:0] bytePattern3;
    reg [3:0] bitCounter = 8;
    reg [7:0] byteHolder;

    event tdpSeqRecognized;
    event tdpProgramNow;
    event abortTDP;
    event attributeCheck;
    event okAttribute;

    reg [7:0] tdp_reg [0:63];
    reg [7:0] tdp_reg_temp [0:63];
    reg [(128*4)-1:0] tdp_pattern;

    initial begin
        iData = 0;
        tdp_pattern = {TDP_PAT3,TDP_PAT2,TDP_PAT1,TDP_PAT0};
        //for(i=0;i<=15;i=i+1)begin
        //KS: flip the bytes within each PAT
        for(i=15;i>=0;i=i-1)begin
            tdp_reg[i] = tdp_pattern[7:0];
            tdp_reg[i+16] = tdp_pattern[135:128];
            tdp_reg[i+32] = tdp_pattern[263:256];
            tdp_reg[i+48] = tdp_pattern[391:384];
            tdp_pattern = tdp_pattern >> 8;
        end
    end

    always @N25Qxxx.startCUIdec begin
        if (cmdAllowed && cmdCode==N25Qxxx.cmd) begin
            $display("[%0t ns] COMMAND DECODED: %0s , withAddr=%h, with2Addr=%h, with4Addr=%h, cmdcode=%h ", 
                            $time, cmdName, withAddr, with2Addr, with4Addr, cmdCode);
            N25Qxxx.latchingMode="2";
            iCmd2 = cmdDim - 1;
            N25Qxxx.cmdRecName = cmdName;
            -> N25Qxxx.codeRecognized;
        end
    end

    //latch attribute (extended)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="extended") begin : CP_latchAttr
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        attr[iCmd2] = N25Qxxx.DQ0;

        if (iCmd2>0)
            iCmd2 = iCmd2 - 1;
        else if(iCmd2==0) begin
            if(attr == 'hFF) begin
                iCmd2 = cmdDim;
                N25Qxxx.latchingMode = "N";
                -> tdpSeqRecognized;
                //disable disableTDP;
            end else begin
                #1;
                ->attributeCheck;
                @okAttribute;
                N25Qxxx.latchingMode = "3";
                bitCounter = 7;
                //iStartAddr = addrDimLatch4;
            end    
            $display("[%0t ns] TDP Attribute Latched: %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttr

    //latch attribute (dual)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="dual") begin : CP_latchAttrDual
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        attr[iCmd2] = N25Qxxx.DQ1;
        attr[iCmd2-1] = N25Qxxx.DQ0;

        if (iCmd2>=3)
            iCmd2 = iCmd2 - 2;
        else if(iCmd2==1) begin
            #1;
            ->attributeCheck;
            @okAttribute;
            N25Qxxx.latchingMode = "3";
            //iStartAddr = addrDimLatch4+1;
            $display("[%0t ns] TDP Attribute Latched (dual) : %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttrDual

    //latch attribute (quad)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="2" && N25Qxxx.protocol=="quad") begin : CP_latchAttrQuad
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        `ifdef HOLD_pin
        attr[iCmd2] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        attr[iCmd2] = N25Qxxx.RESET_DQ3;
        `endif
        attr[iCmd2-1] = N25Qxxx.Vpp_W_DQ2;
        attr[iCmd2-2] = N25Qxxx.DQ1;
        attr[iCmd2-3] = N25Qxxx.DQ0;

        if (iCmd2>3)
            iCmd2 = iCmd2 - 4;
        else if(iCmd2==3) begin
            #1;
            ->attributeCheck;
            @okAttribute;
            N25Qxxx.latchingMode = "3";
            //iStartAddr = addrDimLatch4+3;
            $display("[%0t ns] TDP Attribute Latched: %0h ", $time, attr);
        end    
     end        
    end //CP_latchAttrQuad

    always @(attributeCheck) begin
        if(attr[7:6]=='b11) begin
            ->abortTDP;
        end else if(attr[5:4]=='b11 || attr[5:4]=='b01) begin
            ->abortTDP;
//        end else if(attr[3:0]!='h0) begin
//            $display("  [%0t ns] **WARNING** Bottom four bits of TDP attribute != 0.",$time);
//            ->abortTDP;
        end else
            ->okAttribute;
    end

    always @(negedge N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b00 && (N25Qxxx.protocol=="extended" && attr[5:4] == 'b00)) begin : TDPread_x1
        if(N25Qxxx.ck_count==0) begin
            //dataOut=tdp_reg[tdp_counter];
            //KS: update tdp output
            dataOut = 
              {tdp_reg[tdp_counter*4][4], tdp_reg[tdp_counter*4][0],
               tdp_reg[tdp_counter*4+1][4], tdp_reg[tdp_counter*4+1][0],
               tdp_reg[tdp_counter*4+2][4], tdp_reg[tdp_counter*4+2][0],
               tdp_reg[tdp_counter*4+3][4], tdp_reg[tdp_counter*4+3][0]};
            if(tdp_counter == 15) begin
                tdp_counter = 0;
            end else begin
                tdp_counter = tdp_counter + 1;
            end
        end
        N25Qxxx.bitOut = dataOut[dataDim-1-N25Qxxx.ck_count];
        ->N25Qxxx.sendToBus;
    end //TDPread_x1

    always @(negedge N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b00 && (N25Qxxx.protocol=="dual" ||
                                  (N25Qxxx.protocol=="extended" && attr[5:4] == 'b01))) begin : TDPread_x2 
        if(N25Qxxx.ck_count==0 || N25Qxxx.ck_count==4) begin
            dataOut=tdp_reg[tdp_counter];
            if(tdp_counter == 31) begin
                tdp_counter = 0;
            end else begin
                tdp_counter = tdp_counter + 1;
            end
        end
        #tCLQX
        N25Qxxx.dualQuad.bitOut = dataOut[ dataDim-1 - (2*(N25Qxxx.ck_count%4)) ]; //%=modulo operator
        N25Qxxx.dualQuad.bitOut_extra = dataOut[ dataDim-2 - (2*(N25Qxxx.ck_count%4)) ]; 
        ->N25Qxxx.dualQuad.sendToBus_dual;
    end //TDPread_x2

    always @(negedge N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b00 && (N25Qxxx.protocol=="quad" ||
                                  (N25Qxxx.protocol=="extended" && attr[5:4] == 'b10))) begin : TDPread_x4
        if(N25Qxxx.ck_count==0 || N25Qxxx.ck_count==2 || N25Qxxx.ck_count==4 || N25Qxxx.ck_count==6) begin
            dataOut=tdp_reg[tdp_counter];
            if(tdp_counter == 63) begin
                tdp_counter = 0;
            end else begin
                tdp_counter = tdp_counter + 1;
            end
        end
        `ifdef HOLD_pin
        force N25Qxxx.intHOLD = 1;
        `endif
        #tCLQX
        N25Qxxx.dualQuad.bitOut3 = dataOut[ dataDim-1 - (4*(N25Qxxx.ck_count%2)) ]; //%=modulo operator
        N25Qxxx.dualQuad.bitOut2 = dataOut[ dataDim-2 - (4*(N25Qxxx.ck_count%2)) ]; 
        N25Qxxx.dualQuad.bitOut1 = dataOut[ dataDim-3 - (4*(N25Qxxx.ck_count%2)) ]; 
        N25Qxxx.dualQuad.bitOut0 = dataOut[ dataDim-4 - (4*(N25Qxxx.ck_count%2)) ]; 
        ->N25Qxxx.dualQuad.sendToBus_quad;
    end //TDPread_x4

    always @(posedge N25Qxxx.S) if(N25Qxxx.latchingMode=="3" && attr[7:6] == 'b00) begin
        tdp_counter = 0;
    end

    //program
    //latch data pattern (extended)
    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b01 && (N25Qxxx.protocol=="extended" && attr[5:4] == 'b00)) begin : CP_latchData_x1
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif

        byteHolder[bitCounter] = N25Qxxx.DQ0;
        if(bitCounter == 0) begin
            //tdp_reg_temp[tdp_counter] = byteHolder;
            //KS: update the data scramble
            tdp_reg_temp[tdp_counter*4]    = {3'h7, byteHolder[7], 3'h7, byteHolder[6]};
            tdp_reg_temp[tdp_counter*4+1]  = {3'h7, byteHolder[5], 3'h7, byteHolder[4]};
            tdp_reg_temp[tdp_counter*4+2]  = {3'h7, byteHolder[3], 3'h7, byteHolder[2]};
            tdp_reg_temp[tdp_counter*4+3]  = {3'h7, byteHolder[1], 3'h7, byteHolder[0]};
            tdp_counter = tdp_counter + 1;
            bitCounter = 8;
        end
        //bytePattern0[iData] = N25Qxxx.DQ0;
        bitCounter = bitCounter - 1;

        iData = iData + 1;
     end        
    end //CP_latchData_x1

    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b01 && (N25Qxxx.protocol=="dual" ||
                                  (N25Qxxx.protocol=="extended" && attr[5:4] == 'b01))) begin : CP_latchData_x2  
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif
        ->N25Qxxx.Debug.x10;
        byteHolder[bitCounter] = N25Qxxx.DQ1;
        byteHolder[bitCounter-1] = N25Qxxx.DQ0;

        if(bitCounter==1) begin
            tdp_reg_temp[tdp_counter] = byteHolder;
            //N25Qxxx.latchingMode = "3";
            tdp_counter = tdp_counter + 1;
            bitCounter = 7;
            //iStartAddr = addrDimLatch4+1;
        end else    
            bitCounter = bitCounter - 2;
     end        
    end //CP_latchData_x2

    always @(N25Qxxx.C) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b01 && (N25Qxxx.protocol=="quad" ||
                                  (N25Qxxx.protocol=="extended" && attr[5:4] == 'b10))) begin : CP_latchData_x4
        N25Qxxx.quadMode = 1;
      `ifdef MEDITERANEO
      if (((N25Qxxx.C==0) && (N25Qxxx.VolatileEnhReg.VECR[5] == 0) && (iCmd2 != 7)) || (N25Qxxx.C == 1)) begin 
      `else
      if (N25Qxxx.C==1) begin  
      `endif
        `ifdef HOLD_pin
        byteHolder[bitCounter] = N25Qxxx.HOLD_DQ3;
        `elsif RESET_pin
        byteHolder[bitCounter] = N25Qxxx.RESET_DQ3;
        `endif
        byteHolder[bitCounter-1] = N25Qxxx.Vpp_W_DQ2;
        byteHolder[bitCounter-2] = N25Qxxx.DQ1;
        byteHolder[bitCounter-3] = N25Qxxx.DQ0;
        if(bitCounter==3) begin
            tdp_reg_temp[tdp_counter] = byteHolder;
            //N25Qxxx.latchingMode = "3";
            tdp_counter = tdp_counter + 1;
            bitCounter = 7;
            //iStartAddr = addrDimLatch4+1;
        end else    
            bitCounter = bitCounter - 4;

        end
    end //CP_latchData_x4

    always @(posedge N25Qxxx.S) if(N25Qxxx.latchingMode=="3" && attr[7:6] == 'b01) begin : TDP_program
        if(`WEL==0) begin
            N25Qxxx.f.WEL_error;
            tdp_counter = 0;
            disable TDP_program;
        end    
        if(iData>129) begin
            $display("[WARNING] TDP program aborted, number of clock cycles %0d exceeds 128\n", iData);
        end else begin
            for(i=0;i<=63;i=i+1)begin
              //KS: update this for the case input is less than 64 bytes
              if (i<iData/2)  tdp_reg[i] = tdp_reg_temp[i];
              else            tdp_reg[i] = 'hFF;
            end
        end
        -> stat.WEL_reset;
        tdp_counter = 0;
        iData = 0;
    end //TDP_program

    //erase
    //always @(posedge N25Qxxx.S) if(N25Qxxx.logicOn && N25Qxxx.latchingMode=="3" && attr[7:6] == 'b10) begin : TDP_erase
    always @(posedge N25Qxxx.S) if(N25Qxxx.latchingMode=="3" && attr[7:6] == 'b10) begin : TDP_erase
        if(`WEL==0) begin
            N25Qxxx.f.WEL_error;
            disable TDP_erase;
        end    
        for(i=0;i<=63;i=i+1)begin
            tdp_reg[i] = 8'hFF;
            tdp_reg_temp[i] = 8'hFF;
        end
        -> stat.WEL_reset;
    end
    always @(abortTDP) begin : abortTDP_due_to_reserved_attribute
            $display("  [%0t ns] **WARNING** Reserved value used for attribute.",$time);
                    disable CP_latchAttr;
                    disable CP_latchAttrDual;
                    disable CP_latchAttrQuad;
                    disable TDPread_x1;
                    disable TDPread_x2;
                    disable TDPread_x4;
                    disable TDP_erase;
                    disable TDP_program;
                    if(attr[7:6]=='b11)
                        -> stat.WEL_reset;
                    //N25Qxxx.flag.FSR[1] = 1;
                    disable abortTDP_due_to_reserved_attribute;
    end
    always @(N25Qxxx.latchingMode or N25Qxxx.S) begin 
        if(N25Qxxx.latchingMode == 2 ||
           N25Qxxx.latchingMode == 3 )
        fork : disableTDP
                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable CP_latchAttr;
                    disable CP_latchAttrDual;
                    disable CP_latchAttrQuad;
                    disable TDPread_x1;
                    disable TDPread_x2;
                    disable TDPread_x4;
                    disable TDP_erase;
                    disable disableTDP;
                end
                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable CP_latchAttr;
                    disable CP_latchAttrDual;
                    disable CP_latchAttrQuad;
                    disable TDPread_x1;
                    disable TDPread_x2;
                    disable TDPread_x4;
                    disable TDP_erase;
                    disable disableTDP;
                end
        join
    end
endmodule //CUIdecoder_TDP
`endif //MEDT_TDP











/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           MEMORY MODULE                               --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps

module Memory(mem_file);

    

    `include "include/DevParam.h"


    input [40*8:1] mem_file;

    //-----------------------------
    // data structures definition
    //-----------------------------

    reg [dataDim-1:0] memory [0:memDim-1];
    reg [dataDim-1:0] page [0:pageDim];




    //------------------------------
    // Memory management variables
    //------------------------------

    reg [addrDim-1:0] memAddr;
    reg [addrDim-1:0] pageStartAddr;
    reg [colAddrDim-1:0] pageIndex = 'h0;
    reg [colAddrDim-1:0] zeroIndex = 'h0;

    integer i;




    //-----------
    //  Init
    //-----------

    initial begin 

        for (i=0; i<=memDim-1; i=i+1) 
            memory[i] = data_NP;
        #1;
        
        // if ( `FILENAME_mem!="" && `FILENAME_mem!=" ") begin
        //     $readmemh(`FILENAME_mem, memory);
        //     $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, `FILENAME_mem);
        // end    
    
        if ( mem_file!="" && mem_file!=" ") begin
          $readmemh(mem_file, memory);
          $display("[%0t ns] ==INFO== 1. Load memory content from file: \"%0s\".", $time, mem_file);
        end    
    end



    // always @(N25Qxxx.Vcc_L2) if((N25Qxxx.Vcc_L2) && ( `FILENAME_mem!="" && `FILENAME_mem!=" ")) begin
    always @(N25Qxxx.Vcc_L2) if(N25Qxxx.Vcc_L2) begin
         
         $readmemh(mem_file, memory);
         $display("[%0t ns] ==INFO== 2. Load memory content from file: \"%0s\".", $time, mem_file);
                     

   end      


    //-----------------------------------------
    //  Task used in program & read operations  
    //-----------------------------------------
    
    task refillMem;
        begin
            for (i=0; i<=memDim-1; i=i+1) 
                memory[i] = data_NP;
            #1;
            if ( mem_file!="" && mem_file!=" ") begin
              $readmemh(mem_file, memory);
              $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, mem_file);
            end    
        end
    endtask //refillMem
    
    // set start address & page index
    // (for program and read operations)
    
    task setAddr;

    input [addrDim-1:0] addr;

    begin

        memAddr = addr;
        pageStartAddr = {addr[addrDim-1:pageAddr_inf], zeroIndex};
        pageIndex = addr[colAddrDim-1:0];
    
    end
    
    endtask



    
    // reset page with FF data

    task resetPage;

    for (i=0; i<=pageDim-1; i=i+1) 
        page[i] = data_NP;

    endtask    


    

    // in program operations data latched 
    // are written in page buffer

    task writeDataToPage;

    input [dataDim-1:0] data;

    begin

        page[pageIndex] = data;
        pageIndex = pageIndex + 1; 

    end

    endtask



    // page buffer is written to the memory

    task programPageToMemory; //logic and between old_data and new_data
       reg value;

    for (i=0; i<=pageDim-1; i=i+1)
      `ifdef Stack512Mb
        begin
            value = setMemory(pageStartAddr+i, getMemory(pageStartAddr+i ) & page [i]);
            //$display("In programPageToMemory: page=%0h, index=%0d",page[i],i);
        end  
    `else
        memory[pageStartAddr+i] = memory[pageStartAddr+i] & page[i];
      `endif
        // before page program the page should be reset
    endtask





    // in read operations data are readed directly from the memory

    task readData;

    output [dataDim-1:0] data;
    reg [addrDim + 1: 0] effAddr;
    begin
      `ifdef Stack512Mb
        //data = getMemory(memAddr); etv May1
        data = memory[memAddr]; // etv May1
      `else
        data = memory[memAddr];
      `endif
        if (memAddr < memDim-1)
            memAddr = memAddr + 1;
        else begin
            memAddr=0;
            `ifdef STACKED_1G_MEDT
            $display("  [%0t ns] **WARNING** Highest address reached. Next read will be at the beginning of the memory!", $time);
            `endif
        end
            //aggiunta
        if (VolatileReg.VCR[1:0]!=2'd3) begin //implements the read data output wrap
               
             case (VolatileReg.VCR[1:0])
                    2'd0 : memAddr = {N25Qxxx.addr[addrDim-1: 4], memAddr[3:0]}; 
                    2'd1 : memAddr = {N25Qxxx.addr[addrDim-1: 5], memAddr[4:0]}; 
                    2'd2 : memAddr = {N25Qxxx.addr[addrDim-1: 6], memAddr[5:0]};
             endcase
                
        end      
            

    end

    endtask




    //---------------------------------------
    //  Tasks used for Page Write operation
    //---------------------------------------


    // page is written into the memory (old_data are over_written)
    
    task writePageToMemory; 
       reg value;

       for (i=0; i<=pageDim-1; i=i+1)begin
      `ifdef Stack512Mb
        value = setMemory(pageStartAddr+i,page[i]);
      `else
        memory[pageStartAddr+i] = page[i];
      `endif
  end
        // before page program the page should be reset
    endtask


    // pageMemory is loaded into the pageBuffer
    
    task loadPageBuffer; 

    for (i=0; i<=pageDim-1; i=i+1)
      `ifdef Stack512Mb
        page[i] = getMemory(pageStartAddr+i);
      `else
        page[i] = memory[pageStartAddr+i];
      `endif
        // before page program the page should be reset
    endtask





    //-----------------------------
    //  Tasks for erase operations
    //-----------------------------

    task eraseSector;
    input [addrDim-1:0] A;
    reg [sectorAddrDim-1:0] sect;
    reg [sectorAddr_inf-1:0] zeros;
    reg [addrDim-1:0] mAddr;
    reg value;
    begin
        sect = f.sec(A);
        zeros = 'h0;
        mAddr = {sect, zeros};
        for(i=mAddr; i<=(mAddr+sectorSize-1); i=i+1) begin
          `ifdef Stack512Mb
             //value= setMemory(i, data_NP); 
             memory[i] = data_NP;
          `else
             memory[i] = data_NP;
          `endif
        end
    
    end
    endtask



    `ifdef SubSect 
    
     task eraseSubsector;
     input [addrDim-1:0] A;
     reg [subsecAddrDim-1:0] subsect;
     reg [subsecAddr_inf-1:0] zeros;
     reg [addrDim-1:0] mAddr;
     reg value;
     begin
    
         subsect = f.sub(A);
         zeros = 'h0;
         mAddr = {subsect, zeros};
         for(i=mAddr; i<=(mAddr+subsecSize-1); i=i+1) begin
          `ifdef Stack512Mb
             //value = setMemory(i, data_NP);
             memory[i] = data_NP;
          `else
             memory[i] = data_NP;
          `endif
         end
    
     end
     endtask

    `endif

    `ifdef MEDT_SubSect32K 
    
     task eraseSubsector32K;
     input [addrDim-1:0] A;
     reg [subsec32AddrDim-1:0] subsect;
     reg [subsec32Addr_inf-1:0] zeros;
     reg [addrDim-1:0] mAddr;
     reg value;
     begin
    
         subsect = f.sub32k(A);
         zeros = 'h0;
         mAddr = {subsect, zeros};
         for(i=mAddr; i<=(mAddr+subsec32Size-1); i=i+1) begin
          `ifdef Stack512Mb
             //value = setMemory(i, data_NP);
             memory[i] = data_NP;
          `else
             memory[i] = data_NP;
          `endif
         end
    
     end
     endtask

    `endif


   // `ifndef Stack512Mb 
    task eraseBulk;
     reg value;
      begin
        for (i=0; i<=memDim-1; i=i+1) begin
          `ifdef Stack512Mb
             //value = setMemory(i, data_NP);
             memory[i] = data_NP;
          `else
             memory[i] = data_NP;
          `endif
        end
      end
    endtask
   // `endif 


   // `ifdef Stack512Mb
    task eraseDie;
     reg value;
      begin
        for (i=0; i<=memDim-1; i=i+1) begin
          `ifdef Stack512Mb
             //value = setMemory(i, data_NP); 
             memory[i] = data_NP; // etv May1
          `else
             memory[i] = data_NP;
          `endif
        end
      end
    endtask
   // `endif


    task erasePage;
    input [addrDim-1:0] A;
    reg [pageAddrDim-1:0] page;
    reg [pageAddr_inf-1:0] zeros;
    reg [addrDim-1:0] mAddr;
    reg value;
      begin
        `ifndef Stack512Mb 
      
          page = f.pag(A);
          zeros = 'h0;
          mAddr = {page, zeros}; 
          for(i=mAddr; i<=(mAddr+pageDim-1); i=i+1) begin
          `ifdef Stack512Mb
             //value = setMemory(i, data_NP);
             memory[i] = data_NP;
          `else
             memory[i] = data_NP;
          `endif
          end
      
        `endif 
      end
    endtask






    

endmodule













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           UTILITY FUNCTIONS                           --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps 

module UtilFunctions;

    `include "include/DevParam.h"

    integer i;

    
    //----------------------------------
    // Utility functions for addresses 
    //----------------------------------


    function [sectorAddrDim-1:0] sec;
    input [addrDim-1:0] A;
        sec = A[sectorAddr_sup:sectorAddr_inf];
    endfunction   

    `ifdef SubSect
        function [subsecAddrDim-1:0] sub;
        input [addrDim-1:0] A;
            `ifdef bottom
            if (sec(A)<=bootSec_num-1)
                sub = A[subsecAddr_sup:subsecAddr_inf];
            `else
                sub = A[subsecAddr_sup:subsecAddr_inf];
            `endif    
        endfunction
    `endif

    `ifdef MEDT_SubSect32K
        function [subsec32AddrDim-1:0] sub32k;
        input [addrDim-1:0] A;
            sub32k = A[subsec32Addr_sup:subsec32Addr_inf];
        endfunction    
    `endif

    function [pageAddrDim-1:0] pag;
    input [addrDim-1:0] A;
        pag = A[pageAddr_sup:pageAddr_inf];
    endfunction

    function [pageAddrDim-1:0] col;
    input [addrDim-1:0] A;
        col = A[colAddr_sup:0];
    endfunction
    
    
    
    
    
    //----------------------------------
    // Console messages 
    //----------------------------------

    task clock_error;
        begin
        //$display("  [%0t ns] **ERROR** Number of clock pulse isn't multiple of eight: operation aborted!", $time);
        $display("  [%0t ns] **WARNING** Number of clock pulse isn't multiple of eight: operation aborted!", $time);
        `ifdef MEDITERANEO
            if(N25Qxxx.cmdRecName=="Write NV Configuration Reg") begin
                NonVolatileReg.NVCR=prog.NVCR_temp;
            end    
        `endif
        end
    endtask



    task WEL_error;
        begin
        //$display("  [%0t ns] **ERROR** WEL bit not set: operation aborted!", $time);
        $display("  [%0t ns] **WARNING** WEL bit not set: operation aborted!", $time);
        end
    endtask



    task out_info;
    
        input [addrDim-1:0] A;
        input [dataDim-1:0] D;

        if(N25Qxxx.die_active == 1) begin 
          if (stat.enable_SR_read)          
         $display("  [%0t ns] Data are going to be output: %b. [Read Status Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
         else if (NonVolatileReg.enable_NVCR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Read Non Volatile Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
         else if (VolatileReg.enable_VCR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Read Volatile Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
                  
         else if (VolatileEnhReg.enable_VECR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Read Enhanced Volatile Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
         `ifdef byte_4         
         else if (ExtAddReg.enable_EAR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Extended Address Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
         `endif         
         else if (flag.enable_FSR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Read Flag Status Register] %d %d",
                  $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          else if (lock.enable_lockReg_read)
          $display("  [%0t ns] Data are going to be output: %h. [Read Lock Register of sector %0d] %d %d",
                    $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          else if (PMReg.enable_PMR_read)
          $display("  [%0t ps] Data are going to be output: %h. [Read Protection Management Register] %d %d",
                    $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
        
          `ifdef MEDT_PPB
          else if (ppb.enable_PPBReg_read)
          $display("  [%0t ps] Data are going to be output: %h. [Read PPB Register of sector %0d] %d %d",
                    $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          else if (plb.enable_PLBReg_read)
          $display("  [%0t ps] Data are going to be output: %h. [Read PPB Lock Bit Register] %d %d",
                    $time, D, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          `endif

          else if (read.enable_ID)
            $display("  [%0t ns] Data are going to be output: %h. [Read ID, byte %0d] %d %d", $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
        
          else if (read.enable_OTP) begin
              if (A!=OTP_dim-1)
                  $display("  [%0t ns] Data are going to be output: %h. [Read OTP memory, column %0d] %d %d", $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
              else  
                  $display("  [%0t ns] Data are going to be output: %b. [Read OTP memory, column %0d (control byte)] %d %d", $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
          end

        `ifdef bottom
        else        
        if (sec(A)<=bootSec_num-1) begin
          
          if (read.enable || read.enable_fast)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d of sector %0d)] %d %d",
                  $time, D, A, col(A), pag(A), sub(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2); 
        
          else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d  sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A), sub(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A),  sub(A),sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
        end
        
        
        else if (read.enable || read.enable_fast)
        $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d)] %d %d",
                  $time, D, A, col(A), pag(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2); 
        
        else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d,sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
                  
        else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
    `else          
        else        
          if (read.enable || read.enable_fast)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d of sector %0d)] %d %d",
                  $time, D, A, col(A), pag(A), sub(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2); 
        
          else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d  sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A), sub(A), sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);

          else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d sector %0d)] %d %d",
                    $time, D, A, col(A), pag(A),  sub(A),sec(A), N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
         else if (read.enable_rsfdp)
         $display("  [%0t ns] Data are going to be output: %h. [Read Serial Flash Discovery Parameter. Address %h] %d %d", $time, D, A, N25Qxxx.rdeasystacken, N25Qxxx.rdeasystacken2);
        
        `endif 
    end //N25Qxxx.die_active
    endtask





    //----------------------------------------------------
    // Special tasks used for testing and debug the model
    //----------------------------------------------------
    

    //
    // erase the whole memory, and resets pageBuffer and cacheBuffer
    //
    
    task fullErase;
    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP; 
        
        $display("[%0t ns] ==INFO== The whole memory has been erased.", $time);

    end
    endtask




    //
    // unlock all sectors of the memory
    //
    
    task unlockAll;
    begin

        for (i=0; i<=nSector-1; i=i+1) begin
            `ifdef LockReg
              lock.LockReg_WL[i] = 0;
              lock.LockReg_LD[i] = 0;
            `endif
            lock.lock_by_SR[i] = 0;
        end

        $display("[%0t ns] ==INFO== The whole memory has been unlocked.", $time);

    end
    endtask




    //
    // load memory file
    //

    task load_memory_file;

    input [40*8:1] memory_file;

    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP;
        
        $readmemh(memory_file, mem.memory);
        $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, `FILENAME_mem);
    
    end
    endtask





endmodule












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           PROGRAM MODULE                              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps

module Program;

    

    `include "include/DevParam.h"
    `include "include/UserData.h"

    

    
    event errorCheck, error, noError, noError2;
    
    reg [40*8:1] operation; //get the value of the command currently decoded by CUI decoders
    reg [40*8:1] oldOperation; // tiene traccia di quale operazione e' stata sospesa
    reg [40*8:1] holdOperation;// tiene traccia nel caso di suspend innestati della prima operazione sospesa

    time delay,delay_resume,startTime,latencyTime;                 
                                 
//variabili aggiunte per gestire il prog/erase suspend
    reg [pageAddrDim-1:0] page_susp; //pagina sospesa
 

    reg [sectorAddrDim-1:0] sec_susp;
    reg [subsecAddrDim-1:0] subsec_susp;
    reg Suspended = 0; //variabile che indica se un'operazione di suspend e' attiva
    reg doubleSuspend = 0; //variabile che indica se ci sono due suspend innestati
    reg prog_susp = 0;//indica che l'operazione sospesa e' un program
    reg sec_erase_susp =0; //indica che l'operazione sospesa e' un sector erase
    reg subsec_erase_susp =0; //indica che l'operazione sospesa e' un subsector erase
    reg resumedFromHWReset = 0;
    reg resumedFromSWReset = 0;
    reg HwResetDuringSSE = 0;
    reg SwResetDuringSSE = 0;



    //--------------------------------------------
    //  Page Program  Dual Program & Quad Program
    //--------------------------------------------


    reg writePage_en=0;
    reg [addrDim-1:0] destAddr;
    reg [addrDim-1:0] destAddrSusp1;
    event checkVPPduringQuadProgram;



    always @N25Qxxx.seqRecognized 
    if((N25Qxxx.cmdRecName=="Page Program" || N25Qxxx.cmdRecName=="Dual Program" || N25Qxxx.cmdRecName=="Quad Program" ||
       N25Qxxx.cmdRecName=="Dual Extended Program" ||  N25Qxxx.cmdRecName=="Quad Extended Program" || 
       N25Qxxx.cmdRecName=="Dual Command Page Program" ||
       N25Qxxx.cmdRecName=="Quad Command Page Program" ) && (N25Qxxx.die_active == 1)) begin : page_program_ops

            `ifdef MEDITERANEO
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable page_program_ops;
                end    
            `endif
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - %s aborted due to Prog/Erase Suspend",$time,N25Qxxx.cmdRecName);
            disable page_program_ops;
          end  

       if(flag.FSR[4]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction. Program Status bit is high!",$time); 
                disable page_program_ops;
       end else if(operation=="Program Erase Suspend" && prog_susp) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction after a program suspend",$time); 
                disable page_program_ops;
                
       `ifdef SubSect    
       end else if(operation=="Program Erase Suspend" && subsec_erase_susp) begin
           
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction after a subsector erase suspend",$time); 
                disable page_program_ops;
       `endif
       end else if(operation=="Program Erase Suspend" && sec_erase_susp && sec_susp==f.sec(N25Qxxx.addr)) begin
           
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction in the sector whose erase cycle is suspend",$time); 
                flag.FSR[4]=1;
                disable page_program_ops;

       end else

       
    //fork : program_ops

           begin

            operation = N25Qxxx.cmdRecName;
            mem.resetPage;
            destAddr = N25Qxxx.addr;
            mem.setAddr(destAddr);
            if(Suspended == 0) destAddrSusp1 = destAddr;
            
            if(operation=="Page Program")
                N25Qxxx.latchingMode="D";
            else if(operation=="Dual Program" || operation=="Dual Extended Program" || operation=="Dual Command Page Program") begin
                N25Qxxx.latchingMode="F";
                release N25Qxxx.DQ1;
            end else if(operation=="Quad Program" || operation=="Quad Extended Program" || operation=="Quad Command Page Program") begin
                N25Qxxx.latchingMode="Q";
                release N25Qxxx.DQ1;
                release N25Qxxx.Vpp_W_DQ2;
                `ifdef HOLD_pin
                release N25Qxxx.HOLD_DQ3;
                `endif
                `ifdef RESET_pin
                release N25Qxxx.RESET_DQ3;
                `endif

            end
  
            
            writePage_en = 1;
            fork: check_noData
                begin : waiting_for_cmdlatched
                    //@N25Qxxx.cmdLatched;
                    @N25Qxxx.dataLatched;
                    disable waiting_for_S;
                end
                begin : waiting_for_S
                    @(posedge N25Qxxx.S);
                    $display("  [%0t ns] BOTCH condition, S asserted without data!", $time);
                    writePage_en=0;
                    N25Qxxx.latchingMode="N";
                    disable waiting_for_cmdlatched;
                    disable page_program_ops;
                end
            join //check_noData

          end   
        
    fork : program_ops
                                                                                                                                                                             

        begin : exe
            
           @(posedge N25Qxxx.S);
            
            disable reset;
            writePage_en=0;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            
                delay=program_delay;

                -> errorCheck;
                -> checkVPPduringQuadProgram;

                @(noError) begin
                   mem.programPageToMemory;
                    $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
                end
           
        end 


        begin : reset
        
          @N25Qxxx.resetEvent;
            writePage_en=0;
            operation = "None";
            disable page_program_ops;    
        
        end

    join

end //page_program_ops



    always @N25Qxxx.dataLatched if(writePage_en) begin

        mem.writeDataToPage(N25Qxxx.data);
    
    end








    //------------------------
    //  Write Status register
    //------------------------


    reg [dataDim-1:0] SR_data;
    reg [dataDim-1:0] SR_temp;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write SR") begin : write_SR_ops

       //prova
       if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable write_SR_ops;
                end    

            `ifdef MEDITERANEO
                if(`SRWD==1 && N25Qxxx.W_int===0) begin
                    $display("  [%0t ns] **WARNING** SRWD bit set to 1, and W=0: write SR isn't allowed!", $time);
                    //-> stat.WEL_reset;
                    disable write_SR_ops;
                end else if(PMReg.PMR[4] == 0 ) begin
                    $display("  [%0t ns] **WARNING** PMR[4] bit set to 1, and write SR isn't allowed!", $time);
                    //-> stat.WEL_reset;
                    disable write_SR_ops;
                end
            `endif
                if(prog.prog_susp==1) begin
                    $display(" [%0t ps] **WARNING** Write SR not allowed while in suspend state.",$time); 
                    -> stat.WEL_reset;
                    disable write_SR_ops;
                end
            `ifdef SR7_OTP
                if(stat.SR[7] == 1'b1) begin
                    $display(" [%0t ps] **WARNING** SR7=0, entire SR is locked.",$time); 
                    -> stat.WEL_reset;
                    disable write_SR_ops;
                end
            `endif

        
        @(posedge N25Qxxx.S) begin: WRSR_ops
            `ifdef MEDITERANEO
                if(N25Qxxx.dataLatchedr==0) begin
                    disable write_SR_ops;
                end    
            `endif
            -> stat.WEL_reset;
            operation=N25Qxxx.cmdRecName;
            SR_data=N25Qxxx.data;
            SR_temp = stat.SR;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            //aggiunta verificare
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write SR.",$time);
            delay=write_SR_delay;
            `ifdef MEDITERANEO
                `SRWD = SR_data[7];  
                `BP3  = SR_data[6];  
                `TB   = SR_data[5]; 
                `BP2  = SR_data[4]; 
                `BP1  = SR_data[3]; 
                `BP0  = SR_data[2]; 
            `endif
            -> errorCheck;

            @(noError) begin
                
                `SRWD = SR_data[7];  
                `BP3  = SR_data[6];  
                `TB   = SR_data[5]; 
                `BP2  = SR_data[4]; 
                `BP1  = SR_data[3]; 
                `BP0  = SR_data[2]; 
 
               #0 $display("  [%0t ns] Command execution completed: Write SR. SR=%h, (SRWD,BP3,TB,BP2,BP1,BP0)=%b",
                           $time, stat.SR, {`SRWD,`BP3,`TB,`BP2,`BP1,`BP0} );
            
            end
                
        end
    
    end

    //----------------------------------------
    //  Write Volatile Configuration register
    //----------------------------------------


    reg [dataDim-1:0] VCR_data;
    reg dummySetByVCR = 0;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Volatile Configuration Reg") begin : write_VCR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin
            `ifdef MEDITERANEO
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable write_VCR_ops;
                end    
            `endif
            operation=N25Qxxx.cmdRecName;
            VCR_data=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Volatile Configuration Reg",$time);
            delay=write_VCR_delay;
            -> errorCheck;

            @(noError) begin
                
                // datasheet specifies that VCR.2 is reserved
                VolatileReg.VCR[7:3]=VCR_data[7:3];
                VolatileReg.VCR[1:0]=VCR_data[1:0];

                $display("  [%0t ns] Command execution completed: Write Volatile Configuration Reg. VCR=%h", 
                           $time, VolatileReg.VCR);
                dummySetByVCR = 1;       
            
            end
                
        end
    
    end



    //--------------------------------------------------
    //  Write Volatile Enhanced Configuration register
    //--------------------------------------------------


    reg [dataDim-1:0] VECR_data;
    reg dummySetByVECR = 0;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write VE Configuration Reg") begin : write_VECR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin : WRVECR_ops
            `ifdef MEDITERANEO
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable WRVECR_ops;
                end    
                if(N25Qxxx.dataLatchedr==0)begin
                    disable write_VECR_ops;
                end    
            `endif
            operation=N25Qxxx.cmdRecName;
            VECR_data=N25Qxxx.data;
            `ifndef MEDITERANEO
            VECR_data[5] = 0;  // DTR is disabled by default
        `endif
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Volatile Enhanced Configuration Reg",$time);
            delay=write_VECR_delay;
            -> errorCheck;

            @(noError) begin
                
                VolatileEnhReg.VECR=VECR_data;
                $display("  [%0t ns] Command execution completed: Write Volatile Enhanced Configuration Reg. VECR=%h", 
                           $time, VolatileEnhReg.VECR);
                dummySetByVECR = 1;       
            
            end
            N25Qxxx.dataLatchedr = 0;    
        end
    
    end

    //---------------------------------------------
    //  Write Non Volatile Configuration register
    //--------------------------------------------


    reg [dataDim-1:0] NVCR_LSByte;
    
    reg [dataDim-1:0] NVCR_MSByte;

    reg LSByte;
    reg [dataDim-1:0] bitCounter; //used for commands requiring more than a byte of data.
    reg [(dataDim*2 -1):0] NVCR_temp;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write NV Configuration Reg") begin : write_NVCR_ops

        if (N25Qxxx.protocol=="dual") begin 
            N25Qxxx.latchingMode="F";
            N25Qxxx.ck_count = 0;
       end else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        LSByte=1;
        bitCounter=0;
            `ifdef MEDITERANEO
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable write_NVCR_ops;
                end    
            `endif
        // added the check to abort writing in NVCR register if locked by PMR --  
         if (PMReg.PMR[7] == 0) begin
                $display(" [%0t ps] **WARNING** Cant write to NVCR reg.PMR bit 7 set is 0.Register locked!",$time); 
                flag.FSR[1] = 1;
                disable NVCR_ops;
                 
        end else if (prog.prog_susp==1) begin
                $display(" [%0t ps] **WARNING** Write NVCR not allowed while in suspend state.",$time); 
                disable write_NVCR_ops;
        end
        else begin
          @(posedge N25Qxxx.S) begin: NVCR_ops
              //if(N25Qxxx.dataLatchedr==0 || bitCounter!=14 ) begin
              if((bitCounter!=14 && N25Qxxx.protocol=="extended")||
                  bitCounter!=2 && N25Qxxx.protocol=="quad") begin
                  bitCounter=0;
                  N25Qxxx.dataLatchedr=0;
                  $display(" [%0t ns] Write NV Configuration Reg aborted!", $time);
                  disable write_NVCR_ops;
              end    
              operation=N25Qxxx.cmdRecName;
              NVCR_LSByte=N25Qxxx.LSdata;
              NVCR_MSByte=N25Qxxx.data;
              `ifdef MEDITERANEO
                NVCR_LSByte[5] = N25Qxxx.LSdata[5]; 
              `else
                NVCR_LSByte[5] = 0; // Reserved for DTR
              `endif
              `ifdef NVCR_1_0_RESERVED
                NVCR_LSByte[1:0] = 2'b11;
              `endif
              N25Qxxx.latchingMode="N";
              N25Qxxx.busy=1;
              startTime = $time;
              $display("  [%0t ns] Command execution begins: Write Non Volatile Configuration Register.",$time);
              delay=write_NVCR_delay;
              -> errorCheck;
                  NVCR_temp = NonVolatileReg.NVCR;
                  NonVolatileReg.NVCR={NVCR_MSByte,NVCR_LSByte}; 
                  `ifdef start_in_byte_4
                    NonVolatileReg.NVCR={NVCR_MSByte,NVCR_LSByte[dataDim-1:1],1'b0}; 
                  `endif

              @(noError) begin
                  
//                  NonVolatileReg.NVCR={NVCR_MSByte,NVCR_LSByte}; 
//                  `ifdef start_in_byte_4
//                    NonVolatileReg.NVCR={NVCR_MSByte,NVCR_LSByte[dataDim-1:1],1'b0}; 
//                  `endif
                  
                  $display("  [%0t ns] Command execution completed: Write Non Volatile Configuration Register. NVCR=%h (%b)",
                             $time, NonVolatileReg.NVCR,NonVolatileReg.NVCR);
              
                N25Qxxx.dataLatchedr=0;
                bitCounter=0;
              end
                  
          end
        end
    
    end

    `ifdef MEDT_ADVANCED_SECTOR
    //---------------------------------------------
    //  Write ASP register
    //--------------------------------------------


    reg [dataDim-1:0] ASP_LSByte = 'hFF;
    
    reg [dataDim-1:0] ASP_MSByte = 'hFF;

//    reg LSByte;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="ASP Write") begin : write_ASP_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else N25Qxxx.latchingMode="D";

          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - ASP Write aborted due to Prog/Erase Suspend",$time);
            disable write_ASP_ops;
          end  
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable write_ASP_ops;
                end    
        LSByte=1;
         if (ASP_Reg.ASP[2] == 0 ) begin
                $display(" [%0t ps] **WARNING** Cant write to ASP register anymore. Write once only.!",$time); 
                //flag.FSR[1] = 1;
                //disable write_ASP_ops;
        end     
         begin
          @(posedge N25Qxxx.S) begin: ASP_ops
              operation=N25Qxxx.cmdRecName;
              ASP_LSByte=N25Qxxx.LSdata;
              ASP_MSByte=N25Qxxx.data;
//              ASP_MSByte='hFF;
              N25Qxxx.latchingMode="N";
              N25Qxxx.busy=1;
              startTime = $time;
              $display("  [%0t ns] Command execution begins: Write ASP Register.",$time);
              //delay=write_ASP_delay;
              delay=write_ASP_delay;
              if (ASP_Reg.ASP[1] == 1 ) begin
                  ASP_Reg.ASP={ASP_MSByte,ASP_LSByte}; 
                  //plb.PLB[0] = 0;
                  `ifdef start_in_byte_4
                    ASP_Reg.ASP={ASP_MSByte,ASP_LSByte[dataDim-1:1],1'b0}; 
                  `endif
              end else begin
                $display(" [%0t ps] **WARNING** Cant write to ASP[1]  anymore. Write once only.!",$time); 
              end
              -> errorCheck;

              @(noError) begin
                  
                  //ASP_Reg.ASP={ASP_MSByte,ASP_LSByte}; 
                  ////plb.PLB[0] = 0;
                  //`ifdef start_in_byte_4
                  //  ASP_Reg.ASP={ASP_MSByte,ASP_LSByte[dataDim-1:1],1'b0}; 
                  //`endif
                  
                  $display("  [%0t ns] Command execution completed: Write ASP Register. ASP=%h (%b)",
                             $time, ASP_Reg.ASP,ASP_Reg.ASP);
              
              end
                  
          end
        end
    
    end
`endif // MEDT_ADVANCED_SECTOR
   
         always  @(posedge N25Qxxx.Vcc_L3) begin
            if (N25Qxxx.cmdRecName == "Write NV Configuration Reg" && N25Qxxx.busy == 1) 
                begin
                    N25Qxxx.rescue_seq_flag = 1;
                    $display("[%0t ps] **WARNING** Power Loss during WRNVCR detected. ", $time);
                end
            //else
            //    N25Qxxx.rescue_seq_flag = 0;
         end
    
    
// write protection management register

    reg [dataDim-1:0] PMR_Byte;
    

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Protection Management Reg") begin : write_PMR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";

          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - ASP Write aborted due to Prog/Erase Suspend",$time);
            disable write_PMR_ops;
          end  
             $display("[%0t ps] WEL.%b",$time,`WEL);
             if(`WEL == 0) begin
                N25Qxxx.f.WEL_error;
                disable write_PMR_ops;
             end   

        if (PMReg.PMR[2] == 0) begin
          //added    
                $display(" [%0t ps] **WARNING** Cant write to PMR reg.PMR bit 2 set is 0.Register locked!",$time); 
	         flag.FSR[1] = 1;
	         flag.FSR[4] = 1;
                disable pmr_ops;

        end else begin

        
        @(posedge N25Qxxx.S) begin : pmr_ops
         //   -> stat.WEL_reset;
            operation=N25Qxxx.cmdRecName;
            PMR_Byte=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ps] Command execution begins: Write PMR Configuration Register.",$time);

             delay=write_PMR_delay;
            -> errorCheck;

            @(noError) begin
                
                PMReg.PMR=PMR_Byte; 

                if(PMReg.PMR[3]==0) begin
                    OTP.mem[64][0]=0;
                end
                
                $display("  [%0t ps] Command execution completed: Write PMR Configuration Register. PMR=%h (%b)",
                           $time, PMReg.PMR,PMReg.PMR);
            end
        end
      end
    end

    `ifdef MEDT_PPB
// write PPB Lock Bit register

    reg [dataDim-1:0] PLB_Byte;
    

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="PPB Lock Bit Write") begin : write_PLB_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";

        if (plb.PLB[0] == 0) begin
          //added    
                $display(" [%0t ps] **WARNING** Can't write to PLB reg.PLB bit set to 0. Register locked!",$time); 
                `WEL = 0;
                disable write_PLB_ops;

        end else begin

        
        @(posedge N25Qxxx.S) begin : plb_ops
         //   -> stat.WEL_reset;
             $display("[%0t ps] WEL.%b",$time,`WEL);
             if(`WEL == 0) begin
                N25Qxxx.f.WEL_error;
                disable plb_ops;
            end
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - PPB Lock Bit Write aborted due to Prog/Erase Suspend",$time);
            disable write_PLB_ops;
          end  
            operation=N25Qxxx.cmdRecName;
            PLB_Byte=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ps] Command execution begins: PPB Lock Bit Write.",$time);
             delay=write_PLB_delay;
            -> errorCheck;

            @(noError) begin
                
                //plb.PLB=PLB_Byte; 
                plb.PLB[7:1]='h0;
                plb.PLB[0]='h0;
                
                $display("  [%0t ps] Command execution completed: PPB Lock Bit Write. PLB=%h (%b)",
                           $time, plb.PLB,plb.PLB);
            end
        end
      end
    end
`endif

`ifdef MEDT_PASSWORD

    reg [dataDim-1:0] PASSWRD_Byte;
    reg writePass_en = 0;
    

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Password Write") begin : write_PASS_ops
        PSWORD_Reg.PSWORD_location = 'h0;
        writePass_en=1;
         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";

        if (ASP_Reg.ASP[2:1] == 'b01) begin
          //added    
                $display(" [%0t ps] **WARNING** Cant write to Password reg. Password Mode is already enabled!",$time); 
                disable write_PASS_ops;

        end else if (ASP_Reg.ASP[2:1] == 'b10) begin

                $display(" [%0t ps] **WARNING** Cant write to Password reg. Persistent Protect Mode Lock Bit enabled!",$time); 
                disable write_PASS_ops;

            end else begin

          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - Password Write aborted due to Prog/Erase Suspend",$time);
            disable write_PASS_ops;
          end  
        
        @(posedge N25Qxxx.S) begin : passwrd_ops
         //   -> stat.WEL_reset;
            writePass_en=0;
             $display("[%0t ps] WEL.%b",$time,`WEL);
             if(`WEL == 0) begin
                N25Qxxx.f.WEL_error;
                disable write_PASS_ops;
            end
            operation=N25Qxxx.cmdRecName;
            PLB_Byte=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ps] Command execution begins: Password Write.",$time);
             delay=write_PASSP_delay;
            -> errorCheck;

            @(noError) begin
                
                PSWORD_Reg.PSWORD=PLB_Byte; 
                PSWORD_Reg.programPassToRegister; 
                $display("  [%0t ps] Command execution completed: Password Write. PassWord=%h (%b)",
                           $time, PSWORD_Reg.PSWORD,PSWORD_Reg.PSWORD);
            end
        end
      end
    end
    
    always @N25Qxxx.dataLatched if(writePass_en) begin
        PSWORD_Reg.writeDataToPasswordBuffer(N25Qxxx.data);
    end    

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Password Unlock") begin : write_PASSUNLOCK_ops
                if(prog.prog_susp==1) begin
                    $display(" [%0t ps] **WARNING** Password Unlock not allowed while in suspend state.",$time); 
                    disable write_PASSUNLOCK_ops;
                end
        PSWORD_Reg.PSWORD_location = 'h0;
        writePass_en=1;
         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";

        if (ASP_Reg.ASP[2] == 1) begin
          //added    
                $display(" [%0t ps] **WARNING** Not in Password Protect Mode.",$time); 
                disable passwrdUnlock_ops;

        end else begin

        
        @(posedge N25Qxxx.S) begin : passwrdUnlock_ops
         //   -> stat.WEL_reset;
            writePass_en=0;
             $display("[%0t ps] WEL.%b",$time,`WEL);
           // if(`WEL == 0)
           // N25Qxxx.f.WEL_error;
            operation=N25Qxxx.cmdRecName;
            PLB_Byte=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ps] Command execution begins: Password Unlock.",$time);
             delay=0;
            -> errorCheck;

            @(noError) begin
                
              if(PSWORD_Reg.IsPasswordOK(1)) begin
                $display("  [%0t ps] Command execution completed: Password Unlock Succeeded. PassWord=%h (%b)",
                           $time, PSWORD_Reg.PSWORD,PSWORD_Reg.PSWORD);
                           plb.PLB[0] = 1; 
                   end else begin        
                $display("  [%0t ps] Command execution completed: Password Unlock FAILED!. PassWord=%h (%b)",
                           $time, PSWORD_Reg.PSWORD,PSWORD_Reg.PSWORD);
                   end
            end
        end
      end
    end
`endif

`ifdef byte_4

    //--------------------------------------------------
    //  Write Extended Address register
    //--------------------------------------------------


    reg [dataDim-1:0] WEAR_data;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write EAR") begin : write_EAR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin
            //`ifndef Feature_8
                $display("[%0t ps] WEL.%b",$time,`WEL);
                if(`WEL == 0) begin
                    N25Qxxx.f.WEL_error;
                    disable write_EAR_ops;
                end
                if(N25Qxxx.dataLatchedr==0) begin
                    disable write_EAR_ops;
                end    
            //`endif
            operation=N25Qxxx.cmdRecName;
            WEAR_data=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Extended Address Register",$time);
            delay=write_EAR_delay; //immagino ci sia!!!!
            -> errorCheck;

            @(noError) begin

              if(addrDim > 24) begin
                 
                ExtAddReg.EAR[addrDim - 25 :0] =WEAR_data[addrDim - 25 :0];
                $display("  [%0t ns] Command execution completed: Write Extended Address Register. EAR=%h", 
                           $time, ExtAddReg.EAR);
                         if(ExtAddReg.EAR[EARvalidDim-1:0]==0) $display("[%0t ns] ==INFO== Bottom 128M selected",$time);
                         else $display("[%0t ns] ==INFO== Top 128M selected",$time);

              end
              N25Qxxx.dataLatchedr=0;
            end
                
        end
    
    end


`endif

    //--------------
    // Erase
    //--------------

    always @N25Qxxx.seqRecognized 
    
    if ((N25Qxxx.cmdRecName==="Sector Erase" || N25Qxxx.cmdRecName==="Subsector Erase" || N25Qxxx.cmdRecName==="Subsector Erase 32K" ||N25Qxxx.cmdRecName==="Subsector Erase 32K 4Byte" ||
        N25Qxxx.cmdRecName==="Bulk Erase" || N25Qxxx.cmdRecName==="Die Erase") && (N25Qxxx.die_active == 1))begin : erase_operations
    
            `ifdef MEDITERANEO
                if(`WEL==0) begin
                    N25Qxxx.f.WEL_error;
                    disable erase_operations;
                end    
            `endif
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - %s aborted due to Prog/Erase Suspend",$time,N25Qxxx.cmdRecName);
            disable erase_operations;
          end  
        if(flag.FSR[5]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction. Erase Status bit is high!",$time); 
                disable erase_operations;
                
        end else if(operation=="Program Erase Suspend" && prog_susp=='b1) begin
           
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a program suspend",$time); 
                 disable erase_operations;

        end else  if(operation=="Program Erase Suspend" && sec_erase_susp=='b1) begin
        
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a sector erase suspend",$time); 
                 disable erase_operations;
        `ifdef SubSect
        end else  if(operation=="Program Erase Suspend" && subsec_erase_susp=='b1) begin
                 
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a subsector erase suspend",$time); 
                 disable erase_operations;
        `endif      
        end else      
        fork : erase_ops

        begin : exe
        
           @(posedge N25Qxxx.S);

            disable reset;

            operation = N25Qxxx.cmdRecName;
            destAddr = N25Qxxx.addr;
            if(Suspended == 0) destAddrSusp1 = destAddr;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy = 1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            if (operation=="Sector Erase") delay=erase_delay;
            `ifdef Stack512Mb
              else if (operation=="Die Erase") delay=erase_die_delay;
            `elsif STACKED_MEDT_1G  
              else if (operation=="Die Erase") delay=erase_die_delay;
            `elsif STACKED_MEDT_2G  
              else if (operation=="Die Erase") delay=erase_die_delay;
            `else
              else if (operation=="Bulk Erase") delay=erase_bulk_delay;
            `endif
            `ifdef SubSect
              else if (operation=="Subsector Erase")  delay=erase_ss_delay; 
            `endif  
            `ifdef MEDT_SubSect32K
              else if (operation=="Subsector Erase 32K")  delay=erase_ss32k_delay; 
            `endif  
            `ifdef MEDT_SubSect32K4byte
              else if (operation=="Subsector Erase 32K 4Byte")  delay=erase_ss32k_delay; 
            `endif  
            
            -> errorCheck;

            @(noError) 
                begin
                    if (operation=="Sector Erase")          mem.eraseSector(destAddr);
                    `ifdef Stack512Mb
                      else if (operation=="Die Erase")       mem.eraseDie;
                    `elsif STACKED_MEDT_1G  
                     else if (operation=="Die Erase")       mem.eraseDie;
                    `elsif STACKED_MEDT_2G  
                     else if (operation=="Die Erase")       mem.eraseDie;
                    `else
                      else if (operation=="Bulk Erase")       mem.eraseBulk;
                    `endif
                    `ifdef SubSect
                      else if (operation=="Subsector Erase")  mem.eraseSubsector(destAddr); 
                    `endif
                    `ifdef MEDT_SubSect32K
                      else if (operation=="Subsector Erase 32K") mem.eraseSubsector32K(destAddr);  
                    `endif  
                    `ifdef MEDT_SubSect32K4byte
                      else if (operation=="Subsector Erase 32K 4Byte") mem.eraseSubsector32K(destAddr);  
                    `endif  
                    `ifdef STACKED_MEDT_2G
                        $display("  [%0t ns] Command execution completed: %0s. die=%0d", $time, operation, N25Qxxx.rdeasystacken);
                    `else
                        $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
                    `endif
                end
        end


        begin : reset
        
          @N25Qxxx.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join
end

//------------------------
// Program Erase Suspend
//-------------------------


 always @N25Qxxx.seqRecognized 
    
    if ((N25Qxxx.cmdRecName==="Program Erase Suspend") && (N25Qxxx.die_active == 1)) begin : PES_ops
    
        if (operation=="Bulk Erase" || operation=="Die Erase" || operation=="Program OTP") begin
            $display("[%0t ns] %0s can't be suspended", $time, operation);
        end else if (operation=="Write Protection Management Reg" || operation=="Write SR" || 
            operation=="Write NV Configuration Reg" || operation=="Write PPB Reg") begin 
            $display("[%0t ns] %0s can't be suspended", $time, operation);
            disable PES_ops;
        end
        else if(prog.resumedFromHWReset == 1) $display("[%0t ns] %0s PES after HW Reset is rejected I", $time, operation);
        else if(prog.resumedFromSWReset == 1) $display("[%0t ns] %0s PES after SW Reset is rejected II", $time, operation);
        //else if(prog.HwResetDuringSSE == 1) $display("[%0t ns] %0s PES after HW Reset is rejected III", $time, operation);
        //else if(prog.SwResetDuringSSE == 1) $display("[%0t ns] %0s PES after SW Reset is rejected IV", $time, operation);

        else fork : progerasesusp_ops
        
            begin : exe
            
               @(posedge N25Qxxx.S);

                disable reset;
                if (Suspended) begin 
                    holdOperation=oldOperation;
                    doubleSuspend=1;
                end   
                if(operation != "Program Erase Resume") begin
                  oldOperation = operation; //operazione sospesa
                end
                operation = N25Qxxx.cmdRecName;
                N25Qxxx.latchingMode="N";
                if(oldOperation == "Subsector Erase 32K 4Byte" || oldOperation == "Subsector Erase 32K" || oldOperation == "Subsector Erase" || oldOperation == "Sector Erase") begin
                      flag.FSR[6] = 1;
                  #eraseSusp_latencyTime; // (non definito ancora)
                  Suspended = 1;
                end  
                else begin
                           flag.FSR[2] = 1;
                  #progSusp_latencyTime; // (non definito ancora)
                  N25Qxxx.busy = 0; //WIP =0; FSR[2]=1
                  -> stat.WEL_reset;
                  Suspended = 1;
              end
                if (oldOperation=="Sector Erase") begin
                    latencyTime = erase_latency;
                    delay_resume=erase_delay-($time - startTime);
                    sec_erase_susp = 1;
                    sec_susp= f.sec(destAddr);
                      flag.FSR[6] = 1;
                    disable erase_operations;
                    //-disable errorCheck_ops;
                end
                `ifdef SubSect
                  else if (oldOperation=="Subsector Erase" || oldOperation=="Subsector Erase 32K" || oldOperation=="Subsector Erase 32K 4Byte") begin
                        latencyTime = erase_ss_latency;
                        delay_resume=erase_ss_delay-($time - startTime);
                        subsec_erase_susp = 1;
                        sec_susp= f.sec(destAddr);
                          flag.FSR[6] = 1;
                        disable erase_operations;
                    //-etv    disable errorCheck_ops;
                  end  
                `endif  
                  else if (oldOperation=="Page Program" || oldOperation=="Dual Program" || oldOperation=="Quad Program" ||
                           oldOperation=="Dual Extended Program" || oldOperation=="Quad Extended Program" || 
                           oldOperation=="Dual Command Page Program" || oldOperation=="Quad Command Page Program") begin
                           latencyTime = program_latency;
                           delay_resume=program_delay-($time - startTime);
                           $display("--->>> delay_resume= %t, program_delay= %t, time= %t, startTime= %t", delay_resume, program_delay, $time, startTime);
                           prog_susp = 1;
                           flag.FSR[2] = 1;
                           page_susp = f.pag(destAddr);
                           disable page_program_ops;
                           disable errorCheck_ops;
                  end
            end


        begin : reset
        
          @N25Qxxx.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join

  end


 //------------------------
 // Program Erase Resume
 //-------------------------

always @N25Qxxx.seqRecognized 
  begin
    #1;
    // $display("RESUME: Entered in program erase resume %s " ,N25Qxxx.cmdRecName, $time);
    
    if ((N25Qxxx.cmdRecName==="Program Erase Resume") && (N25Qxxx.die_active == 1)) fork :resume_ops


        begin : exe

                if(prog.prog_susp==0) begin
                    $display(" [%0t ps] **WARNING** Program Erase Resume command aborted, device not in suspend mode.",$time); 
                    disable resume_ops;
                end
            
           @(posedge N25Qxxx.S);
            
            disable reset;
            operation = N25Qxxx.cmdRecName;
            N25Qxxx.latchingMode="N";
            delay=delay_resume;
            
            if (doubleSuspend==1) begin 
                Suspended=1;
            end 
            else Suspended=0;
            N25Qxxx.busy=1;
            
            -> errorCheck;
            fork 

                 begin : susp1
                    @(noError);
                    if (oldOperation=="Sector Erase")  begin
                        if(Suspended == 1) mem.eraseSector(destAddr);
                        else mem.eraseSector(destAddrSusp1);
                        sec_erase_susp = 0;
                    end    
                    `ifdef SubSect
                    else if (oldOperation=="Subsector Erase" || oldOperation=="Subsector Erase 32K" || oldOperation=="Subsector Erase 32K 4Byte") begin
                        if(Suspended == 1) mem.eraseSector(destAddr);
                        else mem.eraseSector(destAddrSusp1);
                        subsec_erase_susp = 0;
                    end    
                        
                    `endif
                    else begin
                        if(Suspended == 0) mem.setAddr(destAddrSusp1);
                        mem.writePageToMemory;
                        prog_susp = 0;
                    end 
                    
                    $display(" [%0t ns] Command execution completed: %0s.", $time, oldOperation);
                    if (doubleSuspend==1) begin 
                       doubleSuspend=0;
                       oldOperation=holdOperation;
                   end    
                   disable susp2;
                end

                begin : susp2
                  @(posedge Suspended);
                  disable susp1;
                end
            join
                
        end 


        begin : reset
        
          @N25Qxxx.resetEvent;
            writePage_en=0;
            operation = "None";
            disable exe;    
        
        end

    join

  end

always @N25Qxxx.resumeSSEfromSwReset
begin
            operation = N25Qxxx.cmdRecName;
            N25Qxxx.latchingMode="N";
            delay=delay_resume;
            
            if (doubleSuspend==1) begin 
                Suspended=1;
            end 
            else Suspended=0;
            N25Qxxx.busy=1;
            
            -> errorCheck;
            fork 

                 begin : susp1a
                    @(noError);
                    `ifdef SubSect
                    if (oldOperation=="Subsector Erase" || oldOperation=="Subsector Erase 32K" || oldOperation=="Subsector Erase 32K 4Byte") begin
                        mem.eraseSubsector(destAddr); 
                        subsec_erase_susp = 0;
                        ->N25Qxxx.SSEresumeDone;
                    end    
                    `endif
                    $display(" [%0t ns] Command execution completed: %0s.", $time, oldOperation);
                    if (doubleSuspend==1) begin 
                       doubleSuspend=0;
                       oldOperation=holdOperation;
                   end    
                   //disable susp2;
                end
            join
        end            

always @N25Qxxx.resumeSSEfromHwReset
        begin
            operation = N25Qxxx.cmdRecName;
            N25Qxxx.latchingMode="N";
            delay=delay_resume;
            
            if (doubleSuspend==1) begin 
                Suspended=1;
            end 
            else Suspended=0;
            N25Qxxx.busy=1;
            
            -> errorCheck;
            fork 

                 begin : susp1b
                    @(noError);
                    `ifdef SubSect
                    if (oldOperation=="Subsector Erase" || oldOperation=="Subsector Erase 32K" || oldOperation=="Subsector Erase 32K 4Byte") begin
                        mem.eraseSubsector(destAddr); 
                        subsec_erase_susp = 0;
                        ->N25Qxxx.SSEresumeHwDone;
                        resumedFromHWReset = 0;
                    end    
                    `endif
                    $display(" [%0t ns] Command execution completed: %0s.", $time, oldOperation);
                    if (doubleSuspend==1) begin 
                       doubleSuspend=0;
                       oldOperation=holdOperation;
                   end    
                   //disable susp2;
                end
            join
        end            
    //---------------------------
    //  Program OTP 
    //---------------------------

    
        reg write_OTP_buffer_en=0;
     
         `define OTP_lockBit N25Qxxx.OTP.mem[OTP_dim-1][0]

         always @N25Qxxx.seqRecognized if((N25Qxxx.cmdRecName=="Program OTP") && (N25Qxxx.die_active == 1)) begin : OTP_PROG

           if(flag.FSR[4] || !PMReg.PMR[3]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction. Program Status bit is high!",$time); 
                disable OTP_prog_ops;
           end else
        if(`WEL == 0) begin
            N25Qxxx.f.WEL_error;
            disable OTP_PROG;
        end    
                if(prog.prog_susp==1) begin
                    $display(" [%0t ps] **WARNING** Program OTP not allowed while in suspend state.",$time); 
                    disable OTP_PROG;
                end

        fork : OTP_prog_ops

            begin
                OTP.resetBuffer;
                OTP.setAddr(N25Qxxx.addr);
                if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
                else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
                else N25Qxxx.latchingMode="D";
                write_OTP_buffer_en = 1;
            end

            begin : exe
               @(posedge N25Qxxx.S);
                disable reset;
                operation=N25Qxxx.cmdRecName;
                write_OTP_buffer_en=0;
                N25Qxxx.latchingMode="N";
                N25Qxxx.busy=1;
                startTime = $time;
                $display("  [%0t ns] Command execution begins: OTP Program.",$time);
                `ifdef MEDITERANEO
                    delay=program_OTP_delay;
                `else    
                    delay=program_delay;
                `endif
                -> errorCheck;

                @(noError) begin
                    OTP.writeBufferToMemory;
                    $display("  [%0t ns] Command execution completed: OTP Program.",$time);
                end
            end  

            begin : reset
               @N25Qxxx.resetEvent;
                write_OTP_buffer_en=0;
                operation = "None";
                disable exe;    
            end
        
        join

    end


        always @N25Qxxx.dataLatched if(write_OTP_buffer_en) begin

            OTP.writeDataToBuffer(N25Qxxx.data);
        
        end

reg enable_4Byte_address;// enable_4Byte_address =1 the device accept 4 bytes of address 
`ifdef byte_4
//-----------------------
// 4-byte address
//-------------------------


`ifndef disEN4BYTE
always @N25Qxxx.seqRecognized if (N25Qxxx.cmdRecName=="Enable 4 Byte Address") fork : CP_enable4ByteAddress

    begin : exe
        @(posedge N25Qxxx.S);
        disable reset;
        //`ifndef Feature_8
        //if(`WEL == 1) 
        if(`WEL == 0) begin
            N25Qxxx.f.WEL_error;
            disable CP_enable4ByteAddress;
        end    
        //`endif    
    `ifdef MEDITERANEO
        if(`WEL == 1) 
        `endif
        begin
            -> stat.WEL_reset;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Enable 4 Byte Address.",$time);
            delay=enable4_address_delay;
            #delay;
            //->errorCheck;

            //@(noError) begin
                enable_4Byte_address=1;
                $display("  [%0t ns] Command execution completed: Enable 4 Byte Address.",$time);
            //end
        end
    end

    begin : reset
        @N25Qxxx.resetEvent;
        disable exe;
    end

join
`endif

`ifndef disEX4BYTE
always @N25Qxxx.seqRecognized if (N25Qxxx.cmdRecName=="Exit 4 Byte Address") fork : CP_exit4ByteAddress
 
    begin : exe
        @(posedge N25Qxxx.S);
        disable reset;
        //`ifndef Feature_8 
        if(`WEL == 0) begin
            N25Qxxx.f.WEL_error;
            disable exe;
        end    
        //`endif    

            -> stat.WEL_reset;
        begin
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Exit 4 Byte Address.",$time);
            delay=exit4_address_delay;

            #delay;
            //->errorCheck;

            //@(noError) begin
                    enable_4Byte_address=0;
                    $display("  [%0t ns] Command execution completed: Exit 4 Byte Address.",$time);
            //end
        end
    end

    begin : reset
        @N25Qxxx.resetEvent;
        disable exe;
    end

join
`endif
`endif



    //------------------------
    //  Error check
    //------------------------
    // This process also models  
    // the operation delays
    

    always @(errorCheck) fork : errorCheck_ops
    
    
        begin : static_check

            if((operation=="Dual Extended Program" || N25Qxxx.protocol=="dual")) begin 
                if((N25Qxxx.DoubleTransferRate == 0 && (N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0)) ||
                   (N25Qxxx.DoubleTransferRate == 1 && (N25Qxxx.ck_count!=6 && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=2))) begin
                    N25Qxxx.f.clock_error;
                    -> error;
                end    
//            end else if ((operation=="Quad Extended Program"|| N25Qxxx.protocol=="quad") && N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && 
//                         N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6) begin 
            end else if ((operation=="Quad Extended Program"|| N25Qxxx.protocol=="quad")) begin
                        if((N25Qxxx.DoubleTransferRate == 0 && (N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6)) ||
                           (N25Qxxx.DoubleTransferRate == 1 && (N25Qxxx.ck_count!=1) && operation=="PPB Lock Bit Write")) begin 
                        N25Qxxx.f.clock_error;
                        -> error;
                    end
            end else if(operation!="Dual Extended Program" && operation!="Quad Program" && operation!="Quad Extended Program" && operation!="Dual Command Page Program" && 
                        operation!="Dual Program" &&
                        operation!="Page Program" && 
                       N25Qxxx.protocol=="extended" ) begin
                            if((N25Qxxx.DoubleTransferRate == 0 && N25Qxxx.ck_count!=0) ||
                               //(N25Qxxx.DoubleTransferRate == 1 && (N25Qxxx.ck_count!=4 && operation == "Write NV Configuration Reg"))) 
                               (N25Qxxx.DoubleTransferRate == 1 && (N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0))) begin 
                                N25Qxxx.f.clock_error;
                                -> error;
                            end         
                            
            end else if(`WEL==0 && operation !="Program Erase Resume" ) begin
               
                if(prog.resumedFromHWReset == 0) begin 
                //`ifndef Feature_8
                    N25Qxxx.f.WEL_error;
                    -> error;
                //`endif
                end    
            
            //end else if ( (operation=="Page Program" || operation=="Dual Program" || operation=="Dual Extended Program" || 
            end 
                if ( (operation=="Page Program" || operation=="Dual Program" || operation=="Dual Extended Program" || 
                           operation=="Quad Extended Program" || operation=="Quad Program" || operation=="Dual Command Page Program" || operation=="Quad Command Page Program" ||
                           operation=="Sector Erase" ||  operation=="Subsector Erase" || operation=="Subsector Erase 32K" || operation=="Subsector Erase 32K 4Byte")

                                                        &&
                          `ifdef Stack512Mb
                            //(isProtected_by_SR_stack(destAddr)!==0 || lock.isProtected_by_lockReg(destAddr)!==0) ) begin
                            (lock.isProtected_by_SR(destAddr)!==0 || lock.isProtected_by_lockReg(destAddr)!==0) ) begin
                          `else
                            `ifdef MEDT_PPB  
                            ((lock.isProtected_by_SR(destAddr)!==0 || lock.isProtected_by_lockReg(destAddr)!==0) || 
                               ppb.isProtected_by_PPBReg(destAddr)!==1 || lock4kb.isProtected_by_lockReg(destAddr)!==0)) begin
                            `else    
                            (lock.isProtected_by_SR(destAddr)!==0 || lock.isProtected_by_lockReg(destAddr)!==0)) begin
                            `endif    
                          `endif
           
                -> error;


                `ifdef Stack512Mb
                  if (isProtected_by_SR_stack(destAddr)!==0 && lock.isProtected_by_lockReg(destAddr)!==0)
                `else
                  if (lock.isProtected_by_SR(destAddr)!==0 && lock.isProtected_by_lockReg(destAddr)!==0)
                `endif
                $display("  [%0t ns] **WARNING** Sector locked by Status Register and by Lock Register: operation aborted.", $time);
            
                `ifdef Stack512Mb
                //else if (isProtected_by_SR_stack(destAddr)!==0)
                else if (lock.isProtected_by_SR(destAddr)!==0)
                `else
                else if (lock.isProtected_by_SR(destAddr)!==0)
                `endif
                $display("  [%0t ns] **WARNING** Sector locked by Status Register: operation aborted.", $time);
            
                else if (lock.isProtected_by_lockReg(destAddr)!==0) 
                $display("  [%0t ns] **WARNING** Sector locked by Lock Register: operation aborted.", $time);
                `ifdef MEDT_4KBLocking
                else if (lock4kb.isProtected_by_lockReg(destAddr)!==0) 
                $display("  [%0t ns] **WARNING** Subsector locked by Lock Register: operation aborted.", $time);
                `endif

                `ifdef MEDT_PPB
                else if (ppb.isProtected_by_PPBReg(destAddr)!==1) 
                $display("  [%0t ns] **WARNING** Sector locked by PPB Register: operation aborted.", $time);
                `endif
             
                `ifdef MEDT_PPB
            end else if (operation=="Bulk Erase" && (lock.isAnySectorProtected(0) || ppb.isAnySectorProtected(0))) begin
            `else
            end else if (operation=="Bulk Erase" && (lock.isAnySectorProtected(0))) begin
                `endif
                
                $display("  [%0t ns] **WARNING** Some sectors are locked: bulk erase aborted.", $time);
                -> error;
            
                `ifdef MEDT_PPB
            end else if (operation=="Die Erase" && (lock.isAnySectorProtected(0) || ppb.isAnySectorProtected(0))) begin
                `else
            end else if (operation=="Die Erase" && (lock.isAnySectorProtected(0))) begin
                `endif
                
                $display("  [%0t ns] **WARNING** Some sectors are locked: die erase aborted.", $time);
                -> error;
            
            end 
            /*
            else if (operation=="Bulk Erase" && N25Qxxx.Vpp_W_DQ2==0) begin
                 $display("  [%0t ns] **WARNING** Vpp_W=0 : bulk erase aborted.", $time);
                 -> error;
            
            end 
            else if (operation=="Die Erase" && N25Qxxx.Vpp_W_DQ2==0) begin
                 $display("  [%0t ns] **WARNING** Vpp_W=0 : bulk erase aborted.", $time);
                 -> error;
            
            end */
            
              //else if(operation=="Write SR" && `SRWD==1 && N25Qxxx.W_int===0) begin
               //   $display("  [%0t ns] **WARNING** SRWD bit set to 1, and W=0: write SR isn't allowed!", $time);
              //    prog.SR_data = prog.SR_temp;
              //    -> error;
              //end
              else if(operation=="Write SR" && PMReg.PMR[4] == 0  ) begin
                  $display("  [%0t ns] **WARNING** PMR[4] bit set to 1, and write SR isn't allowed!", $time);
                  -> error;
              end
               else if(operation=="Write NV Configuration Reg" && PMReg.PMR[7] == 0 ) begin
                  $display("  [%0t ps] **WARNING** PMR bit set to 0 write to NVCR not allowed!", $time);
                  -> error;
              end

             else if(operation=="Write Protection Management Reg" && PMReg.PMR[2] == 0 ) begin
                  $display("  [%0t ps] **WARNING** PMR bit set to 0 write to PMR not allowed!", $time);
                  -> error;
              end

              // added the additional check for PMR bit 3 set to 0 which means the array locked  
                    else if ((operation=="Program OTP" && `OTP_lockBit==0)|| (operation == "Program_OTP" && PMReg.PMR[3] == 0)) begin 
                    $display("  [%0t ps] **WARNING** OTP is read only, because lock bit has been programmed to 0: operation aborted.", $time);
                    -> error;    
                    end
            
        end

        fork : dynamicCheck

            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> error;
            end
            
            `ifdef RESET_pin
//              if (operation!="Write SR") @(N25Qxxx.resetEvent) begin
//                $display("  [%0t ns] **WARNING** Operation Fault because of Device Reset!", $time);
//                -> error;
//              end
                  if (operation!="Write SR" && operation!="Subsector Erase" && oldOperation!="Subsector Erase"
                      && operation!="Subsector Erase 32K" && operation!="Subsector Erase 32K 4Byte") @(N25Qxxx.resetEvent) begin
                    $display("  [%0t ns] **WARNING** Operation Fault because of Device Reset!", $time);
                    -> error;
                end  
            `endif  
            // #delay begin 
            begin : main_ops
              #delay;
            N25Qxxx.busy=0;
                if(!Suspended || !prog.prog_susp) -> stat.WEL_reset;
                -> noError;
                #1; 
                -> noError2;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
        join

        
    join




    always @(error) begin

        N25Qxxx.busy = 0;
        // -> stat.WEL_reset;
        disable errorCheck_ops;
        if (operation=="Page Program" || operation=="Dual Program" || operation=="Quad Program" || operation=="Quad Command Page Program" || operation=="Dual Command Page Program" 
             || operation=="Dual Extended Program" || operation=="Quad Extended Program") disable page_program_ops;
        else if (operation=="Sector Erase" || operation=="Subsector Erase" || operation=="Bulk Erase" || operation=="Die Erase"
             || operation=="Subsector Erase 32K" || operation=="Subsector Erase 32K 4Byte") disable erase_operations;
        else if (operation=="Write SR") disable write_SR_ops;
        else if (operation=="Write Protection Management Reg") disable write_PMR_ops; // added to error check
        `ifdef MEDT_PPB
        else if (operation=="PPB Lock Bit Write") disable write_PLB_ops; 
        else if (operation=="Write PPB Reg") disable ppb.WRPPB;
        `endif
        `ifdef MEDT_PASSWORD
        else if (operation=="Password Write") disable write_PASS_ops; 
        `endif
        else if (operation=="Write NV Configuration Reg") disable write_NVCR_ops;  // added to error check 
        else if (operation=="Write VE Configuration Reg") disable write_VECR_ops;  // added to error check 
        else if (operation=="Write Volatile Configuration Reg") disable write_VCR_ops;  // added to error check 
        else if (operation=="Program OTP") disable OTP_PROG;
        //else if (operation=="Program OTP") disable OTP_prog_ops;
        `ifdef byte_4
        else if (operation=="Write EAR") disable write_EAR_ops; 
        `endif
    end

    `ifndef MEDITERANEO
    always @(checkVPPduringQuadProgram) fork : checkVPP_during_quad_ops
        begin : exe1
            @N25Qxxx.Vpp_W_DQ2;
            disable exe2;
        end    
        begin : exe2      
        if(operation=="Quad Command Page Program") begin
            #200;
            if(N25Qxxx.Vpp_W_DQ2 == 0)
                $display("[%0t]***WARNING*** VPP did not rise within 200ns",$time);
                disable exe1;
                N25Qxxx.protocol = "extended"; 
            end    
        end    
    join //checkVPP_during_quad_ops
    `endif

    task disableOperations;
        begin
        N25Qxxx.busy = 0;
        // -> stat.WEL_reset;
        disable errorCheck_ops;
        if (operation=="Page Program" || operation=="Dual Program" || operation=="Quad Program" || operation=="Quad Command Page Program" || operation=="Dual Command Page Program" 
             || operation=="Dual Extended Program" || operation=="Quad Extended Program") disable page_program_ops;
        else if (operation=="Sector Erase" || operation=="Subsector Erase" || operation=="Bulk Erase" || operation=="Die Erase"
             || operation=="Subsector Erase 32K" || operation=="Subsector Erase 32K 4Byte") disable erase_operations;
        else if (operation=="Write NV Configuration Reg") disable write_NVCR_ops; 
        else if (operation=="Write VE Configuration Reg") disable write_VECR_ops;  // added to error check 
        else if (operation=="Write Volatile Configuration Reg") disable write_VCR_ops;  // added to error check 
        `ifdef byte_4
        else if (operation=="Write EAR") disable write_EAR_ops; 
    `endif
        else if (operation=="Program OTP") disable OTP_PROG;
        `ifdef MEDT_ADVANCED_SECTOR
        else if (operation=="ASP Write") disable write_ASP_ops;
    `endif
        `ifdef MEDT_PPB
        else if (operation=="Write PPB Reg") disable ppb.WRPPB;
    `endif
        else if (operation=="Program Erase Suspend") begin 
            prog.prog_susp=0;
            disable PES_ops;
        end    
        `ifdef MEDT_PASSWORD
        else if (operation=="Password Write") disable write_PASS_ops; 
        `endif
        else if (operation=="Write Protection Management Reg") begin
            PMReg.PMR=prog.PMR_Byte;
                if(PMReg.PMR[3]==0) begin
                    OTP.mem[64][0]=0;
                end
            disable write_PMR_ops;
        end    
        else if (operation=="Write SR") begin
            `ifdef MEDITERANEO
            disable write_SR_ops;
                `SRWD = SR_data[7];  
                `BP3  = SR_data[6];  
                `TB   = SR_data[5]; 
                `BP2  = SR_data[4]; 
                `BP1  = SR_data[3]; 
                `BP0  = SR_data[2]; 
                -> Debug.debugSR;
            `endif   
            end        
     prog.prog_susp=0;

     end 
    endtask



endmodule












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER MODULE                      --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module StatusRegister;


    `include "include/DevParam.h"



    // status register
    reg [7:0] SR;
    




    //--------------
    // Init
    //--------------


    initial begin
        
        //see alias in DevParam.h
        
        SR[2] = 0; // BP0 - block protect bit 0 
        SR[3] = 0; // BP1 - block protect bit 1
        SR[4] = 0; // BP2 - block protect bit 2
        SR[5] = 0; // TB (block protect top/bottom) 
        SR[6] = 0; // BP3 - block protect bit 3
        SR[7] = 0; // SRWD

    end


    always @(N25Qxxx.PollingAccessOn) if(N25Qxxx.PollingAccessOn) begin
        
        SR[0] = 1; // WIP - write in progress
        SR[1] = 0; // WEL - write enable latch

    end

    always @(N25Qxxx.checkProtocol) begin
        
        SR[0] = 0; // WIP - write in progress
        SR[1] = 0; // WEL - write enable latch

    end

    always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) begin
        
        SR[0] = 0; // WIP - write in progress
       // SR[1] = 0; // WEL - write enable latch

    end



        


     


    //----------
    // WIP bit
    //----------
    
    always @(N25Qxxx.busy)
        `WIP = N25Qxxx.busy;

   
    //----------
    // WEL bit 
    //----------
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Enable") fork : WREN 
        
        begin : exe
          @(posedge N25Qxxx.S); 
          disable reset;
          `WEL = 1;
          $display("  [%0t ns] Command execution completed: WEL bit set.", $time);
        end

        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
    
    join


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Disable") fork : WRDI 
        
        begin : exe
          @(posedge N25Qxxx.S);
          disable reset;
          `WEL = 0;
          $display("  [%0t ns] Command execution completed: WEL bit reset.", $time);
        end
        
        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
        
    join


    event WEL_reset;
    always @(WEL_reset)
        `WEL = 0;


    

    //------------------------
    // write status register
    //------------------------

    // see "Program" module



    //----------------------
    // read status register
    //----------------------
    // NB : "Read SR" operation is also modelled in N25Qxxx.module

    reg enable_SR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read SR") begin : READ_SR 
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
    fork
        enable_SR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_SR_read=0;
        
    join    

end


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER MODULE                      --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module FlagStatusRegister;


    `include "include/DevParam.h"



    // status register
    reg [7:0] FSR;
    




    //--------------
    // Init
    //--------------


    initial begin
        FSR[0] = 0; // Reserved (N25Q032),4th address mode enabled(N25Q256)
        FSR[1] = 0; // Protection Status bit 
        FSR[2] = 0; // Program Suspend Status bit 
        FSR[3] = 0; // VPP status bit not implemented
        FSR[4] = 0; // Program Status bit
        FSR[5] = 0; // Erase Status bit 
        FSR[6] = 0; // Erase Suspend status bit 
        FSR[7] = 1; // P/E Controller bit(!WIP)


    end



    //-----------------------
    // P/E Controller bit
    //-----------------------
      always @(`WIP)
              FSR[7]=!(`WIP);

`ifdef byte_4
    //-----------------------
    // 4th address mode enabled bit
    //-----------------------

    always @(N25Qxxx.prog.enable_4Byte_address) 
    
        FSR[0]=N25Qxxx.prog.enable_4Byte_address;

`endif

    //------------------------------
    // Erase and Program Suspend bit 
    //------------------------------
    
    always @(N25Qxxx.seqRecognized) if ((N25Qxxx.cmdRecName=="Program Erase Suspend" && FSR[7]==1 && (N25Qxxx.die_active == 1))) begin  
        if (prog.oldOperation=="Sector Erase" || prog.oldOperation=="Subsector Erase" || prog.oldOperation=="Subsector Erase 32K" || prog.oldOperation=="Subsector Erase 32K 4Byte")  FSR[6]=1;
        else FSR[2]=1;  
    end

    always @(N25Qxxx.seqRecognized) if ((N25Qxxx.cmdRecName=="Program Erase Resume") && (N25Qxxx.die_active == 1)) begin
       if (prog.oldOperation=="Sector Erase" || prog.oldOperation=="Subsector Erase" || prog.oldOperation=="Subsector Erase 32K" || prog.oldOperation=="Subsector Erase 32K 4Byte")  FSR[6]=0;
       else FSR[2]=0;
        end
        
    always @N25Qxxx.SSEresumeHwDone begin
        FSR[6]=0;
    end


//------------------------------------------
// Erase Status bit and Program Status bit 
//------------------------------------------

     always @ prog.error if(`WEL == 1) begin

       if (prog.operation=="Sector Erase" || prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte" || prog.operation=="Bulk Erase" || prog.operation=="Die Erase" )  FSR[5]=1;
        else if (prog.operation=="Program OTP" || prog.operation=="Page Program" || prog.operation=="Dual Program" ||
                 prog.operation=="Quad Program" || prog.operation=="Dual Extended Program" || prog.operation=="Quad Extended Program") 
             FSR[4]=1;  

     end

//-------------------
// Vpp Status bit 
//-------------------

//not implemented 


// `define OTP_lockBit N25Qxxx.OTP.mem[OTP_dim-1][0]
//------------------------
// Protection Status bit 
//------------------------

always @ prog.error  if (((prog.operation=="Page Program" || prog.operation=="Dual Program" ||
                           prog.operation=="Dual Extended Program" || prog.operation=="Quad Extended Program" ||
                           prog.operation=="Quad Program" || prog.operation=="Sector Erase" || 
                           prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte")
                                                        &&
                          `ifdef Stack512Mb
                            (isProtected_by_SR_stack(prog.destAddr)!==0 || lock.isProtected_by_lockReg(prog.destAddr)!==0))
                          `else
                            (lock.isProtected_by_SR(prog.destAddr)!==0 || lock.isProtected_by_lockReg(prog.destAddr)!==0))
                          `endif
                                                           ||
                           (prog.operation=="Bulk Erase" && lock.isAnySectorProtected(0)) 
                                                           ||
                           (prog.operation=="Die Erase" && lock.isAnySectorProtected(0)) 
                                                           ||
                           (prog.operation=="Write SR" && `SRWD==1 && N25Qxxx.W_int===0)
                                                           ||
                            (prog.operation=="Program OTP" && `OTP_lockBit==0))  
                               
                          
                    begin
           
                         FSR[1]=1;

                    end




 //---------------------------
 // read flag status register
 //---------------------------
    // NB : "Read FSR" operation is also modelled in N25Qxxx.module

    reg enable_FSR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Flag SR") fork : READ_FSR 
        
        enable_FSR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_FSR_read=0;
        
    join  

//---------------------------
// clear flag status register
//---------------------------
     always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Clear Flag SR") begin  
        
         @(posedge N25Qxxx.S) begin
         
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            $display("  [%0t ns] Command execution begins:Clear Flag Status Register.",$time);
            
            #(clear_FSR_delay);
            
            N25Qxxx.busy=0;
            
            #0;
            FSR[1] = 0; // Protection Status bit 
            FSR[3] = 0; // VPP status bit
            FSR[4] = 0; // Program Status bit
            FSR[5] = 0; // Erase Status bit 
            $display("  [%0t ns] Command execution completed: Clear Flag Status Register. FSR=%b",
                         $time, FSR);
                        
         end

     end    

       
endmodule   



// adding the new register Protection management register for read

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   PRTOTECTION MANAGEMENT REGISTER MODULE              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module ProtectionManagementRegister;

    `include "include/DevParam.h"

    parameter [7:0] ProcManReg_default = 'b11111111;
   
    // non volatile configuration register

    reg [7:0] PMR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        PMR[7:0] = ProcManReg_default;

    end


    //------------------------------------------
    // write Non Volatile Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Non Volatile Configuration register
    //-----------------------------------------
    // NB : "Read Non Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_PMR_read ;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Protection Management Reg") begin
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
    fork 
        
        enable_PMR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_PMR_read=0;
        
    join    
    end
 endmodule    





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   NON VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module NonVolatileConfigurationRegister(NVConfigReg);

    `include "include/DevParam.h"

    // parameter [15:0] NVConfigReg_default = 'b1111111111111110;
    // parameter [15:0] NVConfigReg_default = 'b1111111111111111;
    // parameter [15:0] NVConfigReg_default = NVCR_DEFAULT_VALUE;
    input [15:0] NVConfigReg;
   
    // non volatile configuration register

    reg [15:0] NVCR = 'hFFFF;

     
    //--------------
    // Init
    //--------------


    initial begin
        #1;
        // $display("In NVCR : nvcr default value is %h  and nvcr=%h",NVConfigReg ,NVCR, $time);
        
        NVCR[15:0] = NVConfigReg;
        // NVCR[15:0] = NVConfigReg_default;
                                            // NVCR[15:12] = 'b1111; //dummy clock cycles number (default)
                                            // NVCR[11:9] = 'b111; // XIP disabled (default)
                                            // NVCR[8:6] = 'b111; //Output driver strength (default)
                                            // NVCR[5] = 'b1; //Double Transfer Rate disabled(default)
                                            // NVCR[4] = 'b1; // Reset/Hold enabled(default)
                                            // NVCR[3] = 'b1; //Quad Input Command disabled (default)
                                            // NVCR[2] = 'b1; //Dual Input Command disabled (default)
                                            // NVCR[1] = 'b1; //reserved default 1(N25Q032),128MB segment enabled for 3bytes operations (default)(N25Q256)
                                            // NVCR[0] = 'b1; //reserved default 1(N25Q032), Address mode selection(default)(N25Q256)
                                            
        
    end


    //------------------------------------------
    // write Non Volatile Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Non Volatile Configuration register
    //-----------------------------------------
    // NB : "Read Non Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_NVCR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read NV Configuration Reg") begin : READ_NVCR
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        
    fork 
        
        enable_NVCR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_NVCR_read=0;
        
    join    
end

    


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module VolatileConfigurationRegister;

    `include "include/DevParam.h"

    parameter [7:0] VConfigReg_default = 'b11111011;
   
    // volatile configuration register

    reg [7:0] VCR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        VCR[7:0] = VConfigReg_default;
                                            // VCR[7:4] = 'b1111; //dummy clock cycles number (default)
                                            // VCR[3] = 'b1; // XIP disabled (default)
                                            // VCR[2] = 'b0; //reserved
                                            //VCR[1:0]='b11 // wrap. Continous reading (Default): All bytes are read sequentially
        
    end


    //------------------------------------------
    // write Volatile Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Volatile Configuration register
    //-----------------------------------------
    // NB : "Read Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_VCR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Volatile Configuration Reg") begin : READ_VCR
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
            @(posedge N25Qxxx.C);
            @(negedge N25Qxxx.C);
            end
        `endif
        
        
        fork 
        
        enable_VCR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_VCR_read=0;
        
    join    

end  


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   NON VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module VolatileEnhancedConfigurationRegister;

    `include "include/DevParam.h"

    `ifdef MEDITERANEO
    parameter [7:0] VEConfigReg_default = 'b11111111;
`else
    parameter [7:0] VEConfigReg_default = 'b11011111;
`endif

    // non volatile configuration register

    reg [7:0] VECR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        VECR[7:0] = VEConfigReg_default;
                                            // VECR[7] = 'b1; //quad input command disable (default)
                                            // VECR[6] = 'b1; // dual input command disable (default)
                                            // VECR[5] = 'b1; //DTR disable (default 1 = off)
                                            // VECR[4] = 'b1; // Reset/Hold disable(default)
                                            // VECR[3] = 'b1; //Accelerator pin enable in Quad SPI protocol(default) //not implemented
                                            //VECR[2:0] ='b111; // Output driver strength
        
    end

always @VECR if (N25Qxxx.Vcc_L2) begin

if (VECR[7]==0) N25Qxxx.protocol="quad";
else if (VECR[6]==0) N25Qxxx.protocol="dual";
else if (VECR[7]==1 && VECR[6]==1) N25Qxxx.protocol="extended";
 $display("[%0t ns] ==INFO== Protocol selected is %0s",$time,N25Qxxx.protocol);

 `ifdef MEDITERANEO
 if (VECR[5] == N25Qxxx.DoubleTransferRate) begin // this is true if host is changing DTR mode
     N25Qxxx.DoubleTransferRate = !VECR[5];
     $display("[%0t ps] ==INFO== %0s Transfer Rate selected", $time, (N25Qxxx.DoubleTransferRate ? "Double" : "Single"));
 end
 `endif

end


    //------------------------------------------
    // write Volatile Enhanced Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Volatile Enhanced Configuration register
    //-----------------------------------------
    // NB : "Read Volatile Enhanced Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_VECR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read VE Configuration Reg")begin : READ_VECR 
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        fork 
        
        enable_VECR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_VECR_read=0;
        
    join    
end

`ifdef ENRSTQIO 

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Enable QPI Mode") fork : EQIO 
        
        begin : exe
          @(posedge N25Qxxx.S); 
          disable reset;
          VECR[7] = 0;
          $display("  [%0t ns] Command execution: Enable QPI, setting VECR[7] to 0.", $time);
        end

        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
    
    join


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Reset QPI Mode") fork : RSTQIO 
        
        begin : exe
          @(posedge N25Qxxx.S);
          disable reset;
          VECR[7] = 1;
          $display("  [%0t ns] Command execution: Reset QPI, setting VECR[7] to 1", $time);
        end
        
        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
        
    join


    event VECR7_reset;
    always @(VECR7_reset)
        VECR[7] = 0;


`endif //ENRSTQIO



    



endmodule   


`ifdef MEDT_PASSWORD
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   PASSWORD REGISTER MODULE                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module PasswordRegister();

    `include "include/DevParam.h"

    reg [(8*8)-1:0] PSWORD = 64'hFFFF_FFFF_FFFF_FFFF;
    //reg [(8*8)-1:0] PSWORD = 'h0011_2233_44cc_ddee;
    reg [(8*8)-1:0] passwordBuffer = 64'hFFFF_FF00_FFFF_FFFF;
    reg passwordReadNotAllowed = 0;

    integer i;
    //-----------------------------------------
    // Read PSWORD register
    //-----------------------------------------
    // NB : "Read Non Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_PSWORD_read;
    reg [3:0] PSWORD_location;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Password Read") begin
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        
        fork 
        
        PSWORD_location = 0;
        enable_PSWORD_read=1;

        if(ASP_Reg.ASP[2] == 1 && ASP_Reg.ASP[1] == 1)
            begin
                $display("[%0t ns] **INFO** Password read is allowed. (ASP.2 = 1)", $time);
                passwordReadNotAllowed = 0;
            end 
        else if(ASP_Reg.ASP[2] == 0 || ASP_Reg.ASP[1] == 0)
            begin
                $display("[%0t ns] **WARNING** Password can't be read when Password Protect Mode is enabled (ASP.2 = 0)", $time);
                passwordReadNotAllowed = 1;
            end
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            begin
                enable_PSWORD_read=0;
                passwordReadNotAllowed = 0;
            end
    join    

end 

    task writeDataToPasswordBuffer;

    input [dataDim-1:0] data;

    begin

        passwordBuffer[(PSWORD_location*8) +: 8] = data;
        PSWORD_location = PSWORD_location + 1; 

    end

    endtask

    task programPassToRegister; //logic and between old_data and new_data
       reg value;

    for (i=0; i<=8; i=i+1)
        PSWORD[(i*8) +: 8] = passwordBuffer[(i*8) +: 8];
        // before page program the page should be reset
    endtask

    function IsPasswordOK;
        input test;
        begin
            IsPasswordOK = 0;
            if (PSWORD == passwordBuffer) IsPasswordOK = 1;
            else IsPasswordOK = 0;
        end
    endfunction

endmodule   

`endif // MEDT_PASSWORD





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           READ MODULE                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module Read;


    `include "include/DevParam.h"
    
   
   
    reg enable, enable_fast, enable_rsfdp = 0;
     `ifdef MEDITERANEO
         reg succeedingReads = 0;
     `endif




    //--------------
    //  Read
    //--------------
    // NB : "Read" operation is also modelled in N25Qxxx.module
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read") 
    begin

        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
            @(posedge N25Qxxx.C);
            @(negedge N25Qxxx.C);
            end
        `endif
        
        fork 
        
        begin
           
            if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin    
                enable = 1;
                mem.setAddr(N25Qxxx.addr);
            end    
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin 
            enable=0;
            `ifdef MEDITERANEO
                succeedingReads = 0;
            `endif
        end
    join
end




    //--------------
    //  Read Fast
    //--------------

    always @(N25Qxxx.seqRecognized) if ((N25Qxxx.cmdRecName=="Read Fast") || 
                                        (N25Qxxx.cmdRecName=="Read Fast DTR") 
                                        ) fork :READFAST_d

        begin
             if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin 
                if(N25Qxxx.protocol == "extended" || N25Qxxx.protocol == "dual") begin
                    if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin
                        if(N25Qxxx.cmdRecName == "Read Fast") begin 
                            if(N25Qxxx.DoubleTransferRate==0) begin
                                N25Qxxx.dummyDimEff = 8; 
                                N25Qxxx.iDummy = 7;
                            end else begin
                                N25Qxxx.dummyDimEff = `defaultDummy; 
                                N25Qxxx.iDummy = `defaultiDummy;
                            end
                        end else begin
                            N25Qxxx.dummyDimEff = `defaultDummy; 
                            N25Qxxx.iDummy = `defaultiDummy;
                        end
                    end else begin
                        N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                        N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                    end
                end   

            
            mem.setAddr(N25Qxxx.addr);
            $display("  [%0t ns] Dummy byte expected ...",$time);
            N25Qxxx.latchingMode="Y"; //Y=dummy
            @N25Qxxx.dummyLatched;
            enable_fast = 1;
            N25Qxxx.latchingMode="N";

            end
        end

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
            enable_fast=0;
            disable READFAST_d;
        end    
    
    join


   //-----------------------------
   //  Read Flash Discovery Table
   //-----------------------------

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Serial Flash Discovery Parameter") fork : READ_SFDP_ops

        begin
            
            FlashDiscPar.setAddr(N25Qxxx.addr);
            $display("  [%0t ns] Dummy byte expected ...",$time);
            N25Qxxx.latchingMode="Y"; //Y=dummy
            if(VolatileEnhReg.VECR[7:6] == 'b10)
            begin
                N25Qxxx.iDummy = 7; // Dual
                N25Qxxx.read.enable_dual = 1;
                N25Qxxx.read.enable_quad = 0;
            end
            else if(VolatileEnhReg.VECR[7:6] == 'b01)
            begin
                N25Qxxx.iDummy = 7; // Quad
                N25Qxxx.read.enable_dual = 0;
                N25Qxxx.read.enable_quad = 1;
            end    
            else 
            begin
                N25Qxxx.iDummy = 7;
                N25Qxxx.read.enable_dual = 0;
                N25Qxxx.read.enable_quad = 0;
            end
            @N25Qxxx.dummyLatched;
            enable_rsfdp = 1;
            N25Qxxx.latchingMode="N";

        end

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
            enable_rsfdp=0;
            N25Qxxx.read.enable_dual = 0;
            N25Qxxx.read.enable_quad = 0;
            disable READ_SFDP_ops;
        end        
    
    join





    //-----------------
    //  Read ID
    //-----------------

    reg enable_ID;
    reg [4:0] ID_index;

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read ID") 
    begin 
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif

        fork 
        
        begin
            enable_ID = 1;
            ID_index=0;
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_ID=0;
        
    join
    end

    //--------------------------
    // Multiple I/O Read ID
    //--------------------------


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Multiple I/O Read ID") 
        
    begin 
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        fork 
        
        begin
            enable_ID = 1;
            ID_index=0;
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_ID=0;
        
    join
    end

    //-------------
    //  Dual Read  
    //-------------

    reg enable_dual=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Dual Output Fast Read" ||
                                          N25Qxxx.cmdRecName=="Dual I/O Fast Read" ||
                                          N25Qxxx.cmdRecName=="Dual Command Fast Read" ||
                                          N25Qxxx.cmdRecName=="Dual Command Fast Read DTR" ||
                                          N25Qxxx.cmdRecName=="Dual Command DOFRDTR" ||
                                          N25Qxxx.cmdRecName=="Dual Command DIOFRDTR" ||
                                          N25Qxxx.cmdRecName=="Extended command DOFRDTR" ||
                                          N25Qxxx.cmdRecName=="Extended command DIOFRDTR"
                                          ) fork :DUAL_d

          begin

           if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin
                if(N25Qxxx.protocol == "dual" || N25Qxxx.protocol == "extended") begin
                    if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin  
                        if(N25Qxxx.cmdRecName=="Extended command DIOFRDTR" ||
                           N25Qxxx.cmdRecName=="Extended command DOFRDTR" ||
                           N25Qxxx.cmdRecName=="Dual Command DOFRDTR" ||
                           N25Qxxx.cmdRecName=="Dual Command Fast Read DTR" ||
                           N25Qxxx.cmdRecName=="Dual Command DIOFRDTR") begin
                            N25Qxxx.dummyDimEff = `defaultDummy; 
                            N25Qxxx.iDummy = `defaultiDummy;
                        end else begin
                            if(N25Qxxx.DoubleTransferRate == 0) begin
                                N25Qxxx.dummyDimEff = 8; 
                                N25Qxxx.iDummy = 7;
                            end else begin
                                N25Qxxx.dummyDimEff = `defaultDummy; 
                                N25Qxxx.iDummy = `defaultiDummy;
                            end
                        end
                    end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                    end
                end     
            
              mem.setAddr(N25Qxxx.addr);
              $display("  [%0t ns] Dummy byte expected ...",$time);
              
              N25Qxxx.latchingMode="Y"; //Y=dummy
              @N25Qxxx.dummyLatched;
              enable_dual = 1;
              N25Qxxx.latchingMode="N";

             end 
          end 

          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
              enable_dual=0;
              disable DUAL_d;
          end    
    
      join



  //-------------------------
  //  Quad Read  
  //-------------------------

    reg enable_quad=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Quad Output Read" ||
                                          N25Qxxx.cmdRecName=="Quad I/O Fast Read" ||
                                          `ifdef MEDT_4READ4D
                                          N25Qxxx.cmdRecName=="Word Read Quad I/O" ||
                                          N25Qxxx.cmdRecName=="Word Read Quad Command Fast Read" ||
                                          `endif
                                          N25Qxxx.cmdRecName=="Quad Command Fast Read" || 
                                          N25Qxxx.cmdRecName=="Quad Command Fast Read DTR" || 
                                          N25Qxxx.cmdRecName=="Quad Command QOFRDTR" || 
                                          N25Qxxx.cmdRecName=="Quad Command QIOFRDTR" || 
                                          N25Qxxx.cmdRecName=="Extended command QOFRDTR" ||
                                          N25Qxxx.cmdRecName=="Extended command QIOFRDTR" 
                                          ) fork :QUAD_d

          begin

           if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(N25Qxxx.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if (prog.subsec_erase_susp && prog.sec_susp==f.sec(N25Qxxx.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector cointaining the subsector whose erase cycle is suspended",$time);


            else begin
                //if(N25Qxxx.dummySetByNVCR == 0 && prog.dummySetByVECR == 0 && prog.dummySetByVCR == 0 && N25Qxxx.protocol == "quad") begin
                if((N25Qxxx.protocol == "quad" || N25Qxxx.protocol == "extended") && 
                    (N25Qxxx.cmdRecName != "Quad Output Read" && N25Qxxx.cmdRecName != "Quad Command QOFRDTR" && N25Qxxx.cmdRecName != "Extended command QOFRDTR" &&
                     //N25Qxxx.cmdRecName != "Extended command QIOFRDTR" && N25Qxxx.cmdRecName != "Quad I/O Fast Read")) begin
                     N25Qxxx.cmdRecName != "Extended command QIOFRDTR"  && N25Qxxx.cmdRecName != "Quad Command Fast Read DTR" &&
                     N25Qxxx.cmdRecName != "Quad Command QIOFRDTR")) begin
                    if(prog.dummySetByVCR == 1) begin
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin  
                            N25Qxxx.dummyDimEff = 10; 
                            N25Qxxx.iDummy = 9;
                        end
                        else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                        end
                            `ifdef MEDT_4READ4D
                                if (N25Qxxx.cmdRecName=="Word Read Quad I/O" || N25Qxxx.cmdRecName=="Word Read Quad Command Fast Read") begin
                                    N25Qxxx.dummyDimEff = 4; 
                                    N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                                end
                            `endif
                    end
                    else if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin  
                        N25Qxxx.dummyDimEff = 10; 
                        N25Qxxx.iDummy = 9;
                            `ifdef MEDT_4READ4D
                                if (N25Qxxx.cmdRecName=="Word Read Quad I/O" || N25Qxxx.cmdRecName=="Word Read Quad Command Fast Read") begin
                                    N25Qxxx.dummyDimEff = 4; 
                                    N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                                end
                            `endif
                    end else begin
                        N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                        N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                        //N25Qxxx.dummyDimEff = 8; 
                        //N25Qxxx.iDummy = 7;
                            `ifdef MEDT_4READ4D
                                if (N25Qxxx.cmdRecName=="Word Read Quad I/O" || N25Qxxx.cmdRecName=="Word Read Quad Command Fast Read") begin
                                    N25Qxxx.dummyDimEff = 4; 
                                    N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                                end
                            `endif
                    end
                end
                else begin
                    `ifdef MEDITERANEO
                    if(N25Qxxx.cmdRecName=="Extended command QOFRDTR" && N25Qxxx.protocol=="extended" ) begin
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            N25Qxxx.dummyDimEff = `defaultDummy; 
                            N25Qxxx.iDummy = `defaultiDummy;
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else if (N25Qxxx.cmdRecName=="Quad Command QOFRDTR" && N25Qxxx.protocol=="quad") begin    
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            N25Qxxx.dummyDimEff = 8; 
                            N25Qxxx.iDummy = 7;
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else if (N25Qxxx.cmdRecName=="Quad Output Read" && N25Qxxx.protocol=="extended") begin    
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            if(N25Qxxx.DoubleTransferRate == 0) begin
                                N25Qxxx.dummyDimEff = 8; 
                                N25Qxxx.iDummy = 7;
                            end else begin
                                N25Qxxx.dummyDimEff = `defaultDummy; 
                                N25Qxxx.iDummy = `defaultiDummy;
                            end
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else begin
                        if(prog.dummySetByVCR == 1) begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                        end else begin
                            N25Qxxx.dummyDimEff = 8; 
                            N25Qxxx.iDummy = 7;
                        end    
//                        if(N25Qxxx.cmdRecName=="Extended command QOFRDTR" || N25Qxxx.cmdRecName=="Quad Command QOFRDTR") begin
//                            if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
//                                N25Qxxx.dummyDimEff = 8; 
//                                N25Qxxx.iDummy = 7;
//                            end else begin
//                                N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
//                                N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
//                            end
//                        end
                    end
                `else
                    if(N25Qxxx.cmdRecName=="Extended command QOFRDTR" && N25Qxxx.protocol=="extended" ) begin
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            N25Qxxx.dummyDimEff = `defaultDummy; 
                            N25Qxxx.iDummy = `defaultiDummy;
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else if (N25Qxxx.cmdRecName=="Quad Command QOFRDTR" && N25Qxxx.protocol=="quad") begin    
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            N25Qxxx.dummyDimEff = 8; 
                            N25Qxxx.iDummy = 7;
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else if (N25Qxxx.cmdRecName=="Quad Output Read" && N25Qxxx.protocol=="extended") begin    
                        if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin 
                            if(N25Qxxx.DoubleTransferRate == 0) begin
                                N25Qxxx.dummyDimEff = 8; 
                                N25Qxxx.iDummy = 7;
                            end else begin
                                N25Qxxx.dummyDimEff = `defaultDummy; 
                                N25Qxxx.iDummy = `defaultiDummy;
                            end
                        end else begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1 ;
                        end
                    end else begin
                        if(prog.dummySetByVCR == 1) begin
                            N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4]; 
                            N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                        end else begin
                            N25Qxxx.dummyDimEff = 8; 
                            N25Qxxx.iDummy = 7;
                        end    
                    end
//                    if(N25Qxxx.protocol == "quad")begin
//                        N25Qxxx.dummyDimEff = 8; 
//                        N25Qxxx.iDummy = 7;
//                    end else begin
//                        N25Qxxx.dummyDimEff = `defaultDummy; 
//                        N25Qxxx.iDummy = `defaultiDummy;
//                    end
//
                `endif
                end     
              mem.setAddr(N25Qxxx.addr);
              $display("  [%0t ns] %d Dummy clock cycles expected ...",N25Qxxx.dummyDimEff,$time);
              N25Qxxx.latchingMode="Y"; //Y=dummy
              //`ifdef MEDT_4READ4D
              //    N25Qxxx.iDummy = 7;
              //`endif    
              N25Qxxx.quadMode = 1;
              @N25Qxxx.dummyLatched;
              enable_quad = 1;
              N25Qxxx.latchingMode="N";

            end
            
          end 

          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
              enable_quad=0;
              disable QUAD_d;
          end    
    
      join




    //-------------
    //  Read OTP 
    //-------------
    // NB : "Read OTP" operation is also modelled in N25Qxxx.module

    reg enable_OTP=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read OTP") fork : READ_OTP
        
          begin
              `ifdef MEDITERANEO
              if(N25Qxxx.protocol == "extended" || N25Qxxx.protocol == "dual") begin
                  if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin
                        if(N25Qxxx.DoubleTransferRate == 0) begin
                            N25Qxxx.dummyDimEff = 8; 
                            N25Qxxx.iDummy = 7;
                        end else begin
                            N25Qxxx.dummyDimEff = `defaultDummy; 
                            N25Qxxx.iDummy = `defaultiDummy;
                        end
                  end else begin
                      N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4];
                      N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                  end
              end else begin
                  if(VolatileReg.VCR[7:4] == 'b1111 || VolatileReg.VCR[7:4] == 'b0000) begin
                      N25Qxxx.dummyDimEff = 10;
                      N25Qxxx.iDummy = 9;
                  end else begin   
                      N25Qxxx.dummyDimEff = VolatileReg.VCR[7:4];
                      N25Qxxx.iDummy = N25Qxxx.dummyDimEff - 1;
                  end
              end    
              `endif

              $display("  [%0t ns] Dummy byte expected ...",$time);
              N25Qxxx.latchingMode="Y"; //Y=dummy
              @N25Qxxx.dummyLatched;

              enable_OTP = 1;
              N25Qxxx.latchingMode="N";
              OTP.setAddr(N25Qxxx.addr);
          end
        
          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
              enable_OTP=0;
              disable READ_OTP;
          end
      join
    
    


    


endmodule


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           FLASH DISCOVERY PARAMETER MODULE             --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps

module FlashDiscoveryParameter(sfdp_file);

`include "include/DevParam.h"


  //input [2048*8:1] sfdp_file ;
  input [48*8:1] sfdp_file ;
//-----------------------------
// data structures definition
//-----------------------------

 reg [dataDim-1:0] FDP [0:FDP_dim-1];


  //------------------------------
  // Memory management variables
  //------------------------------


    reg [23:0] fdpAddr;

    integer i;

 //-----------
 //  Init
 //-----------

    initial begin 

        for (i=0; i<=FDP_dim-1; i=i+1) 
            FDP[i] = data_NP;
        #1;
         
         // if ( `FILENAME_sfdp!="" && `FILENAME_sfdp!=" ") begin
         if ( sfdp_file!="" && sfdp_file!=" ") begin

            $readmemb(sfdp_file, FDP);
            $display("[%0t ns] ==INFO== Load flash discovery paramater table content from file: \"%0s\".", $time, sfdp_file);
    
         end
    end


//read data from the fdp file    
task readData;

    output [dataDim-1:0] data;
    begin
        
        if (fdpAddr[FDP_addrDim -1 :0] < FDP_dim-1) begin

            data = FDP[fdpAddr[FDP_addrDim -1 :0]];

            fdpAddr[FDP_addrDim -1 :0] = fdpAddr[FDP_addrDim -1 :0] + 1;
            $display("In SFDP READ: fdpAddr=%h , data=%h ", fdpAddr[FDP_addrDim -1 :0], data , $time);

            
        end else 
            
            $display("  [%0t ns] **WARNING** Highest address reached", $time);
    end

endtask
 // set start address & page index
    // (for program and read operations)
    
    task setAddr;

    input [addrDim-1:0] addr;

    begin

        fdpAddr[FDP_addrDim -1 :0] = addr[FDP_addrDim -1 :0];
    
    end
    
    endtask

endmodule
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           LOCK MANAGER MODULE                         --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ps 

module LockManager;


`include "include/DevParam.h"




//---------------------------------------------------
// Data structures for protection status modelling
//---------------------------------------------------


// array of sectors lock status (status determinated by Block Protect Status Register bits)
reg [nSector-1:0] lock_by_SR; //(1=locked)

  // Lock Registers (there is a pair of Lock Registers for each sector)
  reg [nSector-1:0] LockReg_WL ;   // Lock Register Write Lock bit (1=lock enabled)
  reg [nSector-1:0] LockReg_LD ;   // Lock Register Lock Down bit (1=lock down enabled)

integer i;






//----------------------------
// Initial protection status
//----------------------------

initial
    for (i=0; i<=nSector-1; i=i+1) begin
        lock_by_SR[i] = 0;
        //LockReg_WL & LockReg_LD are initialized by powerUp  
    end
    


//------------------------
// Reset signal effects
//------------------------

  
  always @N25Qxxx.resetEvent 
        #1
      for (i=0; i<=nSector-1; i=i+1) begin
        if(PMReg.PMR[5] == 0) begin
          LockReg_WL[i] = 1;
        end
        else begin
          LockReg_WL[i] = 0;
        end
        LockReg_LD[i] = 0;
      end    





//----------------------------------
// Power up : reset lock registers
//----------------------------------


//  always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) 
//      for (i=0; i<=nSector-1; i=i+1) begin
//          LockReg_WL[i] = 0;
//          LockReg_LD[i] = 0;
//      end

  always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) 
      for (i=0; i<=nSector-1; i=i+1) begin
        if(PMReg.PMR[5] == 0) begin
          LockReg_WL[i] = 1;
        end
        else begin
          LockReg_WL[i] = 0;
        end
        LockReg_LD[i] = 0;
      end






//------------------------------------------------
// Protection managed by BP status register bits
//------------------------------------------------

integer nLockedSector;
integer temp;


  
  always @(`TB or `BP3 or `BP2 or `BP1 or `BP0) 
  begin

      for (i=0; i<=nSector-1; i=i+1) //reset lock status of all sectors
          lock_by_SR[i] = 0;
    
      temp = {`BP3, `BP2, `BP1, `BP0};
      if(temp==0) begin
          nLockedSector = 0;
      end else begin    
        nLockedSector = 2**(temp-1); 
      end

      if (nLockedSector>0 && `TB==0) // upper sectors protected
          for ( i=nSector-1 ; i>=nSector-nLockedSector ; i=i-1 )
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end
    
      else if (nLockedSector>0 && `TB==1) // lower sectors protected 
          for ( i = 0 ; i <= nLockedSector-1 ; i = i+1 ) 
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end

  end


//--------------------------------------
// Protection managed by Lock Register
//--------------------------------------

reg enable_lockReg_read=0;




    reg [sectorAddrDim-1:0] sect;
    reg [dataDim-1:0] sectLockReg;



    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Lock Reg")
      // if (!PMReg.PMR[5]) begin
      //     $display("  [%0t ps] **WARNING** PMR bit is set. Write lock register is not allowed!", $time);
      //     disable WRLR;
      //  end else 
       fork : WRLR
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - Write Lock Reg aborted due to Prog/Erase Suspend",$time);
            disable WRLR;
          end  
        begin : exe1

            sect = f.sec(N25Qxxx.addr);
            if(N25Qxxx.protocol=="dual")
                N25Qxxx.latchingMode = "F";
            else if(N25Qxxx.protocol=="quad")
                N25Qxxx.latchingMode = "Q";
            else
                N25Qxxx.latchingMode = "D";

            @(N25Qxxx.dataLatched) sectLockReg = N25Qxxx.data;
        end

        begin : exe2
            @(posedge N25Qxxx.S);
            disable exe1;
            disable reset;
            -> stat.WEL_reset;
            if(`WEL==0) begin
                N25Qxxx.f.WEL_error;
                disable exe2;
            end
            `ifdef MEDT_4KBLocking
            else if(sect != 'h0 && sect != 'h1FF) begin    
                if (LockReg_LD[sect]==1) begin
                        $display("  [%0t ns] **WARNING** Lock Down bit is set. Write lock register is not allowed!", $time);
                end
                else begin
                    LockReg_LD[sect]=sectLockReg[1];
                    LockReg_WL[sect]=sectLockReg[0];
                    $display("  [%0t ns] Command execution: lock register of sector %0h set to (%b,%b)", 
                              $time, sect, LockReg_LD[sect], LockReg_WL[sect] );
                end    
            end    
        `else
            else if (LockReg_LD[sect]==1) begin
                    $display("  [%0t ns]- **WARNING** Lock Down bit is set. Write lock register is not allowed!", $time);
            end
            else begin
                LockReg_LD[sect]=sectLockReg[1];
                LockReg_WL[sect]=sectLockReg[0];
                $display("  [%0t ns]- Command execution: lock register of sector %0d set to (%b,%b)", 
                          $time, sect, LockReg_LD[sect], LockReg_WL[sect] );
            end    
            `endif
        end

        begin : reset
            @N25Qxxx.resetEvent;
            disable exe1;
            disable exe2;
        end
        
    join




    // Read lock register

    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Lock Reg") begin : READ_LOCKEG

        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        fork : READ_LOCKREG
        begin
          //sect = f.sec(N25Qxxx.addr); 
          //N25Qxxx.dataOut = {4'b0, LockReg_LD[sect], LockReg_WL[sect]};
          enable_lockReg_read=1;
        end   
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_lockReg_read=0;
        
    join

end





//-------------------------------------------
// Function to test sector protection status
//-------------------------------------------

function isProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] sectAddr;
begin

    sectAddr = f.sec(byteAddr);
    isProtected_by_SR = lock_by_SR[sectAddr]; 

end
endfunction





function isProtected_by_lockReg;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] sectAddr;
begin

      sectAddr = f.sec(byteAddr);
      isProtected_by_lockReg = LockReg_WL[sectAddr];
      $display("  [%0t ns] isProtected_by_lockReg: %h sectAddr: %h", $time,isProtected_by_lockReg, sectAddr);

end
endfunction





function isAnySectorProtected;
input required;
begin

    i=0;   
    isAnySectorProtected=0;
    while(isAnySectorProtected==0 && i<=nSector-1) begin 
          isAnySectorProtected=lock_by_SR[i] || LockReg_WL[i];
        i=i+1;
    end    

end
endfunction







endmodule


`ifdef MEDT_4KBLocking

`timescale 1ns / 1ps 

module LockManager4KB;


`include "include/DevParam.h"

//---------------------------------------------------
// Data structures for protection status modelling
//---------------------------------------------------


// array of sectors lock status (status determinated by Block Protect Status Register bits)
reg [nSSector-1:0] lock_by_SR; //(1=locked)

  // Lock Registers (there is a pair of Lock Registers for each sector)
  reg [nSSector-1:0] LockReg_WL ;   // Lock Register Write Lock bit (1=lock enabled)
  reg [nSSector-1:0] LockReg_LD ;   // Lock Register Lock Down bit (1=lock down enabled)

integer i;


//----------------------------
// Initial protection status
//----------------------------

initial
    for (i=0; i<=nSSector-1; i=i+1)
        lock_by_SR[i] = 0;
        //LockReg_WL & LockReg_LD are initialized by powerUp  
    


//------------------------
// Reset signal effects
//------------------------

  
  always @N25Qxxx.resetEvent 
      for (i=0; i<=nSSector-1; i=i+1) begin
        if(PMReg.PMR[5] == 0) begin
          LockReg_WL[i] = 1;
        end
        else begin
          LockReg_WL[i] = 0;
        end
        LockReg_LD[i] = 0;
      end    


//----------------------------------
// Power up : reset lock registers
//----------------------------------


  always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) 
      for (i=0; i<=nSSector-1; i=i+1) begin
          LockReg_WL[i] = 0;
          LockReg_LD[i] = 0;
      end

//------------------------------------------------
// Protection managed by BP status register bits
//------------------------------------------------

integer nLockedSubSector;
integer temp;


  
  always @(`TB or `BP3 or `BP2 or `BP1 or `BP0) 
  begin

      for (i=0; i<=nSSector-1; i=i+1) //reset lock status of all sectors
          lock_by_SR[i] = 0;
    
      temp = {`BP3, `BP2, `BP1, `BP0};
      nLockedSubSector = 2**(temp-1); 

      if (nLockedSubSector>0 && `TB==0) // upper sectors protected
          for ( i=nSSector-1 ; i>=nSSector-nLockedSubSector ; i=i-1 )
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end
    
      else if (nLockedSubSector>0 && `TB==1) // lower sectors protected 
          for ( i = 0 ; i <= nLockedSubSector-1 ; i = i+1 ) 
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end

  end


//--------------------------------------
// Protection managed by Lock Register
//--------------------------------------

reg enable_lockReg_read=0;




    reg [subsecAddrDim-1:0] sub;
    reg [sectorAddrDim-1:0] sect;
    reg [dataDim-1:0] subLockReg;



    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Lock Reg")
      // if (!PMReg.PMR[5]) begin
      //     $display("  [%0t ps] **WARNING** PMR bit is set. Write lock register is not allowed!", $time);
      //     disable WRLR;
      //  end else 
       fork : WRLR
        begin : exe1
            sect = f.sec(N25Qxxx.addr);
            if(N25Qxxx.protocol=="dual")
                N25Qxxx.latchingMode = "F";
            else if(N25Qxxx.protocol=="quad")
                N25Qxxx.latchingMode = "Q";
            else
                N25Qxxx.latchingMode = "D";

            @(N25Qxxx.dataLatched) subLockReg = N25Qxxx.data;
        end

        begin : exe2
            @(posedge N25Qxxx.S);
            disable exe1;
            disable reset;
            -> stat.WEL_reset;
            if(`WEL==0)
                N25Qxxx.f.WEL_error;
            else if (sect == 'h0 || sect == 'h1ff) begin
                sub = f.sub(N25Qxxx.addr);
                if (LockReg_LD[sub]==1) begin
                    $display("  [%0t ns] **WARNING** Lock Down bit is set. Write lock register of sub-sector is not allowed!", $time);
                end
                else begin
                LockReg_LD[sub]=subLockReg[1];
                LockReg_WL[sub]=subLockReg[0];
                $display("  [%0t ns] Command execution: lock register of sub-sector %0d set to (%b,%b)", 
                          $time, sub, LockReg_LD[sub], LockReg_WL[sub] );
                end    
            end    
        end

        begin : reset
            @N25Qxxx.resetEvent;
            disable exe1;
            disable exe2;
        end
        
    join




    // Read lock register

    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Lock Reg") begin : READ_LOCKREG4KB
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        
        fork
        begin
          //sect = f.sec(N25Qxxx.addr); 
          //N25Qxxx.dataOut = {4'b0, LockReg_LD[sect], LockReg_WL[sect]};
          enable_lockReg_read=1;
        end   
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_lockReg_read=0;
        
    join

end





//-------------------------------------------
// Function to test sector protection status
//-------------------------------------------

function isProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [subsecAddrDim-1:0] subsecAddr;
begin

    subsecAddr = f.sub(byteAddr);
    isProtected_by_SR = lock_by_SR[subsecAddr]; 

end
endfunction


function isProtected_by_lockReg;
input [addrDim-1:0] byteAddr;
reg [subsecAddrDim-1:0] subsecAddr;
begin

      subsecAddr = f.sub(byteAddr);
      isProtected_by_lockReg = LockReg_WL[subsecAddr];
      $display("  [%0t ns] isProtected_by_lockReg: %h subsecAddr: %h", $time,isProtected_by_lockReg, subsecAddr);

end
endfunction


function isAnySubSectorProtected;
input required;
begin

    i=0;   
    isAnySubSectorProtected=0;
    while(isAnySubSectorProtected==0 && i<=nSSector-1) begin 
          isAnySubSectorProtected=lock_by_SR[i] || LockReg_WL[i];
        i=i+1;
    end    

end
endfunction


function isInTopSector;
    input [addrDim-1:0] byteAddr;
    reg [sectorAddrDim-1:0] secAddr;
    begin
        secAddr = f.sec(byteAddr);
        if(secAddr==TOP_sector) begin
            isInTopSector = 1'h1;
        end
    end
endfunction


function isInBottomSector;
    input [addrDim-1:0] byteAddr;
    reg [sectorAddrDim-1:0] secAddr;
    begin
        secAddr = f.sec(byteAddr);
        if(secAddr==BOTTOM_sector) begin
            isInBottomSector = 1'h1;
        end
    end
endfunction






endmodule // LockManager4KB
`endif //MEDT_4KBLocking












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           DUAL OPS MODULE                             --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
// In this module are modeled 
// "Dual Input Fast Program"
// and "Dual Output Fast program"
// commands

`timescale 1ns / 1ps

`ifdef HOLD_pin
  module DualQuadOps (S, C, ck_count, DoubleTransferRate, DQ0, DQ1, Vpp_W_DQ2, HOLD_DQ3);
`else
  module DualQuadOps (S, C, ck_count, DoubleTransferRate, DQ0, DQ1, Vpp_W_DQ2, RESET_DQ3);
`endif
    `include "include/DevParam.h"
    `include "include/UserData.h"

    input S;
    input C;
    input [2:0] ck_count;
    input DoubleTransferRate;

    output DQ0, DQ1, Vpp_W_DQ2;
    
   `ifdef HOLD_pin
    output HOLD_DQ3;
//`else
//        output RESET_DQ3; 
   `endif
 
     `ifdef RESET_pin
        output RESET_DQ3; 
    `endif



    

    //----------------------------
    // Latching data (dual input)
    //----------------------------

    always @(C) if (N25Qxxx.logicOn && N25Qxxx.latchingMode=="F") begin : CP_latchData_fast //fast=dual
      //if (C==1) begin // ENABLE if posedge C in all modes 
      if (C==1 || (C==0 && DoubleTransferRate)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode

        N25Qxxx.data[N25Qxxx.iData] = DQ1;
        N25Qxxx.data[N25Qxxx.iData-1] = DQ0;

        if (N25Qxxx.iData>=3) begin
            N25Qxxx.iData = N25Qxxx.iData-2;
            prog.bitCounter=prog.bitCounter+1;
        end else begin
            if ((N25Qxxx.cmdRecName=="Write NV Configuration Reg" || N25Qxxx.cmdRecName=="ASP Write") && prog.LSByte) begin
                N25Qxxx.LSdata=N25Qxxx.data;
                 prog.LSByte=0;
            end 
                -> N25Qxxx.dataLatched;
                N25Qxxx.dataLatchedr=1;
                $display("  [%0t ns] Data latched: %h", $time,N25Qxxx.data);
                N25Qxxx.iData=N25Qxxx.dataDim-1;
        end    
      end
    end


    //----------------------------
    // Latching data (quad input)
    //----------------------------

    always @(C) if (N25Qxxx.logicOn && N25Qxxx.latchingMode=="Q") begin : CP_latchData_quad //quad
      // if (C==1) begin // ENABLE if posedge C in all modes 
      if (C==1 || (C==0 && DoubleTransferRate)) begin // ENABLE if posedge C in all modes or negedge C in DTR mode
        `ifdef HOLD_pin
        N25Qxxx.data[N25Qxxx.iData] = HOLD_DQ3;
        `endif
       
       `ifdef RESET_pin
        N25Qxxx.data[N25Qxxx.iData] = RESET_DQ3;
        `endif
        
        N25Qxxx.data[N25Qxxx.iData-1] = Vpp_W_DQ2;
        N25Qxxx.data[N25Qxxx.iData-2] = DQ1;
        N25Qxxx.data[N25Qxxx.iData-3] = DQ0;
        if (N25Qxxx.iData==7) begin
            N25Qxxx.iData = N25Qxxx.iData-4;
            prog.bitCounter=prog.bitCounter+1;
        end else begin
            if ((N25Qxxx.cmdRecName=="Write NV Configuration Reg" || N25Qxxx.cmdRecName=="ASP Write") && prog.LSByte) begin
            N25Qxxx.LSdata=N25Qxxx.data;
             prog.LSByte=0;
        end
            -> N25Qxxx.dataLatched;
            N25Qxxx.dataLatchedr=1;
            $display("  [%0t ns] Data latched: %h", $time,N25Qxxx.data);
            N25Qxxx.iData=N25Qxxx.dataDim-1;
        end    
      end
    end





    //----------------------------------
    // dual read (DQ1 and DQ0 out bit)
    //----------------------------------


    reg bitOut='hZ, bitOut_extra='hZ;
    
    reg [addrDim-1:0] readAddr;
    reg [dataDim-1:0] dataOut;

    event sendToBus_dual; 
    
    
    // read with DQ1 and DQ0 out bit (For dual output fast read: DOFR/DIOFR in ext-SPI and DIO-SPI modes)
    always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_dual==1 && N25Qxxx.cmd != 'h5A ) begin
#1;
	doubleIO_memread_output(ck_count * ((DoubleTransferRate || (((N25Qxxx.cmd
  == 'h3D) || (N25Qxxx.cmd == 'hBD) ||(N25Qxxx.cmd == 'h0D) || (N25Qxxx.cmd == 'h39) || (N25Qxxx.cmd == 'hBE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0))  +1)); // 2*ck_count if DTR and when the command is 'hBD or 'h3D, O.W. 1*ck_count
  // == 'h3D) || (N25Qxxx.cmd == 'hBD) ||(N25Qxxx.cmd == 'h0D) || (N25Qxxx.cmd == 'h3E) || (N25Qxxx.cmd == 'hBE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0))  +1)); // 2*ck_count if DTR and when the command is 'hBD or 'h3D, O.W. 1*ck_count
    end  

    always @(posedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_dual==1
    && (DoubleTransferRate || (((N25Qxxx.cmd == 'h3D) || (N25Qxxx.cmd ==
    'hBD)|| (N25Qxxx.cmd == 'h0D) ||  (N25Qxxx.cmd == 'h39) || (N25Qxxx.cmd == 'hBE)|| (N25Qxxx.cmd == 'h0E)) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin
	doubleIO_memread_output(2*ck_count + 1);
    end  

    task doubleIO_memread_output;
      input [2:0] bit_count;
      reg [2:0] bit_count_;
      begin
            `ifdef VCS_ //VCS specific workaround
                if(bit_count==3 && ck_count==1)
                    bit_count_ = 1;
                else if(bit_count==5 && ck_count==2)
                    bit_count_ = 3;
                else if(bit_count==7 && ck_count==3)
                    bit_count_ = 5;
                else if(bit_count==1 && ck_count==4)
                    bit_count_ = 7;
                else
                    bit_count_ = bit_count;

                if(bit_count_==0 || bit_count_==4)
                    begin
                        readAddr = mem.memAddr;
                        mem.readData(dataOut); //read data and increments address
                        f.out_info(readAddr, dataOut);
                        N25Qxxx.dataOut=dataOut; //N25Qxxx.dataOut is accessed by Transactions  
                    end
               #tCLQX
                bitOut = dataOut[ dataDim-1 - (2*(bit_count_%4)) ]; //%=modulo operator
                bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count_%4)) ]; 
                
                -> sendToBus_dual;
            `else

            if(bit_count==0 || bit_count==4)
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
                N25Qxxx.dataOut=dataOut; //N25Qxxx.dataOut is accessed by Transactions  
            end
           
           #tCLQX
            bitOut = dataOut[ dataDim-1 - (2*(bit_count%4)) ]; //%=modulo operator
            bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
            
            -> sendToBus_dual;
            `endif
      end
    endtask  

// read with DQ1 and DQ0 out bit
    always @(negedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual") begin : CP_read_dual
#1
        doubleIO_IDreg_output(ck_count * ((DoubleTransferRate ||
        (((N25Qxxx.cmd == 'h3D) || (N25Qxxx.cmd == 'hBD) || (N25Qxxx.cmd ==
        'h0D) || (N25Qxxx.cmd == 'h39) || (N25Qxxx.cmd == 'hBE) || (N25Qxxx.cmd == 'h0E)) ? 1 : 0))+1)); // 2*ck_count if DTR, nd when the command is 'hBD or 'h3D,O.W. 1*ck_count
        // 'h0D) || (N25Qxxx.cmd == 'h3E) || (N25Qxxx.cmd == 'hBE) || (N25Qxxx.cmd == 'h0E)) ? 1 : 0))+1)); // 2*ck_count if DTR, nd when the command is 'hBD or 'h3D,O.W. 1*ck_count
    end

  //RK always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual") begin : CP_read_dual
  //RK   doubleIO_IDreg_output(ck_count * ((((N25Qxxx.cmd == 'h3D) || 
  //RK      (N25Qxxx.cmd == 'hBD)) ? 1 : 0)  +1)); // 2*ck_count if DTR, nd when the command is 'hBD or 'h3D,O.W. 1*ck_count
  //RK end

  // always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual" && (DoubleTransferRate || (((N25Qxxx.cmd == 'h3D) || (N25Qxxx.cmd == 'hBD)|| (N25Qxxx.cmd == 'h0D) || (N25Qxxx.cmd == 'h3E) || (N25Qxxx.cmd == 'hBE) || (N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin
  always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual" && (DoubleTransferRate || (((N25Qxxx.cmd == 'h3D) || (N25Qxxx.cmd == 'hBD)|| (N25Qxxx.cmd == 'h0D) 
                         || (N25Qxxx.cmd == 'h39) || (N25Qxxx.cmd == 'hBE) || (N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin
#1
      doubleIO_IDreg_output(2*ck_count + 1);
      //doubleIO_IDreg_output(2*(ck_count-1) + 1); 
  end

  //RK always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual" &&  
  //RK      (((N25Qxxx.cmd == 'h3D) || (N25Qxxx.cmd == 'hBD)) ? 1 : 0) && N25Qxxx.dtr_dout_started) begin
  //RK   doubleIO_IDreg_output(2*ck_count + 1);
  //RK end


  task doubleIO_IDreg_output;
    input [2:0] bit_count;
    begin
     #1; 
     if (read.enable_rsfdp==1) begin
  
       if(bit_count==0 || bit_count==4)
       //if(bit_count==0)
       begin
           readAddr = FlashDiscPar.fdpAddr; //
           FlashDiscPar.readData(dataOut); //read data and increments address
           f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
        bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;
  
     end else if (stat.enable_SR_read==1) begin
        
        if(bit_count==0 || bit_count==4) begin 
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
        bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

     end else if (flag.enable_FSR_read==1) begin
        
        if(bit_count==0 || bit_count==4) begin

            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
       if(bit_count==0 || bit_count==4) begin
 
            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
       end    
       
        #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

    //added   
     end else if (PMReg.enable_PMR_read==1) begin
        
        `ifdef MEDITERANEO
        if(bit_count==0 || bit_count==6) begin
        `else
        if(bit_count==0 || bit_count==4) begin
        `endif
            dataOut = PMReg.PMR;
            f.out_info(readAddr, dataOut);
       end    
        
        #tCLQX

         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;
   
     end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
        `ifdef MEDITERANEO
        if(bit_count==0 || bit_count==6) begin
        `else
        if(bit_count==0 || bit_count==4) begin
        `endif
            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;
    

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
     
        if((bit_count==0 || bit_count==4) && N25Qxxx.firstNVCR == 1) begin
 
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            N25Qxxx.firstNVCR=0;
          
        end else if((bit_count==0 || bit_count==4) && N25Qxxx.firstNVCR == 0) begin
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           N25Qxxx.firstNVCR=2;
                                   
        end else if((bit_count==0 || bit_count==4) && N25Qxxx.firstNVCR == 2) begin
           dataOut = 0; 
           f.out_info(readAddr, dataOut);
        end
        

         #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4))]; 
        -> sendToBus_dual;

`ifdef MEDT_GPRR
     end else if (GPRR_Reg.enable_GPRR_read==1) begin
           if ((bit_count == 0 || bit_count==4)) begin
              if (GPRR_Reg.GPRR_location != 0  && GPRR_Reg.GPRR_location >= 64) begin
                 dataOut = 8'h00;
                 f.out_info(readAddr, dataOut);
              end else begin 
                 dataOut = GPRR_Reg.GPRR[(GPRR_Reg.GPRR_location*8) +: 8];
                f.out_info(readAddr, dataOut);
              end
              if(GPRR_Reg.GPRR_location < 65) begin
                GPRR_Reg.GPRR_location = GPRR_Reg.GPRR_location + 1; 
              end
           end
           #tCLQX
           bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
           bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4))]; 
           -> sendToBus_dual;
`endif

`ifdef byte_4

   end else if (ExtAddReg.enable_EAR_read==1) begin
        
        if(bit_count==0 || bit_count==4)  begin
            
            dataOut = ExtAddReg.EAR[7:0];
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

 `endif     
 `ifdef MEDT_4KBLocking
      end else if (lock.enable_lockReg_read==1 || lock4kb.enable_lockReg_read==1) begin
 `else
      end else if (lock.enable_lockReg_read==1) begin
  `endif
          if(bit_count==0 || bit_count==4)  begin
              readAddr = f.sec(N25Qxxx.addr);
              `ifdef MEDT_4KBLocking
                  if(readAddr == 'h0 || readAddr == 'h1ff) begin
                      readAddr = f.sub(N25Qxxx.addr);
                      dataOut = {6'b0, lock4kb.LockReg_LD[readAddr], lock4kb.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end else begin
                      dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end
              `else    
                dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                f.out_info(readAddr, dataOut);
              `endif 
              //readAddr = f.sec(N25Qxxx.addr);
              //dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
              //f.out_info(readAddr, dataOut);
          end
          #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

`ifdef MEDT_PPB
end else if (ppb.enable_PPBReg_read == 1) begin

          if(bit_count==0 || bit_count==4)  begin
              readAddr = f.sec(N25Qxxx.addr);
              if(ppb.PPBReg[readAddr] == 1) dataOut = 8'hff;
              else dataOut = 8'h00;
              f.out_info(readAddr, dataOut);
          end
          #tCLQX
         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
        -> sendToBus_dual;

`endif

      end else if (read.enable_OTP==1) begin 

          if(bit_count==0 || bit_count==4)  begin

              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              $display("---debug--- %h",readAddr);
              if(readAddr >= 'h40)begin
                  dataOut[0] = OTP.mem[readAddr][0] & PMReg.PMR[3];
                  OTP.addr = 'h40;
              end
              f.out_info(readAddr, dataOut);
          end
          if(N25Qxxx.deep_power_down==1) dataOut = 'hzz;
          
           #tCLQX
          bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
          bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
          -> sendToBus_dual;

   
   
    end else if (read.enable_ID==1) begin 

        if(bit_count==0 || bit_count==4)  begin

            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            else if (read.ID_index==3) dataOut=UID;
            else if (read.ID_index==4) dataOut=EDID_0;
            else if (read.ID_index==5) dataOut=EDID_1;
            else if (read.ID_index==6) dataOut=CFD_0;
            else if (read.ID_index==7) dataOut=CFD_1;
            else if (read.ID_index==8) dataOut=CFD_2;
            else if (read.ID_index==9) dataOut=CFD_3;
            else if (read.ID_index==10) dataOut=CFD_4;
            else if (read.ID_index==11) dataOut=CFD_5;
            else if (read.ID_index==12) dataOut=CFD_6;
            else if (read.ID_index==13) dataOut=CFD_7;
            else if (read.ID_index==14) dataOut=CFD_8;
            else if (read.ID_index==15) dataOut=CFD_9;
            else if (read.ID_index==16) dataOut=CFD_10;
            else if (read.ID_index==17) dataOut=CFD_11;
            else if (read.ID_index==18) dataOut=CFD_12;
            else if (read.ID_index==19) dataOut=CFD_13;
            else if (read.ID_index>19) dataOut=0;
            
            if (read.ID_index<=19) read.ID_index=read.ID_index+1;
            //RK else read.ID_index=0;


            f.out_info(readAddr, dataOut);
        
        end
         
         #tCLQX

         bitOut = dataOut[dataDim-1- (2*(bit_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(bit_count%4)) ]; 
         -> sendToBus_dual;
    end

    
   
end
endtask


    always @sendToBus_dual begin
      -> N25Qxxx.sendToBus_stack;
      #0;
      if(N25Qxxx.die_active == 1) begin
        fork

	        N25Qxxx.dtr_dout_started = 1'b1;
            begin
                force DQ1 = 1'bX;
                force DQ0 = 1'bX; 
            end
           begin 
              if((N25Qxxx.cmdRecName == "Read Fast") || 
                (N25Qxxx.cmdRecName == "Dual Command Fast Read") || 
                (N25Qxxx.cmdRecName == "Quad Command Fast Read") || 
                (N25Qxxx.cmdRecName == "Dual Output Fast Read") ||
                (N25Qxxx.cmdRecName == "Dual I/O Fast Read") ||
                (N25Qxxx.cmdRecName == "Quad I/O Fast Read") 
                ) begin 
          //     #(tCLQV - tCLQX) 
                #(tCLQV/2 - tCLQX - 1); 
              end 
              else begin
                #(tCLQV - tCLQX - 1) ;
              end
              // #(tCLQV -tCLQX) begin
                force DQ1 = bitOut;
                force DQ0 = bitOut_extra;
              // end        
            end

        join
      end
  end



    always @(negedge(C)) if(N25Qxxx.logicOn && (read.enable_dual==1 || N25Qxxx.protocol=="dual")) 
        @(posedge S) begin 
           #tSHQZ 
            release DQ0;
            release DQ1;
        end    
   
    //--------------------------------------------------------------
    // Quad read (RESET_DQ3/HOLD_DQ3 Vpp_W_DQ2 DQ1 and DQ0 out bit)
    //--------------------------------------------------------------


    reg bitOut0='hZ, bitOut1='hZ, bitOut2='hZ, bitOut3='hZ;
    

    event sendToBus_quad; 
    
    always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1 && N25Qxxx.cmd != 'h5A) begin
	quadIO_memread_output(ck_count * ((DoubleTransferRate || (((N25Qxxx.cmd
  == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h3A) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) +1)); // 2*ck_count if DTR and when the command is 'hED, O.W. 1*ck_count
  // == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h6E) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) +1)); // 2*ck_count if DTR and when the command is 'hED, O.W. 1*ck_count
    end   

//RK     always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1) begin
//RK 
//RK 	quadIO_memread_output(ck_count * ((((N25Qxxx.cmd == 'h6D) || 
//RK            (N25Qxxx.cmd == 'hED)) ? 1 : 0) +1)); // 2*ck_count if DTR and when the command is 'hED, O.W. 1*ck_count
//RK      end  

    // always @(posedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1 && (DoubleTransferRate || (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h6E) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin
    always @(posedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1 && (DoubleTransferRate || (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h3A) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin

    //RK always @(posedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1 &&  
    //RK       (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED)) ? 1 : 0) && N25Qxxx.dtr_dout_started) begin
	quadIO_memread_output(2*ck_count + 1);
     end  

    task quadIO_memread_output;
      input [2:0] bit_count;
      begin

            if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)//verificare
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
                N25Qxxx.dataOut=dataOut; //N25Qxxx.dataOut is accessed by Transactions  
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
            -> sendToBus_quad;
            
    end  
    endtask


// read with RESET_DQ3/HOLD_DQ3 Vpp_W_DQ2 DQ1 and DQ0 out bit

 always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad") begin : CP_read_quad
  if(DoubleTransferRate == 1) begin
    quadIO_IDreg_output(ck_count * ((((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED)) ? 1 : 0) )); // 2*ck_count if DTR and when the command is 'hED, O.W. 1*ck_count
  end 
  else begin
    quadIO_IDreg_output(ck_count * ((((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED)) ? 1 : 0) +1)); 
  end
 end

 //RK always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad" &&  
 //RK       (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED)) ? 1 : 0) && N25Qxxx.dtr_dout_started) begin
 // always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad" && (DoubleTransferRate || (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h6E) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0))) begin
 always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad" && (DoubleTransferRate || (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D)|| (N25Qxxx.cmd == 'h3A) || (N25Qxxx.cmd == 'hEE) ||(N25Qxxx.cmd == 'h0E) ) ? 1 : 0))) begin
 // always @(posedge C) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad" && (DoubleTransferRate || (((N25Qxxx.cmd == 'h6D) || (N25Qxxx.cmd == 'hED) ||(N25Qxxx.cmd == 'h0D) ) ? 1 : 0)) && N25Qxxx.dtr_dout_started) begin
    quadIO_IDreg_output(2*ck_count + 1);
 end

 task quadIO_IDreg_output;
   input [2:0] bit_count;
   begin   
   #1;
    if (read.enable_rsfdp==1) begin
  
       if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
       begin
           readAddr = FlashDiscPar.fdpAddr;
           FlashDiscPar.readData(dataOut); //read data and increments address
           f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;


    end else if (stat.enable_SR_read==1) begin
        
        if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
        begin
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
       
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;

     end else if (flag.enable_FSR_read==1) begin
        
        if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
        begin
                
            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
       
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
       if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
       begin
                               
            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
       end    
       
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
        -> sendToBus_quad;
      
     // added   
     end else if (PMReg.enable_PMR_read==1) begin
        
       if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
       begin
                               
            dataOut = PMReg.PMR;
            f.out_info(readAddr, dataOut);
       end    
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
        -> sendToBus_quad;
    
     end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
        if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)
        begin
            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
       

        #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;
                                              

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
     
      if((bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6) && N25Qxxx.firstNVCR == 1) begin
 
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            N25Qxxx.firstNVCR=0;
          
      end else if((bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6) && N25Qxxx.firstNVCR == 0) begin
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           N25Qxxx.firstNVCR=2;
                                   
      end else if((bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6) && N25Qxxx.firstNVCR == 2) begin
           dataOut = 0;
           f.out_info(readAddr, dataOut);
       end

       
        #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;

`ifdef MEDT_GPRR
     end else if (GPRR_Reg.enable_GPRR_read==1) begin
           if ((bit_count == 0 || bit_count==4 ||  bit_count==6 ||  bit_count==2)) begin
              if (GPRR_Reg.GPRR_location != 0 && GPRR_Reg.GPRR_location >= 64) begin
                 dataOut = 8'h00;
                 f.out_info(readAddr, dataOut);
              end else begin
                 dataOut = GPRR_Reg.GPRR[(GPRR_Reg.GPRR_location*8) +: 8];
                 f.out_info(readAddr, dataOut);
              end
              if(GPRR_Reg.GPRR_location < 65) begin
                GPRR_Reg.GPRR_location = GPRR_Reg.GPRR_location + 1; 
              end
           end
           #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;
`endif

`ifdef byte_4

   end else if (ExtAddReg.enable_EAR_read==1) begin
        
        if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)  begin
            
            dataOut = ExtAddReg.EAR[7:0];
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;
`endif      
   `ifdef MEDT_4KBLocking
   end else if (lock.enable_lockReg_read==1 || lock4kb.enable_lockReg_read==1) begin
   `else    
   end else if (lock.enable_lockReg_read==1) begin
   `endif

          if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)  begin
              readAddr = f.sec(N25Qxxx.addr);
              `ifdef MEDT_4KBLocking
                  if(readAddr == 'h0 || readAddr == 'h1ff) begin
                      readAddr = f.sub(N25Qxxx.addr);
                      dataOut = {6'b0, lock4kb.LockReg_LD[readAddr], lock4kb.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end else begin
                      dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                      f.out_info(readAddr, dataOut);
                  end
              `else    
                dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
                f.out_info(readAddr, dataOut);
              `endif 
              //dataOut = {6'b0, lock.LockReg_LD[readAddr], lock.LockReg_WL[readAddr]};
              //f.out_info(readAddr, dataOut);
          end
        #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;

`ifdef MEDT_PPB
end else if (ppb.enable_PPBReg_read == 1) begin
          if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)  begin
              readAddr = f.sec(N25Qxxx.addr);
              if(ppb.PPBReg[readAddr] == 1) dataOut = 8'hff;
              else dataOut = 8'h00;
              f.out_info(readAddr, dataOut);
          end
        #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;
`endif
    
      end else if (read.enable_OTP==1) begin 

          if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)  begin

              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              if(readAddr >= 'h40)begin
                  dataOut[0] = OTP.mem[readAddr][0] & PMReg.PMR[3];
                  OTP.addr = 'h40;
              end
              f.out_info(readAddr, dataOut);
          end
          if(N25Qxxx.deep_power_down==1) dataOut = 'hzz;
         #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;

   
   
    end else if (read.enable_ID==1) begin 

        if(bit_count==0 || bit_count==2 || bit_count==4 || bit_count==6)  begin

            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            else if (read.ID_index==3) dataOut=UID;
            else if (read.ID_index==4) dataOut=EDID_0;
            else if (read.ID_index==5) dataOut=EDID_1;
            else if (read.ID_index==6) dataOut=CFD_0;
            else if (read.ID_index==7) dataOut=CFD_1;
            else if (read.ID_index==8) dataOut=CFD_2;
            else if (read.ID_index==9) dataOut=CFD_3;
            else if (read.ID_index==10) dataOut=CFD_4;
            else if (read.ID_index==11) dataOut=CFD_5;
            else if (read.ID_index==12) dataOut=CFD_6;
            else if (read.ID_index==13) dataOut=CFD_7;
            else if (read.ID_index==14) dataOut=CFD_8;
            else if (read.ID_index==15) dataOut=CFD_9;
            else if (read.ID_index==16) dataOut=CFD_10;
            else if (read.ID_index==17) dataOut=CFD_11;
            else if (read.ID_index==18) dataOut=CFD_12;
            else if (read.ID_index==19) dataOut=CFD_13;
            else if (read.ID_index>19) dataOut=0;
            
            if (read.ID_index<=19) read.ID_index=read.ID_index+1;
            //RK else read.ID_index=0;


            f.out_info(readAddr, dataOut);
        
        end
         #tCLQX

         bitOut3 = dataOut[ dataDim-1 - (4*(bit_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(bit_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(bit_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(bit_count%2)) ]; 
         -> sendToBus_quad;
    end

    
   
end
endtask



    always @sendToBus_quad begin
      -> N25Qxxx.sendToBus_stack;
      #0;
      if(N25Qxxx.die_active == 1) begin
        fork

         	N25Qxxx.dtr_dout_started = 1'b1;
            begin
               
               `ifdef HOLD_pin
                force HOLD_DQ3 = 1'bX;
               `endif 
            
               `ifdef RESET_pin
                force RESET_DQ3 = 1'bX;
               `endif 
                force Vpp_W_DQ2 = 1'bX;
                force DQ1 = 1'bX;
                force DQ0 = 1'bX; 
            end
            begin
              if((N25Qxxx.cmdRecName == "Read Fast") || 
                (N25Qxxx.cmdRecName == "Dual Command Fast Read") || 
                (N25Qxxx.cmdRecName == "Quad Command Fast Read") || 
                (N25Qxxx.cmdRecName == "Dual Output Fast Read") ||
                (N25Qxxx.cmdRecName == "Dual I/O Fast Read") ||
                (N25Qxxx.cmdRecName == "Quad I/O Fast Read") || 
                (N25Qxxx.cmdRecName == "Quad Output Read") 
                ) begin 
          //     #(tCLQV - tCLQX) 
                #(tCLQV/2 - tCLQX - 1); 
              end 
              else begin
                #(tCLQV - tCLQX - 2) ;
              end
            
            // #(tCLQV-tCLQX) begin
               
               `ifdef HOLD_pin
                force HOLD_DQ3 = bitOut3;
               `endif
              
               `ifdef RESET_pin
                force RESET_DQ3 = bitOut3;
               `endif 
               
                
                force Vpp_W_DQ2 = bitOut2;
                force DQ1 = bitOut1;
                force DQ0 = bitOut0;
            end        

        join
      end
    end



    always @(negedge(C)) if(N25Qxxx.logicOn && read.enable_quad==1 || N25Qxxx.protocol=="quad") 
    
        @(posedge S) begin 
        
         #tSHQZ          
            release DQ0;
            release DQ1;
            release Vpp_W_DQ2;
            `ifdef HOLD_pin
            release HOLD_DQ3;
            `endif
            
            `ifdef RESET_pin
            release RESET_DQ3;
            `endif 

       end   

    `ifdef RESET_pin 
       
       always @N25Qxxx.resetEvent begin
       
            release DQ0; 
            release Vpp_W_DQ2;
           
            release RESET_DQ3;
       
       end
       
    `endif





endmodule







/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           OTP MEMORY MODULE                           --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module OTP_memory;

    
    `include "include/DevParam.h"


    reg [dataDim-1:0] mem [0:OTP_dim-1];
    reg [dataDim-1:0] buffer [0:OTP_dim-1];
//      `define OTP_lockBit mem[OTP_dim-1][0]

    reg [OTP_addrDim-1:0] addr;
    reg overflow = 0;

    integer i;



    //-----------
    //  Init
    //-----------

    initial begin
        for (i=0; i<=OTP_dim-2; i=i+1) 
            mem[i] = data_NP;
        `ifdef MEDITERANEO
        mem[OTP_dim-1] = 'b1111111x;
        `OTP_lockBit = 1;
    `else
        mem[OTP_dim-1] = 'bxxxxxxxx;
        `OTP_lockBit = 1;
    `endif 

    end



    //---------------------------
    // Program & Read OTP tasks
    //---------------------------


    // set start address
    // (for program and read operations)
    
    task setAddr;
    input [addrDim-1:0] A;
    begin
        overflow = 0;
        addr = A[OTP_addrDim-1:0];
        if (addr > (OTP_dim-1)) 
        begin
            addr = OTP_dim-1;
            overflow =1;
            $display(  "  [%0t ns] **WARNING** Address out of OTP memory area. Column %0d will be considered!", $time, addr);
        end    
    end
    endtask


    task resetBuffer;
    for (i=0; i<=OTP_dim-1; i=i+1)
        buffer[i] = data_NP;
    endtask


    task writeDataToBuffer;
    input [dataDim-1:0] data;
    begin
        
        if (!overflow)
            buffer[addr] = data;
        
        if (addr < OTP_dim-1)
            addr = addr + 1;
        else if (overflow==0) 
            overflow = 1;
        else if (overflow==1)
            $display("  [%0t ns] **WARNING** OTP limit reached: data latched will be discarded!", $time);

    end
    endtask



    task writeBufferToMemory;
    begin

        for (i=0; i<=OTP_dim-2; i=i+1)
            mem[i] = mem[i] & buffer[i];
          mem[OTP_dim-1][0] = mem[OTP_dim-1][0] & buffer[OTP_dim-1][0]; 
          if(mem[OTP_dim-1][0] == 0)begin
              PMReg.PMR[3] = 0;
              $display("[%0t ns] PMR[3] set to 0",$time);
          end
          
    end
    endtask  



    task readData;
    output [dataDim-1:0] data;
    begin

        data = mem[addr];
        if (addr < OTP_dim-1)
            addr = addr + 1;
        //if (addr == OTP_dim) begin
        //    data[0] = mem[addr][0] & PMReg.PMR[3];
        //    $display("---debug--- %b = %b & %b",data[0],mem[addr][0],PMReg.PMR[3]);
        //    $display("---debug--- addr = %h",addr);
        //end    
        if (VolatileReg.VCR[1:0]!=2'd3) begin //implements the read data output wrap
               
             case (VolatileReg.VCR[1:0])
                    2'd0 : addr = {N25Qxxx.addr[addrDim-1: 4], addr[3:0]}; 
                    2'd1 : addr = {N25Qxxx.addr[addrDim-1: 5], addr[4:0]}; 
                    2'd2 : addr = {N25Qxxx.addr[addrDim-1: 6], addr[5:0]};
             endcase
                
        end      
    end
    endtask








endmodule   













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TIMING CHECK                                --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps
`ifdef HOLD_pin
  module TimingCheck (S, C, D, Q, W, H);
`else
  module TimingCheck (S, C, D, Q, W, R);
`endif

    `include "include/DevParam.h"
    `include "include/UserData.h"

    input S, C, D, Q;
    `ifdef HOLD_pin
      input H; 
    `endif
     input W;
    
    `ifdef RESET_pin
      input R; 
    `endif
    `define W_feature
    

    realtime delta; //used for interval measuring
    
   

    //--------------------------
    //  Task for timing check
    //--------------------------

    task check;
        
        input [8*8:1] name;  //constraint check
        input realtime interval;
        input realtime constr;
        
        begin
        
            if (interval<constr)
                //$display("[%0f ns] --TIMING ERROR-- %0s constraint violation. Measured time: %0f ns - Constraint: %0f ns",
                $display("[%0f ns] --TIMING VIOLATION-- %0s constraint violation. Measured time: %0f ns - Constraint: %0f ns",
                          $realtime, name, interval, constr);
            
        
        end
    
    endtask



    //----------------------------
    // Istants to be measured
    //----------------------------

    parameter initialTime = -1000;

    realtime C_high=initialTime, C_low=initialTime;
    realtime S_low=initialTime, S_high=initialTime;
    realtime D_valid=initialTime;
     
    `ifdef HOLD_pin
        realtime H_low=initialTime, H_high=initialTime; 
    `endif

    `ifdef RESET_pin
        realtime R_low=initialTime, R_high=initialTime; 
    `endif

    `ifdef W_feature
        realtime W_low=initialTime, W_high=initialTime; 
    `endif


    //------------------------
    //  C signal checks
    //------------------------


    always 
    @C if(C===0) //posedge(C)
    @C if(C===1)
    begin
        
        delta = $realtime - C_low; 
          check("tCL", delta, tCL);

        delta = $realtime - S_low; 
            check("tSLCH", delta, tSLCH);

        delta = $realtime - D_valid; 
        if (N25Qxxx.latchingMode!="N") 
        begin
            check("tDVCH", delta, tDVCH); // do not check during data output
        end
        delta = $realtime - S_high; 
            check("tSHCH", delta, tSHCH);

        // clock frequency checks
        delta = $realtime - C_high;
	
	    if (read.enable && delta<TR)
		$display("[%0f ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during normal READ operation. T_ck_measured=%0f ns, T_clock_min=%0f ns.",
                      $realtime, fR, delta, TR);
	    else if ( (read.enable_fast || read.enable_ID || read.enable_dual || read.enable_quad || read.enable_OTP || 
                   stat.enable_SR_read || lock.enable_lockReg_read )   
                          && 
                        delta<TC  )
		$display("[%0t ns] --TIMING ERROR-- Violation of Max clock frequency during fast READ operation(%0d MHz). T_ck_measured=%0f ns, T_clock_min=%0f ns.",
                      $realtime, fC, delta, TC);

        
        `ifdef HOLD_pin
        
            delta = $realtime - H_low; 
            check("tHLCH", delta, tHLCH);

            delta = $realtime - H_high; 
            check("tHHCH", delta, tHHCH);
        
        `endif
        
        C_high = $realtime;
        
    end



    always 
    @C if(C===1) //negedge(C)
    @C if(C===0)
    begin
        
       delta = $realtime - C_high; 
            check("tCH", delta, tCH);
        
        C_low = $realtime;
        
    end




    //------------------------
    //  S signal checks
    //------------------------


    always 
    @S if(S===1) //negedge(S)
    @S if(S===0)
    begin
        
        delta = $realtime - C_high; 
            check("tCHSL", delta, tCHSL);

        delta = $realtime - S_high; 
        check("tSHSL", delta, tSHSL);

        `ifdef W_feature
          delta = $realtime - W_high; 
          check("tWHSL", delta, tWHSL);
        `endif


        `ifdef RESET_pin
            //check during decoding
            if (N25Qxxx.resetDuringDecoding) begin 
                delta = $realtime - R_high; 
                check("tRHSL", delta, tRHSL_1);
                N25Qxxx.resetDuringDecoding = 0;
            end 
            //check during program-erase operation
            else if (N25Qxxx.resetDuringBusy && (prog.operation=="Page Program" || prog.operation=="Page Write" ||  
                      prog.operation=="Sector Erase" || prog.operation=="Bulk Erase"  || prog.operation=="Die Erase"  ||  prog.operation=="Page Erase") )   
            begin 
                delta = $realtime - R_high; 
                check("tRHSL", delta, tRHSL_2);
                N25Qxxx.resetDuringBusy = 0;
            end
            //check during subsector erase
            else if ( N25Qxxx.resetDuringBusy && (prog.operation=="Subsector Erase" || prog.operation=="Subsector Erase 32K" || prog.operation=="Subsector Erase 32K 4Byte" )) begin 
                delta = $realtime - R_high; 
                check("tRHSL", delta, tRHSL_3);
                N25Qxxx.resetDuringBusy = 0;
            end
            //check during WRSR
            else if ( N25Qxxx.resetDuringBusy && prog.operation=="Write SR" ) begin 
                delta = $realtime - R_high; 
                check("tRHSL", delta, tRHSL_4);
                N25Qxxx.resetDuringBusy = 0;
            end    
             //check during WNVCR   
            else if ( N25Qxxx.resetDuringBusy && prog.operation=="Write NV Configuration Reg" ) begin 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_5);
                N25Qxxx.resetDuringBusy = 0;
            end
            else begin//verificare 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_6);
                N25Qxxx.resetDuringBusy = 0;

            end
        `endif


        S_low = $realtime;


    end




    always 
    @S if(S===0) //posedge(S)
    @S if(S===1)
    begin
        
        delta = $realtime - C_high; 
            check("tCHSH", delta, tCHSH);
        
        S_high = $realtime;
        
    end



    //----------------------------
    //  D signal (data in) checks
    //----------------------------

    always @D 
    begin

        delta = $realtime - C_high;
        // if (N25Qxxx.latchingMode!="N") check("tCHDX", delta, tCHDX); // do not check during data output
        if (N25Qxxx.latchingMode!="N") begin
          // $display("tCHDX check: delta=%h, tCHDX=%h", delta, tCHDX , $time);
          check("tCHDX", delta, tCHDX); // do not check during data output
        end

        if (isValid(D) && N25Qxxx.latchingMode!="N") D_valid = $realtime;


    end



    //------------------------
    //  Hold signal checks
    //------------------------


    `ifdef HOLD_pin    
    

        always 
        @H if(H===1) //negedge(H)
        @H if(H===0)
        begin
            if(N25Qxxx.intHOLD == 0) begin 
              delta = $realtime - C_high; 
              check("tCHHL", delta, tCHHL);

              H_low = $realtime;
            end
            
        end



        always 
        @H if(H===0) //posedge(H)
        @H if(H===1)
        begin
            if(N25Qxxx.intHOLD == 0) begin 
            
              delta = $realtime - C_high; 
              check("tCHHH", delta, tCHHH);
              
              H_high = $realtime;
            end
            
        end


    `endif




    //------------------------
    //  W signal checks
    //------------------------


    `ifdef W_feature

        always 
        @W if(W===1) //negedge(W)
        @W if(W===0)
        begin
            
            delta = $realtime - S_high; 
            if(N25Qxxx.VolatileEnhReg.VECR[7:6] == 'b01 || N25Qxxx.NonVolatileReg.NVCR[3:2] == 'b01) //disable SHWL check when in quad mode
            begin
            end
            else    
            begin
                check("tSHWL", delta, tSHWL);
            end
            W_low = $realtime;
            
        end

        always 
        @W if(W===0) //posedge(W)
        @W if(W===1)
            W_high = $realtime;
            
    `endif




    //------------------------
    //  RESET signal checks
    //------------------------


    `ifdef RESET_pin

        always 
        @R if(R===1) //negedge(R)
        @R if(R===0)
            R_low = $realtime;
            
        always 
        @R if(R===0) //posedge(R)
        @R if(R===1)
        begin
            
            delta = $realtime - S_high; 
            check("tSHRH", delta, tSHRH);
            
            delta = $realtime - R_low; 
            check("tRLRH", delta, tRLRH);
            
            R_high = $realtime;
            
        end

    `endif




    //----------------
    // Others tasks
    //----------------

    function isValid;
    input ibit;
      if (ibit!==0 && ibit!==1) isValid=0;
      else isValid=1;
    endfunction




    

endmodule   












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           EXTENDED ADDRESS REGISTER MODULE            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps
`ifdef byte_4
module ExtendedAddressRegister;


    `include "include/DevParam.h"

    parameter [7:0] ExtendAddrReg_default = 'b00000000;


    // status register
    reg [7:0] EAR;
    




    //--------------
    // Init
    //--------------


    initial begin
        
       EAR[7:0] = ExtendAddrReg_default;
    end



    //-----------------------------------
    // write extended address register
    //-----------------------------------

    // see "Program" module


//aggiunta
//-----------------------------------
//    EAR[0]
//-----------------------------------





    //--------------------------------
    // read extended address register
    //--------------------------------
    // NB : "Read EAR" operation is also modelled in N25Qxxx.module

    reg enable_EAR_read;
    
//    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read EAR") 
//    begin : READ_EAR
//
//        `ifdef MEDITERANEO
//            if(N25Qxxx.DoubleTransferRate == 1) begin 
//                @(posedge N25Qxxx.C);
//                @(negedge N25Qxxx.C);
//            end
//        `endif
//        
//        fork 
//        
//        enable_EAR_read=1;
//
//        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
//            enable_EAR_read=0;
//            disable READ_EAR;
//        end
//        
//        join    
//    end

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read EAR") 
    begin : READ_EAR
        fork
            begin
            `ifdef MEDITERANEO
                if(N25Qxxx.DoubleTransferRate == 1) begin 
                    @(posedge N25Qxxx.C);
                    @(negedge N25Qxxx.C);
                end
            `endif
            
            enable_EAR_read=1;
            end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
            enable_EAR_read=0;
            disable READ_EAR;
        end
        join
    end

    


    



endmodule  // ExtendedAddressRegister 
`endif

//***********************************************************************
//***********************************************************************
// Stacked N25Q's
//***********************************************************************
//***********************************************************************

`timescale 1ns / 1ps 
`ifdef Stack512Mb
    `define STACKED
`elsif Stack1024Mb
    `define STACKED
`endif

`ifdef STACKED 
  `ifdef HOLD_pin
    module N25QxxxTop (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
  `else 
    module N25QxxxTop (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
  `endif

  `include "include/DevParam.h"
  
  // parameter [15:0] NVConfigReg_default = 'b1111111111111110;

  input S;
  input C;
  input [`VoltageRange] Vcc;
  
  inout DQ0; 
  inout DQ1;
  
  `ifdef HOLD_pin
    inout HOLD_DQ3; //input HOLD, inout DQ3
  `endif
  
  `ifdef RESET_pin
    inout RESET_DQ3; //input RESET, inout DQ3
  `endif
  
  inout Vpp_W_DQ2; //input Vpp_W, inout DQ2 (VPPH not implemented)

  parameter [1:0] deviceStack = 0;
  `include "include/StackDecoder.h"
  
  
    reg [1:0] current_die_sel = 0;
    reg all_die_cmd = 'h0;
    reg read_fsr_done = 'h0;
    wire any_die_busy ;
    reg [3:0] current_die ;
    wire [3:0] current_die_busy ;
    wire [3:0] current_die_active ;

    `ifdef Stack1024Mb
      assign any_die_busy = N25Q_die0.busy || N25Q_die1.busy || N25Q_die2.busy || N25Q_die3.busy ;
      assign current_die_busy = {N25Q_die3.busy , N25Q_die2.busy , N25Q_die1.busy , N25Q_die0.busy} ;
      assign current_die_active = {N25Q_die3.die_active , N25Q_die2.die_active , N25Q_die1.die_active , N25Q_die0.die_active} ;
      reg [1:0] stack_counter = 0;
    `else
      assign any_die_busy = N25Q_die0.busy || N25Q_die1.busy  ;
      assign current_die_busy ={ N25Q_die1.busy , N25Q_die0.busy} ;
      assign current_die_active = {N25Q_die1.die_active , N25Q_die0.die_active} ;
      reg   stack_counter = 0;
    `endif

    // All die commands
    always @(N25Q_die0.cmdLatched) begin
      if((any_die_busy == 0 ) && (read_fsr_done == 0)) begin
        if(N25Q_die0.cmd == 'hB1 ||  N25Q_die0.cmd =='h01 || N25Q_die0.cmd =='h68 ) begin
          all_die_cmd = 1;
          stack_counter = 0;
          read_fsr_done = 1;
        end
        // Lower die commands
        else if(N25Q_die0.cmd == 'h9E ||  N25Q_die0.cmd =='h9F ||
          N25Q_die0.cmd == 'h42 || N25Q_die0.cmd == 'h4B ||  N25Q_die0.cmd
          =='h5A ) begin
          all_die_cmd = 0;
          N25Q_die0.die_active = 1; 
          N25Q_die1.die_active = 0;
          `ifdef Stack1024Mb
            N25Q_die2.die_active = 0;N25Q_die3.die_active = 0;
          `endif
        end
        else if(N25Q_die0.cmd != 'h70) begin
          all_die_cmd = 0;
        end
      end
      else if(any_die_busy == 1) begin 
        if(N25Q_die0.cmd != 'h70 && N25Q_die0.cmd != 'h75) begin
          $display("[%0t ns] ==ERROR== Only FSR and PES commands are allowed.", $time);
        end
      end
      else begin
        $display("[%0t ns] ==ERROR== Needs to issue FSR commands for synchronization.", $time);
      end
    end

    // Stack counter increments
    always @(N25Q_die0.cmdLatched) begin
      if((all_die_cmd == 1) && (N25Q_die0.cmd == 'h70) && (read_fsr_done == 0) ) begin
        stack_counter = stack_counter + 1;
      end
    end

    // Here the all die commands are checked and round robin FSR is
    // implemented
    always @(N25Q_die0.sendToBus_stack) begin
      if((all_die_cmd == 1) && (N25Q_die0.cmd == 'h70)) begin
        read_fsr_done = 0;
        `ifdef Stack1024Mb
          case (stack_counter) 
            0 : begin N25Q_die0.die_active = 1; N25Q_die1.die_active = 0;N25Q_die2.die_active = 0;N25Q_die3.die_active = 0; end
            1 : begin N25Q_die0.die_active = 0; N25Q_die1.die_active = 1;N25Q_die2.die_active = 0;N25Q_die3.die_active = 0; end
            2 : begin N25Q_die0.die_active = 0; N25Q_die1.die_active = 0;N25Q_die2.die_active = 1;N25Q_die3.die_active = 0; end
            3 : begin N25Q_die0.die_active = 0; N25Q_die1.die_active = 0;N25Q_die2.die_active = 0;N25Q_die3.die_active = 1; end
            default : $display("[%0t ns] ERROR in stack counter value ", $time);
          endcase
        `else
          case (stack_counter) 
            0 : begin N25Q_die0.die_active = 1; N25Q_die1.die_active = 0; end
            1 : begin N25Q_die0.die_active = 0; N25Q_die1.die_active = 1; end
            default : $display("[%0t ns] ERROR in stack counter value ", $time);
          endcase
        `endif
        // stack_counter = stack_counter + 1;
      end
      // Sync the die status
      else if((all_die_cmd == 0) && (N25Q_die0.cmd == 'h70)) begin // busy needs to be included??
        if(current_die_busy != 0) begin
          current_die = current_die_busy;
        end
        else begin
          current_die = current_die_active;
        end
        $display("SYNCING the status : current_die=%h, current_die_active=%h, current_die_busy=%h ", current_die,current_die_active,current_die_busy, $time);
        case (current_die)
          1 : begin
                N25Q_die1.stat.SR[1] = (N25Q_die0.flag.FSR[1] == 0) ?  N25Q_die0.stat.SR[1] : N25Q_die1.stat.SR[1] ;
                N25Q_die1.flag.FSR = N25Q_die0.flag.FSR;
                `ifdef Stack1024Mb
                  N25Q_die2.flag.FSR = N25Q_die0.flag.FSR;
                  N25Q_die3.flag.FSR = N25Q_die0.flag.FSR;
                  N25Q_die2.stat.SR[1] = (N25Q_die0.flag.FSR[1] == 0) ?  N25Q_die0.stat.SR[1] : N25Q_die2.stat.SR[1] ;
                  N25Q_die3.stat.SR[1] = (N25Q_die0.flag.FSR[1] == 0) ?  N25Q_die0.stat.SR[1] : N25Q_die3.stat.SR[1] ;
                `endif
              end
          2 : begin
                N25Q_die0.stat.SR[1] = (N25Q_die1.flag.FSR[1] == 0) ?  N25Q_die1.stat.SR[1] : N25Q_die0.stat.SR[1] ;
                N25Q_die0.flag.FSR = N25Q_die1.flag.FSR;
                `ifdef Stack1024Mb
                  N25Q_die2.flag.FSR = N25Q_die1.flag.FSR;
                  N25Q_die3.flag.FSR = N25Q_die1.flag.FSR;
                  N25Q_die2.stat.SR[1] = (N25Q_die1.flag.FSR[1] == 0) ?  N25Q_die1.stat.SR[1] : N25Q_die2.stat.SR[1] ;
                  N25Q_die3.stat.SR[1] = (N25Q_die1.flag.FSR[1] == 0) ?  N25Q_die1.stat.SR[1] : N25Q_die3.stat.SR[1] ;
                `endif
              end
          `ifdef Stack1024Mb
          4 : begin
                N25Q_die0.flag.FSR = N25Q_die2.flag.FSR;
                N25Q_die1.flag.FSR = N25Q_die2.flag.FSR;
                N25Q_die3.flag.FSR = N25Q_die2.flag.FSR;
                N25Q_die0.stat.SR[1] = (N25Q_die2.flag.FSR[1] == 0) ?  N25Q_die2.stat.SR[1] : N25Q_die0.stat.SR[1] ;
                N25Q_die1.stat.SR[1] = (N25Q_die2.flag.FSR[1] == 0) ?  N25Q_die2.stat.SR[1] : N25Q_die1.stat.SR[1] ;
                N25Q_die3.stat.SR[1] = (N25Q_die2.flag.FSR[1] == 0) ?  N25Q_die2.stat.SR[1] : N25Q_die3.stat.SR[1] ;
              end
          8 : begin
                N25Q_die0.flag.FSR = N25Q_die3.flag.FSR;
                N25Q_die1.flag.FSR = N25Q_die3.flag.FSR;
                N25Q_die2.flag.FSR = N25Q_die3.flag.FSR;
                N25Q_die0.stat.SR[1] = (N25Q_die3.flag.FSR[1] == 0) ?  N25Q_die3.stat.SR[1] : N25Q_die0.stat.SR[1] ;
                N25Q_die1.stat.SR[1] = (N25Q_die3.flag.FSR[1] == 0) ?  N25Q_die3.stat.SR[1] : N25Q_die1.stat.SR[1] ;
                N25Q_die2.stat.SR[1] = (N25Q_die3.flag.FSR[1] == 0) ?  N25Q_die3.stat.SR[1] : N25Q_die2.stat.SR[1] ;
              end
          `endif
          //default : $display("[%0t ns] ERROR in current_die_busy decode (N25Q)", $time);
        endcase
      end
      else begin

      end
    end

    //------------------------------
    // Calculating device select during stacked die
    // die active indicates the die selected
    //------------------------------
    
    always@(N25Q_die0.addrLatched) begin
      if((N25Q_die0.prog.enable_4Byte_address == 1) || (N25Q_die0.NonVolatileReg.NVCR[0] == 0)) begin
        stackDieDecode(N25Q_die0.addrLatch[N25Q_die0.addrDim +1: N25Q_die0.addrDim]);
      end
      else begin
        stackDieDecode(N25Q_die0.ExtAddReg.EAR[1:0]);
      end
    end
    
    task stackDieDecode;
      input [1:0] dieaddr ;
        `ifdef Stack1024Mb
        case (dieaddr)
        `else
        case (dieaddr[0])
        `endif
          0 : begin
                N25Q_die0.die_active = 1;
                N25Q_die1.die_active = 0;
                `ifdef Stack1024Mb
                  N25Q_die2.die_active = 0;
                  N25Q_die3.die_active = 0;
                `endif
              end
          1 : begin
                N25Q_die0.die_active = 0;
                N25Q_die1.die_active = 1;
                `ifdef Stack1024Mb
                  N25Q_die2.die_active = 0;
                  N25Q_die3.die_active = 0;
                `endif
              end
          `ifdef Stack1024Mb
          2 : begin
                N25Q_die0.die_active = 0;
                N25Q_die1.die_active = 0;
                N25Q_die2.die_active = 1;
                N25Q_die3.die_active = 0;
              end
          3: begin
                N25Q_die0.die_active = 0;
                N25Q_die1.die_active = 0;
                N25Q_die2.die_active = 0;
                N25Q_die3.die_active = 1;
              end
          `endif
      endcase
    endtask
    
    //-------------------------------------------
    // Function to test sector protection status
    //-------------------------------------------
    
    function isProtected_by_SR_stack;
    input [addrDim-1:0] byteAddr;
    reg [sectorAddrDim+1:0] sectAddr;
    begin
    
        sectAddr = N25Q_die0.f.sec(byteAddr) | (current_die_active -1 ) << sectorAddrDim ;
        isProtected_by_SR_stack = N25Q_die0.lock.lock_by_SR[sectAddr]; 
         $display("In isProtected_by_SR_stack: sectAddr=%h, isProtected_by_SR_stack = %h ", sectAddr ,isProtected_by_SR_stack ,$time);
    
    end
    endfunction

    function [dataDim - 1: 0] getMemory;
      input [addrDim - 1: 0] memAddr;
      begin
        //getMemory = N25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}];
        case(current_die_active)
            'b01: getMemory = N25Q_die0.mem.memory[memAddr];
            'b10: getMemory = N25Q_die1.mem.memory[memAddr];
        endcase
        //$display("In getMemory : memData = %h, addr =%h , current_die_active =%b", getMemory, memAddr , current_die_active, $time);
      end
    endfunction
    
    function setMemory;
      input [addrDim - 1: 0] memAddr;
      input [dataDim - 1: 0] memData;
      begin
        case(current_die_active)
            'b01: N25Q_die0.mem.memory[memAddr] = memData;
            'b10: N25Q_die1.mem.memory[memAddr] = memData;
        endcase
        //$display("In setMemory : memData = %h, addr =%h , current_die_active =%h", memData, memAddr , current_die_active, $time);
        //N25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}] = memData;
        setMemory = 1;
      end
    endfunction
    
    
  endmodule // N25QxxxTop
`endif

`ifdef STACKED_MEDT_1G
    `ifdef Feature_8
        `ifdef HOLD_pin
            module MT25QxxxTop (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `else 
            module MT25QxxxTop (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `endif
    `else
        `ifdef HOLD_pin
            module MT25QxxxTop (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `else 
            module MT25QxxxTop (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `endif
    `endif // Feature_8

`include "include/DevParam.h"

  input S;
  input C;
  input [`VoltageRange] Vcc;
  
  inout DQ0; 
  inout DQ1;

`ifdef Feature_8
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `endif
`else
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
    `endif
`endif

  inout Vpp_W_DQ2; //input Vpp_W, inout DQ2 (VPPH not implemented)

    reg [1:0] current_die_sel = 0;
    reg all_die_cmd = 'h0;
    reg read_fsr_done = 'h0;
    wire any_die_busy ;
    reg [3:0] current_die ;
    wire [3:0] current_die_busy ;
    wire [3:0] current_die_active ;

`include "include/StackDecoder.h"

    assign any_die_busy = MT25Q_die0.busy || MT25Q_die1.busy  ;
    assign current_die_busy ={ MT25Q_die1.busy , MT25Q_die0.busy} ;
    assign current_die_active = {MT25Q_die1.die_active , MT25Q_die0.die_active} ;
    reg   stack_counter = 0;

    // Here the all die commands are checked and round robin FSR is
    // implemented
    always @(MT25Q_die0.sendToBus_stack) begin
      if((all_die_cmd == 1) && (MT25Q_die0.cmd == `CMD_RDFSR)) begin
        read_fsr_done = 0;
        `ifdef Stack1024Mb
          case (stack_counter) 
            0 : begin MT25Q_die0.die_active = 1; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 0; end
            1 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 1;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 0; end
            2 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 1;MT25Q_die3.die_active = 0; end
            3 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 1; end
            default : $display("[%0t ns] ERROR in stack counter value ", $time);
          endcase
        `else
          case (stack_counter) 
            0 : begin MT25Q_die0.die_active = 1; MT25Q_die1.die_active = 0; end
            1 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 1; end
            default : $display("[%0t ns] ERROR in stack counter value ", $time);
          endcase
        `endif
         stack_counter = stack_counter + 1;
      end
      // Sync the die status
      else if((all_die_cmd == 0) && (MT25Q_die0.cmd == `CMD_RDFSR)) begin // busy needs to be included??
        if(current_die_busy != 0) begin
          current_die = current_die_busy;
        end
        else begin
          current_die = current_die_active;
        end
        $display("SYNCING the status : current_die=%h, current_die_active=%h, current_die_busy=%h ", current_die,current_die_active,current_die_busy, $time);
        case (current_die)
          1 : begin
                MT25Q_die1.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die1.flag.FSR = MT25Q_die0.flag.FSR;
                `ifdef Stack1024Mb
                  MT25Q_die2.flag.FSR = MT25Q_die0.flag.FSR;
                  MT25Q_die3.flag.FSR = MT25Q_die0.flag.FSR;
                  MT25Q_die2.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
                  MT25Q_die3.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
                `endif
              end
          2 : begin
                MT25Q_die0.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die0.flag.FSR = MT25Q_die1.flag.FSR;
                `ifdef Stack1024Mb
                  MT25Q_die2.flag.FSR = MT25Q_die1.flag.FSR;
                  MT25Q_die3.flag.FSR = MT25Q_die1.flag.FSR;
                  MT25Q_die2.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
                  MT25Q_die3.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
                `endif
              end
          `ifdef Stack1024Mb
          4 : begin
                MT25Q_die0.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die1.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die3.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die0.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die1.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die3.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
              end
          8 : begin
                MT25Q_die0.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die1.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die2.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die0.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die1.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die2.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
              end
          `endif
          default : $display("[%0t ns] ERROR in current_die_busy decode", $time);
        endcase
      end
      else begin

      end
    end

    // All die commands
    always @(MT25Q_die0.cmdLatched) begin
      if((any_die_busy == 0 ) && (read_fsr_done == 0)) begin
        if(MT25Q_die0.cmd == `CMD_WRNVCR  ||  MT25Q_die0.cmd == `CMD_WRSR   || MT25Q_die0.cmd == `CMD_PPMR    ||
           MT25Q_die0.cmd == `CMD_WRVCR   ||  MT25Q_die0.cmd == `CMD_WRVECR || MT25Q_die0.cmd == `CMD_CLRFSR  ||
           MT25Q_die0.cmd == `CMD_DPD     ||  MT25Q_die0.cmd == `CMD_RDPD   || MT25Q_die0.cmd == `CMD_EN4BYTE ||
           MT25Q_die0.cmd == `CMD_EX4BYTE ||  MT25Q_die0.cmd == `CMD_WREAR  || MT25Q_die0.cmd == `CMD_RSTEN   ||
           MT25Q_die0.cmd == `CMD_RST     ||  MT25Q_die0.cmd == `CMD_WREN   || MT25Q_die0.cmd == `CMD_WRDI ) begin
          all_die_cmd = 1;
          stack_counter = 0;
          read_fsr_done = 1;
        end
        // Lower die commands
        else if(MT25Q_die0.cmd == `CMD_RDID1 ||  MT25Q_die0.cmd == `CMD_RDID2 ||
          MT25Q_die0.cmd == `CMD_POTP || MT25Q_die0.cmd == `CMD_ROTP ||  MT25Q_die0.cmd ==`CMD_RDSFDP ) begin
          all_die_cmd = 0;
          MT25Q_die0.die_active = 1; 
          MT25Q_die1.die_active = 0;
          //MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 0;
        end
        else if(MT25Q_die0.cmd != `CMD_RDFSR) begin
          all_die_cmd = 0;
        end
      end
      else if(any_die_busy == 1) begin 
               if(MT25Q_die0.cmd != `CMD_RDFSR && MT25Q_die0.cmd != `CMD_PES) begin
                 $display("[%0t ns] ==ERROR== Only FSR and PES commands are allowed.", $time);
               end
           end
      else begin
            //$display("[%0t ns] ==ERROR== Needs to issue FSR commands for synchronization.", $time);
           end
    end

    // Stack counter increments
    always @(MT25Q_die0.cmdLatched) begin
      if((all_die_cmd == 1) && (MT25Q_die0.cmd == `CMD_RDFSR) && (read_fsr_done == 0) ) begin
        stack_counter = stack_counter + 1;
      end
    end
    //------------------------------
    // Calculating device select during stacked die
    // die active indicates the die selected
    //------------------------------
    
    always@(MT25Q_die0.addrLatched) begin
      if((MT25Q_die0.prog.enable_4Byte_address == 1) || (MT25Q_die0.NonVolatileReg.NVCR[0] == 0)) begin
        //stackDieDecode(MT25Q_die0.addrLatch[MT25Q_die0.addrDim +1: MT25Q_die0.addrDim]);
        stackDieDecode(MT25Q_die0.addrLatch[MT25Q_die0.addrDim]);
      end
      else begin
        stackDieDecode(MT25Q_die0.ExtAddReg.EAR[1:0]);
      end
    end
    
    task stackDieDecode;
      input [1:0] dieaddr ;
        `ifdef Stack1024Mb
        case (dieaddr)
        `else
        case (dieaddr[0])
        `endif
          0 : begin
                MT25Q_die0.die_active = 1;
                MT25Q_die1.die_active = 0;
                `ifdef Stack1024Mb
                  MT25Q_die2.die_active = 0;
                  MT25Q_die3.die_active = 0;
                `endif
              end
          1 : begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 1;
                `ifdef Stack1024Mb
                  MT25Q_die2.die_active = 0;
                  MT25Q_die3.die_active = 0;
                `endif
              end
          `ifdef Stack1024Mb
          2 : begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 0;
                MT25Q_die2.die_active = 1;
                MT25Q_die3.die_active = 0;
              end
          3: begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 0;
                MT25Q_die2.die_active = 0;
                MT25Q_die3.die_active = 1;
              end
          `endif
      endcase
    endtask //stackDieDecode

    //-------------------------------------------
    // Function to test sector protection status
    //-------------------------------------------
    
    function isProtected_by_SR_stack;
    input [addrDim-1:0] byteAddr;
    reg [sectorAddrDim+1:0] sectAddr;
    begin
    
        sectAddr = MT25Q_die0.f.sec(byteAddr) | (current_die_active -1 ) << sectorAddrDim ;
        isProtected_by_SR_stack = MT25Q_die0.lock.lock_by_SR[sectAddr]; 
        // $display("In isProtected_by_SR_stack: sectAddr=%h, isProtected_by_SR_stack = %h ", sectAddr ,isProtected_by_SR_stack ,$time);
    
    end
    endfunction

    function [dataDim - 1: 0] getMemory;
      input [addrDim - 1: 0] memAddr;
      begin
        getMemory = MT25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}];
        $display("In getMemory : memData = %h, addr =%h , current_die_active =%h", getMemory, memAddr , current_die_active, $time);
      end
    endfunction
    
    function setMemory;
      input [addrDim - 1: 0] memAddr;
      input [dataDim - 1: 0] memData;
      begin
        case(current_die_active)
            'b01: MT25Q_die0.mem.memory[memAddr] = memData;
            'b10: MT25Q_die1.mem.memory[memAddr] = memData;
        endcase
        //MT25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}] = memData;
        setMemory = 1;
      end
    endfunction
endmodule // MT25QxxxTop
`endif // STACKED_MEDT_1G

`ifdef STACKED_MEDT_2G
    `ifdef Feature_8
        `ifdef HOLD_pin
            module MT25QxxxTop (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `else 
            module MT25QxxxTop (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2);
        `endif
    `else
        `ifdef HOLD_pin
            module MT25QxxxTop (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `else 
            module MT25QxxxTop (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
        `endif
    `endif // Feature_8

`include "include/DevParam.h"

  input S;
  input C;
  input [`VoltageRange] Vcc;
  
  inout DQ0; 
  inout DQ1;

`ifdef Feature_8
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
        input RESET2;
    `endif
`else
   `ifdef HOLD_pin
        inout HOLD_DQ3; //input HOLD, inout DQ3
    `elsif RESET_pin
        inout RESET_DQ3; //input HOLD, inout DQ3
    `endif
`endif

  inout Vpp_W_DQ2; //input Vpp_W, inout DQ2 (VPPH not implemented)

    reg [1:0] current_die_sel = 0;
    reg all_die_cmd = 'h0;
    reg read_fsr_done = 'h0;
    wire any_die_busy ;
    reg [3:0] current_die ;
    wire [3:0] current_die_busy ;
    wire [3:0] current_die_active ;

`include "include/StackDecoder.h"

    assign any_die_busy = MT25Q_die0.busy || MT25Q_die1.busy || MT25Q_die2.busy || MT25Q_die3.busy  ;
    assign current_die_busy ={ MT25Q_die3.busy, MT25Q_die2.busy, MT25Q_die1.busy , MT25Q_die0.busy} ;
    assign current_die_active = {MT25Q_die3.die_active, MT25Q_die2.die_active, MT25Q_die1.die_active , MT25Q_die0.die_active} ;
    reg [1:0]   stack_counter = 0;

    // Here the all die commands are checked and round robin FSR is
    // implemented
    always @(MT25Q_die0.sendToBus_stack) begin
      if((all_die_cmd == 1) && ((MT25Q_die0.cmd == `CMD_RDFSR) || (MT25Q_die0.cmd == `CMD_RDSR))) begin
        read_fsr_done = 0;
//        `ifdef Stack1024Mb
          case (stack_counter) 
            0 : begin MT25Q_die0.die_active = 1; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 0; end
            1 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 1;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 0; end
            2 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 1;MT25Q_die3.die_active = 0; end
            3 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 0;MT25Q_die2.die_active = 0;MT25Q_die3.die_active = 1; end
            default : $display("[%0t ns] ERROR in stack counter value ", $time);
          endcase
//        `else
//          case (stack_counter) 
//            0 : begin MT25Q_die0.die_active = 1; MT25Q_die1.die_active = 0; end
//            1 : begin MT25Q_die0.die_active = 0; MT25Q_die1.die_active = 1; end
//            default : $display("[%0t ns] ERROR in stack counter value ", $time);
//          endcase
//        `endif
         stack_counter = stack_counter + 1;
      end
      // Sync the die status
      else if((all_die_cmd == 0) && (MT25Q_die0.cmd == `CMD_RDFSR)) begin // busy needs to be included??
        if(current_die_busy != 0) begin
          current_die = current_die_busy;
        end
        else begin
          current_die = current_die_active;
        end
        //$display("SYNCING the status : current_die=%h, current_die_active=%h, current_die_busy=%h ", current_die,current_die_active,current_die_busy, $time);
        case (current_die)
          1 : begin
                MT25Q_die1.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die1.flag.FSR = MT25Q_die0.flag.FSR;
            //    `ifdef Stack1024Mb
                  MT25Q_die2.flag.FSR = MT25Q_die0.flag.FSR;
                  MT25Q_die3.flag.FSR = MT25Q_die0.flag.FSR;
                  MT25Q_die2.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
                  MT25Q_die3.stat.SR[1] = (MT25Q_die0.flag.FSR[1] == 0) ?  MT25Q_die0.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
            //    `endif
              end
          2 : begin
                MT25Q_die0.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die0.flag.FSR = MT25Q_die1.flag.FSR;
            //    `ifdef Stack1024Mb
                  MT25Q_die2.flag.FSR = MT25Q_die1.flag.FSR;
                  MT25Q_die3.flag.FSR = MT25Q_die1.flag.FSR;
                  MT25Q_die2.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
                  MT25Q_die3.stat.SR[1] = (MT25Q_die1.flag.FSR[1] == 0) ?  MT25Q_die1.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
            //    `endif
              end
         // `ifdef Stack1024Mb
          4 : begin
                MT25Q_die0.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die1.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die3.flag.FSR = MT25Q_die2.flag.FSR;
                MT25Q_die0.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die1.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die3.stat.SR[1] = (MT25Q_die2.flag.FSR[1] == 0) ?  MT25Q_die2.stat.SR[1] : MT25Q_die3.stat.SR[1] ;
              end
          8 : begin
                MT25Q_die0.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die1.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die2.flag.FSR = MT25Q_die3.flag.FSR;
                MT25Q_die0.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die0.stat.SR[1] ;
                MT25Q_die1.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die1.stat.SR[1] ;
                MT25Q_die2.stat.SR[1] = (MT25Q_die3.flag.FSR[1] == 0) ?  MT25Q_die3.stat.SR[1] : MT25Q_die2.stat.SR[1] ;
              end
        //  `endif
       //   default : $display("[%0t ns] ERROR in current_die_busy decode", $time);
        endcase
      end
      else begin

      end
    end

    // All die commands
    always @(MT25Q_die0.cmdLatched) begin
      if((any_die_busy == 0 ) && (read_fsr_done == 0)) begin
        if(MT25Q_die0.cmd == `CMD_WRNVCR  ||  MT25Q_die0.cmd == `CMD_WRSR   || MT25Q_die0.cmd == `CMD_PPMR    ||
           MT25Q_die0.cmd == `CMD_WRVCR   ||  MT25Q_die0.cmd == `CMD_WRVECR || MT25Q_die0.cmd == `CMD_CLRFSR  ||
           MT25Q_die0.cmd == `CMD_DPD     ||  MT25Q_die0.cmd == `CMD_RDPD   || MT25Q_die0.cmd == `CMD_EN4BYTE ||
           MT25Q_die0.cmd == `CMD_EX4BYTE ||  MT25Q_die0.cmd == `CMD_WREAR  || MT25Q_die0.cmd == `CMD_RSTEN   ||
           MT25Q_die0.cmd == `CMD_RST     ||  MT25Q_die0.cmd == `CMD_WREN   || MT25Q_die0.cmd == `CMD_WRDI ) begin
          all_die_cmd = 1;
          stack_counter = 0;
          read_fsr_done = 1;
        end
        // Lower die commands
        else if(MT25Q_die0.cmd == `CMD_RDID1 ||  MT25Q_die0.cmd == `CMD_RDID2 ||
          MT25Q_die0.cmd == `CMD_POTP || MT25Q_die0.cmd == `CMD_ROTP ||  MT25Q_die0.cmd ==`CMD_RDSFDP ) begin
          all_die_cmd = 0;
          MT25Q_die0.die_active = 1; 
          MT25Q_die1.die_active = 0;
          MT25Q_die2.die_active = 0;
          MT25Q_die3.die_active = 0;
        end
        else if(MT25Q_die0.cmd != `CMD_RDFSR) begin
          all_die_cmd = 0;
               read_fsr_done=0;
        end
      end
      else if(any_die_busy == 1) begin 
               if(MT25Q_die0.cmd != `CMD_RDFSR && MT25Q_die0.cmd != `CMD_PES && MT25Q_die0.cmd != `CMD_RDSR) begin
                 $display("[%0t ns] ==ERROR== Only FSR and PES commands are allowed.", $time);
               end
               all_die_cmd=0;
               read_fsr_done=0;
           end
      else begin
            //$display("[%0t ns] ==ERROR== Needs to issue FSR commands for synchronization.", $time);
               all_die_cmd=0;
               read_fsr_done=0;
           end
    end

    // Stack counter increments
    always @(MT25Q_die0.cmdLatched) begin
      if((all_die_cmd == 1) && (MT25Q_die0.cmd == `CMD_RDFSR) && (read_fsr_done == 0) ) begin
        stack_counter = stack_counter + 1;
      end
    end
    //------------------------------
    // Calculating device select during stacked die
    // die active indicates the die selected
    //------------------------------
    
    always@(MT25Q_die0.addrLatched) begin
      if((MT25Q_die0.prog.enable_4Byte_address == 1) || (MT25Q_die0.NonVolatileReg.NVCR[0] == 0)) begin
        stackDieDecode(MT25Q_die0.addrLatch[MT25Q_die0.addrDim +1: MT25Q_die0.addrDim]);
        //stackDieDecode(MT25Q_die0.addrLatch[MT25Q_die0.addrDim + 2]);
      end
      else begin
        stackDieDecode(MT25Q_die0.ExtAddReg.EAR[1:0]);
      end
    end
    
    //Die Erase
//    always @(MT25Q_die0.prog.noError)
//        begin
//            if(MT25Q_die0.prog.operation=="Die Erase") 
//                begin
//                    MT25Q_die1.mem.eraseDie;
//                    MT25Q_die2.mem.eraseDie;
//                    MT25Q_die3.mem.eraseDie;
//                end
//        end

    task stackDieDecode;
      input [1:0] dieaddr ;
      //  `ifdef Stack1024Mb
        case (dieaddr)
      //  `else
      //  case (dieaddr[0])
      //  `endif
          0 : begin
                MT25Q_die0.die_active = 1;
                MT25Q_die1.die_active = 0;
//                `ifdef Stack1024Mb
                  MT25Q_die2.die_active = 0;
                  MT25Q_die3.die_active = 0;
//                `endif
              end
          1 : begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 1;
//                `ifdef Stack1024Mb
                  MT25Q_die2.die_active = 0;
                  MT25Q_die3.die_active = 0;
//                `endif
              end
//          `ifdef Stack1024Mb
          2 : begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 0;
                MT25Q_die2.die_active = 1;
                MT25Q_die3.die_active = 0;
              end
          3: begin
                MT25Q_die0.die_active = 0;
                MT25Q_die1.die_active = 0;
                MT25Q_die2.die_active = 0;
                MT25Q_die3.die_active = 1;
              end
//          `endif
      endcase
    endtask //stackDieDecode

    //-------------------------------------------
    // Function to test sector protection status
    //-------------------------------------------
    
    function isProtected_by_SR_stack;
    input [addrDim-1:0] byteAddr;
    reg [sectorAddrDim+1:0] sectAddr;
    begin
    
        sectAddr = MT25Q_die0.f.sec(byteAddr) | (current_die_active -1 ) << sectorAddrDim ;
        isProtected_by_SR_stack = MT25Q_die0.lock.lock_by_SR[sectAddr]; 
        // $display("In isProtected_by_SR_stack: sectAddr=%h, isProtected_by_SR_stack = %h ", sectAddr ,isProtected_by_SR_stack ,$time);
    
    end
    endfunction

    function [dataDim - 1: 0] getMemory;
      input [addrDim - 1: 0] memAddr;
      begin
        getMemory = MT25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}];
        $display("In getMemory : memData = %h, addr =%h , current_die_active =%h", getMemory, memAddr , current_die_active, $time);
      end
    endfunction
    
    function setMemory;
      input [addrDim - 1: 0] memAddr;
      input [dataDim - 1: 0] memData;
      begin
        case(current_die_active)
            'b0000: MT25Q_die0.mem.memory[memAddr] = memData;
            'b0010: MT25Q_die1.mem.memory[memAddr] = memData;
            'b0100: MT25Q_die2.mem.memory[memAddr] = memData;
            'b1000: MT25Q_die3.mem.memory[memAddr] = memData;
        endcase
        //MT25Q_die0.mem.memory[{current_die_active - 1 ,memAddr}] = memData;
        setMemory = 1;
      end
    endfunction
endmodule // MT25QxxxTop
`endif // STACKED_MEDT_2G


//----------------------------------------------------
// Power Loss Rescue Sequence 1st part detector
//
//----------------------------------------------------

`timescale 1ns / 1ps

module PLRSpart1Detect (S, C, EN4b);

    parameter integer count = 24;
    parameter [8*8:1] protocol = "extended";

    input S;
    input C;
    input EN4b;

    integer iXIP_count;
    integer plrs_part1_excess_clock = 0;
    reg XIP_rst = 0;
    reg start_XIP_rescue = 0;
    reg not_valid_1st_part = 0;
    reg power_rst = 0;
    
    event plrs_part1_count_reached;

    always @N25Qxxx.startCUIdec if ((N25Qxxx.cmd[6] && N25Qxxx.cmd[4] && N25Qxxx.cmd[2] && N25Qxxx.cmd[0] && N25Qxxx.protocol=="dual") ||
                                    (N25Qxxx.cmd[7] && N25Qxxx.cmd[4] && N25Qxxx.cmd[3] && N25Qxxx.cmd[0] && N25Qxxx.protocol=="quad") ||
                                    (N25Qxxx.cmd=='b11111111 && N25Qxxx.protocol=="extended")) begin
        N25Qxxx.cmdRecName = "Power Loss Rescue Sequence";
        //$display("[%0t ns] COMMAND RECOGNIZED: %0s.", $time, N25Qxxx.cmdRecName);
        -> N25Qxxx.seqRecognized; 
    end    

    always @(negedge S) begin
        //if(protocol == N25Qxxx.protocol && power_rst == 0) begin
        if(protocol == N25Qxxx.protocol && EN4b) begin
            iXIP_count = count;  
            //$display("  [%0t ps] PLRS: 1st part of Power Loss Rescue Sequence initiated. ", $time);
            start_XIP_rescue = 1;
            plrs_part1_excess_clock = 0; 
        end
    end
    
    always @(posedge C) begin
    if (start_XIP_rescue ==  1 ) begin : Resc_seq
       if(iXIP_count > 0) begin
          iXIP_count = iXIP_count - 1;
            `ifdef HOLD_pin
                if (N25Qxxx.DQ0 != 1 || N25Qxxx.HOLD_DQ3 != 1) begin
            `else
                if (N25Qxxx.DQ0 != 1 || N25Qxxx.RESET_DQ3 != 1) begin
            `endif
             //$display("  [%0t ps] ***WARNING*** PLRS: 1st part of Power Loss Rescue Sequence to get memory out of XIP mode aborted ", $time);
             //$display("  [%0t ps] ***WARNING*** PLRS: Need to drive DQ0 and DQ3 to 1 !!! ", $time);
    //         iXIP_count = 0;
             //latchingMode = "N";
             disable Resc_seq;
          end
       end else begin
           if(S == 0)
            -> plrs_part1_count_reached;
            end 
       end         
    end // end for always block

    // detects that enough clock cycles for 1st part of PLR Sequence
    // had been given, we then wait for rising edge of S.
    //--------------------------------------------------------------
    always @plrs_part1_count_reached begin
        @(posedge S) begin
            if(not_valid_1st_part == 0) begin
                iXIP_count = 0;
                XIP_rst = 0;
                //N25Qxxx.XIP = 0;
                //VolatileReg.VCR[3] = 1;
                start_XIP_rescue = 0;
              //$display("  [%0t ps] ==INFO== PLRS: 1st part of Power Loss Rescue Sequence to get memory out of XIP mode completed", $time); 
            end else begin
             not_valid_1st_part = 0;
             plrs_part1_excess_clock = 0;
             end
        end
    end

    // checks for excess clock pulses once the required clock pulses
    // have been reached for the 1st part of PLR Sequence
    //---------------------------------------------------------------
    always @plrs_part1_count_reached begin
        plrs_part1_excess_clock = plrs_part1_excess_clock + 1;
        if(plrs_part1_excess_clock > 1) begin
            //$display("   [%0t ps] ==ERROR== Excess clock cycles for 1st part of PLRS ", $time);
            not_valid_1st_part = 1;
        end    
    end

endmodule // PLRSpart1Detect 







//----------------------------------------------------
// Power Loss Rescue Sequence 2st part detector
//
//----------------------------------------------------

`timescale 1ns / 1ps 
//module PLRSpart2Detect (S, C, PLR1Done, PLR2Done, PLR2Abort);
module PLRSpart2Detect (S, C, modify_in_progress);

    parameter integer count = 7;

    input S;
    input C;
    input modify_in_progress;
    reg start_PLR2_rescue = 0;
    reg not_valid_2nd_part = 0;
    reg abort = 0;
    reg plr2_done = 0;
    integer iPow_res = 4;
    integer plrs_part2_excess_clock = 0; 

    event plrs_part2_count_reached;

    always @N25Qxxx.startCUIdec if ((N25Qxxx.cmd[6] && N25Qxxx.cmd[4] && N25Qxxx.cmd[2] && N25Qxxx.cmd[0] && N25Qxxx.protocol=="dual") ||
                                    (N25Qxxx.cmd[7] && N25Qxxx.cmd[4] && N25Qxxx.cmd[3] && N25Qxxx.cmd[0] && N25Qxxx.protocol=="quad") ||
                                    (N25Qxxx.cmd=='b11111111 && N25Qxxx.protocol=="extended")) begin
    //    N25Qxxx.cmdRecName = "Power Loss Rescue Sequence";
        //$display("[%0t ns] COMMAND RECOGNIZED: %0s.", $time, N25Qxxx.cmdRecName);
        -> N25Qxxx.seqRecognized; 
    end    

    always @(negedge S) begin
        `ifdef INT_RST_SEQ
             iPow_res = 16;
        `else
             iPow_res = count;
        `endif
             start_PLR2_rescue = 1;
         plr2_done = 0;
         plrs_part2_excess_clock = 0;
    end    

    always @(posedge C) begin
        if (start_PLR2_rescue) begin : Resc2_seq
            if (iPow_res > 0) begin : Power_rescue_seq
                `ifdef HOLD_pin
                    if (N25Qxxx.DQ0 != 1 || N25Qxxx.HOLD_DQ3 != 1) begin
                `else
                    if (N25Qxxx.DQ0 != 1 || N25Qxxx.RESET_DQ3 != 1) begin
                `endif
                        //$display("  [%0t ps] ***WARNING*** PLRS: 2nd part of Rescue Sequence Aborted ", $time);
                        //$display("  [%0t ps] ***WARNING*** PLRS: Need to drive DQ0 and DQ3 to 1 !!! ", $time);
                        iPow_res = 0;
        //                abort = 1;
                        start_PLR2_rescue = 0;
                        disable Power_rescue_seq;
                    end
            iPow_res = iPow_res - 1;
            end else begin
                -> plrs_part2_count_reached;
            `ifdef HOLD_pin 
                release N25Qxxx.DQ0;
                release N25Qxxx.HOLD_DQ3;
            `else 
                release N25Qxxx.DQ0;
                release N25Qxxx.RESET_DQ3;
            `endif
            //latchingMode = "N";
            end 
        end
    end

    // once enough count for part 2 of PLR Sequence have been reached
    // we wait for the rising edge of S and put bfm in extended.
    //---------------------------------------------------------------
    always @plrs_part2_count_reached begin
        @(posedge S) begin
            if(not_valid_2nd_part == 0) begin
                iPow_res = 0;
                start_PLR2_rescue = 0;
                //power_rst = 0;
                N25Qxxx.rescue_seq_flag = 0;
                plr2_done = 1;
    //          VolatileEnhReg.VECR[5] = 1;
                N25Qxxx.VolatileEnhReg.VECR[6] = 1;
                N25Qxxx.VolatileEnhReg.VECR[7] = 1;    
    //            `ifdef MEDITERANEO
    //          N25Qxxx.DoubleTransferRate = !VolatileEnhReg.VECR[5];
    //            `endif
                `ifdef INT_RST_SEQ
                    $display("  [%0t ps] ==INFO== PLRS: Rescue Sequence to reset the interface of memory device to power up state.", $time);
                `else
                    if(!modify_in_progress) begin
                        $display("  [%0t ps] ==INFO== PLRS: 2nd part of Power Loss Rescue Sequence completed.", $time);
                        N25Qxxx.protocol = "extended";
                    end else begin
                        $display("  [%0t ps] ==WARNING== PLRS: Device Busy, 2nd part of Power Loss Rescue Sequence did not complete.", $time);
                        $display("  [%0t ps] ==WARNING== PLRS: Redo the 2nd part of the sequence or Redo the entire sequence.", $time);
                    end
                `endif      
            end else begin
                iPow_res = 7;
                not_valid_2nd_part = 0;
                plrs_part2_excess_clock = 0;
            end
        end
    end

    // checks for excess clock pulses once the required clock pulses
    // have been reached for the 2nd part of PLR Sequence
    //---------------------------------------------------------------
    always @plrs_part2_count_reached begin
        plrs_part2_excess_clock = plrs_part2_excess_clock + 1;
        if(plrs_part2_excess_clock > 1) begin
            if(not_valid_2nd_part == 0)
                //$display("   [%0t ps] ==ERROR== PLRS: Excess clock cycles for 2nd part of PLRS ", $time);
            not_valid_2nd_part = 1;
        end    
    end

endmodule // PLRSpart2Detect module


`ifdef MEDT_GPRR
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   GENREAL PUPRPOSE REGISTER (GPRR )   MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
module GeneralPurposeRegister;

//    `include "include/DevParam.h"

    parameter [(64*8)-1:0] GPRR_default = 512'b0;
   
    // General purpose register register

    reg [(64*8)-1:0] GPRR;
    reg enable_GPRR_read;
    reg [6:0] GPRR_location;

     
    //--------------
    // Init
    //--------------

    initial begin
        enable_GPRR_read = 0;
        GPRR[(64*8)-1:0] = GPRR_default;
    end

    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read GPRR Reg") 
    fork : READ_GPRR
            begin : GPRR_read 
                
                N25Qxxx.dummyDimEff = 8;
                N25Qxxx.iDummy = 7;
                $display("  [%0t ps] GPRR Read Dummy byte expected ...",$time);
                N25Qxxx.latchingMode="Y"; //Y=dummy
                @N25Qxxx.dummyLatched;
                GPRR_location = 0;
                enable_GPRR_read=1;
                N25Qxxx.latchingMode="N"; // Data out
            end    

            @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                enable_GPRR_read=0;
                GPRR_location = 0;
                disable GPRR_read;
            end
    join    

endmodule   
`endif

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   Persistent Protection Bit (PPB) MODULE              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`ifdef MEDT_PPB //Non-volatile block lock
module PPBManager();
    `include "include/DevParam.h"
    reg [nSector-1:0] PPBReg;
    reg enable_PPBReg_read;
    integer i;

    initial
        for (i=0; i<=nSector-1; i=i+1)
            PPBReg[i] = 1;

    reg [sectorAddrDim-1:0] sect;
    reg [dataDim-1:0] sectPPBReg;


    // PPB Program
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write PPB Reg")
      // if (!PMReg.PMR[5]) begin
      //     $display("  [%0t ps] **WARNING** PMR bit is set. Write lock register is not allowed!", $time);
      //     disable WRLR;
      //  end else 
      begin : WRPPB
        begin : exe1
            sect = f.sec(N25Qxxx.addr);
//            if(N25Qxxx.protocol=="dual")
//                N25Qxxx.latchingMode = "F";
//            else if(N25Qxxx.protocol=="quad")
//                N25Qxxx.latchingMode = "Q";
//            else
//                N25Qxxx.latchingMode = "D";
//
//            @(N25Qxxx.dataLatched) sectPPBReg = N25Qxxx.data;
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - Write PPB Reg aborted due to Prog/Erase Suspend",$time);
            disable WRPPB;
          end  
            if(`WEL==0) begin
                N25Qxxx.f.WEL_error;
                disable WRPPB;
            end
        end

        begin : exe2
            @(posedge N25Qxxx.S);
            //disable exe1;
            //disable reset;
            prog.operation=N25Qxxx.cmdRecName;
            if (ASP_Reg.ASP[2]==0 && plb.PLB[0]==0) begin
                    $display("  [%0t ns]- **WARNING** Attempting to write to PPB in password protect mode. Issue password unlock first.", $time, sect);
                    disable WRPPB;
            end
            else if (plb.PLB[0]==0) begin
                    $display("  [%0t ns]- **WARNING** PLB register  %h already set!", $time, sect);
                    disable WRPPB;
            end
            else if (PMReg.PMR[1]==0 || ASP_Reg.ASP[2:1]=='b01) begin
                    $display("  [%0t ns]- **WARNING** PMR[1]=0  %h already set!", $time, sect);
                    disable WRPPB;
                end
            //else if (PPBReg[sect]==0) begin
            //        $display("  [%0t ns]- **WARNING** PPB register of sect %h already set!", $time, sect);
            //        disable exe2;
            //end
            else begin
                N25Qxxx.latchingMode="N";
                N25Qxxx.busy=1;
                -> stat.WEL_reset;
                //PPBReg[sect]=sectPPBReg[0];
                $display("  [%0t ns]- Command execution: ppb register of sector %0d set to (%b)", 
                          $time, sect, PPBReg[sect]);
                prog.delay=write_PPB_delay;
                -> prog.errorCheck;

                @(prog.noError) begin
                    PPBReg[sect]=0;
                 $display("  [%0t ns] Command execution completed: Write PPB Register. PPB=%h (%b)",
                             $time, PPBReg, PPBReg);
                     end         
            end    
        end

        //begin : reset
        //    @N25Qxxx.resetEvent;
        //    disable WRPPB;
        //end
        
    end

    // PPB Erase 
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Erase PPB Reg")
      // if (!PMReg.PMR[5]) begin
      //     $display("  [%0t ps] **WARNING** PMR bit is set. Write lock register is not allowed!", $time);
      //     disable WRLR;
      //  end else 
       fork : PPBE 
        begin : exe1e
            sect = f.sec(N25Qxxx.addr);
            if(N25Qxxx.protocol=="dual")
                N25Qxxx.latchingMode = "F";
            else if(N25Qxxx.protocol=="quad")
                N25Qxxx.latchingMode = "Q";
            else
                N25Qxxx.latchingMode = "D";

            @(N25Qxxx.dataLatched) sectPPBReg = N25Qxxx.data;
        end

        begin : exe2e
            @(posedge N25Qxxx.S);
            disable exe1e;
            disable resete;
            if(`WEL==0) begin
                N25Qxxx.f.WEL_error;
                disable PPBE;
            end
          if(prog.prog_susp==1) begin
            $display("  [%0t ns] ***WARNING*** - %s aborted due to Prog/Erase Suspend",$time,N25Qxxx.cmdRecName);
            disable PPBE;
        end if ( ASP_Reg.ASP[2:1] == 'b01 ) begin
            $display("  [%0t ns] ***WARNING*** - %s aborted due to ASP[2:1]== 'b01",$time,N25Qxxx.cmdRecName);
            disable PPBE;
        end if ( PMReg.PMR[1:0] == 'b01 ) begin
            $display("  [%0t ns] ***WARNING*** - %s aborted due to PMR[1:0]== 'b01",$time,N25Qxxx.cmdRecName);
            disable PPBE;
        end
            else begin
            prog.operation=N25Qxxx.cmdRecName;
            N25Qxxx.busy=1;
            -> stat.WEL_reset;
                //PPBReg[sect]=sectPPBReg[0];
                $display("  [%0t ns]- Command execution: erase ppb register", 
                          $time, sect, PPBReg[sect]);
                prog.delay=erase_PPB_delay;
                -> prog.errorCheck;

                @(prog.noError) begin
                for (i=0; i<=nSector-1; i=i+1)
                    PPBReg[i] = 1;
                 $display("  [%0t ns] Command execution completed: Erase PPB Register. PPB=%h (%b)",
                             $time, PPBReg, PPBReg);
                     end         
            end    
        end

        begin : resete
            @N25Qxxx.resetEvent;
            disable exe1e;
            disable exe2e;
        end
        
    join // PPB Erase

    // Read PPB register

    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read PPB Reg") begin : READ_PPBReg
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        
        fork

        begin
          enable_PPBReg_read=1;
        end   
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_PPBReg_read=0;
        
    join
end



//-------------------------------------------
// Function to test sector protection status
//-------------------------------------------
function isProtected_by_PPBReg;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] sectAddr;
begin

      sectAddr = f.sec(byteAddr);
      isProtected_by_PPBReg = PPBReg[sectAddr];
      $display("  [%0t ns] isProtected_by_PPBReg: %h sectAddr: %h", $time,isProtected_by_PPBReg, sectAddr);

end
endfunction

function isAnySectorProtected;
input required;
begin

    i=0;   
    isAnySectorProtected=0;
    while(isAnySectorProtected==0 && i<=nSector-1) begin 
        if(PPBReg[i] == 0) begin
            isAnySectorProtected = 1;
        end
        i=i+1;
    end    

end
endfunction

endmodule

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--    PPB Lock Bit Register                              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module PPBLockBitRegister;

    `include "include/DevParam.h"

    parameter [7:0] PLBReg_default = 'b00000001;
   
    // non volatile configuration register

    reg [7:0] PLB;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        PLB[7:0] = PLBReg_default;

    end


    //------------------------------------------
    // write
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read 
    //-----------------------------------------

    reg enable_PLBReg_read = 0;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read PPB Lock Bit") begin : READ_PLB
        
        `ifdef MEDITERANEO
            if(N25Qxxx.DoubleTransferRate == 1) begin
                @(posedge N25Qxxx.C);
                @(negedge N25Qxxx.C);
            end
        `endif
        fork 
        
        enable_PLBReg_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_PLBReg_read=0;
        
    join    
end

 endmodule    
`endif //MEDT_PPB
 
`ifdef MEDT_ADVANCED_SECTOR
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   ASP REGISTER MODULE                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ps

module ASPRegister();

    `include "include/DevParam.h"

    reg [15:0] ASP = 'hFFFF;

     
    //--------------
    // Init
    //--------------

    initial begin
        #1;
        ASP[15:0] = 'hFFFF;
        
    end


    //------------------------------------------
    // write ASP Register
    //------------------------------------------

    // see "Program" module


    //-----------------------------------------
    // Read ASP register
    //-----------------------------------------
    // NB : "Read Non Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_ASP_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="ASP Read") 
    begin 
        `ifdef MEDITERANEO
        if(N25Qxxx.DoubleTransferRate == 1) begin   
            @(posedge N25Qxxx.C);
            @(negedge N25Qxxx.C);
        end
        `endif
        fork 
        
        enable_ASP_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_ASP_read=0;
        
        join    
    end
endmodule // MEDT_ADVANCED_SECTOR   
`endif

`ifdef MT25T_H
`include "include/MT25TOP.v" 
`endif //MT25T
`ifdef MT25T_B
`include "include/MT25TOP.v" 
`endif //MT25T

module DebugModule ();
    `include "include/DevParam.h"

event x0;
event x1;
event x2;
event x3;
event x4;
event x5;
event x6;
event x7;
event x8;
event x9;
event x10;
event x11;
event x12;
reg [addrDim-1:0] Addr0;
reg [addrDim-1:0] Addr1;
event debugSR;
reg [391:0] gprr;    
reg [7:0] gprr_esr;
reg [95:0] gprr_tag;
reg [31:0] gprr_counter;
reg [255:0] gprr_signature;
event gprr_event;

 initial
     gprr = 'b0;


endmodule
