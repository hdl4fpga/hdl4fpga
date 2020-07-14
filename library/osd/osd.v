// intercept video stream and make a window

module osd
#(
  parameter C_x_start = 128,
  parameter C_x_stop  = 383,
  parameter C_y_start = 128,
  parameter C_y_stop  = 383,
  parameter C_transparency = 0
)
(
  input  wire clk_pixel, clk_pixel_ena,
  input  wire [7:0] i_r,
  input  wire [7:0] i_g,
  input  wire [7:0] i_b,
  input  wire i_hsync, i_vsync, i_blank,
  input  wire i_osd_en,
  input  wire [7:0] i_osd_r,
  input  wire [7:0] i_osd_g,
  input  wire [7:0] i_osd_b,
  output wire [9:0] o_osd_x,
  output wire [9:0] o_osd_y,
  output wire [7:0] o_r,
  output wire [7:0] o_g,
  output wire [7:0] o_b,
  output wire o_hsync, o_vsync, o_blank
);


  reg osd_en, osd_xen, osd_yen;
  reg R_xcount_en, R_ycount_en;
  reg R_hsync_prev;
  reg [9:0] R_xcount, R_ycount; // relative to screen
  reg [9:0] R_osd_x, R_osd_y; // relative to OSD
  always @(posedge clk_pixel)
  begin
    if(clk_pixel_ena)
    begin
      if(i_vsync)
      begin
        R_ycount <= 0;
        R_ycount_en <= 0; // wait for blank before counting
      end
      else
      begin
        if(i_blank == 1'b0) // display unblanked
          R_ycount_en <= 1'b1;
        if(R_hsync_prev == 1'b0 && i_hsync == 1'b1)
        begin // hsync rising edge
          R_xcount <= 0;
          R_xcount_en <= 0;
          if(R_ycount_en)
            R_ycount <= R_ycount + 1;
          if(R_ycount == C_y_start)
          begin
            osd_yen <= 1;
            R_osd_y <= 0;
          end
          if(osd_yen)
            R_osd_y <= R_osd_y + 1;
          if(R_ycount == C_y_stop)
          begin
            osd_yen <= 0;
          end
        end
        else
        begin
          if(i_blank == 1'b0) // display unblanked
            R_xcount_en <= 1'b1;
          if(R_xcount_en)
            R_xcount <= R_xcount + 1;
          if(R_xcount == C_x_start)
          begin
            osd_xen <= 1;
            R_osd_x <= 0;
          end
          if(osd_xen)
            R_osd_x <= R_osd_x + 1;
          if(R_xcount == C_x_stop)
          begin
            osd_xen <= 0;
          end
        end
        R_hsync_prev <= i_hsync;
      end
      osd_en <= osd_xen & osd_yen;
    end
  end

  reg [7:0] R_vga_r, R_vga_g, R_vga_b;
  reg R_hsync, R_vsync, R_blank;
  generate
  if(C_transparency)
  always @(posedge clk_pixel)
  begin
    if(clk_pixel_ena)
    begin
      if(osd_en & i_osd_en)
      begin
        R_vga_r <= {i_osd_r[7],i_osd_r[6:0]|i_r[7:1]};
        R_vga_g <= {i_osd_g[7],i_osd_g[6:0]|i_g[7:1]};
        R_vga_b <= {i_osd_b[7],i_osd_b[6:0]|i_b[7:1]};
      end
      else
      begin
        R_vga_r <= i_r;
        R_vga_g <= i_g;
        R_vga_b <= i_b;
      end
      R_hsync <= i_hsync;
      R_vsync <= i_vsync;
      R_blank <= i_blank;
    end
  end
  else // C_transparency == 0
  always @(posedge clk_pixel)
  begin
    if(clk_pixel_ena)
    begin
      if(osd_en & i_osd_en)
      begin
        R_vga_r <= i_osd_r;
        R_vga_g <= i_osd_g;
        R_vga_b <= i_osd_b;
      end
      else
      begin
        R_vga_r <= i_r;
        R_vga_g <= i_g;
        R_vga_b <= i_b;
      end
      R_hsync <= i_hsync;
      R_vsync <= i_vsync;
      R_blank <= i_blank;
    end
  end
  endgenerate

  assign o_osd_x = R_osd_x;
  assign o_osd_y = R_osd_y;
  assign o_r = R_vga_r;
  assign o_g = R_vga_g;
  assign o_b = R_vga_b;
  assign o_hsync = R_hsync;
  assign o_vsync = R_vsync;
  assign o_blank = R_blank;

endmodule
