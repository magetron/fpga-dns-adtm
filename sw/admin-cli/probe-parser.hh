#pragma once

struct [[gnu::packed]] probe_response_t {
  filter_t filter;
  uint64_t stc, sfc, smc, sic, spc;
};


probe_response_t parse_probe_pkt(uint8_t* pkt, size_t length) {

  return {};
}
