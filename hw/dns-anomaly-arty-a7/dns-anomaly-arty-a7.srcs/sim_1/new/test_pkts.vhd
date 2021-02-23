LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY work;
USE work.common.ALL;

PACKAGE test_pkts IS
PROCEDURE receive_normal_pkt
  (E_RX_CLK_period : IN TIME;
   SIGNAL E_RX_DV : OUT STD_LOGIC;
   SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );
PROCEDURE receive_bogus_admin_pkt
  (E_RX_CLK_period : IN TIME;
   SIGNAL E_RX_DV : OUT STD_LOGIC;
   SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );
PROCEDURE receive_admin_pkt
  (E_RX_CLK_period : IN TIME;
   SIGNAL E_RX_DV : OUT STD_LOGIC;
   SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );
PROCEDURE receive_new_normal_pkt
  (E_RX_CLK_period : IN TIME;
   SIGNAL E_RX_DV : OUT STD_LOGIC;
   SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) );
END test_pkts;


PACKAGE BODY test_pkts IS
  PROCEDURE receive_preamble
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- Preamble
    FOR i in 0 to 14 LOOP
      E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    END LOOP;
    
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;

  END receive_preamble;

  PROCEDURE receive_ethernet_header
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- DstMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    -- SrcMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"c"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"e"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    
    -- Ethertype
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;

  END receive_ethernet_header;
  
  
  PROCEDURE receive_new_ethernet_header
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- DstMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    -- SrcMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"c"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    
    -- Ethertype
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;

  END receive_new_ethernet_header; 

  PROCEDURE receive_ip_header
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- IP Version
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;

    -- IP DSCP ECN
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    
    -- IP Total Length
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;

    -- IP ID
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    
    -- IP Flags and Fragment Offset
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;

    -- IP TTL
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
  
    -- IP Protocol UDP
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    
    -- IP Checksum WARNING: needs to change in accordance to pkts
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;

    -- IP Src
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    -- IP Dst
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
  
  END receive_ip_header;
  
  PROCEDURE receive_udp_header
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- UDP Src
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    
    -- UDP Dst
    E_RXD <= x"b"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;  
    
    -- UDP Length
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"b"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    
    -- UDP Checksum
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
  
  END receive_udp_header;


  PROCEDURE receive_normal_payload
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- Payload
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"e"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"b"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"e"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
   
    -- Padding 
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;

    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
  
  END receive_normal_payload;

  PROCEDURE receive_ethernet_crc
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- Ethernet CRC Empty
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"b"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"c"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period; 
    E_RXD <= x"e"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period; 
  END receive_ethernet_crc;

  PROCEDURE receive_admin_ethernet_header
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    -- DstMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    
    -- SrcMAC
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"c"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"e"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    
    -- Ethertype
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
  END receive_admin_ethernet_header;
  
  PROCEDURE receive_admin_payload
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    E_RXD <= x"3"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"6"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"f"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"a"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"9"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"7"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"5"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"1"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"8"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"2"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"d"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"4"; WAIT FOR E_RX_CLK_period;
    
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
    E_RXD <= x"0"; WAIT FOR E_RX_CLK_period;
  
  END receive_admin_payload;

  PROCEDURE receive_normal_pkt
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    E_RX_DV <= '1';
    
    receive_preamble(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ip_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_udp_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_normal_payload(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_crc(E_RX_CLK_period, E_RX_DV, E_RXD);

    -- END OF PACKET
    E_RX_DV <= '0'; 

    -- Interframe Gap
    WAIT FOR E_RX_CLK_period * 24;
  END receive_normal_pkt;

  PROCEDURE receive_bogus_admin_pkt
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    E_RX_DV <= '1';
    
    receive_preamble(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ip_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_udp_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_admin_payload(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_crc(E_RX_CLK_period, E_RX_DV, E_RXD);

    -- END OF PACKET
    E_RX_DV <= '0'; 

    -- Interframe Gap
    WAIT FOR E_RX_CLK_period * 24;
  END receive_bogus_admin_pkt; 
  
  PROCEDURE receive_admin_pkt
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    E_RX_DV <= '1';
    
    receive_preamble(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_admin_ethernet_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ip_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_udp_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_admin_payload(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_crc(E_RX_CLK_period, E_RX_DV, E_RXD);

    -- END OF PACKET
    E_RX_DV <= '0'; 

    -- Interframe Gap
    WAIT FOR E_RX_CLK_period * 24;
  END receive_admin_pkt;
  
  PROCEDURE receive_new_normal_pkt
    (E_RX_CLK_period : IN TIME;
     SIGNAL E_RX_DV : OUT STD_LOGIC;
     SIGNAL E_RXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ) IS
  BEGIN
    E_RX_DV <= '1';
    
    receive_preamble(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_new_ethernet_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ip_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_udp_header(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_normal_payload(E_RX_CLK_period, E_RX_DV, E_RXD);
    receive_ethernet_crc(E_RX_CLK_period, E_RX_DV, E_RXD);

    -- END OF PACKET
    E_RX_DV <= '0'; 

    -- Interframe Gap
    WAIT FOR E_RX_CLK_period * 24;
  END receive_new_normal_pkt;

END test_pkts;
