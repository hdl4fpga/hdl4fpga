// diamond 3.7 accepts this PLL
// diamond 3.8-3.9 is untested
// diamond 3.10 or higher is likely to abort with error about unable to use feedback signal
// cause of this could be from wrong CPHASE/FPHASE parameters
module clk_verilog_v
(
    input [1:0] phasesel, // clkout[] index affected by dynamic phase shift (except clkfb), 5 ns min before apply
    input phasedir, // 0:delayed (lagging), 1:advence (leading), 5 ns min before apply
    input phasestep, // 45 deg step, high for 5 ns min, falling edge = apply
    input phaseloadreg, // high for 10 ns min, falling edge = apply
    input clkin, // 25 MHz, 0 deg
    output clkout0, // 175 MHz, 0 deg
    output clkout1, // 25 MHz, 0 deg
    output clkout2, // 65.625 MHz, 0 deg
    output clkout3, // 6.03448 MHz, 0 deg
    output locked
);
wire [1:0] phasesel_hw;
assign phasesel_hw = phasesel - 1;
(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="175" *)
(* FREQUENCY_PIN_CLKOS="25" *)
(* FREQUENCY_PIN_CLKOS2="65.625" *)
(* FREQUENCY_PIN_CLKOS3="6.03448" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("ENABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(1),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(3),
        .CLKOP_CPHASE(1),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(21),
        .CLKOS_CPHASE(1),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(8),
        .CLKOS2_CPHASE(1),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(87),
        .CLKOS3_CPHASE(1),
        .CLKOS3_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(7)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clkin),
        .CLKOP(clkout0),
        .CLKOS(clkout1),
        .CLKOS2(clkout2),
        .CLKOS3(clkout3),
        .CLKFB(clkout0),
        .CLKINTFB(),
        .PHASESEL0(phasesel_hw[0]),
        .PHASESEL1(phasesel_hw[1]),
        .PHASEDIR(phasedir),
        .PHASESTEP(phasestep),
        .PHASELOADREG(phaseloadreg),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
endmodule
