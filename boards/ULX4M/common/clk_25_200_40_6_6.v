module clk_verilog_v
(
    input [1:0] phasesel, // clkout[] index affected by dynamic phase shift (except clkfb), 5 ns min before apply
    input phasedir, // 0:delayed (lagging), 1:advence (leading), 5 ns min before apply
    input phasestep, // 45 deg step, high for 5 ns min, falling edge = apply
    input phaseloadreg, // high for 10 ns min, falling edge = apply
    input clkin, // 25 MHz, 0 deg
    output clkout0, // 200 MHz, 0 deg
    output clkout1, // 40 MHz, 0 deg
    output clkout2, // 6 MHz, 45 deg
    output clkout3, // 6 MHz, 0 deg
    output locked
);
wire clkfb;
wire clkos;
wire clkop;
wire [1:0] phasesel_hw;
assign phasesel_hw = phasesel - 1;
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("ENABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(1),
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(3),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(15),
        .CLKOS_CPHASE(1),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(100),
        .CLKOS2_CPHASE(13),
        .CLKOS2_FPHASE(4),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(100),
        .CLKOS3_CPHASE(1),
        .CLKOS3_FPHASE(0),
        .CLKFB_DIV(8),
        .CLKI_DIV(1),
        .FEEDBK_PATH("INT_OP")
    ) pll_i (
        .CLKI(clkin),
        .CLKFB(clkfb),
        .CLKINTFB(clkfb),
        .CLKOP(clkop),
        .CLKOS(clkout1),
        .CLKOS2(clkout2),
        .CLKOS3(clkout3),
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL0(phasesel_hw[0]),
        .PHASESEL1(phasesel_hw[1]),
        .PHASEDIR(phasedir),
        .PHASESTEP(phasestep),
        .PHASELOADREG(phaseloadreg),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
assign clkout0 = clkop;
endmodule
