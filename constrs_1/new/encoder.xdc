####################################################################################################

create_clock -name clk -period 10.000 [get_ports clk]
set_clock_uncertainty 0.150 [get_clocks clk]

set_input_delay -clock clk -min 2.000 [get_ports rst_n]
set_input_delay -clock clk -max 8.000 [get_ports rst_n]
set_input_delay -clock clk -min 2.000 [get_ports gen_data[*]]
set_input_delay -clock clk -max 8.000 [get_ports gen_data[*]]

set_output_delay -clock clk -min 2.000 [get_ports {enc_data[*]}]
set_output_delay -clock clk -max 4.000 [get_ports {enc_data[*]}]

####################################################################################################

set_property DONT_TOUCH true [get_cells -hierarchical *]

####################################################################################################