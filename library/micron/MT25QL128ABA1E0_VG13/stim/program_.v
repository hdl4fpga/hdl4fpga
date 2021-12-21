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

    initial 
        begin
        
            $display("\n SIMNAME: program_.v \n");

            tasks.init;

            progArray("pass0");

            tasks.write_nonarray(`CMD_WRVECR,'hFF,'hBF, `ON);
            tasks.read_nonarray(`CMD_RDVECR,1);
            
            progArray("pass1");

            tasks.write_nonarray(`CMD_WRVECR,'hFF,'h7F, `ON);
            tasks.read_nonarray(`CMD_RDVECR,1);
            
            progArray("pass2");
            
            tasks.wrapUp;

        end

task progArray;
    input [40*dataDim-1:0] cycle;
    begin
            if(cycle=="pass1")
                tasks.fillExpVal(40'h04_0302_0100);
            else if (cycle=="pass2")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'hFF_FFFF_0100);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            if(cycle=="pass1" || cycle=="pass2")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'hFF_BBAA_0000);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);


            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_PP,`DIE0_SECTOR_00_B,5,'h00,"linear",`ON);
            tasks.fillExpVal(40'h0403020100);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_DIFP,`DIE0_SECTOR_00_B,5,'h09,"linear",`ON);
            if(cycle=="pass0" || cycle=="pass1")
                begin
                    tasks.fillExpVal(40'h0D0C0B0A09);
                    tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
                    tasks.fillExpVal({5{8'hFF}});
                    tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);
                end

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_DIEFP,`DIE0_SECTOR_00_B,5,'h05,"linear",`ON);
            if(cycle=="pass0" || cycle=="pass1")
                begin
                    tasks.fillExpVal(40'h0908070605);
                    tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
                    tasks.fillExpVal({5{8'hFF}});
                    tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);
                end

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_QIFP,`DIE0_SECTOR_00_B,5,'hAA,"linear",`ON);
            if(cycle=="pass1")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'hAEADACABAA);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_QIEFP,`DIE0_SECTOR_00_B,5,'h55,"toggle",`ON);
            if(cycle=="pass1")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'h55AA55AA55);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_PP4BYTE,`DIE0_SECTOR_00_B,5,'hAA,"toggle",`ON);
            tasks.fillExpVal(40'hAA55AA55AA);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_QIFP4BYTE,`DIE0_SECTOR_00_B,5,'h66,"toggle",`ON);
            if(cycle=="pass1")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'h6699669966);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.erase_array(`CMD_DIEER, `DIE0_SECTOR_00_B,`ON);
            tasks.fillExpVal(40'hFF_FFFF_FFFF);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            tasks.write_enable_i;
            tasks.write_array(`CMD_QIEFP4BYTE,`DIE0_SECTOR_00_B,5,'h00,"linear",`ON);
            if(cycle=="pass1")
                tasks.fillExpVal(40'hFF_FFFF_FFFF);
            else
                tasks.fillExpVal(40'h0403020100);
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_B,5);
            tasks.fillExpVal({5{8'hFF}});
            tasks.read_array_(`CMD_FAST_READ,`DIE0_SECTOR_00_L,5);

            if(cycle=="pass1")
                tasks.fillExpVal('h02);
            else
                tasks.fillExpVal('h00);
            tasks.read_nonarray(`CMD_RDSR,1);
            tasks.fillExpVal('h80);
            tasks.read_nonarray(`CMD_RDFSR,1);
    end
endtask //progArray
endmodule    
