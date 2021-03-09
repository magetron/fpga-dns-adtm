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

void trigger_send (const ifreq& ifreq_i, const int32_t sock_raw) {
  sockaddr_ll sadr_ll;
  sadr_ll.sll_ifindex = ifreq_i.ifr_ifindex;
  sadr_ll.sll_halen = ETH_ALEN;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x0A;
  sadr_ll.sll_addr[0] = 0x35;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x00;

  int32_t send_len = sendto(sock_raw, PKTBUF, PAYLOAD_LENGTH + sizeof(udphdr) + sizeof(iphdr) + sizeof(ethhdr), 0,
                            reinterpret_cast<const sockaddr *>(&sadr_ll), sizeof(sockaddr_ll));
  if (send_len < 0)
  {
    printf("ERROR in sending, sendlen=%d, errno=%d\n", send_len, errno);
    perror("Socket:");
    exit(1);
  }

  usleep(SEND_TIME);
}

void form_packet (const ifreq& ifreq_c, const ifreq& ifreq_i) {

  ethhdr *eth = reinterpret_cast<ethhdr *>(PKTBUF);
  eth->h_source[0] = MAC_ADDRS[0].byte[0];
  eth->h_source[1] = MAC_ADDRS[0].byte[1];
  eth->h_source[2] = MAC_ADDRS[0].byte[2];
  eth->h_source[3] = MAC_ADDRS[0].byte[3];
  eth->h_source[4] = MAC_ADDRS[0].byte[4];
  eth->h_source[5] = MAC_ADDRS[0].byte[5];
  eth->h_dest[0] = MAC_ADDRS[1].byte[0];
  eth->h_dest[1] = MAC_ADDRS[1].byte[1];
  eth->h_dest[2] = MAC_ADDRS[1].byte[2];
  eth->h_dest[3] = MAC_ADDRS[1].byte[3];
  eth->h_dest[4] = MAC_ADDRS[1].byte[4];
  eth->h_dest[5] = MAC_ADDRS[1].byte[5];
  eth->h_proto = htons(static_cast<uint16_t>(e_ethertype::IPv4));

  printf("src MAC: %02X:%02X:%02X:%02X:%02X:%02X\n", eth->h_source[0], eth->h_source[1],
         eth->h_source[2], eth->h_source[3],
         eth->h_source[4], eth->h_source[5]);
  printf("dst MAC: %02X:%02X:%02X:%02X:%02X:%02X\n", eth->h_dest[0], eth->h_dest[1],
        eth->h_dest[2], eth->h_dest[3],
        eth->h_dest[4], eth->h_dest[5]);

  iphdr *ip = reinterpret_cast<iphdr *>(eth + 1);
  ip->ihl = 5;
  ip->version = 4;
  ip->tos = 16;
  ip->id = htons(10201);
  ip->ttl = 64;
  ip->protocol = 17;
  ip->saddr = *reinterpret_cast<uint32_t*>(&IP_ADDRS[0]);
  ip->daddr = *reinterpret_cast<uint32_t*>(&IP_ADDRS[1]);

  char ipstr[INET_ADDRSTRLEN];
  printf("src IP: %s\n", inet_ntop(AF_INET, &(ip->saddr), ipstr, INET_ADDRSTRLEN));
  printf("dst IP: %s\n", inet_ntop(AF_INET, &(ip->daddr), ipstr, INET_ADDRSTRLEN));

  udphdr *udp = reinterpret_cast<udphdr *>(ip + 1);
  udp->source = htons(UDP_PORTS[0].port);
  udp->dest = htons(UDP_PORTS[1].port);
  udp->check = 0;
  printf("src Port: %d\n", ntohs(udp->source));
  printf("dst Port: %d\n", ntohs(udp->dest));

  char *payload = reinterpret_cast<char *>(udp + 1);
  if (PACKET_MODE == packet_mode_t::UDP_TEST) {
    memcpy(payload, "test01", 7);
    PAYLOAD_LENGTH = 7;
  } else {
    memcpy(payload, PAYLOAD, PAYLOAD_LENGTH);
  }

  udp->len = htons(PAYLOAD_LENGTH + sizeof(udphdr));
  ip->tot_len = htons(PAYLOAD_LENGTH + sizeof(udphdr) + sizeof(iphdr));
  ip->check = htons(IPchecksum(reinterpret_cast<uint16_t *>(ip), (sizeof(iphdr) / 2)));

}

void change_packet () {
  // DO NOTHING
}

int main (int argc, char** argv) {
  parse_args_sender(argc, argv);

  // init socket
  int32_t sock_raw = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW);
  if (sock_raw == -1)
  {
    printf("ERROR in socket\n");
  }
  ifreq ifreq_i;
  memset(&ifreq_i, 0, sizeof(ifreq_i));
  printf("%s\n", INTF_NAME);
  strncpy(ifreq_i.ifr_name, INTF_NAME, strnlen(INTF_NAME, INTF_LENGTH));
  if ((ioctl(sock_raw, SIOCGIFINDEX, &ifreq_i)) < 0)
  {
    printf("ERROR in index ioctl reading");
  }
  ifreq ifreq_c;
  memset(&ifreq_c, 0, sizeof(ifreq_c));
  strncpy(ifreq_c.ifr_name, INTF_NAME, strnlen(INTF_NAME, INTF_LENGTH));
  if ((ioctl(sock_raw, SIOCGIFHWADDR, &ifreq_c)) < 0)
  {
    printf("ERROR in SIOCGIFHWADDR ioctl reading\n");
  }

  form_packet(ifreq_c, ifreq_i);
  if (SEND_MODE == send_mode_t::DAEMON) {
    while (true) {
      trigger_send(ifreq_i, sock_raw);
    }
  } else if (SEND_MODE == send_mode_t::ONCE) {
    trigger_send(ifreq_i, sock_raw);
  } else if (SEND_MODE == send_mode_t::CHANGING) {
    while (true) {
      trigger_send(ifreq_i, sock_raw);
      change_packet();
      form_packet(ifreq_c, ifreq_i);
    }
  }

  return 0;
}
