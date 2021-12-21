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

`ifdef byte_4

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
   
    // `ifdef N25Q256A31E
    //     defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
    // `endif
    // `ifdef N25Q256A33E
    //     defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
    // `endif
    //  `ifdef N25Q032A13E
    //     defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
    // `endif
    // `ifdef N25Q256A11E
    //     defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
    // `endif

    // transactions handles
    integer trans, fiber;
    
     reg [15:0] regData='b1111111111111111;

     reg[7:0] extAddRegData;

    reg [addrDim-1:0] A0='h0, A1, A2='h08;


    initial begin
        
        if((devName=="N25Q256A31E") || (devName=="N25Q256A33E")) begin
            A1='h0FFFFFA;
        end else begin
             A1='h3FFFFA;
        end  


        fiber = $sdi_create_fiber("Test fiber");
        
        tasks.init;

        //----------------
        //  Standard read
        //----------------
        $display("\n ----- Read.");

        // read from memory file
        trans = $sdi_transaction("BeginEnd", fiber, "Read 1");
        tasks.send_command('h03);
        tasks.send_3byte_address(A0);
        tasks.read(4);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

        // read from memory file
        trans = $sdi_transaction("BeginEnd", fiber, "Read 2");
        tasks.send_command('h03);
        tasks.send_3byte_address(A1);
        tasks.read(8);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;


        
    // write non volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        trans = $sdi_transaction("BeginEnd",fiber,"Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regData[6:2] = 'b01001; 
        regData[0] = 'b0;
        tasks.send_data(regData[7:0]);
        tasks.send_data(regData[15:8]);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #(write_NVCR_delay+100);  


        $display("\n--- Power up");

        tasks.setVcc('d0);
        #100;
        `ifdef VCC_3V
        tasks.setVcc('d3000);
        `else
        tasks.setVcc('d1800);
        `endif
        #full_access_power_up_delay;
        
         // read non volatile configuration register 
         $display("\n--- Read non volatile configuration register");

        trans = $sdi_transaction("BeginEnd",fiber,"Read non volatile configuration register");
        tasks.send_command_quad('hB5);
        tasks.read_quad(2); 
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;


            // Quad I/O Fast read  
        $display("\n---Testing Quad I/O Fast read");
        $display("\n---EB");
        trans = $sdi_transaction("BeginEnd",fiber,"Quad I/O Fast read");
        tasks.send_command_quad('hEB);
        tasks.send_4byte_address_quad(A1);
        tasks.send_dummy_quad('h200,15); //dummy byte
        tasks.read_quad(8);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

     // Quad I/O Fast read  
        $display("\n---Testing Quad I/O Fast read");
        $display("\n---EB");
        trans = $sdi_transaction("BeginEnd",fiber,"Quad I/O Fast read");
        tasks.send_command_quad('hEB);
        tasks.send_4byte_address_quad(A0);
        tasks.send_dummy_quad('h200,15); //dummy byte
        tasks.read_quad(8);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;


           // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        trans = $sdi_transaction("BeginEnd",fiber,"Write volatile enhanced configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h61);
        regData[6:2] = 'b00011; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #(write_VECR_delay+100);  

         // read volatile enhanced configuration register 
         $display("\n--- Read volatile enhanced configuration register");

        trans = $sdi_transaction("BeginEnd",fiber,"Read volatile enhanced configuration register");
        tasks.send_command_dual('h65);
        tasks.read_dual(2); 
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

          // Dual read  
        $display("\n---Testing dual command fast read");
        $display("\n---0B");
        trans = $sdi_transaction("BeginEnd",fiber,"Dual Read");
        tasks.send_command_dual('h0B);
        tasks.send_4byte_address_dual(A1);
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(8);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---3B");
        trans = $sdi_transaction("BeginEnd",fiber,"Dual Read");
        tasks.send_command_dual('h3B);
        tasks.send_4byte_address_dual(A0);
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---BB");
        trans = $sdi_transaction("BeginEnd",fiber,"Dual Read");
        tasks.send_command_dual('hBB);
        tasks.send_4byte_address_dual(A2);
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

        
          // Exit 4 byte address  
        $display("\n--- Exit 4 byte address");
        trans = $sdi_transaction("BeginEnd",fiber,"Exit 4 byte address");
        tasks.write_enable_dual;
        tasks.send_command_dual('hE9);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #(exit4_address_delay+100);  


        $display("\n---Testing dual command fast read");
        $display("\n---BB");
        trans = $sdi_transaction("BeginEnd",fiber,"Dual Read");
        tasks.send_command_dual('hBB);
        tasks.send_3byte_address_dual(A2);
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;


           // write extended address register 
        $display("\n--- Write extended address register");
        trans = $sdi_transaction("BeginEnd",fiber," Write extended address register");
        tasks.write_enable_dual;
        tasks.send_command_dual('hC5);
        extAddRegData[7:0] = 'h1; 
        tasks.send_data_dual(extAddRegData[7:0]);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #(write_EAR_delay+100);  


          // read extended address register 
         $display("\n--- Read extended address register");  
        trans = $sdi_transaction("BeginEnd",fiber,"Read extended address register");
        tasks.send_command_dual('hC8);
        tasks.read_dual(2); 
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;

         $display("\n---Testing dual command fast read");
        $display("\n---BB");
        trans = $sdi_transaction("BeginEnd",fiber,"Dual Read");
        tasks.send_command_dual('hBB);
        tasks.send_3byte_address_dual(A2);
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        $sdi_end_transaction(trans);
        #100;


        
    end

`endif
endmodule    
