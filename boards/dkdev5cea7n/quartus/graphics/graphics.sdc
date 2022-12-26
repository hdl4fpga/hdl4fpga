create_clock           -name  refclk -period 10.000 [get_ports {refclk}
derive_pll_clocks

create_clock           -name  virtual_dqs_in -period 5.000
create_clock           -name  dqs_in -period 5.000[get_ports {strobe_in}]

set_input_delay        -clock {virtual_dqs_in} -max -add_delay 0.400 [get_ports {read_write_data_io[*]}]
set_input_delay        -clock {virtual_dqs_in} -min -add_delay -0.400 [get_ports{read_write_data_io[*]}]
set_input_delay        -clock {virtual_dqs_in} -clock_fall -max -add_delay 0.400 [get_ports {read_write_data_io[*]}]
set_input_delay        -clock {virtual_dqs_in} -clock_fall -min -add_delay -0.400 [get_ports {read_write_data_data_io[*]}]

create_generated_clock -name dqs_out -source [get_pins{dqdqs2_inst| bidir_hardfifo_dqdqs2_inst|altdq_dqs2_inst|phy_clkbuf|outclk[1] }] -phase 0 [get_ports {strobe_io}] -add

set_output_delay       -clock   {dqs_out} -max 0.250 [get_ports {read_write_data_io[*]}] -add_delay
set_output_delay       -clock   {dqs_out} -max 0.250 -clock_fall [get_ports {read_write_data_io[*]}] -add_delay
set_output_delay       -clock   {dqs_out} -min -0.250 [get_ports {read_write_data_io[*]}] -add_delay
set_output_delay       -clock   {dqs_out} -min -0.250 -clock_fall [get_ports {read_write_data_io[*]}] -add_delay

set_false_path         -setup -rise_from [get_clocks {virtual_dqs_in}] -fall_to [get_clocks {dqs_in}]
set_false_path         -setup -fall_from [get_clocks {virtual_dqs_in}] -rise_to [get_clocks {dqs_in}]
set_false_path         -hold  -rise_from [get_clocks {virtual_dqs_in}] -rise_to [get_clocks {dqs_in}]
set_false_path         -hold  -fall_from [get_clocks {virtual_dqs_in}] -fall_to [get_clocks {dqs_in}]

set_false_path         -setup   -rise_from [get_clocks{pll_inst|alterapll_inst| altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {dqs_out}]
set_false_path         -setup   -fall_from [get_clocks{pll_inst|alterapll_inst| altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {dqs_out}]
set_false_path         -hold    -rise_from [get_clocks{pll_inst|alterapll_inst| altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {dqs_out}]
set_false_path         -hold    -fall_from [get_clocks{pll_inst|alterapll_inst| altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {dqs_out}]
set_false_path         -from    [get_clocks {virtual_dqs_in}] -to [get_clocks {dqs_out}]

set_multicycle_path    -rise_from    [get_clocks {virtual_dqs_in}] -rise_to [get_clocks {dqs_in}] -setup -end 0
set_multicycle_path    -fall_from    [get_clocks {virtual_dqs_in}] -fall_to [get_clocks {dqs_in}] -setup -end 0

#set_false_path        -from    [get_keepers {*|dqs_enable_ctrl~DQSENABLEOUT_DFF}] -to [get_clocks{dqs_out}]