int com_admin_show (char* arg) {
  if (strncmp(arg, "fpga", 5) == 0) {
    print_filter_configuration(f);
  } else if (strncmp(arg, "curr", 5) == 0) {
    print_filter_configuration(f_curr);
  } else {
    fprintf (stderr, "%s: specify [fpga/curr]\n", arg);
    return -1;
  }
  return 0;
}
