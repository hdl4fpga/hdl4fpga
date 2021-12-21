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

    initial begin
        
        $display("\n SIMNAME: erase_.v \n");

        tasks.init;
        
        eraseArray("pass0");

        tasks.write_nonarray(`CMD_WRVECR,'hFF,'hBF, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);
            
        eraseArray("pass1");

        tasks.write_nonarray(`CMD_WRVECR,'hFF,'h7F, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);
            
        eraseArray("pass2");

        tasks.wrapUp;
    end

task eraseArray;
    input [40*dataDim-1:0] cycle;
    begin
        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.erase_array(`CMD_SSE32K, `DIE0_SECTOR_00_B,`ON);

        tasks.fillExpVal(40'hFF_FFFF_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);
        
        tasks.reInitialize_memory();

        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.erase_array(`CMD_SSE, `DIE0_SECTOR_00_B,`ON);

        tasks.fillExpVal(40'hFF_FFFF_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.reInitialize_memory();

        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.erase_array(`CMD_SE, `DIE0_SECTOR_00_B,`ON);

        tasks.fillExpVal(40'hFF_FFFF_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.reInitialize_memory();

        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

//        tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
//
//        tasks.fillExpVal(40'hFF_FFFF_FFFF);
//        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
//        tasks.fillExpVal(40'hFF_FFFF_FFFF);
//        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.reInitialize_memory();

        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.erase_array(`CMD_SE4BYTE, `DIE0_SECTOR_00_B,`ON);

        tasks.fillExpVal(40'hFF_FFFF_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.reInitialize_memory();

        tasks.fillExpVal(40'hFF_FFFF_0100);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.erase_array(`CMD_SSE4BYTE, `DIE0_SECTOR_00_B,`ON);

        tasks.fillExpVal(40'hFF_FFFF_FFFF);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
        tasks.fillExpVal(40'hFF_BBAA_0000);
        tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

        tasks.reInitialize_memory();
    end
endtask //eraseArray

endmodule    
