#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <errno.h>

#include "fpga-prober.hh"
#include "parser.hh"

int bind_raw_sock_to_intf (char *device, int rawsock, int protocol)
{
  struct sockaddr_ll sll;
  struct ifreq ifr;

  memset(&sll, 0, sizeof(sll));
  memset(&ifr, 0, sizeof(ifr));
  strncpy((char *)ifr.ifr_name, device, INTF_LENGTH);
  if((ioctl(rawsock, SIOCGIFINDEX, &ifr)) == -1) {
    printf("Error getting Interface index !\n");
    exit(-1);
  }
  sll.sll_family = AF_PACKET;
  sll.sll_ifindex = ifr.ifr_ifindex;
  sll.sll_protocol = htons(protocol);
  if((bind(rawsock, (struct sockaddr *)&sll, sizeof(sll)))== -1) {
    perror("Error binding raw socket to interface\n");
    exit(-1);
  }
  return 1;
}

int main (int argc, char** argv) {
  parse_args_receiver(argc, argv);

  int32_t sock_r = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  if (sock_r < 0) {
    printf("Error in opening raw socket\n");
    perror("Socket:");
    return -1;
  }

  bind_raw_sock_to_intf(INTF_NAME, sock_r, ETH_P_ALL);

  uint8_t* buffer = new uint8_t[BUFFER_SIZE];
  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);

  while (true) {
    size_t pkt_size = recvfrom(sock_r, buffer, BUFFER_SIZE, 0,
                               &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));
    ethhdr *eth = reinterpret_cast<ethhdr*>(buffer);

    printf("%02X.%02X.%02X.%02X.%02X.%02X, size = %ld\n",
        eth->h_source[0], eth->h_source[1],
        eth->h_source[2], eth->h_source[3],
        eth->h_source[4], eth->h_source[5],
        pkt_size);

  }

  delete [] buffer;

  return 0;
}
