#pragma once

int com_admin_load (char* arg) {
  printf("loading admin configuration from %s...", arg);
  if (read_file(arg) == -1) {
    return -1;
  }

  f_curr = parse_admin_bin(file_payload, file_payload_length);

  printf("loaded\n");

  return 0;
}
