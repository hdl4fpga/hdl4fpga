`timescale 1 ns / 100 ps
module yk4c0a3 (
          ux28c5,
          sclk,
          eclk,
          ps636f6,
          jpf9f9a,
          dqsdel,
          qgdbd92,
          osdec91,
          blf6489,
          lsb244f,
          mg9227b,
          db913d8,
          ls89ec7,
          vv4f63b,


          ddrclkpol,
          prmbdet,
          wy3bff7,
          aaacc86,
          zx55990,
          sj90c17,
          xy860bc,
          fcb8615,

          shc30aa
          );
input          ux28c5;
input          sclk;
input          eclk;
input          ps636f6;
input          jpf9f9a;
input          dqsdel;
input          qgdbd92;
input [6:0]    osdec91;
input          blf6489;
input          lsb244f;
input          mg9227b;
input          db913d8;
input          ls89ec7;
input          vv4f63b;
output         ddrclkpol;
output         prmbdet;
output         wy3bff7;
output         aaacc86;
output         zx55990;
output         sj90c17;
output         xy860bc;
output         fcb8615;
inout          shc30aa;
wire           zxec465;
wire           qg6232f;
wire           pu11978;
wire           sj90c17;
wire           xy860bc;
wire           hq2f09c;
wire           yk784e2;
wire           pfc2710;
wire           xl13887;
wire           pu9c43f;
wire           ipe21fb;

`ifdef ECP3_SP2

`else

`endif

`ifdef SIM
wire           co10fdc;

`ifdef ECP3_8_0

`endif

`else

`ifdef ECP3_8_0

`endif

`endif

`ifdef SIM
wire           ym87ee0;
wire           ls3f700;
wire           rgfb803;
wire           kddc01a;

`endif

`ifdef SIM

`else

`endif
reg sue00d5;
reg hdaa7dd;
reg gd8f4ec;
reg by7cff7;
reg mg34c40;
reg end3b2d;
reg [6 : 0] sw9d96d;
reg dzecb68;
reg uv65b46;
reg xl2da34;
reg ww6d1a6;
reg su68d31;
reg ic46988;
reg aldc24d;
reg rge126d;
reg db936b;
reg cm49b5e;
reg zk4daf1;
reg ay6d78b;
reg bl6bc59;
reg ip5e2cf;
reg zkf167c;
reg [2047:0] ks1500e;
wire [21:0] pua8071;

`ifdef ECP3_SP2


`else


`endif


`ifdef SIM

`ifdef ECP3_8_0

`endif


`else

`ifdef ECP3_8_0

`endif


`endif

`ifdef SIM

`endif

`ifdef SIM


`else


`endif


localparam rt4038b = 22,hq1c5e = 32'hfdffe0cb;
localparam [31:0] jee2f3 = hq1c5e;
localparam ph8bcde = hq1c5e & 4'hf;
localparam [11:0] jpf37b4 = 'h7ff;
wire [(1 << ph8bcde) -1:0] icded3f;
reg [rt4038b-1:0] ohb4fce;
reg [ph8bcde-1:0] fc3f3ab [0:1];
reg [ph8bcde-1:0] icceadf;
reg sh756f8;
integer ohab7c4;
integer en5be24;


`ifdef ECP3_SP2


`else


`endif


`ifdef SIM


`ifdef ECP3_8_0


`endif


`else


`ifdef ECP3_8_0


`endif


`endif


`ifdef SIM


`endif


`ifdef SIM


`else


`endif











assign  pfc2710  = ~xl2da34 & ~uv65b46;

assign  xl13887        = (dzecb68 ) ? 1'b0 :  ww6d1a6;

assign  pu9c43f        = (dzecb68 ) ? 1'b0 :  su68d31;
assign  ipe21fb = dzecb68 ? 1'b0 : uv65b46;





`ifdef ECP3_SP2

defparam ks54b0.ISI_CAL = "BYPASS" ;
ODDRX2DQSA ks54b0 (.SCLK(sclk), .DB0(ipe21fb), .DB1(mg9227b), .DQSW(hq2f09c), .DQCLK0(sj90c17), .DQCLK1(xy860bc), .Q(qg6232f), .DQSTCLK(pu11978)) ;


`else

defparam ks54b0.ISI_CAL = "BYPASS" ;
ODDRX2DQSA ks54b0 (.SCLK(sclk), .DB0(ipe21fb), .DB1(mg9227b), .DQSW(hq2f09c), .DQCLK0(sj90c17), .DQCLK1(xy860bc), .Q(qg6232f), .DQSTCLK(pu11978))   ;

`endif






ODDRTDQSA th50dc4 (.TA(xl13887), .SCLK(sclk), .DB(pu9c43f), .DQSTCLK(pu11978), .DQSW(hq2f09c), .Q(zxec465));






`ifdef SIM



`ifdef ECP3_8_0

defparam ou97666.NRZMODE = "ENABLED" ;

`endif
    DQSBUFD ou97666 (.DQSI(co10fdc), .SCLK(sclk), .READ(jpf9f9a), .DQSDEL(dqsdel),   .ECLK(eclk), .ECLKW(ps636f6), .RST(ux28c5),   .DYNDELPOL(qgdbd92),   .DYNDELAY6(osdec91[6]), .DYNDELAY5(osdec91[5]),   .DYNDELAY4(osdec91[4]), .DYNDELAY3(osdec91[3]), .DYNDELAY2(osdec91[2]),   .DYNDELAY1(osdec91[1]), .DYNDELAY0(osdec91[0]),   .DQSW(hq2f09c), .DDRCLKPOL(ddrclkpol), .PRMBDET(prmbdet),   .DATAVALID(wy3bff7), .DDRLAT(aaacc86), .ECLKDQSR(zx55990), .DQCLK0(sj90c17),   .DQCLK1(xy860bc));

`else



`ifdef ECP3_8_0

defparam ou97666.NRZMODE = "ENABLED" ;

`endif
    DQSBUFD ou97666 (.DQSI(yk784e2), .SCLK(sclk), .READ(jpf9f9a), .DQSDEL(dqsdel),   .ECLK(eclk), .ECLKW(ps636f6), .RST(ux28c5),   .DYNDELPOL(qgdbd92),   .DYNDELAY6(osdec91[6]), .DYNDELAY5(osdec91[5]),   .DYNDELAY4(osdec91[4]), .DYNDELAY3(osdec91[3]), .DYNDELAY2(osdec91[2]),   .DYNDELAY1(osdec91[1]), .DYNDELAY0(osdec91[0]),   .DQSW(hq2f09c), .DDRCLKPOL(ddrclkpol), .PRMBDET(prmbdet),   .DATAVALID(wy3bff7), .DDRLAT(aaacc86), .ECLKDQSR(zx55990), .DQCLK0(sj90c17),   .DQCLK1(xy860bc));

`endif







`ifdef SIM

assign #`WL_DQS_PHASE_DLY rgfb803  = rge126d;
assign kddc01a = dzecb68 ? rgfb803 : rge126d;

assign #`DQS_TRC_DEL ym87ee0  = kddc01a;   
assign #`DQS_TRC_DEL ls3f700 = aldc24d;
assign #`DQS_TRC_DEL co10fdc   = zk4daf1;    

`endif





`ifdef SIM
  BB oha4cdf(.I(ym87ee0), .T(ls3f700), .O(yk784e2), .B(shc30aa))  ;

`else
  BB oha4cdf(.I(qg6232f), .T(zxec465), .O(yk784e2), .B(shc30aa))    ;

`endif


ODDRTDQA lqdf496 (.TA(vv4f63b), .SCLK(sclk), .DQCLK0(sj90c17), .DQCLK1(xy860bc), .Q(fcb8615));
always@* begin sue00d5<=pua8071[0];hdaa7dd<=pua8071[1];gd8f4ec<=pua8071[2];by7cff7<=pua8071[3];mg34c40<=pua8071[4];end3b2d<=pua8071[5];sw9d96d<={osdec91>>1,pua8071[6]};dzecb68<=pua8071[7];uv65b46<=pua8071[8];xl2da34<=pua8071[9];ww6d1a6<=pua8071[10];su68d31<=pua8071[11];ic46988<=pua8071[12];aldc24d<=pua8071[13];rge126d<=pua8071[14];db936b<=pua8071[15];cm49b5e<=pua8071[16];zk4daf1<=pua8071[17];ay6d78b<=pua8071[18];bl6bc59<=pua8071[19];ip5e2cf<=pua8071[20];zkf167c<=pua8071[21];end
always@* begin ks1500e[2047]<=eclk;ks1500e[2046]<=ps636f6;ks1500e[2044]<=jpf9f9a;ks1500e[2040]<=dqsdel;ks1500e[2033]<=qgdbd92;ks1500e[2024]<=ipe21fb;ks1500e[2018]<=osdec91[0];ks1500e[1988]<=blf6489;ks1500e[1929]<=lsb244f;ks1500e[1811]<=mg9227b;ks1500e[1789]<=pfc2710;ks1500e[1574]<=db913d8;ks1500e[1530]<=xl13887;ks1500e[1247]<=pu11978;ks1500e[1101]<=ls89ec7;ks1500e[1023]<=ux28c5;ks1500e[1012]<=pu9c43f;ks1500e[894]<=yk784e2;ks1500e[623]<=qg6232f;ks1500e[447]<=hq2f09c;ks1500e[311]<=zxec465;ks1500e[155]<=vv4f63b;end         assign icded3f = ks1500e,pua8071 = ohb4fce; initial begin ohab7c4 = $fopen(".fred"); $fdisplay( ohab7c4, "%3h\n%3h", (jee2f3 >> 4) & jpf37b4, (jee2f3 >> (ph8bcde+4)) & jpf37b4 ); $fclose(ohab7c4); $readmemh(".fred", fc3f3ab); end always @ (icded3f) begin icceadf = fc3f3ab[1]; for (en5be24=0; en5be24<rt4038b; en5be24=en5be24+1) begin ohb4fce[en5be24] = icded3f[icceadf]; sh756f8 = ^(icceadf & fc3f3ab[0]); icceadf = {icceadf, sh756f8}; end end 
endmodule
