#pragma once

void com_admin_edit_add_print_error_msg (char* arg) {
  com_admin_edit_print_filter_types();
  fprintf(stderr, "%s: specify [filter-type] [filter-content]\n", arg);
}

void com_admin_edit_add_print_full_msg (char* arg) {
  fprintf(stderr, "%s: exceeding limit of items\n", arg);
}

void com_admin_edit_add_print_dns_too_long_msg (char* arg) {
  fprintf(stderr, "%s: exceeding limit of dns item length\n", arg);
}

int com_admin_edit_add (char* arg) {
  if (!*arg) {
    com_admin_edit_add_print_error_msg(arg);
    return -1;
  }
  char* sarg = splitstr(arg);
  if (!sarg) {
    com_admin_edit_add_print_error_msg(arg);
    return -1;
  }

  if        (strncmp(arg, "srcmac", 7) == 0) {
    if (f_curr.srcMACLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto mac = parse_mac(sarg);
    f_curr.srcMACList[f_curr.srcMACLength++] = mac;
  } else if (strncmp(arg, "dstmac", 7) == 0) {
    if (f_curr.dstMACLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto mac = parse_mac(sarg);
    f_curr.dstMACList[f_curr.dstMACLength++] = mac;
  } else if (strncmp(arg, "srcip", 6) == 0) {
    if (f_curr.srcIPLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto ip = parse_ip(sarg);
    f_curr.srcIPList[f_curr.srcIPLength++] = ip;
  } else if (strncmp(arg, "dstip", 6) == 0) {
    if (f_curr.dstIPLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto ip = parse_ip(sarg);
    f_curr.dstIPList[f_curr.dstIPLength++] = ip;
  } else if (strncmp(arg, "srcport", 8) == 0) {
    if (f_curr.srcPortLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto port = parse_port(sarg);
    f_curr.srcPortList[f_curr.srcPortLength++] = port;
  } else if (strncmp(arg, "dstport", 8) == 0) {
    if (f_curr.dstPortLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    auto port = parse_port(sarg);
    f_curr.dstPortList[f_curr.dstPortLength++] = port;
  } else if (strncmp(arg, "dns", 4) == 0) {
    if (f_curr.dnsLength == FILTER_DEPTH) {
      com_admin_edit_add_print_full_msg(arg);
      return -1;
    }
    size_t len = strnlen(sarg, 17);
    if (len > 16) {
      com_admin_edit_add_print_dns_too_long_msg(sarg);
      return -1;
    }
    memcpy(&f_curr.dnsList[f_curr.dnsLength], sarg, len);
    f_curr.dnsItemEndPtr[f_curr.dnsLength] = len * 8;
    f_curr.dnsLength++;
  } else {
    com_admin_edit_add_print_error_msg(arg);
    return -1;
  }

  return 0;
}
