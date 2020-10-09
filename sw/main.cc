#define BUFFER_SIZE 65536

#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <arpa/inet.h>

#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <type_traits>

int main () {
  int32_t sock_r = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  if (sock_r < 0) {
    printf("Error in opening raw socket\n");
    return -1;
  }

  uint8_t* buffer = reinterpret_cast<uint8_t*>(malloc(BUFFER_SIZE));
  memset(buffer, 0, BUFFER_SIZE);
  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);

  while (true) {
    size_t pkt_size = recvfrom(sock_r, buffer, BUFFER_SIZE, 0,
                               &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));
    ethhdr *eth = reinterpret_cast<ethhdr*>(buffer);
    printf("\nEthernet Header\n");
    printf("\t|-Source Address : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X\n", eth->h_source[0],eth->h_source[1],eth->h_source[2],eth->h_source[3],eth->h_source[4],eth->h_source[5]);
    printf("\t|-Destination Address : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X\n", eth->h_dest[0],eth->h_dest[1],eth->h_dest[2],eth->h_dest[3],eth->h_dest[4],eth->h_dest[5]);
    printf("\t|-Protocol : 0x%04X\n", ntohs(eth->h_proto));

  }

  return 0;
}
