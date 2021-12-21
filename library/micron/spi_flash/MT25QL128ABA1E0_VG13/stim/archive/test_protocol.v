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

    // defparam Testbench.DUT.memory_file = "";

    reg [15:0] regData='b1111111111111111;

    reg [addrDim-1:0] A0='h0, A1, A2='h08,B1='h003300;

    integer i;

    initial begin

        if ((devName=="N25Q256A33E") ||(devName=="N25Q256A31E")||(devName=="N25Q256A13E")||(devName=="N25Q256A11E"))
            A1='hFFFFFA;
        else if ((devName=="N25Q032A13E") ||(devName=="N25Q032A11E"))
            A1='h3FFFFA;


        tasks.init;
        

        // dual program
        $display("\n --- Dual program");
        tasks.write_enable;
        tasks.send_command('hA2);
        `ifdef byte_4
        tasks.send_3byte_address(B1);
        `else
        tasks.send_address(B1);
        `endif
        for (i=1; i<=8; i=i+1)
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


       
         // write volatile configuration register 
        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        tasks.send_command('h81);
        regData[6:2] = 'b01011; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(2); 
        tasks.close_comm;
        #100;


           // write non volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regData[6:2] = 'b01001; 
        tasks.send_data(regData[7:0]);
        tasks.send_data(regData[15:8]);
        tasks.close_comm;
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
 
        tasks.send_command_quad('hB5);
        tasks.read_quad(2); 
        tasks.close_comm;
        #100;

          // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h61);
        regData[6:2] = 'b00011; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read volatile enhanced configuration register 
        $display("\n--- Read volatile  enhanced configuration register");
 
        tasks.send_command_dual('h65);
        tasks.read_dual(2); 
        tasks.close_comm;
        #100;
        
          // Dual read  
        $display("\n---Testing dual command fast read");
        $display("\n---0B");
        tasks.send_command_dual('h0B);
        `ifdef byte_4
        tasks.send_3byte_address_dual(A1);
        `else
        tasks.send_address_dual(A1);
        `endif
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(8);
        tasks.close_comm;
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---3B");
        tasks.send_command_dual('h3B);
        `ifdef byte_4
        tasks.send_3byte_address_dual(A0);
        `else
        tasks.send_address_dual(A0);
        `endif
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---BB");
        tasks.send_command_dual('hBB);
        `ifdef byte_4
        tasks.send_3byte_address_dual(A2);
        `else
        tasks.send_address_dual(A2);
        `endif
        tasks.send_dummy_dual('h80,15); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        #100;

         $display("\n --- Dual command Page program");
        tasks.write_enable_dual;
        tasks.send_command_dual('hA2);
        `ifdef byte_4
        tasks.send_3byte_address_dual(B1);
        `else
        tasks.send_address_dual(B1);
        `endif

        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command_dual('h0B);
        `ifdef byte_4
        tasks.send_3byte_address_dual(B1);
        `else
        tasks.send_address_dual(B1);
        `endif

        tasks.send_dummy_dual('h00,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;



    end  


    endmodule
