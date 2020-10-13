
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name led-flash -dir "/mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/led-flash/planAhead_run_1" -part xc3s500evq100-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/led-flash/led.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/led-flash} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "led_test.ucf" [current_fileset -constrset]
add_files [list {led_test.ucf}] -fileset [get_property constrset [current_run]]
link_design
