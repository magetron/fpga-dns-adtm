#pragma once

void print_help (char* arg, COMMAND* commands) {
  int printed = 0;

  for (int i = 0; commands[i].name; i++) {
    if (!*arg || (strcmp (arg, commands[i].name) == 0)) {
      printf("%s\t\t%s\n", commands[i].name, commands[i].doc);
      printed++;
    }
  }

  if (!printed) {
  printf("No commands match '%s'. Possibilties are:\n", arg);

  for (int i = 0; commands[i].name; i++) {
    if (printed == 6) {
      printed = 0;
      printf ("\n");
    }
    printf ("%s\t", commands[i].name);
    printed++;
  }

  if (printed) printf ("\n");
  }
}

int com_help (char *arg) {
  print_help(arg, commands);
  return 0;
}
