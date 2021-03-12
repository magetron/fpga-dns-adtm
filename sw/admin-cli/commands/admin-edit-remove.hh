#pragma once

void com_admin_edit_remove_print_error_msg (char* arg) {
  com_admin_edit_print_filter_types();
  fprintf(stderr, "%s: specify [filter-type] [filter-index]\n", arg);
}

void com_admin_edit_remove_print_index_msg (char* arg) {
  com_admin_edit_print_filter_types();
  fprintf(stderr, "%s: filter-index shall be in range 0 to %d\n", arg, FILTER_DEPTH - 1);
}

void com_admin_edit_remove_print_empty_msg (char* arg) {
  fprintf(stderr, "%s: filter removal index invalid\n", arg);
}

int com_admin_edit_remove (char* arg) {
  if (!*arg) {
    com_admin_edit_remove_print_error_msg(arg);
    return -1;
  }

  char* sarg = splitstr(arg);
  if (!sarg) {
    com_admin_edit_remove_print_error_msg(arg);
    return -1;
  }

  size_t len = strnlen(sarg, 2);
  if (len != 1 || !(sarg[0] >= '0' && sarg[0] <= '9')) {
    com_admin_edit_remove_print_index_msg(sarg);
    return -1;
  }
  uint8_t index = sarg[0] - '0';
  if (index >= FILTER_DEPTH) {
    com_admin_edit_remove_print_index_msg(sarg);
    return -1;
  }

  if        (strncmp(arg, "srcmac", 7) == 0) {
    if (index >= f_curr.srcMACLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.srcMACLength--;
    f_curr.srcMACList[index] = f_curr.srcMACList[f_curr.srcMACLength];
    f_curr.srcMACList[f_curr.srcMACLength] = {};
  } else if (strncmp(arg, "dstmac", 7) == 0) {
    if (index >= f_curr.dstMACLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.dstMACLength--;
    f_curr.dstMACList[index] = f_curr.dstMACList[f_curr.dstMACLength];
    f_curr.dstMACList[f_curr.dstMACLength] = {};
  } else if (strncmp(arg, "srcip", 6) == 0) {
    if (index >= f_curr.srcIPLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.srcIPLength--;
    f_curr.srcIPList[index] = f_curr.srcIPList[f_curr.srcIPLength];
    f_curr.srcIPList[f_curr.srcIPLength] = {};
  } else if (strncmp(arg, "dstip", 6) == 0) {
    if (index >= f_curr.dstIPLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.dstIPLength--;
    f_curr.dstIPList[index] = f_curr.dstIPList[f_curr.dstIPLength];
    f_curr.dstIPList[f_curr.dstIPLength] = {};
  } else if (strncmp(arg, "srcport", 8) == 0) {
    if (index >= f_curr.srcPortLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.srcPortLength--;
    f_curr.srcPortList[index] = f_curr.srcPortList[f_curr.srcPortLength];
    f_curr.srcPortList[f_curr.srcPortLength] = {};
  } else if (strncmp(arg, "dstport", 8) == 0) {
    if (index >= f_curr.dstPortLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.dstPortLength--;
    f_curr.dstPortList[index] = f_curr.dstPortList[f_curr.dstPortLength];
    f_curr.dstPortList[f_curr.dstPortLength] = {};
  } else if (strncmp(arg, "dns", 4) == 0) {
    if (index >= f_curr.dnsLength) {
      com_admin_edit_remove_print_empty_msg(sarg);
      return -1;
    }
    f_curr.dnsLength--;
    f_curr.dnsList[index] = f_curr.dnsList[f_curr.dnsLength];
    f_curr.dnsItemEndPtr[index] = f_curr.dnsItemEndPtr[f_curr.dnsLength];
    f_curr.dnsList[f_curr.dnsLength] = {};
    f_curr.dnsItemEndPtr[f_curr.dnsLength] = 0;
  } else {
    com_admin_edit_remove_print_error_msg(arg);
    return -1;
  }

  return 0;
}
