#pragma once

void com_admin_edit_set_print_error_msg (char* arg) {
  com_admin_edit_print_filter_types();
  fprintf(stderr, "%s: specify [filter-type] [black/white]\n", arg);
}

int com_admin_edit_set (char* arg) {
  if (!*arg) {
    com_admin_edit_set_print_error_msg(arg);
    return -1;
  }
  char* sarg = splitstr(arg);
  if (!sarg) {
    com_admin_edit_set_print_error_msg(arg);
    return -1;
  }

  uint8_t bw = 0;
  if (strncmp(sarg, "black", 6) == 0) {
    bw = 0;
  } else if (strncmp(sarg, "white", 6) == 0) {
    bw = 1;
  } else {
    com_admin_edit_set_print_error_msg(arg);
    return -1;
  }

  if        (strncmp(arg, "srcmac", 7) == 0) {
    f_curr.srcMACBW = bw;
  } else if (strncmp(arg, "dstmac", 7) == 0) {
    f_curr.dstMACBW = bw;
  } else if (strncmp(arg, "srcip", 6) == 0) {
    f_curr.srcIPBW = bw;
  } else if (strncmp(arg, "dstip", 6) == 0) {
    f_curr.dstIPBW = bw;
  } else if (strncmp(arg, "srcport", 8) == 0) {
    f_curr.srcPortBW = bw;
  } else if (strncmp(arg, "dstport", 8) == 0) {
    f_curr.dstPortBW = bw;
  } else if (strncmp(arg, "dns", 4) == 0) {
    f_curr.dnsBW = bw;
  } else {
    com_admin_edit_set_print_error_msg(arg);
    return -1;
  }

  return 0;
}


