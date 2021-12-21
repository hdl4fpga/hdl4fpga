//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  MT25QL512ABA1E0 
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


`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file
    
    // defparam Testbench.DUT.memory_file = "";



    reg [addrDim-1:0] A1='h01ABCD1; 
    


    initial begin

        tasks.init;

        //--------------------------------------------------------
        // Testing locking features controlled by lock registers 
        //--------------------------------------------------------

        $display("\n\n-----Testing lock register features.\n");

        // read lock register
        tasks.send_command('hE8);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(2);
        tasks.close_comm;
        #100;

         // page program ok
        tasks.write_enable;
        tasks.send_command('h02);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h1A);
        tasks.send_data('h2B);
        tasks.close_comm;
        #(program_delay+100);

        // read 1
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(3);
        tasks.close_comm;
        
        // write lock register (to lock sector to be programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h01);
        tasks.close_comm;
        #100;

        // read lock register
        tasks.send_command('hE8);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(1);
        tasks.close_comm;
        #100;
        
         // page program (error)
        $display("\n Page Program (error)");
        tasks.write_enable;
        tasks.send_command('h02);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h1A);
        tasks.send_data('h2B);
        tasks.close_comm;
        #100;

        // read 1
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(3);
        tasks.close_comm;
        

        
        // write lock register (lock down sector programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h02);
        tasks.close_comm;
        #100;

        // write lock register (error because sector is locked down)
        tasks.write_enable;
        tasks.send_command('hE5);
         `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h03);
        tasks.close_comm;
        #100;

    
    end


endmodule    
