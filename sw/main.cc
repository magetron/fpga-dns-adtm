#define BUFFER_SIZE 65536
#define IP_ETHERTYPE 0x0800
#define TCP_IP_PROTO 0x06
#define UDP_IP_PROTO 0x11

#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

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
  setsockopt(sock_r, SOL_SOCKET, SO_BINDTODEVICE, "lo", 3);

  uint8_t* buffer = reinterpret_cast<uint8_t*>(malloc(BUFFER_SIZE));
  memset(buffer, 0, BUFFER_SIZE);
  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);

  while (true) {
    size_t pkt_size = recvfrom(sock_r, buffer, BUFFER_SIZE, 0,
                               &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));
    ethhdr *eth = reinterpret_cast<ethhdr*>(buffer);

    if (ntohs(eth->h_proto) == IP_ETHERTYPE) {
      iphdr* ip = reinterpret_cast<iphdr*>(eth + 1);
      in_addr src; src.s_addr = ip->saddr;
      in_addr dst; dst.s_addr = ip->daddr;

      switch (ip->protocol) {
        case TCP_IP_PROTO:
          break;
        case UDP_IP_PROTO:
          udphdr* udp = reinterpret_cast<udphdr*>(ip + 1);
          printf("\nEthernet Header\n");
          printf("\t|-Source Address : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X\n", eth->h_source[0],eth->h_source[1],eth->h_source[2],eth->h_source[3],eth->h_source[4],eth->h_source[5]);
          printf("\t|-Destination Address : %.2X-%.2X-%.2X-%.2X-%.2X-%.2X\n", eth->h_dest[0],eth->h_dest[1],eth->h_dest[2],eth->h_dest[3],eth->h_dest[4],eth->h_dest[5]);
          printf("\t|-Protocol : 0x%04X\n", ntohs(eth->h_proto));
          printf("IP Header\n");
          printf("\t|-Version : %d\n",(uint32_t)ip->version);
          printf("\t|-Internet Header Length : %d DWORDS or %d Bytes\n", (uint32_t)ip->ihl,((uint32_t)(ip->ihl))*4);
          printf("\t|-Type Of Service : %d\n", (uint32_t)ip->tos);
          printf("\t|-Total Length : %d Bytes\n", ntohs(ip->tot_len));
          printf("\t|-Identification : %d\n", ntohs(ip->id));
          printf("\t|-Time To Live : %d\n", (uint32_t)ip->ttl);
          printf("\t|-Protocol : %d\n",(uint32_t)ip->protocol);
          printf("\t|-Header Checksum : %d\n", ntohs(ip->check));
          printf("\t|-Source IP : %s\n", inet_ntoa(src));
          printf("\t|-Destination IP : %s\n", inet_ntoa(dst));
          printf("UDP Header\n");
          printf("\t|-Source Port : %d\n", udp->source);
          printf("\t|-Dst Port : %d\n", udp->dest);
          printf("\t|-Length : %d\n", udp->len);
          printf("\t|-Checksum : %d\n", udp->check);
          break;
      }
    }

  }

  return 0;
}
