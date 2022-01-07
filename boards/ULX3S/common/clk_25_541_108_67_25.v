module clk_verilog_v
(
    input clkin, // 25 MHz, 0 deg
    output [3:0] clkout, // 0: 541.667 MHz, 0 deg; 1: 108.333 MHz, 0 deg; 2: 67.7083 MHz, 0 deg; 3: 25.7936 MHz, 0 deg
    output locked
);
wire clkfb;
wire clkos;
wire clkop;
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(0),
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(1),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(5),
        .CLKOS_CPHASE(0),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(8),
        .CLKOS2_CPHASE(0),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(21),
        .CLKOS3_CPHASE(0),
        .CLKOS3_FPHASE(0),
        .CLKFB_DIV(65),
        .CLKI_DIV(3),
        .FEEDBK_PATH("INT_OP")
    ) pll_i (
        .CLKI(clkin),
        .CLKFB(clkfb),
        .CLKINTFB(clkfb),
        .CLKOP(clkop),
        .CLKOS(clkout[1]),
        .CLKOS2(clkout[2]),
        .CLKOS3(clkout[3]),
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
assign clkout[0] = clkop;
endmodule
