// SPI RAM RW slave with BTN IRQ

// AUTHOR=EMARD
// LICENSE=BSD

// 0xFBxxxxxx: {irq,btn[6:0]}
// others    : SPI RAM

// read with dummy byte which should be discarded

// write 00 <MSB_addr> <LSB_addr> <byte0> <byte1>
// read  01 <MSB_addr> <LSB_addr> <dummy_byte> <byte0> <byte1>

module spi_ram_btn
#(
  parameter [7:0] c_addr_btn = 8'hFB, // high addr byte of BTNs
  parameter [7:0] c_addr_irq = 8'hF1, // high addr byte of IRQ flag
  parameter c_debounce_bits = 20, // more -> slower BTNs
  parameter c_addr_bits = 32, // don't touch
  parameter c_sclk_capable_pin = 0 //, // 0-sclk is generic pin, 1-sclk is clock capable pin
)
(
  input  wire clk, // faster than SPI clock
  input  wire csn, sclk, mosi, // SPI lines to be sniffed
  inout  wire miso, // 3-state line, active when csn=0
  // BTNs
  input  wire [6:0] btn,
  output wire irq,
  // BRAM interface
  output wire rd, wr,
  output wire [c_addr_bits-1:0] addr,
  input  wire [7:0] data_in,
  output wire [7:0] data_out
);

  // IRQ controller tracks BTN state
  reg R_btn_irq;
  reg [6:0] R_btn, R_btn_latch;
  reg R_spi_rd;
  reg [c_debounce_bits-1:0] R_btn_debounce;
  always @(posedge clk)
  begin
    R_spi_rd <= rd;
    if(rd == 1'b0 && R_spi_rd == 1'b1 && addr[c_addr_bits-1:c_addr_bits-8] == c_addr_irq)
      R_btn_irq <= 1'b0;
    else // BTN state is read from 0xFBxxxxxx
    begin
      R_btn_latch <= btn;
      if(R_btn != R_btn_latch && R_btn_debounce[$bits(R_btn_debounce)-1] == 1 && R_btn_irq == 0)
      begin
        R_btn_irq <= 1'b1;
        R_btn_debounce <= 0;
        R_btn <= R_btn_latch;
      end
      else
        if(R_btn_debounce[$bits(R_btn_debounce)-1] == 1'b0)
          R_btn_debounce <= R_btn_debounce + 1;
    end
  end

  wire [7:0] mux_data_in = addr[c_addr_bits-1:c_addr_bits-8] == c_addr_irq ? {R_btn_irq,7'b0}
                         : addr[c_addr_bits-1:c_addr_bits-8] == c_addr_btn ? {1'b0,R_btn}
                         : data_in;
  assign irq = R_btn_irq;

  spirw_slave_v
  #(
    .c_sclk_capable_pin(c_sclk_capable_pin),
    .c_addr_bits(c_addr_bits)
  )
  spirw_slave_v_inst
  (
    .clk(clk),
    .csn(csn),
    .sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .wr(wr),
    .rd(rd),
    .addr(addr),
    .data_in(mux_data_in),
    .data_out(data_out)
  );

endmodule
