#pragma once

int com_stats_show (char*);
int com_stats_help (char*);
int com_stats_probe(char*);

COMMAND stats_commands[] = {
  { "show", com_stats_show, "show filter stats from FPGA (in-cache)" },
  { "probe", com_stats_probe, "probe FPGA for latest filter stats"},
  { "help", com_stats_help, "display this text" },
  { "?", com_stats_help, "synonym for `help'" },
  { (char *)nullptr, (rl_icpfunc_t *)nullptr, (char *)nullptr }
};

int com_stats (char* arg) {
  if (!*arg) {
    com_stats_help(arg);
  } else {
    execute(arg, stats_commands);
  }
  return 0;
}

int com_stats_help (char* arg) {
  print_help(arg, stats_commands);
  return 0;
}

#include "stats-show.hh"

#include "stats-probe.hh"
