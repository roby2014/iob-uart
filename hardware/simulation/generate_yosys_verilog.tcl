set TOP uart_core
set INCLUDE_PATH [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]
set VERILOG_OUTPUT [lindex $argv 3]
set GENERIC_OUTPUT [lindex $argv 4]

#debug purposes
puts "INCLUDE_PATH: $INCLUDE_PATH \n"
puts "DEFINE: $DEFINE \n"
puts "VSRC: $VSRC \n"

set VSRC [lrange $VSRC 0 end-1] ;# we dont want to synthesize "system_tb.v"

puts "\n-> Synthesizing design...\n"
set yosys_script "$TOP.ys"
set yosys_script_handle [open $yosys_script "w"]
puts $yosys_script_handle "read -define USE_SPRAM $DEFINE \n"
puts $yosys_script_handle "verilog_defaults -add $INCLUDE_PATH \n"
puts $yosys_script_handle "read_verilog $VSRC \n"
if {$GENERIC_OUTPUT != 0} {
    puts "Generating generic verilog output..."
   puts $yosys_script_handle "synth -top $TOP \n"
} else {
    puts "Generating ECP5 FPGA specific verilog output..."
    puts $yosys_script_handle "synth_ecp5 -top $TOP -json $TOP.json \n"
}
puts $yosys_script_handle "write_verilog $VERILOG_OUTPUT \n"
close $yosys_script_handle
exec yosys -T $yosys_script -q -q -t -l "${TOP}_synthesis.log"