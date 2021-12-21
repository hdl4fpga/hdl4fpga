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


`timescale 1ns / 1ps

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 

    `ifdef  N25Q256A33E
      `define FILENAME_mem "mem_Q256.vmf"
    `elsif  N25Q256A13E
      `define FILENAME_mem "mem_Q256.vmf"
    `elsif  N25Q256A31E
      `define FILENAME_mem "mem_Q256.vmf"
    `elsif  N25Q256A11E
      `define FILENAME_mem "mem_Q256.vmf"
    `elsif  N25Q032A13E
      `define FILENAME_mem "mem_Q032.vmf"
    `elsif  N25Q032A11E
      `define FILENAME_mem "mem_Q032.vmf"
    `else  
      `define FILENAME_mem "mem_Q256.vmf"
    `endif

    // `ifdef  N25Q256A33E
    //   defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
    // `elsif  N25Q512A13E
    //   defparam Testbench.DUT.f.memory_file = "mem_Q256.vmf";
    // `elsif  N25Q256A31E
    //   defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
    //  `elsif  N25Q032A13E
    //   defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
    //  `elsif  N25Q032A11E
    //   defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
    // `else
    //   defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
    // `endif




    reg [addrDim-1:0] A0='h0, A1, A2='h08;


    initial begin
        
        if((devName=="N25Q256A33E") || (devName=="N25Q256A31E")) begin
            A1='hFFFFFA;
        end else begin
             A1='h3FFFFA;
        end


        tasks.init;

        //----------------
        //  Standard read
        //----------------
        $display("\n ----- Read.");

        $display("\n--- Set EAR to topmost segment");
        tasks.write_enable;
        tasks.send_command('hC5);
        tasks.send_data(8'h03);
        tasks.close_comm;

        $display("\n--- Enter 4 byte address");
        tasks.write_enable;
        tasks.send_command('hB7);
        tasks.close_comm;

	tasks.addr_4byte_select(1); // on



        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address('hA0);
        `else
        tasks.send_address('hA0);  
        `endif

        tasks.read(4);
        tasks.close_comm;
        #100;

        // read from memory file
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address('hA1);
        `else
        tasks.send_address('hA1);  
         `endif
        tasks.read(8);
        tasks.close_comm;
        #100;

            //----------------
            //  Fast read DTR
            //----------------
            tasks.dtr_mode_select(0); // off
            tasks.send_command('h0D);

            #(tasks.T/2); // need to synchronise STR task  clk with DTR task clk

            tasks.dtr_mode_select(1);
            tasks.send_3byte_address('hA1);
            tasks.send_dummy('hF0,15); //dummy byte
            $display("\n ----- Fast Read data");
            tasks.read(4);
            tasks.close_comm;

            #100;

            //----------------
            //  Dual read DTR
            //----------------
            
            $display("\n ----- Dual Read and address in DTR mode");
            tasks.dtr_mode_select(0); // off
            tasks.send_command('h3D);
            #(tasks.T/2);
            tasks.dtr_mode_select(1);
            tasks.send_3byte_address('hA1); 
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(3);   
            tasks.close_comm;
            #100;

        
           //-----------------------------
            //  Dual i/o read DTR
            //----------------------------
            $display("\n ----- Dual I/O Fast Read in DTR.");
         
            tasks.dtr_mode_select(0); // off
            // dual read from memory file
            tasks.send_command('hBD);
            tasks.dtr_mode_select(1);
            `ifdef byte_4
            tasks.send_3byte_address_dual('hA2);
            `else
            tasks.send_address_dual('hA2);  
             `endif
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(3);
            tasks.close_comm;
            #500;

            //----------------
            // Quad read DTR
            //----------------
            tasks.dtr_mode_select(0); // off
            tasks.send_command('h6D);
            #(tasks.T/2); // need to synchronise STR task  clk with DTR task clk
            $display("\n ----- Quad Fast Read and address in DTR mode");
            tasks.dtr_mode_select(1);
            tasks.send_3byte_address('hA2);
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_quad(4);
            tasks.close_comm;
            #100;


            //----------------
            //   Quad I/O read DTR
            //----------------
            tasks.dtr_mode_select(0); // off
            tasks.send_command('hED);
            #(tasks.T/2); // need to synchronise STR task  clk with DTR task clk
            $display("\n -----  Quad I/O read read and address in DTR mode");
            tasks.dtr_mode_select(1);
            tasks.send_3byte_address_quad('hA1);
            tasks.send_dummy('h200,15); //dummy byte
            tasks.read_quad(8);
            tasks.close_comm;

            #(tasks.T/2);

            tasks.dtr_mode_select(0); // off

            //----------------
            //  Fast read
            //----------------
            $display("\n ----- Fast Read.");
            
            // fast read from memory file
            tasks.send_command('h0B);
            `ifdef byte_4
            tasks.send_3byte_address('hA0);
            `else
            tasks.send_address('hA0);  
            `endif
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read(4);
            tasks.close_comm;
            #100;


            //----------------
            //   Dual I/O read
            //----------------
            $display("\n ----- Dual I/O read");
            
            //  Dual I/O read from memory file
            tasks.send_command('hBB);
            `ifdef byte_4
            tasks.send_3byte_address_dual('hA1);
            `else
             tasks.send_address_dual('hA1);
            `endif
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(8);
            tasks.close_comm;
            #100;


            //----------------
            // Quad read
            //----------------
            $display("\n ----- Quad Fast Read.");
            
            // fast read from memory file
            tasks.send_command('h6B);
            `ifdef byte_4
            tasks.send_3byte_address('hA2);
            `else
         tasks.send_address('hA2);  
             `endif
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_quad(4);
            tasks.close_comm;
            #100;

            //----------------
            //   Quad I/O read
            //----------------
            $display("\n -----  Quad I/O read");
            
            //  Quad I/O read from memory file
            tasks.send_command('hEB);
            `ifdef byte_4
            tasks.send_3byte_address_quad('hA1);
            `else
             tasks.send_address_quad('hA1);
            `endif
            tasks.send_dummy('h200,15); //dummy byte
            tasks.read_quad(8);
            tasks.close_comm;
            #100;

        //----------------
        //  Read ID
        //----------------
        $display("\n ----- Read ID.");
        
        // read ID
        tasks.send_command('h9F);
        tasks.read(24);
        tasks.close_comm;
        #100;
        



end

endmodule    
