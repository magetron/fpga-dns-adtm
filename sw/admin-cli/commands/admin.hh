#pragma once

#include "filter-printer.hh"

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
  execute(arg, admin_commands);
  return 0;
}

int com_admin_help (char* arg) {
  print_help(arg, admin_commands);
  return 0;
}

int com_admin_show (char* arg) {
  if (strncmp(arg, "fpga", 5) == 0) {
    print_filter_configuration(f);
  } else if (strncmp(arg, "curr", 5) == 0) {
    print_filter_configuration(f_curr);
  } else {
    fprintf (stderr, "%s: specify [fpga/curr]\n", arg);
    return -1;
  }
  return 0;
}

int com_admin_edit (char* arg) {
  printf("admin edit arg=[%s]\n", arg);
  return 0;
}

int com_admin_apply (char* arg) {
  printf("admin apply arg=[%s]\n", arg);
  return 0;
}

