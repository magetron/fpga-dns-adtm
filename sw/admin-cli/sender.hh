#pragma once

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

uint8_t send_pkt_buf[BUFFER_SIZE];
size_t send_pkt_length = 0;
ifreq send_ifreq_i;
ifreq send_ifreq_c;
int32_t send_sock_raw;

void initialise_sender_socket () {
  printf("initialising sender socket...\n");

  send_sock_raw = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW);
  if (send_sock_raw == -1) {
    fprintf(stderr, "ERROR in socket\n");
  }
  memset(&send_ifreq_i, 0, sizeof(send_ifreq_i));
  strncpy(send_ifreq_i.ifr_name, if_name, if_length);
  if ((ioctl(send_sock_raw, SIOCGIFINDEX, &send_ifreq_i)) < 0) {
    fprintf(stderr, "ERROR in index ioctl reading\n");
  }
  memset(&send_ifreq_c, 0, sizeof(send_ifreq_c));
  strncpy(send_ifreq_c.ifr_name, if_name, if_length);
  if ((ioctl(send_sock_raw, SIOCGIFHWADDR, &send_ifreq_c)) < 0) {
    fprintf(stderr, "ERROR in SIOCGIFHWADDR ioctl reading\n");
  }
}

void teardown_sender () {
  printf("tearing down sender socket...\n");

  shutdown(send_sock_raw, SHUT_RDWR);
  close(send_sock_raw);
}

void trigger_send () {

  printf("sending pkt...");

  sockaddr_ll sadr_ll;
  sadr_ll.sll_ifindex = send_ifreq_i.ifr_ifindex;
  sadr_ll.sll_halen = ETH_ALEN;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x0A;
  sadr_ll.sll_addr[0] = 0x35;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x00;
  sadr_ll.sll_addr[0] = 0x00;

  ssize_t send_len = sendto(send_sock_raw, send_pkt_buf, send_pkt_length + sizeof(udphdr) + sizeof(iphdr) + sizeof(ethhdr), 0,
                            reinterpret_cast<const sockaddr *>(&sadr_ll), sizeof(sockaddr_ll));
  if (send_len < 0) {
    fprintf(stderr, "ERROR in sending, sendlen=%ld, errno=%d\n", send_len, errno);
    perror("Socket:");
  } else {
    printf("send done\n");
  }
}

void form_packet (const mac_addr_t& srcmac, const mac_addr_t& dstmac,
                  const ip_addr_t& srcip, const ip_addr_t& dstip,
                  const udp_port_t& srcport, const udp_port_t& dstport,
                  const uint8_t* udp_payload, const size_t udp_payload_length) {

  printf("forming pkt...\n");

  send_pkt_length = udp_payload_length;

  ethhdr *eth = reinterpret_cast<ethhdr *>(send_pkt_buf);
  eth->h_source[0] = srcmac.byte[0];
  eth->h_source[1] = srcmac.byte[1];
  eth->h_source[2] = srcmac.byte[2];
  eth->h_source[3] = srcmac.byte[3];
  eth->h_source[4] = srcmac.byte[4];
  eth->h_source[5] = srcmac.byte[5];
  eth->h_dest[0] = dstmac.byte[0];
  eth->h_dest[1] = dstmac.byte[1];
  eth->h_dest[2] = dstmac.byte[2];
  eth->h_dest[3] = dstmac.byte[3];
  eth->h_dest[4] = dstmac.byte[4];
  eth->h_dest[5] = dstmac.byte[5];
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
  ip->saddr = *reinterpret_cast<const uint32_t*>(&srcip);
  ip->daddr = *reinterpret_cast<const uint32_t*>(&dstip);

  char ipstr[INET_ADDRSTRLEN];
  printf("src IP: %s\n", inet_ntop(AF_INET, &(ip->saddr), ipstr, INET_ADDRSTRLEN));
  printf("dst IP: %s\n", inet_ntop(AF_INET, &(ip->daddr), ipstr, INET_ADDRSTRLEN));

  udphdr *udp = reinterpret_cast<udphdr *>(ip + 1);
  udp->source = htons(srcport.port);
  udp->dest = htons(dstport.port);
  udp->check = 0;
  printf("src Port: %d\n", ntohs(udp->source));
  printf("dst Port: %d\n", ntohs(udp->dest));

  char *payload = reinterpret_cast<char *>(udp + 1);
  memcpy(payload, udp_payload, udp_payload_length);

  udp->len = htons(udp_payload_length + sizeof(udphdr));
  ip->tot_len = htons(udp_payload_length + sizeof(udphdr) + sizeof(iphdr));
  ip->check = htons(IPchecksum(reinterpret_cast<uint16_t *>(ip), (sizeof(iphdr) / 2)));

}
