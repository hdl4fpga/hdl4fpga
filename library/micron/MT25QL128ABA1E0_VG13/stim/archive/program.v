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

    // transactions handles


    reg [addrDim-1:0] A1='h01FFFC, //Near the end of the page.
                      A2='h01FF00, //At the beggining of same page. 
                      B1='h003300;
    integer i;


    initial begin

        tasks.init;

        //---------------
        // page program
        //---------------

        // write lock register (to unlock sector to be programmed)
        $display("\n --- Write lock register (unlock)");
        tasks.write_enable;
        tasks.send_command('hE5);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('h00);
        tasks.close_comm;
        #100;

        // page program 
        $display("\n --- Page program ok");
        tasks.write_enable;
        tasks.send_command('h02);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        $display("\n --- Read");
        // read 1
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(5);
        tasks.close_comm;
        // read 2
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A2);
        `else
        tasks.send_address(A2);
        `endif
        tasks.read(5);
        tasks.close_comm;


        //---------------
        // dual program
        //---------------
        
        // write lock register (to unlock sector to be programmed)
        $display("\n --- Write lock register");
        tasks.write_enable;
        tasks.send_command('hE5);
        `ifdef byte_4
        tasks.send_3byte_address(B1);
        `else
        tasks.send_address(B1);
        `endif
        tasks.send_data('h00);
        tasks.close_comm;
        #100;

        // dual program
        $display("\n --- Dual program");
        tasks.write_enable;
        tasks.send_command('hA2);
        `ifdef byte_4
        tasks.send_3byte_address(B1);
        `else
        tasks.send_address(B1);
        `endif
        for (i=1; i<=5; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(B1);
        `else
        tasks.send_address(B1);
        `endif
        tasks.read(9);
        tasks.close_comm;

        //-----------------------
        // dual extended program
        //-----------------------
        // dual extended program
        $display("\n --- Dual extended program");
        tasks.write_enable;
        tasks.send_command('hD2);
        `ifdef byte_4
        tasks.send_3byte_address_dual(B1);
        `else
        tasks.send_address_dual(B1);
        `endif
        for (i=1; i<=5; i=i+1)
            tasks.send_data_dual('hD1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(B1);
        `else
        tasks.send_address(B1);
        `endif
        tasks.read(9);
        tasks.close_comm;

        
        //---------------
        // quad program
        //---------------
        
        // quad program
        $display("\n --- Quad program");
        tasks.write_enable;
        tasks.send_command('h32);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        for (i=1; i<=3; i=i+1)
            tasks.send_data_quad('hF1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
         tasks.send_command('h32);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.read(9);
        tasks.close_comm;
        
        //---------------
        // quad extended program
        //---------------
        
        // quad extended program
        $display("\n --- Quad extended program");
        tasks.write_enable;
        tasks.send_command('h12);
        `ifdef byte_4
        tasks.send_3byte_address_quad(A1);
        `else
        tasks.send_address_quad(A1);
        `endif
        for (i=1; i<=5; i=i+1)
            tasks.send_data_quad('hF1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
       `else
        tasks.send_address(A1);
        `endif
        tasks.read(9);
        tasks.close_comm;


 
    end


endmodule    
