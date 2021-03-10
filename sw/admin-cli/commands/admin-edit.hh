#pragma once

int com_admin_edit_add (char*);
int com_admin_edit_remove (char*);
int com_admin_edit_set (char*);
int com_admin_edit_help (char*);

COMMAND admin_edit_commands[] = {
  { "add", com_admin_edit_add, "add [filter-type] [filter-content]" },
  { "set", com_admin_edit_set, "set [filter-type] [black/white]" },
  { "remove", com_admin_edit_remove, "remove [filter-type] [filter-index]" },
  { "help", com_admin_edit_help, "display this text" },
  { "?", com_admin_edit_help, "synonym for `help'" },
  { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

int com_admin_edit (char* arg) {
  if (!*arg) {
    com_admin_edit_help(arg);
  } else {
    execute(arg, admin_edit_commands);
  }
  return 0;
}

int com_admin_edit_help (char* arg) {
  print_help(arg, admin_edit_commands);
  return 0;
}

static inline uint8_t parse_hex(char c) {
  if (c >= '0' && c <= '9') {
    return c - 48;
  } else if (c >= 'a' && c <= 'f') {
    return c - 87;
  } else if (c >= 'A' && c <= 'F') {
    return c - 55;
  } else {
    return 0;
  }
}

mac_addr_t parse_mac (char* s) {
  mac_addr_t mac = {};
  size_t len = strnlen(s, 18);
  if (len < 17) {
    return mac;
  }
  uint8_t cur_byte = 0;
  size_t j = 0;
  for (size_t i = 0; i < len; i++) {
    if ((s[i] >= '0' && s[i] <= '9')
     || (s[i] >= 'a' && s[i] <= 'f')
     || (s[i] >= 'A' && s[i] <= 'F')) {
      cur_byte = (cur_byte << 4) + parse_hex(s[i]);
    } else if (s[i] == ':') {
      mac.byte[j] = cur_byte;
      cur_byte = 0;
      j++;
    } else {
      return mac;
    }
  }
  mac.byte[j] = cur_byte;
  return mac;
}

ip_addr_t parse_ip (char* s) {
  ip_addr_t ip = {};
  size_t len = strnlen(s, 16);
  if (len < 7) {
    return ip;
  }
  uint8_t cur_number = 0;
  size_t j = 0;
  for (size_t i = 0; i < len; i++) {
    if (s[i] >= '0' && s[i] <= '9') {
      cur_number = cur_number * 10 + (s[i] - 48);
    } else if (s[i] == '.') {
      ip.num[j] = cur_number;
      cur_number = 0;
      j++;
    } else {
      return ip;
    }
  }
  ip.num[j] = cur_number;
  return ip;
}

udp_port_t parse_port(char* s) {
  udp_port_t port = {};
  size_t len = strnlen(s, 6);
  uint16_t cur_number = 0;
  for (size_t i = 0; i < len; i++) {
    if (s[i] >= '0' && s[i] <= '9') {
      cur_number = cur_number * 10 + (s[i] - 48);
    } else {
      return port;
    }
  }
  port.port = __bswap_16(cur_number);
  return port;
}

void com_admin_edit_print_filter_types () {
  printf("filter-type := [srcmac/dstmac/srcip/dstip/srcport/dstport/dns]\n");
}

#include "admin-edit-add.hh"

#include "admin-edit-remove.hh"

#include "admin-edit-set.hh"
