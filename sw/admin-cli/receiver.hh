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

uint8_t recv_pkt_buf[BUFFER_SIZE];
ssize_t recv_pkt_length = 0;
ifreq recv_ifreq;
int32_t recv_sock_raw;

void initialise_receiver_socket () {
  recv_sock_raw = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  if (recv_sock_raw == -1) {
    fprintf(stderr, "ERROR in socket\n");
  }
  sockaddr_ll sadr_ll;
  memset(&sadr_ll, 0, sizeof(sadr_ll));
  memset(&recv_ifreq, 0, sizeof(recv_ifreq));
  strncpy((char *)recv_ifreq.ifr_name, if_name, IF_NAMESIZE);
  if((ioctl(recv_sock_raw, SIOCGIFINDEX, &recv_ifreq)) == -1) {
    fprintf(stderr, "ERROR in index ioctl reading!\n");
  }
  sadr_ll.sll_family = AF_PACKET;
  sadr_ll.sll_ifindex = recv_ifreq.ifr_ifindex;
  sadr_ll.sll_protocol = htons(ETH_P_ALL);
  if((bind(recv_sock_raw, (struct sockaddr *)&sadr_ll, sizeof(sadr_ll)))== -1) {
    perror("ERROR in binding raw socket to interface\n");
  }

}

void trigger_recv () {
  printf("receiving pkt...");

  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);

  recv_pkt_length = recvfrom(recv_sock_raw, recv_pkt_buf, BUFFER_SIZE, 0,
                             &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));

  if (recv_pkt_length == -1) {
    fprintf(stderr, "ERROR in receiving, recv_len=%ld, errno=%d\n", recv_pkt_length, errno);
    perror("Socket:");
  } else {
    printf("recv done\n");
  }

}

void trigger_recv(mac_addr_t target_src_mac, size_t timeout) {

  printf("receiving pkt...");

  sockaddr s_addr;
  size_t s_addr_len = sizeof(s_addr);
  size_t timec = 0;
  mac_addr_t* dstmac = nullptr;
  mac_addr_t* srcmac = nullptr;

  do {
    recv_pkt_length = recvfrom(recv_sock_raw, recv_pkt_buf, BUFFER_SIZE, 0,
                             &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));
    if (recv_pkt_length == -1) {
      fprintf(stderr, "ERROR in receiving, recv_len=%ld, errno=%d\n", recv_pkt_length, errno);
      perror("Socket:");
      return;
    }
    dstmac = reinterpret_cast<mac_addr_t*>(recv_pkt_buf);
    srcmac = dstmac + 1;
    timec++;
  } while (memcmp(&target_src_mac, srcmac, sizeof(mac_addr_t)) != 0 && timec <= timeout);

  if (timec > timeout) {
    fprintf(stderr, "ERROR receiving probe reponse pkt, timeout reached\n");
  } else {
    printf("recv done\n");
  }

}

