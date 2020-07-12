// SPI receiver for OSD text window
// VGA video stream pipeline processor

module spi_osd
#(
  parameter  [7:0] c_addr_enable  = 8'hFE, // high addr byte of enable byte
  parameter  [7:0] c_addr_display = 8'hFD, // high addr byte of display data, +0x10000 for inverted
  parameter        c_start_x      = 64,  // x1  pixel window h-position
  parameter        c_start_y      = 48,  // x1  pixel window v-position
  parameter        c_chars_x      = 64,  // x8  pixel window h-size
  parameter        c_chars_y      = 24,  // x16 pixel window v-size
  parameter        c_init_on      = 1,   // 0:default OFF 1:default ON
  parameter        c_inverse      = 1,   // 0:no inverse, 1:inverse support
  parameter        c_transparency = 0,   // 1:see-thru OSD menu 0:opaque
  parameter [23:0] c_bgcolor      = 24'h503020, // RRGGBB menu background color
  parameter        c_char_file    = "osd.mem",            // initial window content, 2 ASCII HEX digits per line
  parameter        c_font_file    = "font_bizcat8x16.mem" // font bitmap, 8 ASCII BIN digits per line
)
(
  input  wire clk_pixel, clk_pixel_ena,
  input  wire [7:0] i_r,
  input  wire [7:0] i_g,
  input  wire [7:0] i_b,
  input  wire i_hsync, i_vsync, i_blank,
  input  wire i_csn, i_sclk, i_mosi,
  inout  wire o_miso,
  output wire [7:0] o_r,
  output wire [7:0] o_g,
  output wire [7:0] o_b,
  output wire o_hsync, o_vsync, o_blank
);

    reg [7+c_inverse:0] tile_map [0:c_chars_x*c_chars_y-1]; // tile memory (character map)
    initial
      $readmemh(c_char_file, tile_map);

    wire ram_wr;
    wire [31:0] ram_addr;
    wire [7:0] ram_di;
    reg  [7:0] ram_do;
    spirw_slave_v
    #(
        .c_addr_bits(32),
        .c_sclk_capable_pin(1'b0)
    )
    spirw_slave_inst
    (
        .clk(clk_pixel),
        .csn(i_csn),
        .sclk(i_sclk),
        .mosi(i_mosi),
        .miso(o_miso),
        .wr(ram_wr),
        .addr(ram_addr),
        .data_in(ram_do),
        .data_out(ram_di)
    );
    always @(posedge clk_pixel)
    begin
      if(ram_wr && (ram_addr[31:24] == c_addr_display))
        if(c_inverse)
          tile_map[ram_addr] <= {ram_addr[16],ram_di}; // ASCII to 0xFDx0xxxx normal, 0xFDx1xxxx inverted
        else
          tile_map[ram_addr] <= ram_di;
      //ram_do <= tile_map[ram_addr];
    end

    reg osd_en = c_init_on;
    always @(posedge clk_pixel)
    begin
      if(ram_wr && (ram_addr[31:24] == c_addr_enable)) // write to 0xFExxxxxx enables/disables OSD
        osd_en <= ram_di[0];
    end

    wire [9:0] osd_x, osd_y;
    reg [7:0] font[0:4095];
    initial
      $readmemb(c_font_file, font);
    reg [7:0] data_out;
    wire [11:0] tileaddr = (osd_y >> 4) * c_chars_x + (osd_x >> 3);
    generate
      if(c_inverse)
        always @(posedge clk_pixel)
          data_out[7:0] <= font[{tile_map[tileaddr], osd_y[3:0]}] ^ {8{tile_map[tileaddr][8]}};
      else
        always @(posedge clk_pixel)
          data_out[7:0] <= font[{tile_map[tileaddr], osd_y[3:0]}];
    endgenerate
    wire [7:0] data_out_align = {data_out[0], data_out[7:1]};
    wire osd_pixel = data_out_align[7-osd_x[2:0]];

    wire [7:0] osd_r = osd_pixel ? 8'hff : c_bgcolor[23:16];
    wire [7:0] osd_g = osd_pixel ? 8'hff : c_bgcolor[15:8];
    wire [7:0] osd_b = osd_pixel ? 8'hff : c_bgcolor[7:0];

    // OSD overlay
    osd
    #(
      .C_x_start(c_start_x),
      .C_x_stop (c_start_x+8*c_chars_x-1),
      .C_y_start(c_start_y),
      .C_y_stop (c_start_y+16*c_chars_y-1),
      .C_transparency(c_transparency)
    )
    osd_instance
    (
      .clk_pixel(clk_pixel),
      .clk_pixel_ena(1'b1),
      .i_r(i_r),
      .i_g(i_g),
      .i_b(i_b),
      .i_hsync(i_hsync),
      .i_vsync(i_vsync),
      .i_blank(i_blank),
      .i_osd_en(osd_en),
      .o_osd_x(osd_x),
      .o_osd_y(osd_y),
      .i_osd_r(osd_r),
      .i_osd_g(osd_g),
      .i_osd_b(osd_b),
      .o_r(o_r),
      .o_g(o_g),
      .o_b(o_b),
      .o_hsync(o_hsync),
      .o_vsync(o_vsync),
      .o_blank(o_blank)
    );

endmodule
