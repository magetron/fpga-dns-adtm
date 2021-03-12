#pragma once

#include <net/if.h>

int done = 0;

char if_name[IF_NAMESIZE + 1] = "enp8s0";
size_t if_length = 0;
uint8_t probe_board_on_launch = 0;
