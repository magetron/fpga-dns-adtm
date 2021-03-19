LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY work;
USE work.common.ALL;

LIBRARY work;
USE work.test_pkt_infra.ALL;

PACKAGE test_srcmac_pkts IS
  PROCEDURE srcmac_empty_test_suite
  (E_RX_CLK_period : IN TIME;
  SIGNAL E_RX_DV : OUT STD_LOGIC;
  SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));


PACKAGE BODY test_srcmac_pkts IS

  PROCEDURE receive_srcmac_empty_admin_packet
    (E_RX_CLK_period : IN TIME;
    SIGNAL E_RX_DV : OUT STD_LOGIC;
    SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)) IS
  BEGIN
    E_RX_DV <= '1';
    receive_preamble(E_RX_CLK_period, E_RXD);
    receive_ethernet_header(E_RX_CLK_period, x"000a35ffffff", x"b043df1bb706", E_RXD);
    receive_ip_header(E_RX_CLK_period, x"0ac4e67a", x"0a6b1ba0", x"0078", E_RXD);
    receive_udp_header(E_RX_CLK_period, x"2ba3", x"2ebc", x"0064", E_RXD);
    receive_empty_admin_payload(E_RX_CLK_period, E_RXD);
    E_RX_DV <= '1';
  END receive_srcmac_empty_admin_packet;

  PROCEDURE srcmac_empty_test_suite
    (E_RX_CLK_period : IN TIME;
    SIGNAL E_RX_DV : OUT STD_LOGIC;
    SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)) IS
  BEGIN
    receive_srcmac_empty_admin_packet(E_RX_CLK_period, E_RX_DV, E_RXD);
    WAIT FOR E_RX_CLK_period * 200;
    receive_any_random_packet();
    WAIT FOR E_RX_CLK_period * 200;
    receive_any_random_packet();
  END srcmac_empty_test_suite;


END test_pkts;
