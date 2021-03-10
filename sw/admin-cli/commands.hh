#pragma once

typedef int rl_icpfunc_t (char *);

int com_history (char *);
int com_help (char *);
int com_admin (char *);
int com_quit (char *);
int com_clear (char *);


typedef struct {
   const char *name;                   /* User printable name of the function. */
   rl_icpfunc_t *func;           /* Function to call to do the job. */
   const char *doc;                    /* Documentation for this function.  */
} COMMAND;

COMMAND commands[] = {
  { "admin", com_admin, "FPGA filter administrator utilities" },
  { "history", com_history, "list history" },
  { "clear", com_clear, "clear the screen" },
  { "quit", com_quit, "quit FPGA administrator cli" },
  { "help", com_help, "display this text" },
  { "?", com_help, "synonym for `help'" },
  { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

COMMAND* find_command (char* name, COMMAND* commands) {
  for (int i = 0; commands[i].name; i++)
    if (strcmp (name, commands[i].name) == 0)
      return (&commands[i]);
  return ((COMMAND *)nullptr);
}

int execute (char* line, COMMAND* commands) {
  size_t i = 0;
  while (line[i] && !isspace(line[i])) i++;
  line[i++] = '\0';

  COMMAND* command = find_command(line, commands);

  if (!command) {
    fprintf (stderr, "%s: no such command\n", line);
    return -1;
  }

  while (line[i] && isspace (line[i])) i++;

  return ((*(command->func)) (&line[i]));
}

#include "commands/history.hh"
#include "commands/help.hh"
#include "commands/admin.hh"

int com_quit (char* arg) {
  done = 1;
  return 0;
}

int com_clear (char* arg) {
  printf("\u001B[2J\u001B[0;0f");
  return 0;
}
