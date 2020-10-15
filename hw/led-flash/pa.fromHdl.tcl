
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name led-flash -dir "/mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/led-flash/planAhead_run_2" -part xc3s500efg320-5
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "led_test.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {led.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top led $srcset
add_files [list {led_test.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s500efg320-5
