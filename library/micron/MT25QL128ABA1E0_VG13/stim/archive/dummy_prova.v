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
 
//    `ifdef  N25Q256A33E
//       defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
//     `endif
//      `ifdef  N25Q256A31E
//       defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
//     `endif
//     
//  
//      `ifdef  N25Q032A13E 
//       defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
//     `endif
//      `ifdef  N25Q032A11E 
//       defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
//     `endif


    reg [15:0] regData='b1111111111111111;


    reg [addrDim-1:0] A0='h0, A1, A2='h08;


    initial begin
        
        if((devName=="N25Q256A33E") || (devName=="N25Q256A31E")) begin
            A1='hFFFFFA;
        end else begin
             A1='h3FFFFA;
        end  
 
        tasks.init;

































        
            //----------------
            //  Dual read
            //----------------
            $display("\n ----- Dual Read.");

            // dual read from memory file
            tasks.send_command('h3B);
             `ifdef byte_4
            tasks.send_3byte_address(A2);
            `else
            tasks.send_address(A2);
            `endif
            tasks.send_dummy('hF0,15); //dummy byte
            tasks.read_dual(3);
            tasks.close_comm;
            #100;

            //----------------
            //  Fast read
            //----------------
            $display("\n ----- Fast Read.");
            
            // fast read from memory file
            tasks.send_command('h0B);
             `ifdef byte_4
            tasks.send_3byte_address(A0);
            `else
            tasks.send_address(A0);
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
            tasks.send_3byte_address_dual(A1);
            `else
            tasks.send_address_dual(A1);
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
            tasks.send_3byte_address(A2);
            `else
            tasks.send_address(A2);
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
            tasks.send_3byte_address_quad(A1);
            `else
            tasks.send_address_quad(A1);
            `endif
            tasks.send_dummy_quad('hZ,15); //dummy byte
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

          // write volatile configuration register 
        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        tasks.send_command('h81);
        regData[7:4] = 'b0100; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(2); 
        tasks.close_comm;
        #100;

        $display("\n ----- Dual I/O read");
            
            //  Dual I/O read from memory file
            tasks.send_command('hBB);
             `ifdef byte_4
            tasks.send_3byte_address_dual(A1);
            `else
            tasks.send_address_dual(A1);
            `endif
            tasks.send_dummy('hF0,4); //dummy byte
            tasks.read_dual(8);
            tasks.close_comm;
            #100;

            
            //----------------
            //   Quad I/O read
            //----------------
            $display("\n -----  Quad I/O read");
            
            //  Quad I/O read from memory file
            tasks.send_command('hEB);
             `ifdef byte_4
            tasks.send_3byte_address_quad(A1);
            `else
            tasks.send_address_quad(A1);
            `endif
            tasks.send_dummy('h200,4); //dummy byte
            tasks.read_quad(8);
            tasks.close_comm;
            #100;


             // write non volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regData[15:12] = 'b0001; 
        tasks.send_data(regData[7:0]);
        tasks.send_data(regData[15:8]);
        tasks.close_comm;
        #(write_NVCR_delay+100);  


        $display("\n--- Power up");

        tasks.setVcc('d0);
        #100;
        tasks.setVcc('d3000);
        #full_access_power_up_delay;
         // read non volatile configuration register 
         $display("\n--- Read non volatile configuration register");

        tasks.send_command('hB5);
        tasks.read(2); 
        tasks.close_comm;
        #100;

          //----------------
          //  Dual read
          //----------------
            $display("\n ----- Dual Read.");

            // dual read from memory file
            tasks.send_command('h3B);
             `ifdef byte_4
            tasks.send_3byte_address(A2);
            `else
            tasks.send_address(A2);
            `endif
            tasks.send_dummy('hF0,1); //dummy byte
            tasks.read_dual(3);
            tasks.close_comm;
            #100;


    end


endmodule    
