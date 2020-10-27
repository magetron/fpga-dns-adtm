
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name testlcd -dir "/mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/testlcd/planAhead_run_1" -part xc3s500efg320-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "spartan3e.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {lcd.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {charmem.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {topmodule.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top topmodule $srcset
add_files [list {spartan3e.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s500efg320-4
