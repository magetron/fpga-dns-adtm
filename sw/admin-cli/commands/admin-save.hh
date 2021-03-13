#pragma once

int com_admin_save(char* arg) {
  printf("saving admin configuration to %s...", arg);

  write_to_admin_pkt(f_curr, arg);

  printf("saved\n");

  return 0;
}
