#include <cstdio>
#include <cstdlib>

#include <editline/readline.h>

#include "const.hh"
#include "string-ops.hh"
#include "commands.hh"
#include "completion.hh"

COMMAND* find_command (char* name) {
  for (int i = 0; commands[i].name; i++)
    if (strcmp (name, commands[i].name) == 0)
      return (&commands[i]);
  return ((COMMAND *)nullptr);
}

int execute_line (char* line) {
  size_t i = 0;
  while (line[i] && !isspace(line[i])) i++;
  line[i++] = '\0';

  COMMAND* command = find_command(line);

  if (!command) {
    fprintf (stderr, "%s: no such command\n", line);
    return (-1);
  }

  while (line[i] && isspace (line[i])) i++;

  return line[i] ? ((*(command->func)) (&line[i])) : ((*(command->func)) (&line[i]));
}

int main(int argc, char** argv) {
  printf("FPGA administrator v0.1, press Ctrl+C to exit ...\n");

  initialize_readline();
  stifle_history(HISTORY_LENGTH);

  char* buf;
  char* line;
  while ((buf = readline("> ")) != nullptr) {
    line = stripwhite(buf);
    
    if (strlen(line) > 0) {
      add_history(line);
      execute_line(line);
    }

    free(buf);
  }

  return 0;
}
