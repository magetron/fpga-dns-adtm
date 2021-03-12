#pragma once

int com_stats_probe (char* arg) {
  probe_fpga_update_local();
  print_stats(s);
  return 0;
}
