#pragma once

static inline void parse_args (int argc, char** argv) {
  int c;
  opterr = 0;
  while ((c = getopt(argc, argv, "pf:h")) != -1) {
    switch (c) {
      case 'p':
        probe_board_on_launch = 1;
        break;
      case 'f':
        if_length = strnlen(optarg, IF_NAMESIZE);
        strncpy(if_name, optarg, if_length + 1);
        break;
      default:
        printf("Unrecognised argument\n");
      case 'h':
        printf("Usage:\n"
               "-f [interface-name] \t specify interface\n"
               "-p                  \t specify if probe FPGA on CLI launch\n");
        exit(0);
    }
  }
}
