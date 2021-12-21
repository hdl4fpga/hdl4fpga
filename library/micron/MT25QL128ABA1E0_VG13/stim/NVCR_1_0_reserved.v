//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  MT25QL128ABA1E0
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
`timescale 1ns / 1ns
// the port list of current module is contained in "StimGen_interface.h" file
`include "top/StimGen_interface.h"

//----------------------------------------------------------------------------------------
// Description:
// This test will serve as part of the regression suite to be used during edits and debug.
//----------------------------------------------------------------------------------------

reg [8*dataDim-1:0] pass;

    initial begin
        
        $display("\n SIMNAME: read_nonarray_.v \n");

        tasks.init;

        NVCR_ops("pass2");
        
        tasks.wrapUp;
    end

task NVCR_ops;
    input [40*dataDim-1:0] cycle;
    begin

        tasks.fillExpVal(16'hFFFF);
        tasks.read_nonarray(`CMD_RDNVCR,2);
        tasks.write_nonarray(`CMD_WRNVCR,'hAA,'h7C, `ON);
        tasks.fillExpVal(16'hAA7F);
        tasks.read_nonarray(`CMD_RDNVCR,2);

        tasks.Reset_by_Vcc;

        tasks.read_nonarray(`CMD_RDNVCR,2);

        tasks.fillExpVal(896'h363DBD81FF820F4A5BD5BDFB757A757A2C25816CE1038E8B00994A240000520FD810200CEB29FFFFBB27FFFFFFFFFFFFBB273B276B27EB2907FFFFFFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF02010003FF00003010010500FF01010550444653);
        tasks.read_nonarray(`CMD_RDSFDP,112);
    end
endtask //nonarray_reads

endmodule    
