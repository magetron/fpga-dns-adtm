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

int com_admin_edit_add (char* arg) {
  printf("admin edit add arg=[%s]\n", arg);
  return 0;
}

int com_admin_edit_remove (char* arg) {
  printf("admin edit remove arg=[%s]\n", arg);
  return 0;
}

int com_admin_edit_set (char* arg) {
  printf("admin edit set arg=[%s]\n", arg);
  return 0;
}
