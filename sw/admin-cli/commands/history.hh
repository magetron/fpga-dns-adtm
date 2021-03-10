#pragma once

int com_history (char* arg) {
  while (previous_history());

  size_t lc = 0;

  for (HIST_ENTRY *he = current_history(); he != NULL; he = next_history()) {
    printf("%ld \t %s\n", ++lc, he->line);
  }

  return 0;
}
