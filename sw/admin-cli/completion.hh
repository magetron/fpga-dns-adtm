// ONLY top-level command completion at the moment

#pragma once
#include <cstring>
#include <editline/readline.h>

char *command_generator(const char *, int);
char **admincli_completion(const char *, int, int);

void initialise_readline () {
   rl_readline_name = "admincli";
   rl_attempted_completion_function = admincli_completion;
}

char** admincli_completion (const char* text, int start, int end) {
  char **matches = (char **)nullptr;

  if (start == 0)
    matches = completion_matches((char*)text, command_generator);

  return (matches);
}

char* command_generator (const char *text, int state) {
  static int list_index, len;
  const char *name;

  if (!state) {
    list_index = 0;
    len = strlen (text);
  }

  while ((name = commands[list_index].name)) {
    list_index++;

    if (strncmp(name, text, len) == 0)
      return dupstr(name);
    }

  return (char *)nullptr;
}
