`timescale 1ns / 1ps  

/*Project Oberon, Revised Edition 2013

Book copyright (C)2013 Niklaus Wirth and Juerg Gutknecht;
software copyright (C)2013 Niklaus Wirth (NW), Juerg Gutknecht (JG), Paul
Reed (PR/PDR).

Permission to use, copy, modify, and/or distribute this software and its
accompanying documentation (the "Software") for any purpose with or
without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.*/

// PS/2 mouse PDR 14.10.2013 / 03.09.2015 / 01.10.2015
// with Microsoft 3rd (scroll) button init magic
module mousem_v
(
  input clk, reset,
  inout msclk, msdat,
  output [27:0] dataout
);

  reg [10:0] x, y;
  reg [2:0] btns;
  reg [2:0] sent;
  reg [30:0] rx;
  reg [9:0] tx;
  reg [14:0] count;
  reg [5:0] filter;
  reg req;
  wire shift, endbit, endcount, done, run;
  wire [8:0] cmd;  //including odd tx parity bit
  wire [10:0] dx, dy;

// 322222222221111111111 (scroll mouse z and rx parity p ignored)
// 0987654321098765432109876543210   X, Y = overflow
// -------------------------------   s, t = x, y sign bits
// yyyyyyyy01pxxxxxxxx01pYXts1MRL0   normal report
// p--ack---0Ap--cmd---01111111111   cmd + ack bit (A) & byte

  assign run = (sent == 7);
  assign cmd = (sent == 0) ? 9'h0F4 :   //enable reporting, rate 200,100,80
   (sent == 2) ? 9'h0C8 : (sent == 4) ? 9'h064 : (sent == 6) ? 9'h150 : 9'h1F3;
  assign endcount = (count[14:12] == 3'b111);  // more than 11*100uS @25MHz
  assign shift = ~req & (filter == 6'b100000);  //low for 200nS @25MHz
  assign endbit = run ? ~rx[0] : ~rx[10];
  assign done = endbit & endcount & ~req;
  assign dx = {{3{rx[5]}}, rx[7] ? 8'b0 : rx[19:12]};  //sign+overfl
  assign dy = {{3{rx[6]}}, rx[8] ? 8'b0 : rx[30:23]};  //sign+overfl
//  assign dataout = {run,  // full debug
//    run ? {rx[25:0], endbit} : {rx[30:10], endbit, sent, tx[0], ~req}};
//  assign dataout = {run,  // debug then normal
//    run ? {btns, 2'b0, y, 2'b0, x} : {rx[30:10], sent, endbit, tx[0], ~req}};
  assign dataout = {run, btns, 1'b0, y, 1'b0, x}; // normal
  assign msclk = req ? 1'b0 : 1'bz;  //bidir clk/request
  assign msdat = ~tx[0] ? 1'b0 : 1'bz;  //bidir data

  always @ (posedge clk) begin
    filter <= {filter[4:0], msclk};
    count <= (reset | shift | endcount) ? 0 : count+1;
    req <= ~reset & ~run & (req ^ endcount);
    sent <= reset ? 0 : (done & ~run) ? sent+1 : sent;
    tx <= (reset | run) ? 10'h3FF : req ? {cmd, 1'b0} : shift ? {1'b1, tx[9:1]} : tx;
    rx <= (reset | done) ? 31'h7FFFFFFF : (shift & ~endbit) ? {msdat, rx[30:1]} : rx;
    x <= ~run ? 0 : done ? x + dx : x;
    y <= ~run ? 0 : done ? y + dy : y;
    btns <= ~run ? 0 : done ? {rx[1], rx[3], rx[2]} : btns;
  end

endmodule
