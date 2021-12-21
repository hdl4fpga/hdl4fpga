
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
//  Verilog Behavioral Model
//  Version 1.2
//
//  Copyright (c) 2013 Micron Inc.
//
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//-MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON--MICRON-
//
// This file and all files delivered herewith are Micron Confidential Information.
// 
// 
// Disclaimer of Warranty:
// -----------------------
// This software code and all associated documentation, comments
// or other information (collectively "Software") is provided 
// "AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
// ("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
// RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
// FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
// SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
// THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
// MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
// RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
// ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
// OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
// EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
// LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
// SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
// OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
// ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
// EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
// Because some jurisdictions prohibit the exclusion or limitation
// of liability for consequential or incidental damages, the above
// limitation may not apply to you.
// 
// Copyright 2013 Micron Technology, Inc. All rights reserved.
//


/*-------------------------------------------------------------------------
-- The procedures here following may be used to send
-- commands to the serial flash.
-- These procedures must be combined using one of the following sequences:
--  
-- 1) send_command / close_comm 
-- 2) send_command / send_address / close_comm
-- 3) send_command / send_address / send_data /close_comm
-- 4) send_command / send_address / read / close_comm
-- 5) send_command / read / close_comm
-- NOT ALL TASKS HAVE DTR ADDED
-------------------------------------------------------------------------*/

`timescale 1ns / 1ps

module StimTasksConfig();
    `include "include/UserData.h"
    `include "include/DevParam.h"

endmodule


`ifdef HOLD_pin
  module StimTasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);
`else
  module StimTasks (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);
`endif

`include "include/DevParam.h"

    output S;
    reg S;
    
    output [`VoltageRange] Vcc;
    reg [`VoltageRange] Vcc;

    output clock_active;
    reg clock_active;

    
    output DQ0, DQ1; 
    reg DQ0='bZ; reg DQ1='bZ; 
    
    output Vpp_W_DQ2;
    reg Vpp_W_DQ2;

    
    `ifdef HOLD_pin
        output HOLD_DQ3; reg HOLD_DQ3; 
    `endif
    
    `ifdef RESET_pin
        output RESET_DQ3; reg RESET_DQ3; 
    `endif


    reg DoubleTransferRate = 0;
    reg double_command = 0;
    reg dummy_bytes_sent = 0;
    reg [7:0] sampled_read_byte; // local variable that samples output pins for data byte
    reg four_byte_address_mode = 0;
    reg four_4byte_address_mode = 0; // added the register to check for exclusive 4 byte address commands
    reg protocol;
    wire [3:0] num_addr_bytes;    
    assign num_addr_bytes = ((four_byte_address_mode || four_4byte_address_mode) ? 4 : 3); // appended the 4 byte address mode for checking the number of bytes
    reg [dataDim-1:0] expVal [113:1]; //expected value data structure (80 x 8bytes)


        



    //-----------------
    // Initialization
    //-----------------


    task init;
    begin
        
        S = 1;
        `ifdef HOLD_pin
          HOLD_DQ3 = 1; 
        `endif
        `ifdef RESET_pin
          RESET_DQ3 = 1;
        `endif
        power_up;

    end
    endtask



    task power_up;
    begin

    `ifdef VCC_3V
        Vcc='d3000;
    `else
        Vcc='d1800;
    `endif    
        Vpp_W_DQ2=1;
        #(full_access_power_up_delay+100);

    end
    endtask

    //----------------------------------------------------------
    // Tasks for send commands, send adressses, and read memory
    //----------------------------------------------------------


    task send_command;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

      //  if (cmd == 'h27 || cmd == 'hFF || cmd == 'hFE)
     //      double_command = 0;
  
        //$display("doubeltransferrate is : %b", DoubleTransferRate);
	if (DoubleTransferRate) begin
          clock_active = 1;  #(T/4);
          S=0; #(T/2); 
        
          for (i=cmdDim-1; i>=1; i=i-1) begin
            DQ0=cmd[i]; #(T/2);
          end

          DQ0=cmd[0]; #(T/2); 
	end else begin // single transfer rate
         if(! double_command) begin      
           clock_active = 1;  #(T/4);
           S=0;
         end
         #(T/4); 
         double_command = 0;
        
         for (i=cmdDim-1; i>=1; i=i-1) begin
            DQ0=cmd[i]; 
            #T;
            
         end
        
         DQ0=cmd[0]; 
         //#(T/2+T/4); 
         #(T/2); 
         #(T/4); //test 
	end

    end
    endtask



   task send_command_dual;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0; #(T/2); 
        for (i=cmdDim-1; i>=3; i=i-2) begin
             DQ1=cmd[i]; 
             DQ0=cmd[i-1];
             #(T/2);
        end
        DQ1 =cmd[1];
        DQ0=cmd[0]; #(T/2); 
        DQ1=1'bZ;
	end else begin // single transfer rate
        if(!double_command) begin
            clock_active = 1;  #(T/4);
            S=0; 
        end
        #(T/4); 
        
        double_command = 0;

        for (i=cmdDim-1; i>=3; i=i-2) begin
             DQ1=cmd[i]; 
             DQ0=cmd[i-1];
             #T;
        end
        DQ1 =cmd[1];
        DQ0=cmd[0];  #(T/2+T/4); 
        `ifndef MT25QL128ABA1E0
        DQ1=1'bZ;
        `endif
	end

    end
    endtask


    task send_command_quad;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0; #(T/2); 

        for (i=cmdDim-1; i>=7; i=i-4) begin

            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
             `endif
             `ifdef RESET_pin
              RESET_DQ3 = 1;
             `endif

             Vpp_W_DQ2=cmd[i-1];
             DQ1=cmd[i-2]; 
             DQ0=cmd[i-3];
             #(T/2);
        end    
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
            `endif
            `ifdef RESET_pin
              RESET_DQ3 =cmd[i];
            `endif

            Vpp_W_DQ2=cmd[i-1];
            DQ1=cmd[i-2]; 
            DQ0=cmd[i-3]; #(T/2);
         
           `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
           `endif
           `ifdef RESET_pin 
            RESET_DQ3 = 1'bZ;

           `endif
           Vpp_W_DQ2=1'bZ;
           DQ1=1'bZ;
	end else begin // single transfer rate
        if(!double_command) begin
            clock_active = 1;  
            #(T/4);
        end
        S=0; 
        #(T/4); 
        
        
                            $display("---DEBUG--- cmd=%0h\n",cmd);
       
        double_command = 0;

        for (i=cmdDim-1; i>=7; i=i-4) begin
        
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
             `endif

            `ifdef RESET_pin
             RESET_DQ3=cmd[i];
            `endif
             
             Vpp_W_DQ2=cmd[i-1];
             DQ1=cmd[i-2]; 
             DQ0=cmd[i-3];
            #T;
        end   
        
           `ifdef HOLD_pin
            HOLD_DQ3=cmd[i];
           `endif

           `ifdef RESET_pin
            RESET_DQ3=cmd[i];
           `endif
           
            Vpp_W_DQ2=cmd[i-1];
            DQ1=cmd[i-2]; 
            DQ0=cmd[i-3]; 
            #(T/2+T/4);
           // #(T/4);
//#5;
           
           `ifndef MT25QL128ABA1E0
           `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=1'bZ;
           `endif
           
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
        `endif
       end



   end
 endtask

    task send_command_quad2;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0; #(T/2); 

        for (i=cmdDim-1; i>=7; i=i-4) begin

            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
             `endif
             `ifdef RESET_pin
              RESET_DQ3 = 1;
             `endif

             Vpp_W_DQ2=cmd[i-1];
             DQ1=cmd[i-2]; 
             DQ0=cmd[i-3];
             #(T/2);
        end    
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
            `endif
            `ifdef RESET_pin
              RESET_DQ3 =cmd[i];
            `endif

            Vpp_W_DQ2=cmd[i-1];
            DQ1=cmd[i-2]; 
            DQ0=cmd[i-3]; #(T/2);
         
           `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
           `endif
           `ifdef RESET_pin 
            RESET_DQ3 = 1'bZ;

           `endif
           Vpp_W_DQ2=1'bZ;
           DQ1=1'bZ;
	end else begin // single transfer rate
//        clock_active = 1;  
//        #(T/4);
//        S=0; 
        #(T/4); 
        
            double_command = 0;

        for (i=cmdDim-1; i>=7; i=i-4) begin
        
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
             `endif

            `ifdef RESET_pin
             RESET_DQ3=cmd[i];
            `endif
             
             Vpp_W_DQ2=cmd[i-1];
             DQ1=cmd[i-2]; 
             DQ0=cmd[i-3];
            #T;
        end   
        
           `ifdef HOLD_pin
            HOLD_DQ3=cmd[i];
           `endif

           `ifdef RESET_pin
            RESET_DQ3=cmd[i];
           `endif
           
            Vpp_W_DQ2=cmd[i-1];
            DQ1=cmd[i-2]; 
            DQ0=cmd[i-3]; 
            #(T/2+T/4);
           // #(T/4);
//#5;
           
           `ifndef MT25QL128ABA1E0
           `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=1'bZ;
           `endif
           
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
        `endif
       end



   end
 endtask

//`ifdef byte_4
    task send_3byte_address;

    `ifdef STACKED_MEDT_1G
    input [addrDim : 0] addr;
    `else
    input [addrDim-1 : 0] addr;
    `endif
    integer i;
    
    begin
        $display("--send_3byte_address--");
        if (DoubleTransferRate) begin
          for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #(T/2);
          end

          DQ0 = addr[0];  #(T/2);
        end else begin // single transfer rate

          #(T/4);
          for (i=(8*num_addr_bytes)-1; i>=1; i=i-1) begin
            //DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #T;
            DQ0 = (i > addrDim ? 1'b0 : addr[i]); #T;
            //DQ0 =  addr[i]; #T;
          end    

          DQ0 = addr[0];  #(T/2+T/4);
          DQ0=1'bZ; 
        end

    end
    endtask 

    task send_3byte_address_;

    input [addrDimLatch4-1 : 0] addr;

    integer i;
    
    begin
        if (DoubleTransferRate) begin
          for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #(T/2);
          end

          DQ0 = addr[0];  #(T/2);
        end else begin // single transfer rate

          #(T/4);
          for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            //DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #T;
            DQ0 =  addr[i]; #T;
          end    

          DQ0 = addr[0];  #(T/2+T/4);
          DQ0=1'bZ; 
        end

    end
    endtask 

    task XIP_send_3byte_address;


      input [addrDim-1 : 0] addr;


      integer i;
    
    begin
        if (DoubleTransferRate) begin
          clock_active = 1;  #(T/4);
          S=0;
          #(T/2);
          for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #(T/2);
          end

          DQ0 = addr[0];  #(T/2);
          DQ0=1'bZ;
        end else begin // single transfer rate
          clock_active = 1;  #(T/4);
          S=0;  
          #(T/4);
          for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #T;
          end    

          DQ0 = addr[0];  #(T/2+T/4);
          DQ0=1'bZ;
        end

    end
    endtask 


  task send_3byte_address_dual;

    input [addrDim-1 : 0] addr;
 

    integer i;
    
    begin
        if (DoubleTransferRate) begin
          #(T/2);
          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #(T/2);
          end
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end else begin // single transfer rate

          #(T/4);
          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #T;
          end    
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2+T/4);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end

    end
    endtask 

  task send_3byte_address_dual_;

    input [addrDimLatch4-1 : 0] addr;
 

    integer i;
    
    begin

        if (DoubleTransferRate) begin
          #(T/2);
          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #(T/2);
          end
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end else begin // single transfer rate

          #(T/4);
          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
//            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
//            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            DQ1 =  addr[i];
            DQ0 =  addr[i-1];
            #T;
          end    
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2+T/4);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end

    end
    endtask //send_3byte_address_dual_

    task XIP_send_3byte_address_dual;


    input [addrDim-1 : 0] addr;


    integer i;
    
    begin
    
        if (DoubleTransferRate) begin
          clock_active = 1;  #(T/4);
          S=0;
          #(T/2);

          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #(T/2);
          end
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end else begin // single transfer rate

          clock_active = 1;  #(T/4);
          S=0;
          #(T/4);
          for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #T;
          end 
          DQ1 = addr[1];
          DQ0 = addr[0];  #(T/2+T/4);
          DQ1=1'bZ;
          DQ0=1'bZ;
        end 

    end
    endtask 

task send_3byte_address_quad;
    input [addrDim-1 : 0] addr;
    integer i;
    begin
        if (DoubleTransferRate) begin
            #(T/2);
            for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
                `ifdef HOLD_pin
                HOLD_DQ3= (i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                `ifdef RESET_pin
                RESET_DQ3= (i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                Vpp_W_DQ2= (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
                DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
                DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
                #(T/2);
            end //for loop
        `ifdef HOLD_pin
        HOLD_DQ3=addr[3];
        `endif
        `ifdef RESET_pin
        RESET_DQ3=addr[3];
        `endif

        Vpp_W_DQ2=addr[2];
        DQ1 = addr[1];
        DQ0 = addr[0]; #(T/2);

        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
        DQ0=1'bZ;
        end else begin // single transfer rate
            #(T/4);
            for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
                `ifdef HOLD_pin
                HOLD_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                `ifdef RESET_pin
                RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
                DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
                DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
                #T;
            end 
        `ifdef HOLD_pin
        HOLD_DQ3=addr[i];
        `endif

        `ifdef RESET_pin
        RESET_DQ3=addr[i];
        `endif
        Vpp_W_DQ2=addr[i-1];
        DQ1 = addr[i-2];
        DQ0 = addr[i-3]; #(T/2+T/4);

        `ifdef HOLD_pin    
        HOLD_DQ3=1'bZ;
        `endif

        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
        DQ0=1'bZ;
        end //else
    end //if
endtask //send_3byte_address_quad

task send_3byte_address_quad_;
    input [addrDimLatch4-1 : 0] addr;
    integer i;
    begin
        if (DoubleTransferRate) begin
            #(T/2);
            for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
                `ifdef HOLD_pin
                HOLD_DQ3= (i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                `ifdef RESET_pin
                RESET_DQ3= (i > addrDim-1 ? 1'b0 : addr[i]);
                `endif
                Vpp_W_DQ2= (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
                DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
                DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
                #(T/2);
            end //for loop
        `ifdef HOLD_pin
        HOLD_DQ3=addr[3];
        `endif
        `ifdef RESET_pin
        RESET_DQ3=addr[3];
        `endif

        Vpp_W_DQ2=addr[2];
        DQ1 = addr[1];
        DQ0 = addr[0]; #(T/2);

        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
        DQ0=1'bZ;
        end else begin // single transfer rate
            #(T/4);
            for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
//                `ifdef HOLD_pin
//                HOLD_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
//                `endif
//                `ifdef RESET_pin
//                RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
//                `endif
//                Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
//                DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
//                DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
                `ifdef HOLD_pin
                HOLD_DQ3= addr[i];
                `endif
                `ifdef RESET_pin
                RESET_DQ3= addr[i];
                `endif
                Vpp_W_DQ2= addr[i-1];
                DQ1 =  addr[i-2];
                DQ0 =  addr[i-3];
                #T;
            end 
        `ifdef HOLD_pin
        HOLD_DQ3=addr[i];
        `endif

        `ifdef RESET_pin
        RESET_DQ3=addr[i];
        `endif
        Vpp_W_DQ2=addr[i-1];
        DQ1 = addr[i-2];
        DQ0 = addr[i-3]; #(T/2+T/4);

        `ifdef HOLD_pin    
        HOLD_DQ3=1'bZ;
        `endif

        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
        DQ0=1'bZ;
        end //else
    end //if
endtask //send_3byte_address_quad_


    task XIP_send_3byte_address_quad;


    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        
        if (DoubleTransferRate) begin
          clock_active = 1;  #(T/4);
          S=0;
          #(T/2);
          for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
           `ifdef HOLD_pin
            HOLD_DQ3= (i > addrDim-1 ? 1'b0 : addr[i]);
            `endif
            `ifdef RESET_pin
            RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
            `endif
            Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            DQ1 =  (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
            DQ0 =  (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
            #(T/2);
          end

            `ifdef HOLD_pin
            HOLD_DQ3=addr[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[3];
            `endif
            Vpp_W_DQ2=addr[2];
            DQ1 = addr[1];
            DQ0 = addr[0]; #(T/2);

           `ifdef HOLD_pin
          HOLD_DQ3=1'bZ;
          `endif
          `ifdef RESET_pin
            RESET_DQ3=1'bZ;
          `endif
  
          Vpp_W_DQ2=1'bZ;
          DQ1=1'bZ;
        end else begin // single transfer rate

          clock_active = 1;  #(T/4);
          S=0;
          #(T/4);
        for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin

           `ifdef HOLD_pin 
            HOLD_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
           `endif
         
           `ifdef RESET_pin
            RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
           `endif

            Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
            DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
            #T;
         end 
           `ifdef HOLD_pin 
            HOLD_DQ3=addr[i];
           `endif
           
           `ifdef RESET_pin
            RESET_DQ3=addr[i];
           `endif

            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3]; #(T/2+T/4);
            
           `ifdef HOLD_pin   
            HOLD_DQ3=1'bZ;
           `endif
           
           `ifdef RESET_pin
             RESET_DQ3=1'bZ;
           `endif
           
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
            DQ0=1'bZ;
       end
        

    end
    endtask 

 
 //

 task send_4byte_address;

    input [addrDim-1 : 0] addr4;



    integer i;
    
    begin

        #(T/4);

       
        // first MSB bits are don't care
       `ifdef N25Q256A33E

        DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T;
     
       `endif

       `ifdef N25Q256A31E

        DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T;
     
       `endif 

        for (i=addrDim-1; i>=1; i=i-1) begin

            DQ0 = addr4[i]; #T;
        end    

        DQ0 = addr4[0];  #(T/2+T/4);
        DQ0=1'bZ;

    end
    endtask 


    task XIP_send_4byte_address;

    input [addrDim-1 : 0] addr;


      integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        S=0;  
        #(T/4);


          // first MSB bits are don't care
       `ifdef N25Q256A33E

         DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T;
         
     
       `endif 
        
        `ifdef N25Q256A31E

         DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T; DQ0=0;#T; DQ0=0; #T; DQ0=0; #T;
         
     
       `endif 
        for (i=addrDim-1; i>=1; i=i-1) begin

            DQ0 = addr[i]; #T;
      
      end    

        DQ0 = addr[0];  #(T/2+T/4);
        DQ0=1'bZ;

    end
    endtask 


  task send_4byte_address_dual;

    input [addrDim-1 : 0] addr4;


    integer i;
    
    begin

        #(T/4);
        
        //verificare
        `ifdef N25Q256A33E  

        DQ1=0; DQ0=0;  #T; DQ1=0; DQ0=0; #T; DQ1=0;  DQ0=0; #T; DQ1=0; DQ0=addr4[addrDim-1]; #T;

     
       `endif 

        `ifdef N25Q256A31E  

        DQ1=0; DQ0=0;  #T; DQ1=0; DQ0=0; #T; DQ1=0;  DQ0=0; #T; DQ1=0; DQ0=addr4[addrDim-1]; #T;

     
       `endif 

       

        for (i=addrDim-2; i>=3; i=i-2) begin

            DQ1 = addr4[i];

            DQ0 = addr4[i-1];

            #T;
        end    
        
        DQ1 = addr4[1];

        DQ0 = addr4[0];  #(T/2+T/4);

        DQ1=1'bZ;
        DQ0=1'bZ;
        

    end
    endtask 

    task XIP_send_4byte_address_dual;

    input [addrDim-1 : 0] addr4;


    integer i;
    
    begin
    
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);
        
         //verificare
        `ifdef N25Q256A33E  

         DQ1=0; DQ0=0;  #T; DQ1=0; DQ0=0; #T; DQ1=0;  DQ0=0; #T; DQ1=0; DQ0=addr4[addrDim-1]; #T;

                   
        `endif 
         
         `ifdef N25Q256A31E  

         DQ1=0; DQ0=0;  #T; DQ1=0; DQ0=0; #T; DQ1=0;  DQ0=0; #T; DQ1=0; DQ0=addr4[addrDim-1]; #T;

                   
        `endif

        for (i=addrDim-2; i>=3; i=i-2) begin
        
            DQ1 = addr4[i];
            DQ0 = addr4[i-1];
            #T;
            
        end 
        
        DQ1 = addr4[1];
        DQ0 = addr4[0];  #(T/2+T/4);
        DQ1=1'bZ;
        DQ0=1'bZ;
        

    end
    endtask 

    task send_4byte_address_quad;

    input [addrDim-1 : 0] addr4;
 

    integer i;
    
    begin

        #(T/4);
    
        `ifdef N25Q256A33E  

          `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=0;
             
             #T; 

             `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=addr4[addrDim-1];

             #T;


        `endif


        `ifdef N25Q256A31E  

          `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=0;
             
             #T; 

             `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=addr4[addrDim-1];

             #T;


        `endif


        for (i=addrDim-2; i>=7; i=i-4) begin

           `ifdef HOLD_pin
            HOLD_DQ3=addr4[i];
           `endif
           
           `ifdef RESET_pin
            RESET_DQ3=addr4[i];
           `endif
           

            Vpp_W_DQ2=addr4[i-1];
            DQ1 = addr4[i-2];
            DQ0 = addr4[i-3];
            #T;
            
        end 
        
           `ifdef HOLD_pin
            HOLD_DQ3=addr4[i];
           `endif
           
           `ifdef RESET_pin
            RESET_DQ3=addr4[i];
           `endif
           

            Vpp_W_DQ2=addr4[i-1];
            DQ1 = addr4[i-2];
            DQ0 = addr4[i-3]; #(T/2+T/4);
            
           `ifdef HOLD_pin    
            HOLD_DQ3=1'bZ;
           `endif
            
           `ifdef RESET_pin
            RESET_DQ3=1'bZ;
           `endif

            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
            DQ0=1'bZ;
        

    end
    endtask 


    task XIP_send_4byte_address_quad;

    input [addrDim-1 : 0] addr4;

    integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);
        
        `ifdef N25Q256A33E  

          `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=0;
             
             #T; 

             `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=addr4[addrDim-1];

             #T;


        `endif

         `ifdef N25Q256A31E  

          `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=0;
             
             #T; 

             `ifdef HOLD_pin
            HOLD_DQ3=0;
           `endif

           `ifdef RESET_pin
            RESET_DQ3=0;
           `endif

            Vpp_W_DQ2=0;
            
             DQ1=0;
             
             
             DQ0=addr4[addrDim-1];

             #T;


        `endif


        
        for (i=addrDim-2; i>=7; i=i-4) begin

           `ifdef HOLD_pin 
            HOLD_DQ3=addr4[i];
           `endif
         
           `ifdef RESET_pin
            RESET_DQ3=addr4[i];
           `endif

            Vpp_W_DQ2=addr4[i-1];
            DQ1 = addr4[i-2];
            DQ0 = addr4[i-3];
            #T;
            
       end 
       
           `ifdef HOLD_pin 
            HOLD_DQ3=addr4[i];
           `endif
           
           `ifdef RESET_pin
            RESET_DQ3=addr4[i];
           `endif

            Vpp_W_DQ2=addr4[i-1];
            DQ1 = addr4[i-2];
            DQ0 = addr4[i-3]; #(T/2+T/4);
            
           `ifdef HOLD_pin   
            HOLD_DQ3=1'bZ;
           `endif
           
           `ifdef RESET_pin
             RESET_DQ3=1'bZ;
           `endif
           
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
            DQ0=1'bZ;
        

    end
    endtask 

//`else

    task send_address;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
	if (DoubleTransferRate) begin
        for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #(T/2);
        end    

        DQ0 = addr[0];  #(T/2);
	end else begin // single transfer rate

        #(T/4);


        `ifdef N25Q032A13E
          DQ0=0; #T; DQ0=0;#T;
        `endif   
        `ifdef N25Q032A11E
          DQ0=0; #T; DQ0=0;#T;
        `endif  
        for (i=addrDim-1; i>=1; i=i-1) begin
            DQ0 = addr[i]; #T;
        end    

        DQ0 = addr[0];  #(T/2+T/4);
      end

    end
    endtask 


 task XIP_send_address;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        
	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0;  
        #(T/2);


        for (i=8*num_addr_bytes-1; i>=1; i=i-1) begin
            DQ0 = (i > addrDim-1 ? 1'b0 : addr[i]); #(T/2);
        end    

        DQ0 = addr[0];  #(T/2);
	end else begin // single transfer rate
        clock_active = 1;  #(T/4);
        S=0;  
        #(T/4);


         `ifdef N25Q032A13E
          DQ0=0; #T; DQ0=0;#T;
        `endif   
         `ifdef N25Q032A11E
          DQ0=0; #T; DQ0=0;#T;
        `endif 

        for (i=addrDim-1; i>=1; i=i-1) begin
            DQ0 = addr[i]; #T;
        end    

        DQ0 = addr[0];  #(T/2+T/4);

      end
    end
    endtask 


  task send_address_dual;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
	if (DoubleTransferRate) begin
        for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #(T/2);
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2);
        DQ1=1'bZ;
	end else begin // single transfer rate

        #(T/4);
        
         `ifdef N25Q032A13E
          DQ1=0;DQ0=0;#T;
        `endif   
          
           `ifdef N25Q032A11E
          DQ1=0;DQ0=0;#T;
        `endif   


        for (i=addrDim-1; i>=3; i=i-2) begin
            DQ1 = addr[i];
            DQ0 = addr[i-1];
            #T;
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2+T/4);
        DQ1=1'bZ;

      end

    end
    endtask 

    task XIP_send_address_dual;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0;
        #(T/2);

        for (i=8*num_addr_bytes-1; i>=3; i=i-2) begin
            DQ1 = (i > addrDim-1 ? 1'b0 : addr[i]);
            DQ0 = (i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            #(T/2);
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2);
        DQ1=1'bZ;
	end else begin // single transfer rate
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);
        
         `ifdef N25Q032A13E
          DQ1=0;DQ0=0;#T;
        `endif
         `ifdef N25Q032A11E
          DQ1=0;DQ0=0;#T;
        `endif

        for (i=addrDim-1; i>=3; i=i-2) begin
            DQ1 = addr[i];
            DQ0 = addr[i-1];
            #T;
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2+T/4);
        DQ1=1'bZ;

      end 

    end
    endtask 

    task send_address_quad;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin

	if (DoubleTransferRate) begin
        for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
            `ifdef HOLD_pin
            HOLD_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
            `endif
            `ifdef RESET_pin
            RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
            `endif

            Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
            DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
            #(T/2);
        end 
            `ifdef HOLD_pin
            HOLD_DQ3=addr[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[3];
            `endif

            Vpp_W_DQ2=addr[2];
            DQ1 = addr[1];
            DQ0 = addr[0]; #(T/2);

        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif

        `ifdef RESET_pin
          RESET_DQ3=1'bZ;
        `endif


        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
	end else begin // single transfer rate
        #(T/4);
        
        `ifdef N25Q032A13E
        
        `ifdef HOLD_pin
            HOLD_DQ3=0;
        `endif
        
        `ifdef RESET_pin
            RESET_DQ3=0;
        `endif
         Vpp_W_DQ2=0;

          DQ1=addr[addrDim-1]; 
          DQ0=addr[addrDim-2];
          #T;
        `endif
         
         `ifdef N25Q032A11E
        
        `ifdef HOLD_pin
            HOLD_DQ3=0;
        `endif
        
        `ifdef RESET_pin
            RESET_DQ3=0;
        `endif
         Vpp_W_DQ2=0;

          DQ1=addr[addrDim-1]; 
          DQ0=addr[addrDim-2];
          #T;
        `endif

        for (i=addrDim-3; i>=7; i=i-4) begin
        `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
        `endif
        `ifdef RESET_pin
            RESET_DQ3=addr[i];
        `endif

         
            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3];
            #T;
        end  
         `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
         `endif
         `ifdef RESET_pin
            RESET_DQ3=addr[i];
        `endif

            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3]; #(T/2+T/4);
        
        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        
        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;

      end 

    end
    endtask 


    task XIP_send_address_quad;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        
    	if (DoubleTransferRate) begin
        clock_active = 1;  #(T/4);
        S=0;
        #(T/2);
        for (i=8*num_addr_bytes-1; i>=7; i=i-4) begin
           
           `ifdef HOLD_pin
            HOLD_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
            `endif
            `ifdef RESET_pin
            RESET_DQ3=(i > addrDim-1 ? 1'b0 : addr[i]);
            `endif
            Vpp_W_DQ2=(i-1 > addrDim-1 ? 1'b0 : addr[i-1]);
            DQ1 = (i-2 > addrDim-1 ? 1'b0 : addr[i-2]);
            DQ0 = (i-3 > addrDim-1 ? 1'b0 : addr[i-3]);
            #(T/2);
        end  
            
            `ifdef HOLD_pin
            HOLD_DQ3=addr[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[3];
            `endif
            Vpp_W_DQ2=addr[2];
            DQ1 = addr[1];
            DQ0 = addr[0]; #(T/2);
        
         `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif

        `ifdef RESET_pin
          RESET_DQ3=1'bZ;
        `endif


        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;
	end else begin // single transfer rate
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);
         
          
        `ifdef N25Q032A13E
        
        `ifdef HOLD_pin
            HOLD_DQ3=0;
        `endif
        
        `ifdef RESET_pin
            RESET_DQ3=0;
        `endif
         Vpp_W_DQ2=0;

          DQ1=addr[addrDim-1]; 
          DQ0=addr[addrDim-2];
          #T;
        `endif
         
         `ifdef N25Q032A11E
        
        `ifdef HOLD_pin
            HOLD_DQ3=0;
        `endif
        
        `ifdef RESET_pin
            RESET_DQ3=0;
        `endif
         Vpp_W_DQ2=0;

          DQ1=addr[addrDim-1]; 
          DQ0=addr[addrDim-2];
          #T;
        `endif

        for (i=addrDim-3; i>=7; i=i-4) begin
            `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
            `endif
           `ifdef RESET_pin
            RESET_DQ3=addr[i];
           `endif
            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3];
            #T;
        end 
        
           `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
           `endif
           `ifdef RESET_pin
            RESET_DQ3=addr[i];
           `endif
            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3]; #(T/2+T/4);
        
        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
        RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;

      end 

    end
    endtask 

//`endif
 //

    task send_data;

    input [dataDim-1:0] data;
    
    integer i;
    
    begin

	if (DoubleTransferRate) begin
        for (i=dataDim-1; i>=1; i=i-1) begin
            DQ0=data[i]; #(T/2);
        end

        DQ0=data[0]; #(T/2); 
	end else begin // single transfer rate
        #(T/4);

        
        for (i=dataDim-1; i>=1; i=i-1) begin
            DQ0=data[i]; #T;
        end

        DQ0=data[0]; #(T/2+T/4); 
      end

    end
    endtask





    
        task send_data_dual;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

	if (DoubleTransferRate) begin
            for (i=dataDim-1; i>=3; i=i-2) begin
                DQ1=data[i]; 
                DQ0=data[i-1];
                #(T/2);
            end

            DQ1=data[1];
            DQ0=data[0]; #(T/2);
            DQ1=1'bZ;
	end else begin // single transfer rate
            #(T/4);

            
            for (i=dataDim-1; i>=3; i=i-2) begin
                DQ1=data[i]; 
                DQ0=data[i-1];
                #T;
            end

            DQ1=data[1];
            DQ0=data[0]; #(T/2+T/4);
            DQ1=1'bZ;

          end
        end
        endtask



        task send_data_quad;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

	if (DoubleTransferRate) begin
            for (i=dataDim-1; i>=7; i=i-4) begin
                
                `ifdef HOLD_pin
                HOLD_DQ3=data[i];
                `endif
                `ifdef RESET_pin
                RESET_DQ3=data[i];
                `endif
                Vpp_W_DQ2=data[i-1];
                DQ1=data[i-2]; 
                DQ0=data[i-3];
                #(T/2);
            end
            
            `ifdef HOLD_pin
            HOLD_DQ3=data[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=data[3];
            `endif

            Vpp_W_DQ2=data[2];
            DQ1=data[1];
            DQ0=data[0]; #(T/2);
            
            `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
            `endif
            `ifdef RESET_pin
             RESET_DQ3=1'bZ;
            `endif
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
	end else begin // single transfer rate
            #(T/4);

            
            for (i=dataDim-1; i>=7; i=i-4) begin
               `ifdef HOLD_pin
                HOLD_DQ3=data[i];
                 `endif
               `ifdef RESET_pin
                RESET_DQ3=data[i];
                `endif

                Vpp_W_DQ2=data[i-1];
                DQ1=data[i-2]; 
                DQ0=data[i-3];
                #T;
            end
            `ifdef HOLD_pin
            HOLD_DQ3=data[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=data[3];
            `endif

            Vpp_W_DQ2=data[2];
            DQ1=data[1];
            DQ0=data[0]; #(T/2+T/4);
            `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
            `endif
            `ifdef RESET_pin
            RESET_DQ3=1'bZ;
            `endif

            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;
          end

        end
        endtask



task send_dummy;

    input [dummyDim-1:0] data;

    input integer n;
    
    integer i;
    
    begin

	if (DoubleTransferRate) begin
        for (i=n-1; i>=1; i=i-1) begin
            DQ0=data[i]; #T;
        end

	// Unlike other DTR instr/addr/data tasks, we end in middle of high clk pulse, instead of middle of low clk pulse
	// Difference is caused by fact that in DTR, last instr/addr/data bit is latched on negedge clk, but last dummy bit is latched on posedge clk
        DQ0=data[0]; #(T/2);
	end else begin // single transfer rate
        #(T/4);

        
        for (i=n-1; i>=1; i=i-1) begin
            DQ0=data[i]; #T;
        end

        DQ0=data[0]; #(T/2+T/4); 
      end

    end
    endtask

  task send_dummy_dual;

    input [dummyDim-1:0] data;

    input integer n;
    
    integer i;
    
    begin
        if (DoubleTransferRate)
            begin
                for (i=n-1; i>=1; i=i-1) begin
                    DQ1=data[i]; 
                    DQ0=data[i]; 
                    #T;
                end
            
                DQ1=data[0];
                DQ0=data[0]; 
                #(T/2); 
            end
        else 
        begin
        $display("\ndummy cycles...\n");
        #(T/4);

        
        for (i=n-1; i>=1; i=i-1) begin
            DQ1=data[i]; 
            DQ0=data[i]; 
            #T;
        end
        
        DQ1=data[0];
        DQ0=data[0]; 
        #(T/2+T/4); 
        end 
        DQ1=1'bZ;


        //->DUT.MT25Q_die0.Debug.x5;

    end
    endtask




   task send_dummy_quad;

    input [dummyDim-1:0] data;

    input integer n;

    
    integer i;
    
    begin
        if(DoubleTransferRate)
            begin
                for (i=n-1; i>=1; i=i-1) begin
                   
                   `ifdef HOLD_pin
                     HOLD_DQ3=data[i];
                   `endif
                   `ifdef RESET_pin
                     RESET_DQ3=data[i];
                   `endif
                     Vpp_W_DQ2=data[i];

                     DQ1=data[i]; 
                     DQ0=data[i]; 
                     #T;
                end
                
                `ifdef HOLD_pin
                 HOLD_DQ3=data[0];
                `endif
                `ifdef RESET_pin
                 RESET_DQ3=data[0];
                `endif
                Vpp_W_DQ2=data[0];
                DQ1=data[0];
                DQ0=data[0]; 
                #(T/2); 
            end
        else begin
        #(T/4);

        
        for (i=n-1; i>=1; i=i-1) begin
           
           `ifdef HOLD_pin
             HOLD_DQ3=data[i];
           `endif
           `ifdef RESET_pin
             RESET_DQ3=data[i];
           `endif
             Vpp_W_DQ2=data[i];

             DQ1=data[i]; 
             DQ0=data[i]; #T;
        end
        
        `ifdef HOLD_pin
         HOLD_DQ3=data[0];
        `endif
        `ifdef RESET_pin
         RESET_DQ3=data[0];
        `endif
        Vpp_W_DQ2=data[0];
        DQ1=data[0];
        DQ0=data[0]; #(T/2+T/4); 
    end
       `ifdef HOLD_pin
         HOLD_DQ3=1'bZ;
       `endif
       `ifdef RESET_pin
        RESET_DQ3=1'bZ;
       `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;



    end
    endtask


 
    task read;

    input n;
    integer n, i, j;

   reg [7:0] temp_read_byte;
    
    fork
    begin
    for (i=1; i<=n; i=i+1) begin 
        #(8*T/(DoubleTransferRate+1)); // halved if DTR mode
    end  
    if (DoubleTransferRate && dummy_bytes_sent) #(T/2);
    end
    begin
	if (DoubleTransferRate) begin
	    #1; // task may be at nededge C already, but data output actually starts on next negedge
	    for (j=1; j<=n; j=j+1) begin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.DQ1; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[6] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[5] = Testbench.DQ1;
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[4] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[3] = Testbench.DQ1;
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[2] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[1] = Testbench.DQ1;
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[0] = Testbench.DQ1;
		sampled_read_byte = temp_read_byte;
		`ifdef PRINT_ALL_DATA
		$display("SIO-DTR Read out byte at time %t is %2h", $time, sampled_read_byte);
		`endif
        checkData(sampled_read_byte, expVal[j]);
	    end
	end else begin // single transfer rate
	    #1; // task may be at posedge C already, but data output actually starts on next posedge
	    for (j=1; j<=n; j=j+1) begin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.DQ1; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[6] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[5] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[4] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[3] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[2] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[1] = Testbench.DQ1;
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[0] = Testbench.DQ1;
		sampled_read_byte = temp_read_byte;
		`ifdef PRINT_ALL_DATA
		$display("SIO Read out byte at time %t is %2h", $time, sampled_read_byte);
		`endif
        checkData(sampled_read_byte, expVal[j]);
	    end
	end
    end
    join

    endtask

    
// -------------------------------------------------------------------
// task name: checkData
// description: compares sampled data during reads with expected data
// inputs:
//
// -------------------------------------------------------------------
task checkData;
    input [dataDim-1:0] data;
    input [dataDim-1:0] exp;
    begin
        if(data !== exp)
            begin
                `ifdef COMPARE_DATA
                $display("\n [ERROR] Read data does not match expected data! %h != %h\n",data, exp);
                `endif
                -> tasks.checkDataError;
                tasks.errorCount = tasks.errorCount + 1;
            end
        else
            $display("\n [INFO] Read data matched. %h == %h",data,exp);
    end
endtask //checkData

// -------------------------------------------------------------------
// task name: wrapUp
// description: task to call at the end of the simulation.
// inputs: NA
// -------------------------------------------------------------------
task wrapUp;
    begin
        $display("-------------------------------------------------------------------");
        $display("\n [INFO] There are %0d data compare mismatch. \n",tasks.errorCount);
        $display("-------------------------------------------------------------------");
    end
endtask //wrapUp

    
    task read_dual;

    input n;
    integer n, i, j;
    reg [7:0] temp_read_byte;
    
    fork
        begin
            DQ0 = 1'bZ;
            //for (i=1; i<=2*n; i=i+1) begin 
            for (i=1; i<=n; i=i+1) begin 
                #(4*T/(DoubleTransferRate+1)); // halved if DTR mode
            end   
            if (DoubleTransferRate && dummy_bytes_sent) #(T/2);
        end
        begin
            if (DoubleTransferRate) begin
                #1; // task may be at nededge C already, but data output actually starts on next negedge
                //for (j=1; j<=2*n; j=j+1) begin
                for (j=1; j<=n; j=j+1) begin
        		@(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[7] = Testbench.DQ1; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
        						temp_read_byte[6] = Testbench.DQ0;
        		@(posedge ck_gen.C) #(tCHQV+2);	temp_read_byte[5] = Testbench.DQ1;
        						temp_read_byte[4] = Testbench.DQ0;
        		@(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[3] = Testbench.DQ1;
        						temp_read_byte[2] = Testbench.DQ0;
        		@(posedge ck_gen.C) #(tCHQV+2);	temp_read_byte[1] = Testbench.DQ1;
        						temp_read_byte[0] = Testbench.DQ0;
                sampled_read_byte = temp_read_byte;
                `ifdef PRINT_ALL_DATA
                $display("DIO-DTR Read out byte at time %t is %2h", $time, sampled_read_byte);
                `endif
                checkData(sampled_read_byte, expVal[j]);
                end
            end else begin // single transfer rate
                #1; // task may be at posedge C already, but data output actually starts on next posedge
                //for (j=1; j<=2*n; j=j+1) begin
                for (j=1; j<=n; j=j+1) begin
                @(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[7] = Testbench.DQ1; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
                                temp_read_byte[6] = Testbench.DQ0;
                @(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[5] = Testbench.DQ1;
                                temp_read_byte[4] = Testbench.DQ0;
                @(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[3] = Testbench.DQ1;
                                temp_read_byte[2] = Testbench.DQ0;
                @(negedge ck_gen.C) #(tCLQV+2);	temp_read_byte[1] = Testbench.DQ1;
                                temp_read_byte[0] = Testbench.DQ0;
                sampled_read_byte = temp_read_byte;
                `ifdef PRINT_ALL_DATA
                $display("DIO Read out byte at time %t is %2h", $time, sampled_read_byte);
                `endif
                checkData(sampled_read_byte, expVal[j]);
                end
            end
        end
    join
    endtask

   
   task read_quad;

    input n;
    integer n, i, j;
    reg [7:0] temp_read_byte;
    
    fork
    begin
    DQ0 = 1'bZ;
    //for (i=1; i<=4*n; i=i+1) begin 
    for (i=1; i<=n; i=i+1) begin 
        #(2*T/(DoubleTransferRate+1)); // halved if DTR mode
    end   
    if (DoubleTransferRate && dummy_bytes_sent) #(T/2);
    end
    begin
	if (DoubleTransferRate) begin
	    #1; // task may be at nededge C already, but data output actually starts on next negedge
	    //for (j=1; j<=4*n; j=j+1) begin
	    for (j=1; j<=n; j=j+1) begin
		`ifdef HOLD_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.HOLD_DQ3; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
		`endif
		`ifdef RESET_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.RESET_DQ3;
		`endif
						temp_read_byte[6] = Testbench.Vpp_W_DQ2;
						temp_read_byte[5] = Testbench.DQ1;
						temp_read_byte[4] = Testbench.DQ0;
		`ifdef HOLD_pin
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[3] = Testbench.HOLD_DQ3;
		`endif
		`ifdef RESET_pin
		@(posedge ck_gen.C) #(tCHQV+1);	temp_read_byte[3] = Testbench.RESET_DQ3;
		`endif
						temp_read_byte[2] = Testbench.Vpp_W_DQ2;
						temp_read_byte[1] = Testbench.DQ1;
						temp_read_byte[0] = Testbench.DQ0;
		sampled_read_byte = temp_read_byte;
		`ifdef PRINT_ALL_DATA
		$display("QIO-DTR Read out byte at time %t is %2h", $time, sampled_read_byte);
		`endif
        checkData(sampled_read_byte, expVal[j]);
	    end
	end else begin // single transfer rate
	    #1; // task may be at posedge C already, but data output actually starts on next posedge
	    //for (j=1; j<=4*n; j=j+1) begin
	    for (j=1; j<=n; j=j+1) begin
		`ifdef HOLD_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.HOLD_DQ3; // use Testbench.DQ1 b/c local DQ1 only shows what task is driving (highZ)
		`endif
		`ifdef RESET_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[7] = Testbench.RESET_DQ3;
		`endif
						temp_read_byte[6] = Testbench.Vpp_W_DQ2;
						temp_read_byte[5] = Testbench.DQ1;
						temp_read_byte[4] = Testbench.DQ0;
		`ifdef HOLD_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[3] = Testbench.HOLD_DQ3;
		`endif
		`ifdef RESET_pin
		@(negedge ck_gen.C) #(tCLQV+1);	temp_read_byte[3] = Testbench.RESET_DQ3;
		`endif
						temp_read_byte[2] = Testbench.Vpp_W_DQ2;
						temp_read_byte[1] = Testbench.DQ1;
						temp_read_byte[0] = Testbench.DQ0;
		sampled_read_byte = temp_read_byte;
		`ifdef PRINT_ALL_DATA
		$display("QIO Read out byte at time %t is %2h", $time, sampled_read_byte);
		`endif
        checkData(sampled_read_byte, expVal[j]);
	    end
	end
    end
    join

    endtask




    // shall be used in a sequence including send command
    // and close communication tasks
    
    task add_clock_cycle;

    input integer n;
    integer i;

        for(i=1; i<=n; i=i+1) #T;

    endtask







    task close_comm;

    begin
        S = 1;
        clock_active = 0;
        # T;
        # 100;

    end
    endtask





    //------------------
    // others tasks
    //------------------


    `ifdef HOLD_pin
    task set_HOLD;
    input value;
        HOLD_DQ3 = value;
    endtask
    `endif


    task set_clock;
    input value;
        clock_active = value;
    endtask 


    task set_S;
    input value;
        S = value;
    endtask
    

    task setVcc;
    input [`VoltageRange] value;
        Vcc = value;
    endtask


    task Vcc_waveform;
    input [`VoltageRange] V1; input time t1;
    input [`VoltageRange] V2; input time t2;
    input [`VoltageRange] V3; input time t3;
    begin
      Vcc=V1; #t1;
      Vcc=V2; #t2;
      Vcc=V3; #t3;
    end
    endtask

    task Reset_by_Vcc;
        begin
            $display("\n---- RESET by Vcc Toggle ----\n");
            Vcc = 'd3000;
            Vcc = 'd0000;
            #100;
            Vcc = 'd3000;
            #3000;
        end
    endtask //Reset_by_Vcc


    task set_Vpp_W;
    input value;
        Vpp_W_DQ2 = value;
    endtask



    `ifdef RESET_pin
    
    task set_RESET;
    input value;
        RESET_DQ3 = value;
    endtask

    task RESET_pulse;
    begin
        RESET_DQ3 = 0;
        #100;
        RESET_DQ3 = 1;
    end
    endtask
    
    `endif
    

    task dtr_mode_select;
    input on_off;
        DoubleTransferRate = on_off;
    endtask



    task addr_4byte_select;
    input on_off;
        four_byte_address_mode = on_off;
    endtask



    //------------------------------------------
    // Tasks to send complete command sequences
    //------------------------------------------


    task write_enable;
    begin
        send_command('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task write_enable_dual;
    begin
        send_command_dual('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task write_enable_quad;
    begin
        send_command_quad('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

`ifdef byte_4
    task unlock_sector_3byte_address;

    input [addrDim-2:0] A;

    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_3byte_address(A);
        tasks.send_data('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_dual_3byte_address;

    input [addrDim-2:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_dual;
        tasks.send_command_dual('hE5);
        tasks.send_3byte_address_dual(A);
        tasks.send_data_dual('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_quad_3byte_address;

     input [addrDim-2:0] A; 
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_quad;
        tasks.send_command_quad('hE5);
        tasks.send_3byte_address_quad(A);
        tasks.send_data_quad('h00);
        tasks.close_comm;
        #100;
    end 
    endtask



`else

      task unlock_sector;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_address(A);
        tasks.send_data('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_dual;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_dual;
        tasks.send_command_dual('hE5);
        tasks.send_address_dual(A);
        tasks.send_data_dual('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_quad;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_quad;
        tasks.send_command_quad('hE5);
        tasks.send_address_quad(A);
        tasks.send_data_quad('h00);
        tasks.close_comm;
        #100;
    end 
    endtask


`endif

//--------------------------------------------------------------------
//
// encapsulated sequences
//
//--------------------------------------------------------------------

reg qioIsActive = `OFF;
reg dioIsActive = `OFF;

reg [1:0] ioProtocol = 'b00; 
reg [4:0] dummyVCR = 5'h00; //uppermost bit indicate that CMD_WRVCR was called
event checkDataError;
integer errorCount = 0;
//assign ioProtocol = {qioIsActive,dioIsActive};

 
// -------------------------------------------------------------------
// task name: write_enable_i
// description: intelligent write enable task
// inputs: NA
// -------------------------------------------------------------------
task write_enable_i; 
    begin
        $display("\n --- Write Enable --- \n");
        send_command_i(`CMD_WREN);
        close_comm;
        #100;
    end
endtask //write_enable_i

// -------------------------------------------------------------------
// task name: write_disable_i
// description: intelligent write disable task
// inputs: NA
// -------------------------------------------------------------------
task write_disable_i; 
    begin
        $display("\n --- Write Disable --- \n");
        send_command_i(`CMD_WRDI);
        close_comm;
        #100;
    end
endtask //write_disable_i

// -------------------------------------------------------------------
// task name: send_command_i
// description: send command, check ioProtocol if sending will be done
//              single, dual, or quad
// inputs: cmd - 8 bit command
//
// -------------------------------------------------------------------
task send_command_i;
    input [cmdDim-1:0] cmd;
    begin
        case(ioProtocol)
            `SIO: send_command(cmd);
            `DIO: send_command_dual(cmd);
            `QIO: send_command_quad(cmd);
            default: send_command(cmd);
        endcase
    end
endtask

// -------------------------------------------------------------------
// task name: reInitialize_memory
// description: a 'utility' task that can be used
//              to re-initialize memory with the content of .vmf file
// inputs: NA
// -------------------------------------------------------------------
task reInitialize_memory;
    begin
        `ifdef Stack512Mb
            $display("\n\n --- Reinitializing Array for die0 ---");
            DUT.N25Q_die0.mem.refillMem;
            $display("\n\n --- Reinitializing Array for die1 ---");
            DUT.N25Q_die1.mem.refillMem;
        `elsif STACKED_MEDT_1G
            $display("\n\n --- Reinitializing Array for die0 ---");
            DUT.MT25Q_die0.mem.refillMem;
            $display("\n\n --- Reinitializing Array for die1 ---");
            DUT.MT25Q_die1.mem.refillMem;
        `elsif STACKED_MEDT_2G
            $display("\n\n --- Reinitializing Array for die0 ---");
            DUT.MT25Q_die0.mem.refillMem;
            $display("\n\n --- Reinitializing Array for die1 ---");
            DUT.MT25Q_die1.mem.refillMem;
            $display("\n\n --- Reinitializing Array for die2 ---");
            DUT.MT25Q_die2.mem.refillMem;
            $display("\n\n --- Reinitializing Array for die3 ---");
            DUT.MT25Q_die3.mem.refillMem;
        `else
            //$display("\n\n --- Reinitializing Array ---");
            //DUT.mem.refillMem;
        `endif
    end
endtask //reInitialize_memory

// -------------------------------------------------------------------
// task name: send_addr
// description:  
// inputs: addr --  address in hex
// -------------------------------------------------------------------
task send_addr;
    `ifdef byte_4
    input [addrDimLatch4-1:0] addr;
    `elsif MEDT_MSE
    input [addrDimLatch4-1:0] addr;
    `else
    input [addrDimLatch-1:0] addr;
    `endif
    begin
        if(four_byte_address_mode == 1)
            tasks.send_3byte_address_(addr);
        else
            tasks.send_3byte_address(addr);
    end
endtask //send_addr

// -------------------------------------------------------------------
// task name: send_addr_dual
// description:  
// inputs: addr --  address in hex
// -------------------------------------------------------------------
task send_addr_dual;
    `ifdef byte_4
    input [addrDimLatch4-1:0] addr;
    `elsif MEDT_MSE
    input [addrDimLatch4-1:0] addr;
    `else
    input [addrDimLatch-1:0] addr;
    `endif
    begin
        if(four_byte_address_mode == 1)
            tasks.send_3byte_address_dual_(addr);
        else
            tasks.send_3byte_address_dual(addr);
    end
endtask //send_addr_dual

// -------------------------------------------------------------------
// task name: send_addr_quad
// description:  
// inputs: addr --  address in hex
// -------------------------------------------------------------------
task send_addr_quad;
    `ifdef byte_4
    input [addrDimLatch4-1:0] addr;
    `elsif MEDT_MSE
    input [addrDimLatch4-1:0] addr;
    `else
    input [addrDimLatch-1:0] addr;
    `endif
    begin
        if(four_byte_address_mode == 1)
            tasks.send_3byte_address_quad_(addr);
        else
            tasks.send_3byte_address_quad(addr);
    end
endtask //send_addr_quad

// -------------------------------------------------------------------
// task name: enter_4_byte
// description: stimulus to configure BFM for 4 byte address mode 
// inputs: NA
// tasks called:
//      write_enable_i
//      send_command_i
//      addr_4byte_select
//      close_comm
// how to call:
// -------------------------------------------------------------------
task enter_4_byte;
    begin
        $display("\n ---- Enter 4 Byte Address Mode ----\n");
        tasks.write_enable_i;
        tasks.send_command_i(`CMD_EN4BYTE);
        tasks.addr_4byte_select(`ON); //on
        tasks.close_comm;
    end
endtask //enter_4_byte

// -------------------------------------------------------------------
// task name: exit_4_byte
// description: stimulus to exit 4 byte mode
// inputs: NA
// tasks called:
//      write_enable_i
//      send_command_i
//      addr_4byte_select
//      close_comm
// how to call:
// -------------------------------------------------------------------
task exit_4_byte;
    begin
        $display("\n ---- Exit 4 Byte Address Mode ----\n");
        tasks.write_enable_i;
        tasks.send_command_i('hE9);
        tasks.addr_4byte_select(`OFF); 
        tasks.close_comm;
    end
endtask //exit_4_byte

task read_array;
    `ifdef byte_4
    input [addrDimLatch4-1:0] addr;
    `else
    input [addrDimLatch-1:0] addr;
    `endif
    input integer n;
    begin
        $display("\n --- Read Array ---");
        tasks.send_command(`CMD_READ);
        tasks.send_addr(addr);
        tasks.read_i(n);
        tasks.close_comm;
    end
endtask //read_array

task read_i; //intelligent read
    input integer n;
    begin
        case(ioProtocol)
            `SIO: read(n);
            `DIO: read_dual(n);
            `QIO: read_quad(n);
        endcase
    end
endtask //read_i


// -------------------------------------------------------------------
// task name: send_data_pattern
// description:
// inputs:
//      n - number of data to send
//      start_data - value of the starting data
//      data_pattern_type -
//          linear - increment by i the value of start_data
//          toggle - invert start_data value
//          1b - single byte
//          2b - 2 byte data
//          8b - 8 byte data
//      sdq - single, dual, or quad
// tasks called:
//      send_data, send_data_dual, send_data_quad
//
// how to call:
//      send_data_pattern(n,start_data,data_pattern_type,sdq)
// -------------------------------------------------------------------
task send_data_pattern;
    input integer n;
    input [8*dataDim-1:0] start_data;
    input [8*dataDim-1:0] data_pattern_type;
    input integer sdq; //single, dual, quad
    integer i;
    reg [dataDim-1:0] tempData;
    begin
        case(data_pattern_type)
            //increment data from start_data until start_data+n
            "linear": begin
                        for (i=0; i<=n; i=i+1)
                            case(sdq)
                                1: tasks.send_data(start_data[7:0]+i);
                                2: tasks.send_data_dual(start_data[7:0]+i);
                                4: tasks.send_data_quad(start_data[7:0]+i);
                            endcase
                      end //linear
            "toggle": begin          
                        tempData = start_data[7:0];
                        for (i=0; i<=n; i=i+1)
                            begin
                                case(sdq)
                                    1: tasks.send_data(tempData[7:0]);
                                    2: tasks.send_data_dual(tempData[7:0]);
                                    4: tasks.send_data_quad(tempData[7:0]);
                                endcase
                                tempData = ~tempData;
                            end
                      end //toggle
                "1b": begin          
                        for (i=0; i<=n; i=i+1)
                            case(sdq)
                                1: tasks.send_data(start_data[7:0]);
                                2: tasks.send_data_dual(start_data[7:0]);
                                4: tasks.send_data_quad(start_data[7:0]);
                            endcase
                        fillExpVal(start_data[15:0]);
                      end //1b
                "2b": begin          
                        for (i=0; i<=n; i=i+1)
                            case(sdq)
                                1: begin
                                       tasks.send_data(start_data[7:0]);
                                       tasks.send_data(start_data[15:8]);
                                   end
                                2: begin
                                       tasks.send_data_dual(start_data[7:0]);
                                       tasks.send_data_dual(start_data[15:8]);
                                   end
                                4: begin
                                       tasks.send_data_quad(start_data[7:0]);
                                       tasks.send_data_quad(start_data[15:8]);
                                   end
                            endcase
                        fillExpVal(start_data[15:0]);
                      end //2b
                "8b": begin          
                        for (i=0; i<=n; i=i+1)
                            case(sdq)
                                1: begin
                                       tasks.send_data(start_data[7:0]);
                                       tasks.send_data(start_data[15:8]);
                                       tasks.send_data(start_data[23:16]);
                                       tasks.send_data(start_data[31:24]);
                                       tasks.send_data(start_data[39:32]);
                                       tasks.send_data(start_data[47:40]);
                                       tasks.send_data(start_data[55:48]);
                                       tasks.send_data(start_data[63:56]);
                                   end
                                2: begin
                                       tasks.send_data_dual(start_data[7:0]);
                                       tasks.send_data_dual(start_data[15:8]);
                                       tasks.send_data_dual(start_data[23:16]);
                                       tasks.send_data_dual(start_data[31:24]);
                                       tasks.send_data_dual(start_data[39:32]);
                                       tasks.send_data_dual(start_data[47:40]);
                                       tasks.send_data_dual(start_data[55:48]);
                                       tasks.send_data_dual(start_data[63:56]);
                                   end
                                4: begin
                                       tasks.send_data_quad(start_data[7:0]);
                                       tasks.send_data_quad(start_data[15:8]);
                                       tasks.send_data_quad(start_data[23:16]);
                                       tasks.send_data_quad(start_data[31:24]);
                                       tasks.send_data_quad(start_data[39:32]);
                                       tasks.send_data_quad(start_data[47:40]);
                                       tasks.send_data_quad(start_data[55:48]);
                                       tasks.send_data_quad(start_data[63:56]);
                                   end
                            endcase
                        fillExpVal(start_data[63:0]);
                      end //8b
        endcase              
    end
endtask //send_data_pattern
    
//encapsulated sequences -end-

//encapsulated sequences upgrade -start-

// -------------------------------------------------------------------
// task name: read_array_
// description:
// inputs:
//      cmd  - 8bit opcode
//      addr - 32bit address
//      n    - number of bytes to read
//
// tasks called:
//      seqr
//      addr_4byte_select
//      sendError
// 
// how to call:
//      read_array_(cmd,addr,n,startData,dpt,completeWrite);
// -------------------------------------------------------------------
task read_array_;
    input [cmdDim-1:0] cmd;
    input [addrDimLatch4-1:0] addr;
    input integer n;
    begin
        case(cmd)
            `CMD_READ:  begin
                            $display("\n --- Read Array CMD_READ %0h---\n",`CMD_READ);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                        end //CMD_READ
       `CMD_FAST_READ:  begin
                            $display("\n --- Read Array CMD_FAST_READ %0h---\n",`CMD_FAST_READ);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_FAST_READ
            `CMD_DOFR:  begin            
                            $display("\n --- Read Array CMD_DOFR %0h---\n",`CMD_DOFR);
                            case(ioProtocol)
                                `SIO: seqr(1,1,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                        end //CMD_DOFR
           `CMD_DIOFR:  begin            
                            $display("\n --- Read Array CMD_DIOFR %0h---\n",`CMD_DIOFR);
                            case(ioProtocol)
                                `SIO: seqr(1,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                        end //CMD_DIOFR
            `CMD_QOFR:  begin            
                            $display("\n --- Read Array CMD_QOFR %0h---\n",`CMD_QOFR);
                            case(ioProtocol)
                                `SIO: seqr(1,1,4,"r",8,0,10,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",8,0,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_QOFR
           `CMD_QIOFR:  begin            
                            $display("\n --- Read Array CMD_QIOFR %0h---\n",`CMD_QIOFR);
                            case(ioProtocol)
                                `SIO: seqr(1,4,4,"r",10,0,10,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",10,0,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_QIOFR
         `CMD_4READ4D:  begin            
                            $display("\n --- Read Array CMD_4READ4D %0h---\n",`CMD_4READ4D);
                            case(ioProtocol)
                                `SIO: seqr(1,4,4,"r",4,0,4,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",4,0,4,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_QIOWR
       `CMD_READ4BYTE:  begin
                            $display("\n --- Read Array CMD_READ4BYTE %0h---\n",`CMD_READ4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_READ4BYTE
  `CMD_FAST_READ4BYTE:  begin
                            $display("\n --- Read Array CMD_FAST_READ4BYTE %0h---\n",`CMD_FAST_READ4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",8,8,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_FAST_READ4BYTE
       `CMD_DOFR4BYTE:  begin
                            $display("\n --- Read Array CMD_DOFR4BYTE %0h---\n",`CMD_DOFR4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,1,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_DOFR4BYTE
      `CMD_DIOFR4BYTE:  begin
                            $display("\n --- Read Array CMD_DIOFR4BYTE %0h---\n",`CMD_DIOFR4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_DIOFR4BYTE
       `CMD_QOFR4BYTE:  begin
                            $display("\n --- Read Array CMD_QOFR4BYTE %0h---\n",`CMD_QOFR4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,1,4,"r",8,0,10,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",8,0,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_QOFR4BYTE
      `CMD_QIOFR4BYTE:  begin
                            $display("\n --- Read Array CMD_QIOFR4BYTE %0h---\n",`CMD_QIOFR4BYTE);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,4,4,"r",10,0,10,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",10,0,10,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_QIOFR4BYTE
    `CMD_FAST_READDTR:  begin
                            $display("\n --- Read Array CMD_FAST_READDTR %0h---\n",`CMD_FAST_READDTR);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_FAST_READDTR
         `CMD_DOFRDTR:  begin            
                            $display("\n --- Read Array CMD_DOFRDTR %0h---\n",`CMD_DOFRDTR);
                            case(ioProtocol)
                                `SIO: seqr(1,1,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                        end //CMD_DOFRDTR
        `CMD_DIOFRDTR:  begin            
                            $display("\n --- Read Array CMD_DIOFRDTR %0h---\n",`CMD_DIOFRDTR);
                            case(ioProtocol)
                                `SIO: seqr(1,2,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                        end //CMD_DIOFRDTR
         `CMD_QOFRDTR:  begin            
                            $display("\n --- Read Array CMD_QOFRDTR %0h---\n",`CMD_QOFRDTR);
                            case(ioProtocol)
                                `SIO: seqr(1,1,4,"r",6,0,8,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",6,0,8,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_QOFRDTR
        `CMD_QIOFRDTR:  begin            
                            $display("\n --- Read Array CMD_QIOFRDTR %0h---\n",`CMD_QIOFRDTR);
                            case(ioProtocol)
                                `SIO: seqr(1,4,4,"r",8,0,8,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",8,0,8,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                        end //CMD_QIOFRDTR
`CMD_FAST_READ4BYTEDTR: begin
                            $display("\n --- Read Array CMD_FAST_READ4BYTEDTR %0h---\n",`CMD_FAST_READ4BYTEDTR);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",6,6,8,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_FAST_READ4BYTEDTR
   `CMD_DIOFR4BYTEDTR:  begin            
                            $display("\n --- Read Array CMD_DIOFR4BYTEDTR %0h---\n",`CMD_DIOFR4BYTEDTR);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,2,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",6,6,0,cmd,addr,n,`_,`_,`_);
                                `QIO: notSupported();
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_DIOFR4BYTEDTR
   `CMD_QIOFR4BYTEDTR:  begin            
                            $display("\n --- Read Array CMD_QIOFR4BYTEDTR %0h---\n",`CMD_QIOFR4BYTEDTR);
                            addr_4byte_select(`ON); 
                            case(ioProtocol)
                                `SIO: seqr(1,4,4,"r",8,0,8,cmd,addr,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: seqr(4,4,4,"r",8,0,8,cmd,addr,n,`_,`_,`_);
                                default:tasks.sendError;
                            endcase
                            addr_4byte_select(`OFF); 
                        end //CMD_QIOFR4BYTEDTR
        endcase //cmd
    end
endtask //read_array_

// -------------------------------------------------------------------
// task name: seqr
// description: stimulus 'sequencer'
//              The task consist of 5 portions. command, address,
//              dummy, data, dpt, and delay.
// inputs:
//      sCmd     - send command
//      sAddr    - send address
//      Data     - receive/write data
//              **sCmd, sAddr, Data can take the value of 0,1,2,4
//              **4 (quad), 2 (dual), 1 (extended), 0 (not supported
//              **thus don't execute. ex. if sCmd = 4, send the 
//              **opcode in cmd input by quad.          
//      mode     - 'r'(incoming), 'w'(outgoing), '`_'(none)
//      sioDummy - default dummy count for extended
//      dioDummy - default dummy count for dual IO
//      qioDummy - default dummy count for quad IO
//      cmd      - 8-bit opcode
//      addr     - 32 bit address
//      n        - for writes, n is the number of data to be written
//               - for reads, n is the number of data reads
//      start_data -start data value (8bits) for writes else `_
//      dpt      - data pattern type (linear, toggle)
//      nDelay   - delay value (time) for writes and erase else 0
//
// how to call:
//  seqr(sCmd,sAddr,Data,mode,sioDummy,dioDummy,qioDummy,cmd,addr,n,startData,dpt,nDelay);
// -------------------------------------------------------------------
task seqr; //sequencer
    input integer sCmd;     
    input integer sAddr;    
    input integer sData;    
    input [dataDim-1:0]   mode;     
    input integer sioDummy; 
    input integer dioDummy; 
    input integer qioDummy; 
    input [cmdDim-1:0] cmd; 
    input [addrDimLatch4-1:0] addr;    
    input integer n;        
    input [8*dataDim-1:0] start_data; 
    input [8*dataDim-1:0] dpt; //Data pattern type
    input time nDelay; 
    integer sioD; //SIO Dummy
    integer dioD; //DIO Dummy
    integer qioD; //QIO Dummy
    begin
        //Command portion of  sequence
        if(sCmd == 1)
            send_command(cmd);
        else if (sCmd == 2)
            send_command_dual(cmd);
        else if (sCmd == 4)
            send_command_quad(cmd);
    
        if(cmd == `CMD_FAST_READDTR || 
           cmd == `CMD_DOFRDTR ||
           cmd == `CMD_DIOFRDTR ||
           cmd == `CMD_QOFRDTR ||
           cmd == `CMD_QIOFRDTR ||
           cmd == `CMD_FAST_READ4BYTEDTR || 
           cmd == `CMD_DIOFR4BYTEDTR ||
           cmd == `CMD_QIOFR4BYTEDTR)
            dtr_mode_select(`ON);

        //Address portion of sequence
        if(sAddr == 1)
            tasks.send_addr(addr);
        else if (sAddr == 2)
            tasks.send_addr_dual(addr);
        else if (sAddr == 4)
            tasks.send_addr_quad(addr);

        //check if CMD_VCR was invoked
        //if yes, we use dummy setting in
        //VCR[7:4]
        if(dummyVCR[4] == `ON)
            begin
                sioD = dummyVCR[3:0];
                dioD = dummyVCR[3:0];
                qioD = dummyVCR[3:0];
            end
        else
            begin
                sioD = sioDummy;
                dioD = dioDummy;
                qioD = qioDummy;
            end

        //Dummy portion of sequence    
        case(sCmd)
            1: begin
                    if(sioDummy != 0)
                        send_dummy('h00,sioD);
               end     
            2: begin   
                    if(dioDummy != 0)
                        send_dummy_dual('h00,dioD);
               end
            4: begin
                    if(qioDummy != 0)
                        send_dummy_quad('h00,qioD);
               end
        endcase       
        
        //Data portion of sequence        
        if(mode == "r")
            begin
                if(sData == 1)
                    read(n);
                else if (sData == 2)
                    read_dual(n);
                else if (sData == 4)
                    read_quad(n);
            end
        else if( mode == "w")
            begin
                send_data_pattern(n,start_data,dpt,sData);
            end
        close_comm;

        if(cmd == `CMD_FAST_READDTR ||
           cmd == `CMD_DOFRDTR ||
           cmd == `CMD_DIOFRDTR ||
           cmd == `CMD_QOFRDTR ||
           cmd == `CMD_QIOFRDTR ||
           cmd == `CMD_FAST_READ4BYTEDTR || 
           cmd == `CMD_DIOFR4BYTEDTR ||
           cmd == `CMD_QIOFR4BYTEDTR)
            dtr_mode_select(`OFF);

        //Delay portion
        if(nDelay != 0)
            #(nDelay+100);

        `ifdef HOLD_pin
            release DUT.HOLD_DQ3;
        `endif
        `ifdef RESET_pin
            release DUT.RESET_DQ3;
        `endif
            release DUT.Vpp_W_DQ2;
            release DUT.DQ1;
            release DUT.DQ0;


    end
endtask //seqr

// -------------------------------------------------------------------
// task name: seqrEFI
// description:
// inputs:
// how to call:
// -------------------------------------------------------------------
task seqrEFI;
    input integer sCmd;     
    input integer sAddr;    
    input [cmdDim-1:0] opcode1; 
    input [cmdDim-1:0] opcode2;
    input [cmdDim-1:0] attr;   //attribute
    input [addrDimLatch4-1:0] start_addr;    
    input [addrDimLatch4-1:0] stop_addr;    
    input time nDelay; 
    reg   [addrDimLatch4-1:0] start_addr_temp;
    reg   [addrDimLatch4-1:0] stop_addr_temp;
    
    begin
        //Command portion of  sequence
        if(sCmd == 1) begin
            send_command(opcode1);
            send_command(opcode2);
            #(T/4);
            send_command(attr);
        end else if (sCmd == 2) begin
            send_command_dual(opcode1);
            send_command_dual(opcode2);
            #(T/4);
            send_command_dual(attr);
        end else if (sCmd == 4) begin
            send_command_quad(opcode1);
            send_command_quad(opcode2);
            send_command_quad2(attr);
        end
        
        if(attr != 'hFF) begin
            //Address portion of sequence
            addr_4byte_select(`ON);
            
            //FE = LSB first
            if (attr == 'hFE) begin
                start_addr_temp[31:24] = start_addr[7:0];
                start_addr_temp[23:16] = start_addr[15:8];
                start_addr_temp[15:8]  = start_addr[23:16];
                start_addr_temp[7:0]   = start_addr[31:24];
                stop_addr_temp[31:24]  = stop_addr[7:0];
                stop_addr_temp[23:16]  = stop_addr[15:8];
                stop_addr_temp[15:8]   = stop_addr[23:16];
                stop_addr_temp[7:0]    = stop_addr[31:24];
            //FC = MSB first
            end else if (attr == 'hFC) begin
                start_addr_temp = start_addr;
                stop_addr_temp  = stop_addr;
            end

            if(sAddr == 1) begin
                #(T/4);
                tasks.send_addr(start_addr_temp);
                tasks.send_addr(stop_addr_temp);
            end else if (sAddr == 2) begin
                #(T/4);
                tasks.send_addr_dual(start_addr_temp);
                tasks.send_addr_dual(stop_addr_temp);
            end else if (sAddr == 4) begin
                tasks.send_addr_quad(start_addr_temp);
                tasks.send_addr_quad(stop_addr_temp);
            end

            addr_4byte_select(`OFF);
        end

        close_comm; //pulls S# high 

        //Delay portion
        if(nDelay != 0)
            #(nDelay+100);
    end
endtask //seqrEFI

// -------------------------------------------------------------------
// task name: erase_array
// description: 
// inputs:
//      cmd  - 8bit opcode
//      addr - 32bit address
//      completeErase - 0|1
//                    - 0 -> sequence will be driven until assertion
//                           of S#, no delay is provided thus the sim
//                           will not proceed, allowing the insertion
//                           of SR/FSR reads for polling. (or other
//                           commands ex. PES)
//                    - 1 -> erase will complete.
// how to call:
//      erase_array(cmd,addr,completeErase)
// -------------------------------------------------------------------
task erase_array;
    input [cmdDim-1:0] cmd;
    input [addrDimLatch4-1:0] addr;
    input completeErase;
    time delay;
    begin
        write_enable_i;
        $display("\n --- Erase Array ---\n");
        case(cmd)
            `CMD_SSE32K: begin
                            delay = (completeErase) ? t32SSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                         end //CMD_SSE32K
               `CMD_SSE: begin
                            delay = (completeErase) ? tSSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                         end //CMD_SSE
                `CMD_SE: begin
                            delay = (completeErase) ? tSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                         end //CMD_SE
                `CMD_BE: begin
                            delay = (completeErase) ? tBE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                         end //CMD_BE
             `CMD_DIEER: begin
                            delay = (completeErase) ? tDE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                         end //CMD_DIEER
           `CMD_SE4BYTE: begin
                            addr_4byte_select(`ON); 
                            delay = (completeErase) ? tSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                            addr_4byte_select(`OFF); 
                         end //CMD_SE4BYTE
          `CMD_SSE4BYTE: begin
                            addr_4byte_select(`ON); 
                            delay = (completeErase) ? tSSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                            addr_4byte_select(`OFF); 
                         end //CMD_SSE4BYTE
       `CMD_SSE32K4BYTE: begin
                            addr_4byte_select(`ON); 
                            delay = (completeErase) ? tSSE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `DIO: seqr(2,2,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                `QIO: seqr(4,4,0,`_,0,0,0,cmd,addr,`_,`_,`_,delay);
                                default: sendError();
                            endcase
                            addr_4byte_select(`OFF); 
                         end //CMD_SSE4BYTE
        endcase
    end
endtask //erase_array

task EFI_ops;
    input [cmdDim-1:0] opcode1;
    input [cmdDim-1:0] opcode2;
    input [cmdDim-1:0] attr;
    input [addrDimLatch4-1:0] start_addr;    
    input [addrDimLatch4-1:0] stop_addr;    
    input completeCommand;
    time delay; 
    begin
        if(opcode1 == `CMD_MSE_OP1) begin
            case(opcode2)
               `CMD_MSE_OP2: begin //multi-sector erase
                                delay = (completeCommand) ? tSE : 0;
                                case(ioProtocol)
                                    `SIO: seqrEFI(1,1,opcode1,opcode2,attr,start_addr,stop_addr,delay);
                                    `DIO: seqrEFI(2,2,opcode1,opcode2,attr,start_addr,stop_addr,delay);
                                    `QIO: seqrEFI(4,4,opcode1,opcode2,attr,start_addr,stop_addr,delay);
                                    default: sendError();
                                endcase
                             end
            endcase
        end else begin
            $display("\n [ERROR:stim]\n");
        end
    end
endtask //EFI_ops

task TDP_ops;
    input [cmdDim-1:0] opcode;
    input [cmdDim-1:0] attr;
    input integer n;
    input [8*dataDim-1:0] start_data;
    input [8*dataDim-1:0] dpt;//data_pattern_type;
    //input [127:0] patterns;
    begin
        if(opcode == `CMD_TDP) begin
            case(ioProtocol)
                `SIO: seqrTDP(1,1,opcode,attr,n,start_data,dpt);
                `DIO: seqrTDP(2,2,opcode,attr,n,start_data,dpt);
                `QIO: seqrTDP(4,4,opcode,attr,n,start_data,dpt);
                default: sendError();
            endcase
        end
    end
endtask //TDP_ops

task seqrTDP;
    input integer sCmd;
    input integer sData;
    input [cmdDim-1:0] opcode;
    input [cmdDim-1:0] attr;
    input integer n;
    input [8*dataDim-1:0] start_data;
    input [8*dataDim-1:0] dpt;//data_pattern_type;
    begin
        //Command portion of  sequence
        if(sCmd == 1) begin
            send_command(opcode);
            double_command = 1;
            send_command(attr);
        end else if (sCmd == 2) begin
            send_command_dual(opcode);
            double_command = 1;
            send_command_dual(attr);
        end else if (sCmd == 4) begin
            send_command_quad(opcode);
            double_command = 1;
            send_command_quad2(attr);
        end

        case(attr[7:6])
            'b00: begin //read
                    if(sData==1) begin
                        case(attr[5:4])
                            'b00: read(n); //SPI x1
                            'b01: read_dual(n); //SPI dual input/output
                            'b10: read_quad(n); //SPI quad input/output
                            'b11: read_quad(n); //Reserved same as 10
                            default: $display(); 
                        endcase
                    end else if(sData == 2) begin
                        read_dual(n);
                    end else if(sData == 4) begin
                        read_quad(n);
                    end
                  end
            'b01: begin //program
                    case(attr[5:4])
                        'b00: send_data_pattern(n,start_data,dpt,1);
                        'b01: send_data_pattern(n,start_data,dpt,2);
                        'b10: send_data_pattern(n,start_data,dpt,4);
                        'b11: send_data_pattern(n,start_data,dpt,4);
                        default: $display(); 
                    endcase
                    $display("[INFO] TDP program\n");
                  end
            'b10: begin //erase
                    $display("[INFO] TDP erase\n");
                  end
            default: begin //Reserved
                     end
        endcase //att[7:6]             

        close_comm;
    
        `ifdef HOLD_pin
            release DUT.HOLD_DQ3;
        `endif
        `ifdef RESET_pin
            release DUT.RESET_DQ3;
        `endif
            release DUT.Vpp_W_DQ2;
            release DUT.DQ1;
            release DUT.DQ0;
    end
endtask //seqrTDP

// -------------------------------------------------------------------
// task name: write_array
// description: 
// inputs:
//      cmd  - 8bit opcode
//      addr - 32bit address
//      n    - number of bytes to write
//      startData - starting address value
//      dpt  - data patern type (linear, toggle)
//      completeWrite - `ON|`OFF (0|1)
//                    - 0 -> sequence will be driven until assertion
//                           of S#, no delay is provided thus the sim
//                           will not proceed, allowing the insertion
//                           of SR/FSR reads for polling. (or other
//                           commands ex. PES)
//                    - 1 -> erase will complete.
// tasks called: 
//      seqr
//      write_enable_i
//      addr_4byte_select
//
// how to call:
//      write_array(cmd,addr,n,startData,dpt,completeWrite);
// 
// -------------------------------------------------------------------
task write_array;
    input [cmdDim-1:0] cmd;
    input [addrDimLatch4-1:0] addr;
    input integer n;
    input [2*dataDim-1:0] startData;
    input [8*dataDim-1:0] dpt; //data pattern type
    input completeWrite;
    time delay;
    begin
        $display("\n --- Write Array ---\n");
        delay = (completeWrite) ? tPP : 0;
        case(cmd)
            `CMD_PP: begin
                        case(ioProtocol)
                            `SIO: seqr(1,1,1,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                     end //CMD_PP
          `CMD_DIFP: begin
                        case(ioProtocol)
                            `SIO: seqr(1,1,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `QIO: notSupported();
                            default: sendError(); 
                        endcase
                     end //CMD_DIFP
         `CMD_DIEFP: begin
                        case(ioProtocol)
                            `SIO: seqr(1,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `QIO: notSupported();
                            default: sendError(); 
                        endcase
                     end //CMD_DIEFP
          `CMD_QIFP: begin
                        case(ioProtocol)
                            `SIO: seqr(1,1,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: notSupported();
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                     end //CMD_QIFP
         `CMD_QIEFP: begin
                        case(ioProtocol)
                            `SIO: seqr(1,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: notSupported();
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                     end //CMD_QIEFP
       `CMD_PP4BYTE: begin
                        addr_4byte_select(`ON); 
                        case(ioProtocol)
                            `SIO: seqr(1,1,1,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                        addr_4byte_select(`OFF); 
                     end //CMD_PP4BYTE
     `CMD_QIFP4BYTE: begin
                        addr_4byte_select(`ON); 
                        case(ioProtocol)
                            `SIO: seqr(1,1,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: notSupported();
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                        addr_4byte_select(`OFF); 
                     end //CMD_QIFP4BYTE
    `CMD_QIEFP4BYTE: begin
                        addr_4byte_select(`ON); 
                        case(ioProtocol)
                            `SIO: seqr(1,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            `DIO: notSupported();
                            `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                            default: sendError(); 
                        endcase
                        addr_4byte_select(`OFF); 
                     end //CMD_QIEFP4BYTE
        endcase
    end
endtask //write_array

task read_nonarray;
    input [cmdDim-1:0] cmd;
    input integer n;
    begin
        $display("\n --- Read Non-Array ---\n");
        case(cmd)
            `CMD_RDSR,
            `CMD_RDFSR,
            `CMD_RDNVCR,
            `CMD_RDVCR,
            `CMD_RDVECR,
            `CMD_RDEAR:  begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,0,2,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,0,4,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                         end //CMD_(RDSR,RDFSR,RDNVCR,RDVCR,RDVECR,RDEAR)
            `CMD_RDSFDP: begin
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",8,8,8,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,8,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",8,8,8,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                         end //CMD_RDSFDP
             `CMD_RDID2: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: notSupported();
                                default: sendError(); 
                            endcase
                         end //CMD_RDID2
          `CMD_MIORDID1: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,0,2,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,0,4,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                         end //CMD_MIORDID1
          `CMD_MIORDID2: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,0,2,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,0,4,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase 
                         end //CMD_MIORDID2
        endcase
    end
endtask //read_nonarray

// -------------------------------------------------------------------
// task name: write_nonarray
// description: stimulus sequence driver for non-array write commands
//              ex. SR, FSR, NVCR, VCR, VECR, EAR. Also includes non
//              register commands ex. RSTEN, RSTMEM, EQIO, RSTQIO
// inputs:
//      cmd     - 8bit opcode/command
//      hiByte  - higher 8 bits of data
//      loByte  - lower 8 bits data
//      completeWrite - `ON|`OFF (0|1)
//                    - 0 -> sequence will be driven until assertion
//                           of S#, no delay is provided thus the sim
//                           will not proceed, allowing the insertion
//                           of SR/FSR reads for polling. (or other
//                           commands ex. PES)
//                    - 1 -> register write will complete.
// how to call:
//      write_nonarray(cmd, hiByte, loByte, completeWrite);
// example:
//      write_nonarray(`CMD_WREAR,`_,'hAA,`ON);
// -------------------------------------------------------------------
task write_nonarray;
    input [cmdDim-1:0] cmd;
    input [dataDim-1:0] hiByte;
    input [dataDim-1:0] loByte;
    input completeWrite;
    integer n;
    time delay;
    begin
        $display("\n --- Write Non-Array ---\n");
        delay = (completeWrite) ? tW : 0;
        case(cmd)
            `CMD_WRSR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             default: sendError(); 
                         endcase
                       end //CMD_WRSR
          `CMD_CLRFSR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,0,`_,0,0,0,cmd,`_,`_,`_,`_,delay);
                             `DIO: seqr(2,0,0,`_,0,0,0,cmd,`_,`_,`_,`_,delay);
                             `QIO: seqr(4,0,0,`_,0,0,0,cmd,`_,`_,`_,`_,delay);
                             default: sendError(); 
                         endcase
                       end //CMD_CLRFSR
          `CMD_WRNVCR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"2b",delay);
                             `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"2b",delay);
                             `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"2b",delay);
                             default: sendError(); 
                         endcase
                       end //CMD_WRNVCR
           `CMD_WRVCR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             default: sendError(); 
                         endcase
                       dummyVCR = {1'b1,loByte[7:4]};
                       end //CMD_WRVCR
          `CMD_WRVECR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             default: sendError(); 
                         endcase
                         if(loByte[7] == 0)
                            begin
                                ioProtocol = `QIO;
                                $display("\n ---Quad Mode--- \n");
                            end
                         else if(loByte[6] == 0)
                            begin
                                ioProtocol = `DIO;
                                $display("\n ---Dual Mode--- \n");
                            end
                         else 
                            begin
                                ioProtocol = `SIO;
                                $display("\n ---Single Mode--- \n");
                            end    
                       end //CMD_WRVECR
           `CMD_WREAR: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,0,{hiByte,loByte},"1b",delay);
                             default: sendError(); 
                         endcase
                       end //CMD_WREAR
            `CMD_EQIO: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `DIO: seqr(2,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `QIO: seqr(4,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             default: sendError(); 
                         endcase
                         ioProtocol =  `QIO;
                       end //CMD_EQIO
          `CMD_RSTQIO: begin
                         write_enable_i;
                         case(ioProtocol)
                             `SIO: seqr(1,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `DIO: seqr(2,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `QIO: seqr(4,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             default: sendError(); 
                         endcase
                         ioProtocol =  `SIO;
                         `ifdef HOLD_pin
                         set_HOLD('bz);
                        `endif
                       end //CMD_RSTQIO
           `CMD_RSTEN: begin
                         case(ioProtocol)
                             `SIO: seqr(1,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `DIO: seqr(2,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `QIO: seqr(4,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             default: sendError(); 
                         endcase
                       end //CMD_RSTEN
             `CMD_RST: begin
                         case(ioProtocol)
                             `SIO: seqr(1,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `DIO: seqr(2,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             `QIO: seqr(4,0,0,"w",0,0,0,cmd,`_,`_,`_,`_,delay);
                             default: sendError(); 
                         endcase
                         ioProtocol =  `SIO;
                         dummyVCR = 5'h00;
                       end //CMD_RST
        endcase
    end
endtask //write_nonarray

// -------------------------------------------------------------------
// task name: otp_ops
// description: driver sequences for 'One Time Programmable' cmds
// inputs:
//      cmd  - 8bit opcode/command
//      addr - 32bit address
//      n    - number of bytes to read (for read commands)
//      startData - 
//      dpt  - 'data pattern type' choices are:
//             linear, toggle, 1b, 2b, 8b 
//             (see send_data_pattern task for description)
//      completeWrite - can take value of `ON (1) or `OFF (0)
//                      this input tells the sequence to wait for the
//                      write command to finish. If `OFF, it won't wait
//                      thus we can insert RDSR or RDFSR                      
//
// how to call:
// asp_ops(cmd, addr, n, startData, dpt, completeWrite);
// ex. for reads
//      otp_ops(`CMD_ROTP,`_,69,`_,`_,`_);
// ex. for writes
//      otp_ops(`CMD_POTP,`_,0,'h55,"1b",`ON);
// -------------------------------------------------------------------
task otp_ops;
    input [cmdDim-1:0] cmd;
    input [addrDimLatch4-1:0] addr;
    input integer n;
    input [2*dataDim-1:0] startData;
    input [8*dataDim-1:0] dpt;
    input completeWrite;
    time delay;
    begin
        case(cmd)
            `CMD_ROTP: begin
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",8,8,10,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",8,8,10,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",8,8,10,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase 
                         end //CMD_ROTP
            `CMD_POTP: begin
                          delay = (completeWrite) ? tPOTP : 0;
                          case(ioProtocol)
                              `SIO: seqr(1,1,1,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                              `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                              `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                              default: sendError(); 
                          endcase
                       end //CMD_POTP
        endcase
    end
endtask //otp_ops

// -------------------------------------------------------------------
// task name: asp_ops
// description: driver sequences for 'advanced sector protection' cmds
// inputs:
//      cmd  - 8bit opcode/command
//      addr - 32bit address
//      n    - number of bytes to read (for read commands)
//      startData - 
//      dpt  - 'data pattern type' choices are:
//             linear, toggle, 1b, 2b, 8b 
//             (see send_data_pattern task for description)
//      completeWrite - can take value of `ON (1) or `OFF (0)
//                      this input tells the sequence to wait for the
//                      write command to finish. If `OFF, it won't wait
//                      thus we can insert RDSR or RDFSR                      
//
// how to call:
// asp_ops(cmd, addr, n, startData, dpt, completeWrite);
// ex. for reads
//      asp_ops(`CMD_ASPRD,`_,2,`_,`_,`_);
// ex. for writes
//      asp_ops(`CMD_ASPP,`_,0,'hFF55,"2b",`ON);
// -------------------------------------------------------------------
task asp_ops;
    input [cmdDim-1:0] cmd;
    input [addrDimLatch4-1:0] addr;
    input integer n;
    input [8*dataDim-1:0] startData;
    input [8*dataDim-1:0] dpt;
    input completeWrite;
    time delay;
    begin
        $display("\n --- Advanced Sector Protection Operations ---\n");
        case(cmd)
            `CMD_ASPRD: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: seqr(2,0,2,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `QIO: seqr(4,0,4,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                        end //CMD_ASPRD - Read (Advanced) Sector Protection
            `CMD_RDVLB: begin
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                        end //CMD_RDVLB - Read Volatile Lock Bit
       `CMD_RDVLB4BYTE: begin
                            addr_4byte_select(`ON);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                            addr_4byte_select(`OFF);
                        end //CMD_RDVLB4BYTE - Read Volatile Lock Bit 4 Byte
           `CMD_RDNVLB: begin
                            addr_4byte_select(`ON);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `DIO: seqr(2,2,2,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                `QIO: seqr(4,4,4,"r",0,0,0,cmd,addr,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                            addr_4byte_select(`OFF);
                        end //CMD_RDNVLB - Read Non-Volatile Lock Bit
            `CMD_RDGFB: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                `DIO: notSupported();
                                `QIO: notSupported();
                                default: sendError(); 
                            endcase
                        end //CMD_RDGFB - Read Global Freeze Bit
             `CMD_ASPP: begin
                            delay = (completeWrite) ? tWRASP : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_ASPP
            `CMD_WRVLB: begin
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_WRVLB
       `CMD_WRVLB4BYTE: begin
                            addr_4byte_select(`ON);
                            case(ioProtocol)
                                `SIO: seqr(1,1,1,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `DIO: seqr(2,2,2,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `QIO: seqr(4,4,4,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                            addr_4byte_select(`OFF);
                        end //CMD_WRVLB4BYTE
        `ifdef MEDT_PPB
           `CMD_WRNVLB: begin
                            delay = (completeWrite) ? tPPBP : 0;
                            addr_4byte_select(`ON);
                            case(ioProtocol)
                                `SIO: seqr(1,1,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `DIO: seqr(2,2,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `QIO: seqr(4,4,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                            addr_4byte_select(`OFF);
                        end //CMD_WRNVLB
            `CMD_ERNVLB: begin
                            delay = (completeWrite) ? tPPBE : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `DIO: seqr(2,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `QIO: seqr(4,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_ERNVLB
        `endif //MEDT_PPB
            `CMD_WRGFB: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `DIO: seqr(2,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                `QIO: seqr(4,0,0,"w",0,0,0,cmd,addr,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_WRGFB
           `CMD_PASSRD: begin
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"r",0,0,0,cmd,`_,n,`_,`_,`_);
                                default: sendError(); 
                            endcase
                        end //CMD_PASSRD - Read Password 
            `CMD_PASSP: begin
                            delay = (completeWrite) ? write_PASSP_delay : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_PASSP
            `CMD_PASSU: begin
                            delay = (completeWrite) ? write_PASSP_delay : 0;
                            case(ioProtocol)
                                `SIO: seqr(1,0,1,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `DIO: seqr(2,0,2,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                `QIO: seqr(4,0,4,"w",0,0,0,cmd,`_,n,startData,dpt,delay);
                                default: sendError(); 
                            endcase
                        end //CMD_PASSU
        endcase //cmd
    end
endtask //asp_ops


task sendError;
    begin
        $display("\n Error \n");
    end
endtask //sendError    

task notSupported;
    begin
        case (ioProtocol)
            `SIO: $display("[WARN] Command not supported in SIO mode\n");
            `DIO: $display("[WARN] Command not supported in DIO mode\n");
            `QIO: $display("[WARN] Command not supported in QIO mode\n");
        endcase
    end
endtask //notSupported

// -------------------------------------------------------------------
// task name: fillExpVal
// description: allows us to assign values to expVal array
// inputs:
// -------------------------------------------------------------------
task fillExpVal;
    input [128*dataDim-1:0] fill;
    integer i;
    begin
        for(i=1; i<=(113*dataDim-1);i=i+1)
            begin
                expVal[i] = fill[(((i-1)*8)+7)-:8];
            end
    end
endtask //fillExpVal
//encapsulated sequences upgrade -end-


endmodule 

