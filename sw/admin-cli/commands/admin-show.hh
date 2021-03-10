static inline int print_filter_BW (unsigned bw) {
  return bw ? printf("\tWhitelisted") : printf("\tBlacklisted");
}

static inline void print_MAC (mac_addr_t* mac) {
  printf("\t%02X:%02X:%02X:%02X:%02X:%02X",
    mac->byte[0], mac->byte[1],
    mac->byte[2], mac->byte[3],
    mac->byte[4], mac->byte[5]);
}

static inline void print_IP (ip_addr_t* ip) {
  printf("\t%d.%d.%d.%d",
    ip->num[0], ip->num[1], ip->num[2], ip->num[3]);
}

void print_filter_configuration (filter_t f) {
  printf("src MAC\n");
  if (f.srcMACLength > 0) {
    print_filter_BW(f.srcMACBW); printf("\n");
    for (unsigned i = 0; i < f.srcMACLength; i++) {
      print_MAC(&f.srcMACList[i]); printf("\n");
    }
  } else {
    printf("\tNone\n");
  }

  printf("dst MAC\n");
  if (f.dstMACLength > 0) {
    print_filter_BW(f.dstMACBW); printf("\n");
    for (unsigned i = 0; i < f.dstMACLength; i++) {
      print_MAC(&f.dstMACList[i]); printf("\n");
    }
  } else {
    printf("\tNone\n");
  }

  printf("src IP\n");
  if (f.srcIPLength > 0) {
    print_filter_BW(f.srcIPBW); printf("\n");
    for (unsigned i = 0; i < f.srcIPLength; i++) {
      print_IP(&f.srcIPList[i]); printf("\n");
    }
  } else {
    printf("\tNone\n");
  }

  printf("dst IP\n");
  if (f.dstIPLength > 0) {
    print_filter_BW(f.dstIPBW); printf("\n");
    for (unsigned i = 0; i < f.dstIPLength; i++) {
      print_IP(&f.dstIPList[i]); printf("\n");
    }
  } else {
    printf("\tNone\n");
  }

  printf("src UDP port\n");
  if (f.srcPortLength > 0) {
    print_filter_BW(f.srcPortBW); printf("\n");
    for (unsigned i = 0; i < f.srcPortLength; i++) {
      printf("\t%d", __bswap_16(f.srcPortList[i].port));
    }
    printf("\n");
  } else {
    printf("\tNone\n");
  }

  printf("dst UDP port\n");
  if (f.dstPortLength > 0) {
    print_filter_BW(f.dstPortBW); printf("\n");
    for (unsigned i = 0; i < f.dstPortLength; i++) {
      printf("\t%d", __bswap_16(f.dstPortList[i].port));
    }
    printf("\n");
  } else {
    printf("\tNone\n");
  }

  printf("DNS string\n");
  if (f.dnsLength > 0) {
    print_filter_BW(f.dnsBW); printf("\n");
    for (unsigned i = 0; i < f.dnsLength; i++) {
      printf("\t");
      printf("bits = %d [", f.dnsItemEndPtr[i]);
      unsigned l = ((unsigned)(f.dnsItemEndPtr[i]) + 7) / 8;
      for (unsigned j = 0; j < l; j++) {
        printf("%c", f.dnsList[i].c[j]);
      }
      printf("]\n");
    }
  }
}

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
