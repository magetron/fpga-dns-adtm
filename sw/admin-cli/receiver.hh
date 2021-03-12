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

uint8_t recv_pkt_buf[BUFFER_SIZE];
ssize_t recv_pkt_length = 0;
ifreq recv_ifreq;
int32_t recv_sock_raw;
uint8_t probe_pkt_buf[BUFFER_SIZE];
ssize_t probe_pkt_length = 0;

int trigger_recv (uint8_t debug);
void probe_receiver_daemon ();
std::thread probe_receiver_thread;
volatile uint8_t probe_receiver_shutdown = 0;
volatile uint8_t probe_reply_received = 0;

void probe_receiver_daemon () {
  do {
    if (trigger_recv(0) == 0) {
      mac_addr_t* dstmac = reinterpret_cast<mac_addr_t*>(recv_pkt_buf);
      mac_addr_t* srcmac = dstmac + 1;
      if (memcmp(&probe_dst_mac, srcmac, sizeof(mac_addr_t)) == 0) {
        memcpy(probe_pkt_buf, recv_pkt_buf, recv_pkt_length);
        probe_pkt_length = recv_pkt_length;
        probe_reply_received = 1;
      }
    }
  } while (!probe_receiver_shutdown);
}

void initialise_receiver_socket_and_thread () {
  printf("initialising receiver socket and thread...\n");

  recv_sock_raw = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  if (recv_sock_raw == -1) {
    fprintf(stderr, "ERROR in socket\n");
  }
  timeval read_timeout;
  read_timeout.tv_sec = 1;
  read_timeout.tv_usec = 0;
  setsockopt(recv_sock_raw, SOL_SOCKET, SO_RCVTIMEO, &read_timeout, sizeof read_timeout);

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

  probe_receiver_thread = std::thread{probe_receiver_daemon};
}

void teardown_receiver_socket_and_thread () {
  printf("tearing down receiver socket and thread...\n");

  shutdown(recv_sock_raw, SHUT_RDWR);
  close(recv_sock_raw);
  probe_receiver_shutdown = 1;
  probe_receiver_thread.join();
}

int trigger_recv (uint8_t debug) {
  if (debug) {
    printf("receiving pkt...");
  }

  sockaddr s_addr;
  s_addr.sa_family = AF_PACKET;
  for (size_t i = 0; i < 6; i++) s_addr.sa_data[i] = probe_dst_mac.byte[i];
  size_t s_addr_len = sizeof(s_addr);

  recv_pkt_length = recvfrom(recv_sock_raw, recv_pkt_buf, BUFFER_SIZE, 0,
                             &s_addr, reinterpret_cast<socklen_t*>(&s_addr_len));

  if (debug) {
    if (recv_pkt_length == -1) {
      fprintf(stderr, "ERROR in receiving, recv_len=%ld, errno=%d\n", recv_pkt_length, errno);
      perror("Socket:");
    } else {
      printf("recv done\n");
    }
  }

  if (recv_pkt_length == -1) {
    return -1;
  } else {
    return 0;
  }

}

uint8_t probe_reply_recv(uint64_t us_timeout) {
  uint64_t t = 0;
  while (!probe_reply_received && t <= us_timeout) {
    usleep(10);
    t += 10;
  }
  return probe_reply_received;
}

// DEPRECATED
/*
void trigger_recv(mac_addr_t target_src_mac, size_t timeout) {

  printf("receiving pkt...");

  sockaddr s_addr;
  s_addr.sa_family = AF_PACKET;
  for (size_t i = 0; i < 6; i++) s_addr.sa_data[i] = probe_dst_mac.byte[i];

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
    printf("\n");
    fprintf(stderr, "ERROR receiving probe reponse pkt, timeout reached\n");
  } else {
    printf("recv done\n");
  }

}
*/

