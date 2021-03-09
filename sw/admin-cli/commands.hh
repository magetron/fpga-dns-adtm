#pragma once

typedef int rl_icpfunc_t (char *);

int com_history (char *);
int com_help (char *);

typedef struct {
   const char *name;                   /* User printable name of the function. */
   rl_icpfunc_t *func;           /* Function to call to do the job. */
   const char *doc;                    /* Documentation for this function.  */
} COMMAND;

COMMAND commands[] = {
   { "history", com_history, "list history" },
   { "help", com_help, "display this text" },
   { "?", com_help, "synonym for `help'" },
   { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

int com_history (char* arg) {
  while (previous_history());

  size_t lc = 0;

  for (HIST_ENTRY *he = current_history(); he != NULL; he = next_history()) {
    printf("%ld \t %s\n", ++lc, he->line);
  }

  return 0;
}

int com_help (char *arg) {
  int printed = 0;

  for (int i = 0; commands[i].name; i++) {
    if (!*arg || (strcmp (arg, commands[i].name) == 0)) {
      printf("%s\t\t%s.\n", commands[i].name, commands[i].doc);
      printed++;
    }
  }

  if (!printed) {
  printf("No commands match `%s'. Possibilties are:\n", arg);

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

  return 0;
}
