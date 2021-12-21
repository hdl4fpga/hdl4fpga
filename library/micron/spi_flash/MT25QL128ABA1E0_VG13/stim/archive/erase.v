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
    
//      `ifdef  N25Q256A33E
//        parameter [20*8:1] mem = "mem_Q256.vmf";
//     `endif
//      `ifdef  N25Q256A31E
//        parameter [20*8:1] mem = "mem_Q256.vmf";
//     `endif
//     
//  
//      `ifdef  N25Q032A13E 
//        parameter [20*8:1] mem = "mem_Q032.vmf";
//     `endif
//      `ifdef  N25Q032A11E 
//        parameter [20*8:1] mem = "mem_Q032.vmf";
//     `endif

    // defparam Testbench.DUT.memory_file = mem;



    reg [addrDim-1:0] S0='h080000; //sector 8
    reg [addrDim-1:0] S1='h08FFFE; //sector 8 last columns
    
    reg [addrDim-1:0] SS0='h07F000; //sector 7, last subsector (subsector begin) 
    reg [addrDim-1:0] SS1='h07FFFE; //sector 7, last subsector (subsector end)
    

    
    reg [addrDim-1:0] addr='hFFFFFA; //location programmed in memory file
    
    reg [dataDim-1:0] regData = 'h0;

    integer i;
    


    initial begin

        
        tasks.init;





        //---------------
        // Sector erase 
        //---------------

        $display("\n---- Sector erase");

        // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
        `ifdef byte_4
        tasks.send_3byte_address(S0);
        `else
        tasks.send_address(S0);
        `endif
        tasks.close_comm;
        #(erase_delay+100);

        // read 1 (begin of the sector) 
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(S0);
        `else
        tasks.send_address(S0);
        `endif
        tasks.read(3);
        tasks.close_comm;

        // read 2 (end of the sector) 
        tasks.send_command('h03);
        `ifdef byte_4
        tasks.send_3byte_address(S1);
        `else
        tasks.send_address(S0);
        `endif

        tasks.read(4);
        tasks.close_comm;


         $display("\n---- Sector erase with suspend");
         // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
         `ifdef byte_4
        tasks.send_3byte_address(S0); 
        `else
        tasks.send_address(S0);
        `endif
        tasks.close_comm;
        #100;
        $display("\n --- sector erase suspend");
        tasks.send_command('h75);
        tasks.close_comm;
        #erase_latency;

        $display("\n --- program");
        tasks.write_enable;
        tasks.send_command('h02);
         `ifdef byte_4
        tasks.send_3byte_address(SS0);
        `else
        tasks.send_address(SS0);
        `endif

        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        $display("\n --- erase resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(erase_delay+100);

        $display("\n---- Sector erase with suspend");
         // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
         `ifdef byte_4
        tasks.send_3byte_address(S0);
        `else
        tasks.send_address(S0);
        `endif
        tasks.close_comm;
        #100;
        $display("\n --- sector erase suspend");
        tasks.send_command('h75);
        tasks.close_comm;
        #erase_latency;
        
        tasks.write_enable;
        tasks.send_command('hD8);
         `ifdef byte_4
        tasks.send_3byte_address(SS0);
        `else
        tasks.send_address(SS0);
        `endif

        tasks.close_comm;
        #(erase_delay+100);




        $display("\n --- erase resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(erase_delay+100);

        
        


        
        `ifdef SubSect
        
            //-----------------
            // Subsector erase 
            //-----------------

            $display("\n---- Subsector erase");

            // reload memory file
            DUT.f.load_memory_file("FILENAME_mem");

            // subsector esase 
            tasks.write_enable;
            tasks.send_command('h20);
            `ifdef byte_4
            tasks.send_3byte_address(SS0);
            `else
            tasks.send_address(SS0);
            `endif 
            tasks.close_comm;
            #(erase_ss_delay+100);

            // read 1 (begin of subsector) 
            tasks.send_command('h03);
            `ifdef byte_4
            tasks.send_3byte_address(SS0);
            `else
            tasks.send_address(SS0);
            `endif 
            tasks.read(3);
            tasks.close_comm;

            // read 2 (end of subsector) 
            tasks.send_command('h03);
            `ifdef byte_4
            tasks.send_3byte_address(SS1);
            `else
            tasks.send_address(SS1);
            `endif 
            tasks.read(4);
            tasks.close_comm;



            $display("\n---- Subsector erase");

            // reload memory file
            DUT.f.load_memory_file("FILENAME_mem");

            // subsector esase 
            tasks.write_enable;
            tasks.send_command('h20);
            `ifdef byte_4
            tasks.send_3byte_address(SS0);
            `else
            tasks.send_address(SS0);
            `endif 
            tasks.close_comm;
            #100;
            
            $display("\n --- subsector erase suspend");
            tasks.send_command('h75);
            tasks.close_comm;
            #erase_ss_latency;
            tasks.send_command('h03);
            `ifdef byte_4
            tasks.send_3byte_address(S0);
            `else
            tasks.send_address(S0);
            `endif 

            tasks.read(3);
            tasks.close_comm;
            $display("\n --- erase resume");

            tasks.send_command('h7A);
            tasks.close_comm;

            #(erase_ss_delay);

            // read 1 (begin of subsector) 
            tasks.send_command('h03);
            `ifdef byte_4
            tasks.send_3byte_address(SS0);
            `else
            tasks.send_address(SS0);
            `endif 
            tasks.read(3);
            tasks.close_comm;

            // read 2 (end of subsector) 
            tasks.send_command('h03);
            `ifdef byte_4
            tasks.send_3byte_address(SS1);
            `else
            tasks.send_address(SS1);
            `endif 
            tasks.read(4);
            tasks.close_comm;

        `endif



        //-----------------
        // Bulk erase 
        //-----------------

        $display("\n---- Bulk erase");

        // reload memory file
        DUT.f.load_memory_file("FILENAME_mem");

            
            // write lock register (to lock one sector)
            tasks.write_enable;
            tasks.send_command('hE5);
            `ifdef byte_4
            tasks.send_3byte_address(S0);
            `else
            tasks.send_address(S0);
            `endif 

            tasks.send_data('h01);
            tasks.close_comm;
            #100;

            // bulk erase (error) 
            tasks.write_enable;
            tasks.send_command('hC7);
            tasks.close_comm;
            #100;

            // write lock register (to unlock the sector)
            tasks.write_enable;
            tasks.send_command('hE5);
            `ifdef byte_4
            tasks.send_3byte_address(S0);
            `else
            tasks.send_address(S0);
            `endif 
            tasks.send_data('h00);
            tasks.close_comm;
            #100;
        
        // clear flag status register 
        tasks.send_command('h50);
        tasks.close_comm;
        #clear_FSR_delay;


        // bulk erase (ok) 
        tasks.write_enable;
        tasks.send_command('hC7);
        tasks.close_comm;
        #100;

        // read SR 
        tasks.send_command('h05);
        tasks.read(2);
        tasks.close_comm;
        #erase_bulk_delay;
        
        // read  
        tasks.send_command('h03);
         `ifdef byte_4
        tasks.send_3byte_address(addr);
        `else
        tasks.send_address(addr);
        `endif
        tasks.read(3);
        tasks.close_comm;
        



    end


endmodule    
