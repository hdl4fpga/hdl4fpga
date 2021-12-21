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

//-----------------------------
// For the N25Qxxx device
//-----------------------------

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


// `ifdef N25Q256A33E
// 
//     defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
// `endif
// 
// `ifdef  N25Q256A31E
//       defparam Testbench.DUT.memory_file = "mem_Q256.vmf";
//     `endif
//     
// 
// `ifdef N25Q032A13E
//     defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
// `endif    
// 
//  `ifdef  N25Q032A11E 
//       defparam Testbench.DUT.memory_file = "mem_Q032.vmf";
//   `endif


    reg [7:0] regData='b111111000;

    reg [15:0] regDataNVCR='b1111111111111111;


    reg [addrDim-1:0] A0='h0, A1, A2='h08,B1='h003300;

    initial begin

        if((devName=="N25Q256A33E") || (devName=="N25Q256A31E")) begin
            A1='hFFFFFA;
        end else
             A1='h3FFFFA;
 


        tasks.init;
        

        $display("\n---Enter XIP mode by setting the VCR");
          // write volatile configuration register 
        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        tasks.send_command('h81);
        regData[3] = 'b0; 
        tasks.send_data(regData);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(2); 
        tasks.close_comm;
        #100;
       

        // read
        $display("\n --- Read");
        tasks.send_command('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address(A0);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;




        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address(A2);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;
         
        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A1);
        `else
        tasks.XIP_send_address(A2);
        `endif

        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;

 
         // read
        $display("\n --- Read XIP not active");
        tasks.send_command('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address(A0);
        `endif
        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;


         $display("\n---Enter XIP mode by setting the NVCR");
          // write volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regDataNVCR[11:9] = 'b000; 
        tasks.send_data(regDataNVCR[7:0]);
        tasks.send_data(regDataNVCR[15:8]);

        tasks.close_comm;
        #(write_NVCR_delay+100);  

         // read non volatile configuration register 
        tasks.send_command('hB5);
        tasks.read(2); 
        tasks.close_comm;
        #100;
        
          $display("\n--- Power up");

        tasks.setVcc('d0);
        #100;
        `ifdef VCC_3V
        tasks.setVcc('d3000);
        `endif
        `ifdef VCC_1e8V
        tasks.setVcc('d1800);
        `endif

        
        #full_access_power_up_delay;
        

        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A2);
        `else
        tasks.XIP_send_address(A2);
        `endif
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;
         
        //read
        $display("\n --- Read XIP active");
        `ifdef byte_4
        tasks.XIP_send_3byte_address(A1);
        `else
        tasks.XIP_send_address(A1);
        `endif

        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;

 
         // read
        $display("\n --- Read XIP not active");
        tasks.send_command('h0B);
        `ifdef byte_4
        tasks.send_3byte_address(A0);
        `else
        tasks.send_address(A0);
        `endif

        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;

    end  


    endmodule
