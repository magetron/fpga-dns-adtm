#include <cstdio>
#include <cstdlib>
#include <cstdint>

#include <editline/readline.h>
#include <getopt.h>

#include "const.hh"
#include "string-ops.hh"
#include "file-ops.hh"

#include "main.hh"

#include "fpga.hh"
#include "filter.hh"
#include "sender.hh"

#include "args-parser.hh"
#include "commands.hh"
#include "completion.hh"

int main(int argc, char** argv) {
  parse_args(argc, argv);

  printf("FPGA administrator v0.1, https://github.com/magetron/cpu-fpga-nwofle\n");

  initialise_readline();
  initialise_fpga_configuration();
  initialise_send_socket();
  stifle_history(HISTORY_LENGTH);

  char* buf;
  char* line;
  while (!done && (buf = readline("> ")) != nullptr) {
    line = stripwhite(buf);

    if (strlen(line) > 0) {
      add_history(line);
      execute(line, commands);
    }

    free(buf);
  }

  return 0;
}
