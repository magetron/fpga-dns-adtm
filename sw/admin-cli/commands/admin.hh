#pragma once

int com_admin_show (char*);
int com_admin_edit (char*);
int com_admin_help (char*);
int com_admin_apply(char*);
int com_admin_probe(char*);

COMMAND admin_commands[] = {
  { "show", com_admin_show, "show current / on-FPGA admin configurations [fpga/curr]" },
  { "edit", com_admin_edit, "edit current admin configurations" },
  { "apply", com_admin_apply, "apply current admin configurations" },
  { "probe", com_admin_probe, "probe FPGA for on-board configuration"},
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

#include "admin-probe.hh"
