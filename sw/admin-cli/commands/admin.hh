#pragma once

static const mac_addr_t admin_dst_mac = {0x00, 0x0a, 0x35, 0xff, 0xff, 0xff};

int com_admin_show (char*);
int com_admin_edit (char*);
int com_admin_help (char*);
int com_admin_apply(char*);

COMMAND admin_commands[] = {
  { "show", com_admin_show, "show current / on-FPGA admin configurations [fpga/curr]" },
  { "edit", com_admin_edit, "edit current admin configurations" },
  { "apply", com_admin_apply, "apply current admin configurations" },
  { "help", com_admin_help, "display this text" },
  { "?", com_admin_help, "synonym for `help'" },
  { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

int com_admin (char* arg) {
  if (!*arg) {
    com_admin_help(arg);
  } else {
    execute(arg, admin_commands);
  }
  return 0;
}

int com_admin_help (char* arg) {
  print_help(arg, admin_commands);
  return 0;
}

#include "admin-show.hh"

#include "admin-edit.hh"

#include "admin-apply.hh"

