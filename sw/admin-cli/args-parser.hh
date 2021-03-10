#pragma once

static inline void parse_args (int argc, char** argv) {
  int c;
  opterr = 0;
  while ((c = getopt(argc, argv, "f:h")) != -1) {
    switch (c) {
      case 'f':
        if_length = strnlen(optarg, IF_NAMESIZE);
        strncpy(if_name, optarg, if_length);
        break;
      case 'h':
      default:
        printf("Unrecognised argument\n");
        printf("Usage:\n"
               "sudo ./main.out -f en0\n");
        exit(0);
    }
  }
}
