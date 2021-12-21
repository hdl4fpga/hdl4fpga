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




    reg [addrDim-1:0] A1='h010000; //sector 1
    reg [addrDim-1:0] A2='h040000; //sector 4
    
    reg [dataDim-1:0] regData = 'h0;

    integer i;
    


    initial begin

        
        tasks.init;


        //--------------------------------------------------------
        // Testing locking features controlled by status register
        //--------------------------------------------------------

        // write status register 
        $display("\n--- Write status register");
        tasks.write_enable;
        tasks.send_command('h01);
        regData[6:2] = 'b01011; // (BP3,TB,BP2,BP1,BP0)=(0,1,0,1,1) - lock sector 0 to 3
        tasks.send_data(regData); 
        tasks.close_comm;
        #(write_SR_delay+100);  

        // write lock register sector 1 (disable lock register lock) 
        $display("\n--- Write lock register");

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

        // write lock register sector 4 (disable lock register lock)
        
        tasks.write_enable;
        tasks.send_command('hE5);
        `ifdef byte_4
        tasks.send_3byte_address(A2);
        `else
        tasks.send_address(A2);
        `endif
        tasks.send_data('h00);
        tasks.close_comm;
        #100;

        // page program A1 in sector 1 (error) (lock register lock disabled, but status register lock enabled)
        $display("\n--- Program error");

        tasks.write_enable;
        tasks.send_command('h02);
        `ifdef byte_4
        tasks.send_3byte_address(A1);
        `else
        tasks.send_address(A1);
        `endif
        tasks.send_data('hA1);
        tasks.close_comm;
        #100;

         // read flag status register 
        $display("\n--- Read flag status register"); 
        tasks.send_command('h70);
        tasks.read(2); 
        tasks.close_comm;
        #100;

        
        
        // page program A2 in sector 4 (ok) (lock register lock disabled, status register lock disabled too)
        $display("\n--- Program error because Program status bit is high");
        tasks.write_enable;
        tasks.send_command('h02);
        `ifdef byte_4
        tasks.send_3byte_address(A2);
        `else
        tasks.send_address(A2);
        `endif
        tasks.send_data('hA2);
        tasks.close_comm;
        #(100+program_delay);


         // clear flag status register 
        $display("\n--- Clear flag status register");
 
        tasks.send_command('h50);
        tasks.close_comm;
        #(100+clear_FSR_delay);

         // read flag status register 
        tasks.send_command('h70);
        tasks.read(2); 
        tasks.close_comm;
        #100;

        

        // write status register (set OTP bit) 
        $display("\n--- write status register (set SRWD bit)");

        tasks.write_enable;
        tasks.send_command('h01);
        regData[6:2] = 'b01011; // (BP3,TB,BP2,BP1,BP0)=(0,1,0,1,1) - lock sector 0 to 3
        regData[7] = 1'b1; // SRWD bit
        tasks.send_data(regData); 
        tasks.close_comm;
        #(write_SR_delay+100);
        
        tasks.set_Vpp_W(0);
        
        // write status register (error because SRWD bit is set) 
        $display("\n--- write status register (error because SRWD bit is set and Vpp_W=0)");
        tasks.write_enable;
        tasks.send_command('h01);
        regData[6:2] = 'b00100; // (BP3,TB,BP2,BP1,BP0)=(0,0,1,0,0)
        regData[7] = 1'b0; // SRWD bit
        tasks.send_data(regData); 
        tasks.close_comm;
        #100;

        // read status register 
        tasks.send_command('h05);
        tasks.read(2); 
        tasks.close_comm;
        #100;
        

    end


endmodule    
