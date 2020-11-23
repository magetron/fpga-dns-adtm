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
  uint8_t* sendbuf = new uint8_t[BUFFER_SIZE];

  ethhdr* eth = reinterpret_cast<ethhdr*>(sendbuf);
  eth->h_dest[0] = 0x00;
  eth->h_dest[1] = 0x0C;
  eth->h_dest[2] = 0x29;
  eth->h_dest[3] = 0x5F;
  eth->h_dest[4] = 0x29;
  eth->h_dest[5] = 0xAE;

  eth->h_source[0] = 0x00;
  eth->h_source[1] = 0x0A;
  eth->h_source[2] = 0x35;
  eth->h_source[3] = 0x00;
  eth->h_source[4] = 0x00;
  eth->h_source[6] = 0x00;
  eth->h_proto = 0x00;

  auto* ethlab = reinterpret_cast<etherlab*>(eth + 1);
  ethlab->version = 0x20;
  ethlab->channels = 0xD0;
  for (size_t i = 0; i < 8; i++)
    ethlab->data[i] = 0;

}