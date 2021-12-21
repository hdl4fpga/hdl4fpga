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
// This testcase cycles through the different non array read/write commands.
// The nonarray_reads task does all the major work.  It is called three times
// through pass0, pass1, and lastly pass2. 
// Pass0 - SIO
// pass1 - DIO
// pass2 - QIO
// This test will serve as part of the regression suite to be used during edits and debug.
//----------------------------------------------------------------------------------------

reg [8*dataDim-1:0] pass;

    initial begin
        
        $display("\n SIMNAME: read_nonarray_.v \n");

        tasks.init;
        nonarray_reads("pass0");

        tasks.write_nonarray(`CMD_WRVECR,'hFF,'hBF, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);

        nonarray_reads("pass1");

        tasks.write_nonarray(`CMD_WRVECR,'hFF,'h7F, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);

        nonarray_reads("pass2");
        
        tasks.wrapUp;
    end

task nonarray_reads;
    input [40*dataDim-1:0] cycle;
    begin
        tasks.fillExpVal(64'h9876_0040_1018_BA20);
        tasks.read_nonarray(`CMD_RDID2,5);
        tasks.read_nonarray(`CMD_MIORDID1,8);

        tasks.fillExpVal(160'h10FE_DCBA_9876_5432_1FFE_DCBA_9876_0040_1018_BA20);
        tasks.read_nonarray(`CMD_MIORDID2,20);
        tasks.read_nonarray(`CMD_MIORDID2,31);

        tasks.fillExpVal(896'h363DBD81FF820F4A5BD5BDFB757A757A2C25816CE1038E8B00994A240000520FD810200CEB29FFFFBB27FFFFFFFFFFFFBB273B276B27EB2907FFFFFFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF02010003FF00003010010500FF01010550444653);
        tasks.read_nonarray(`CMD_RDSFDP,112);

        tasks.fillExpVal(24'h00_0000);
        tasks.read_nonarray(`CMD_RDSR,3);

        tasks.write_enable_i;

        tasks.fillExpVal(24'h02_0202);
        tasks.read_nonarray(`CMD_RDSR,3);

        tasks.write_disable_i;

        tasks.fillExpVal(24'h00_0000);
        tasks.read_nonarray(`CMD_RDSR,3);

        tasks.fillExpVal(24'h80_8080);
        tasks.read_nonarray(`CMD_RDFSR,3);

        tasks.fillExpVal(16'hFFFF);
        tasks.read_nonarray(`CMD_RDNVCR,2);
        tasks.fillExpVal(8'hFB);
        tasks.read_nonarray(`CMD_RDVCR,1);
        case(cycle)
            "pass0": tasks.fillExpVal(8'hFF);
            "pass1": tasks.fillExpVal(8'hBF);
            "pass2": tasks.fillExpVal(8'h7F);
        endcase
        tasks.read_nonarray(`CMD_RDVECR,1);

        tasks.write_nonarray(`CMD_WRSR, 'h00, 'hF0, `ON);
        tasks.read_nonarray(`CMD_RDSR,1);

        tasks.write_nonarray(`CMD_WRSR, 'h00, 'h00, `ON);
        if(cycle=="pass2") begin
            tasks.fillExpVal(8'hF2);
        end
        tasks.read_nonarray(`CMD_RDSR,1);

        tasks.fillExpVal(8'h80);
        tasks.read_nonarray(`CMD_RDFSR,1);
        tasks.write_nonarray(`CMD_CLRFSR,'h00,'h00, `ON);
        tasks.fillExpVal(8'h80);
        tasks.read_nonarray(`CMD_RDFSR,1);

        tasks.write_nonarray(`CMD_WRNVCR,'hAA,'h55, `ON);
        tasks.fillExpVal(16'hAA57);
        tasks.read_nonarray(`CMD_RDNVCR,2);

        tasks.write_nonarray(`CMD_WRVCR,'hAA,'hAA, `ON);
        tasks.read_nonarray(`CMD_RDVCR,1);

        tasks.write_nonarray(`CMD_WRVECR,'h55,'h55, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);

        tasks.write_nonarray(`CMD_WRVECR,'hFF,'hFF, `ON);
        tasks.read_nonarray(`CMD_RDVECR,1);
        
        case(cycle)
            "pass0": tasks.fillExpVal({66{8'hFF}});
            "pass1": tasks.fillExpVal({66{8'h55}});
            "pass2": tasks.fillExpVal({66{8'h55}});
        endcase    
        tasks.otp_ops(`CMD_ROTP,`_,65,`_,`_,`_);
        tasks.write_enable_i;
        tasks.otp_ops(`CMD_POTP,`_,65,'h55,"1b",`ON);
        tasks.fillExpVal({66{8'h55}});
        tasks.otp_ops(`CMD_ROTP,`_,65,`_,`_,`_);

        tasks.write_nonarray(`CMD_EQIO,`_,`_, `ON);

        tasks.otp_ops(`CMD_ROTP,`_,65,`_,`_,`_);

        tasks.write_nonarray(`CMD_RSTQIO,`_,`_, `ON);

        tasks.otp_ops(`CMD_ROTP,`_,65,`_,`_,`_);

//        tasks.fillExpVal(8'hzz);
//        tasks.read_nonarray(`CMD_RDEAR,1);
//        tasks.write_nonarray(`CMD_WREAR,`_,'hAA, `ON);
//        tasks.fillExpVal(8'hzz);
//        tasks.read_nonarray(`CMD_RDEAR,1);
//        tasks.write_nonarray(`CMD_WREAR,`_,'h00, `ON);
//        tasks.fillExpVal(8'hzz);
//        tasks.read_nonarray(`CMD_RDEAR,1);
                
        tasks.fillExpVal({2{8'h00}});
        tasks.asp_ops(`CMD_RDVLB,`DIE0_SECTOR_08_L,2,`_,`_,`_);
        tasks.write_enable_i;
        tasks.asp_ops(`CMD_WRVLB,`DIE0_SECTOR_08_L,0,'hFF55,"1b",`ON);
        tasks.fillExpVal({2{8'h01}});
        tasks.asp_ops(`CMD_RDVLB,`DIE0_SECTOR_08_L,2,`_,`_,`_);

//        tasks.fillExpVal({2{8'hzz}});
//        tasks.asp_ops(`CMD_RDVLB4BYTE,`DIE0_SECTOR_00_B,2,`_,`_,`_);
//        tasks.write_enable_i;
//        tasks.asp_ops(`CMD_WRVLB4BYTE,`DIE0_SECTOR_00_B,0,'hFF55,"1b",`ON);
//        tasks.fillExpVal({2{8'hzz}});
//        tasks.asp_ops(`CMD_RDVLB4BYTE,`DIE0_SECTOR_00_B,2,`_,`_,`_);

        tasks.fillExpVal({2{8'hFF}});
        tasks.asp_ops(`CMD_RDNVLB,`DIE0_SECTOR_08_L,2,`_,`_,`_);
        tasks.write_enable_i;
        tasks.asp_ops(`CMD_WRNVLB,`DIE0_SECTOR_08_L,0,'hFF55,"2b",`ON);
        case(cycle)
            "pass0": tasks.fillExpVal({2{8'h00}});
            "pass1": tasks.fillExpVal({2{8'hFF}});
            "pass2": tasks.fillExpVal({2{8'hFF}});
        endcase
        tasks.asp_ops(`CMD_RDNVLB,`DIE0_SECTOR_08_L,2,`_,`_,`_);

        tasks.write_enable_i;
        tasks.asp_ops(`CMD_ERNVLB,`DIE0_SECTOR_08_L,0,'hFF55,"1b",`ON);

        tasks.fillExpVal({2{8'hFF}});
        tasks.asp_ops(`CMD_RDNVLB,`DIE0_SECTOR_08_L,2,`_,`_,`_);

        tasks.fillExpVal({2{8'h01}});
        tasks.asp_ops(`CMD_RDGFB,`DIE0_SECTOR_08_L,1,`_,`_,`_);
        tasks.write_enable_i;
        tasks.asp_ops(`CMD_WRGFB,`DIE0_SECTOR_00_B,0,'hFF00,"1b",`ON);
        tasks.asp_ops(`CMD_RDGFB,`DIE0_SECTOR_08_L,1,`_,`_,`_);

        case(cycle)
            "pass0": tasks.fillExpVal({8{8'hFF}});
            "pass1": tasks.fillExpVal({8{8'hZZ}});
            "pass2": tasks.fillExpVal({8{8'hZZ}});
        endcase
        tasks.asp_ops(`CMD_PASSRD,`_,8,`_,`_,`_);
        tasks.write_enable_i;
        pass = 64'hAA55DD11EE3344CC; 
        tasks.asp_ops(`CMD_PASSP,`_,0,pass,"8b",`ON);
        if(cycle=="pass1" || cycle=="pass2") begin
            tasks.fillExpVal({8{8'hZZ}});
        end
        tasks.asp_ops(`CMD_PASSRD,`_,8,`_,`_,`_);

        case(cycle)
            "pass0": tasks.fillExpVal({2{8'hFF}});
            "pass1": tasks.fillExpVal(16'hFFF2);
            "pass2": tasks.fillExpVal(16'hFFF2);
        endcase
        tasks.asp_ops(`CMD_ASPRD,`_,2,`_,`_,`_);
        tasks.write_enable_i;
        tasks.asp_ops(`CMD_ASPP,`_,0,'hFFF2,"2b",`ON);
        tasks.fillExpVal(16'hFFF2);
        tasks.asp_ops(`CMD_ASPRD,`_,2,`_,`_,`_);

        tasks.asp_ops(`CMD_PASSU,`_,0,pass+1,"8b",`ON);
        tasks.asp_ops(`CMD_PASSU,`_,0,pass,"8b",`ON);

        tasks.write_nonarray(`CMD_WRNVCR,'hFF,'hFF, `ON);
        tasks.read_nonarray(`CMD_RDNVCR,2);

        tasks.write_nonarray(`CMD_RSTEN,`_,`_, `ON);
        tasks.write_nonarray(`CMD_RST,`_,`_, `ON);

    end
endtask //nonarray_reads

endmodule    
