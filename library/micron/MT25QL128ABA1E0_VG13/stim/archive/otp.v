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





    reg [addrDim-1:0] A1='h00, //Beginning of OTP area.
                      A2='h40, //Last column of OTP area (control byte).
                      A3='h7F; //Out of OTP area.  
    integer i;


    initial begin


        tasks.init;

        // program OTP
         $display("\n--- program OTP");
        tasks.write_enable;
        tasks.send_command('h42);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        for (i=1; i<=4; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (out of OTP area)
         $display("\n--- program OTP(out of OTP area)");

        tasks.write_enable;
        tasks.send_command('h42);
        `ifdef byte_4
        tasks.send_3byte_address(A3);
        `else
        tasks.send_address(A3);
        `endif
        tasks.send_data('hFF);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (limit of OTP area)
         $display("\n--- program OTP(limit)");

        tasks.write_enable;
        tasks.send_command('h42);
        `ifdef byte_4
        tasks.send_3byte_address(A2-1);
        `else
        tasks.send_address(A2-1);
        `endif
        for (i=1; i<=4; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #program_delay;
        #100;

        // program OTP (error because of lock bit) 
         $display("\n--- program OTP(error)");
        tasks.write_enable;
        tasks.send_command('h42);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h00);
        tasks.close_comm;
        #100;


        // read OTP
         $display("\n--- Read OTP");
        tasks.send_command('h4B);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(5);
        tasks.close_comm;

        // read OTP (limit of OTP area)
         $display("\n--- Read  limit of OTP");
        tasks.send_command('h4B);
         `ifdef byte_4
        tasks.send_3byte_address(A2-1);
        `else
        tasks.send_address(A2-1);
        `endif
        tasks.read(4);
        tasks.close_comm;
    
    end



endmodule    
