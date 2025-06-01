set_time_format -unit ns -decimal_places 3
create_clock -name {osc_50mhz} -period 20.000 -waveform { 0.000 10.000 } [get_ports { osc_50mhz }]
create_generated_clock -source {videopll_e|pll_i|pll|inclk[0]} -divide_by 11 -multiply_by 8 -duty_cycle 50.00 -name {videopll_e|pll_i|pll|clk[2]} {videopll_e|pll_i|pll|clk[2]}