#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <errno.h>
#include <unistd.h>

#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <type_traits>

#include "config.hh"

struct [[gnu::packed]] etherlab {
  uint8_t version;
  uint8_t channels;
  uint16_t data[8];
};


uint16_t checksum(uint16_t* buff, int32_t _16bitword)
{
  uint32_t sum;
  for (sum=0; _16bitword>0; _16bitword--) sum += htons(*(buff)++);
  sum = ((sum >> 16) + (sum & 0xFFFF));
  sum += (sum>>16);
  return (uint16_t)(~sum);
}

int main () {
  int32_t sock_raw = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW);
  if (sock_raw == -1) {
    printf("ERROR in socket\n");
  }

  ifreq ifreq_i;
  memset(&ifreq_i, 0, sizeof(ifreq_i));
  strncpy(ifreq_i.ifr_name, "ens37", 6);
  if ((ioctl(sock_raw, SIOCGIFINDEX, &ifreq_i)) < 0) {
    printf("ERROR in index ioctl reading");
  }

  ifreq ifreq_c;
  memset(&ifreq_c, 0, sizeof(ifreq_c));
  strncpy(ifreq_c.ifr_name, "ens37", 6);
  if ((ioctl(sock_raw, SIOCGIFHWADDR, &ifreq_c)) < 0) {
    printf("ERROR in SIOCGIFHWADDR ioctl reading\n");
  }

  uint8_t* sendbuf = new uint8_t[BUFFER_SIZE];

  ethhdr* eth = reinterpret_cast<ethhdr*>(sendbuf);
  eth->h_source[0] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[0]);
  eth->h_source[1] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[1]);
  eth->h_source[2] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[2]);
  eth->h_source[3] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[3]);
  eth->h_source[4] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[4]);
  eth->h_source[5] = (uint8_t)(ifreq_c.ifr_hwaddr.sa_data[5]);
  printf("%02X.%02X.%02X.%02X.%02X.%02X\n", eth->h_source[0], eth->h_source[1],
                                          eth->h_source[2], eth->h_source[3],
                                          eth->h_source[4], eth->h_source[5]);
  eth->h_dest[0] = 0xFF;
  eth->h_dest[1] = 0xFF;
  eth->h_dest[2] = 0xFF;
  eth->h_dest[3] = 0xFF;
  eth->h_dest[4] = 0xFF;
  eth->h_dest[6] = 0xFF;
  eth->h_proto = 0x00;

  auto* ethlab = reinterpret_cast<etherlab*>(eth + 1);

  uint16_t c = 0;
  while (true) {
    ethlab->version=0x10;
    ethlab->channels=0xFF;
    if (c == 255) c = 0;
    else c++;
    ethlab->data[7] = htons(c);

    sockaddr_ll sadr_ll;
    sadr_ll.sll_ifindex = ifreq_i.ifr_ifindex;
    sadr_ll.sll_halen = ETH_ALEN;
    sadr_ll.sll_addr[0] = 0x00;
    sadr_ll.sll_addr[0] = 0x0A;
    sadr_ll.sll_addr[0] = 0x35;
    sadr_ll.sll_addr[0] = 0x00;
    sadr_ll.sll_addr[0] = 0x00;
    sadr_ll.sll_addr[0] = 0x00;

    int32_t send_len = sendto(sock_raw, sendbuf, sizeof(etherlab) + sizeof(ethhdr), 0,
                               reinterpret_cast<const sockaddr*>(&sadr_ll), sizeof(sockaddr_ll));
    if (send_len < 0) {
      printf("ERROR in sending, sendlen=%d, errno=%d\n", send_len, errno);
      perror("Socket:");
      return -1;
    }
    usleep(1e6);
  }

  delete [] sendbuf;

  return 0;
}
