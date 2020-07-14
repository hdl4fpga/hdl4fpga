// SPI RW slave

// AUTHOR=EMARD
// LICENSE=BSD

// read with dummy byte which should be discarded

// write 00 <MSB_addr> <LSB_addr> <byte0> <byte1>
// read  01 <MSB_addr> <LSB_addr> <dummy_byte> <byte0> <byte1>

module spirw_slave_v
#(
  parameter c_addr_bits = 16,
  parameter c_sclk_capable_pin = 0 //, // 0-sclk is generic pin, 1-sclk is clock capable pin
)
(
  input  wire clk, // faster than SPI clock
  input  wire csn, sclk, mosi, // SPI lines to be sniffed
  inout  wire miso, // 3-state line, active when csn=0
  // BRAM interface
  output wire rd, wr,
  output wire [c_addr_bits-1:0] addr,
  input  wire [7:0] data_in,
  output wire [7:0] data_out
);
  reg [c_addr_bits:0] R_raddr;
  //reg [8-1:0] R_MISO;
  //reg [8-1:0] R_MOSI;
  reg [8-1:0] R_byte;
  reg R_request_read;
  reg R_request_write;
  localparam c_count_bits=$clog2(c_addr_bits+8)+1;
  reg [c_count_bits-1:0] R_bit_count;
  generate
    if(c_sclk_capable_pin)
    begin
      // sclk is clock capable pin
      always @(posedge sclk or posedge csn)
      begin
        if(csn)
        begin
          R_request_read <= 1'b0;
          R_request_write <= 1'b0;
          R_bit_count <= c_addr_bits+7; // 24 bits = 3 bytes to read cmd/addr, then data
        end
        else // csn == 0
          begin
            if(R_request_read)
              R_byte <= data_in;
            else
              R_byte <= { R_byte[8-2:0], mosi };
            if(R_bit_count[c_count_bits-1] == 1'b0) // first 3 bytes
            begin
              R_raddr <= { R_raddr[c_addr_bits-1:0], mosi };
              R_bit_count <= R_bit_count - 1;
            end
            else // after first 3 bytes
            begin
              if(R_bit_count[3:0] == 4'd7) // first bit in new byte, increment address from 5th SPI byte on
                R_raddr[c_addr_bits-1:0] <= R_raddr[c_addr_bits-1:0] + 1;
              if(R_bit_count[2:0] == 3'd1)
                R_request_read <= R_raddr[c_addr_bits];
              else
                R_request_read <= 1'b0;
              if(R_bit_count[2:0] == 3'd0) // last bit in byte
              begin
                if(R_raddr[c_addr_bits] == 1'b0)
                  R_request_write <= 1'b1; // write
                R_bit_count[3] <= 1'b0; // allow to inc address from 5th SPI byte on
              end
              else
                R_request_write <= 1'b0;
              R_bit_count[2:0] <= R_bit_count[2:0] - 1;
            end // after 1st 3 bytes
          end // csn = 0, rising sclk edge
      end // always
    end // generate
    else // sclk is not CLK capable pin
    begin
      // sclk is generic pin
      // it needs clock synchronous edge detection
      reg R_mosi;
      reg [1:0] R_sclk;
      always @(posedge clk)
      begin
        R_sclk <= {R_sclk[0], sclk};
        R_mosi <= mosi;
      end
      always @(posedge clk)
      begin
        if(csn)
        begin
          R_request_read <= 1'b0;
          R_request_write <= 1'b0;
          R_bit_count <= c_addr_bits+7; // 24 bits = 3 bytes to read cmd/addr, then data
        end
        else // csn == 0
        begin
          if(R_sclk == 2'b01) // rising edge
          begin
            if(R_request_read)
              R_byte <= data_in;
            else
              R_byte <= { R_byte[8-2:0], mosi };
            if(R_bit_count[c_count_bits-1] == 1'b0) // first 3 bytes
            begin
              R_raddr <= { R_raddr[c_addr_bits-1:0], R_mosi };
              R_bit_count <= R_bit_count - 1;
            end
            else // after first 3 bytes
            begin
              if(R_bit_count[3:0] == 4'd7) // first bit in new byte, increment address from 5th SPI byte on
                R_raddr[c_addr_bits-1:0] <= R_raddr[c_addr_bits-1:0] + 1;
              if(R_bit_count[2:0] == 3'd1)
                R_request_read <= R_raddr[c_addr_bits];
              else
                R_request_read <= 1'b0;
              if(R_bit_count[2:0] == 3'd0) // last bit in byte
              begin
                if(R_raddr[c_addr_bits] == 1'b0)
                  R_request_write <= 1'b1; // write
                R_bit_count[3] <= 1'b0; // allow to inc address from 5th SPI byte on
              end
              else
                R_request_write <= 1'b0;
              R_bit_count[2:0] <= R_bit_count[2:0] - 1;
            end // after 1st 3 bytes
          end // sclk rising edge
        end // csn=0
      end // always
    end // generate
  endgenerate
  assign rd   = R_request_read;
  assign wr   = R_request_write;
  assign addr = R_raddr[c_addr_bits-1:0];
  assign miso = csn ? 1'bz : R_byte[8-1];
  assign data_out = R_byte;
endmodule
