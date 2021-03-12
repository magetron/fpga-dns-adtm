#pragma once

int com_admin_probe (char* arg) {
  
  probe_fpga_update_local();

  return 0;
}
