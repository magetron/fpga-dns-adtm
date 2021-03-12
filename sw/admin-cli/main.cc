#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <thread>

#include <editline/readline.h>
#include <getopt.h>

#include "const.hh"
#include "string-ops.hh"
#include "file-ops.hh"

#include "main.hh"

#include "fpga.hh"
#include "filter.hh"
#include "net-ops.hh"
#include "sender.hh"
#include "receiver.hh"
#include "probe-parser.hh"

#include "args-parser.hh"
#include "commands.hh"
#include "completion.hh"

int main(int argc, char** argv) {
  parse_args(argc, argv);

  printf("Greetings! FPGA administrator v0.1, https://github.com/magetron/cpu-fpga-nwofle\n");

  initialise_readline();
  initialise_fpga_configuration();
  initialise_network_randomiser();
  
  initialise_sender_socket();
  initialise_receiver_socket_and_thread();
  stifle_history(HISTORY_LENGTH);

  printf("currently operating on %s\n", if_name);

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

  teardown_sender();
  teardown_receiver_socket_and_thread();

  printf("Bye!\n");
  
  return 0;
}
