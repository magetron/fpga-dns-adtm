#pragma once

stats_t s;

void print_stats (stats_t s) {
  printf("valid packets received            = %ld\n", s.stc);
  printf("valid packets replied             = %ld (%.6lf%%)\n", s.sfc, (double)s.sfc/s.stc * 100);
  printf("valid packets passed MAC filters  = %ld (%.6lf%%)\n", s.smc, (double)s.smc/s.stc * 100);
  printf("valid packets passed IP filters   = %ld (%.6lf%%)\n", s.sic, (double)s.sic/s.stc * 100);
  printf("valid packets passed UDP filters  = %ld (%.6lf%%)\n", s.spc, (double)s.spc/s.stc * 100);
  printf("valid packets passed DNS filters  = %ld (%.6lf%%)\n", s.sfc, (double)s.sfc/s.stc * 100);
}
