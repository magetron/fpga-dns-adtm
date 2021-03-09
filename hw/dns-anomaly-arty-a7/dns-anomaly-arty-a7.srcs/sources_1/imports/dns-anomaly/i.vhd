LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY corein IS
  GENERIC (
    g_admin_mac : STD_LOGIC_VECTOR(47 DOWNTO 0) := x"ffffff350a00";
    g_admin_key : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"decaface"
  );
  PORT (
    clk : IN STD_LOGIC;
    -- Data received.
    el_rcv_data : IN rcv_data_t;
    el_rcv_dv : IN STD_LOGIC;
    el_rcv_ack : OUT STD_LOGIC;
    
    -- rcved data to snd
    snd_rcv_data : OUT rcv_data_t;
    snd_en : OUT STD_LOGIC;

    -- LEDs.
    LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END corein;

ARCHITECTURE rtl OF corein IS

  TYPE state_t IS (
    -- MINDFUL: must have odd number of stages to slip in an update
    -- within TX clk cycles

    Idle,

    Read,
    CheckAdmin,

    -- Admin Stages
    CalcHash,
    HashAuth,
    UpdateFilterSrcMACMeta,
    UpdateFilterSrcMACList,
    UpdateFilterDstMACMeta,
    UpdateFilterDstMACList,
    UpdateFilterSrcIPMeta,
    UpdateFilterSrcIPList,
    UpdateFilterDstIPMeta,
    UpdateFilterDstIPList,
    UpdateFilterSrcPortMeta,
    UpdateFilterSrcPortList,
    UpdateFilterDstPortMeta,
    UpdateFilterDstPortList,
    UpdateFilterDNSMeta,
    UpdateFilterDNSList,

    -- Filtering Stages
    CheckSrcMAC,
    CmpSrcMAC,
    FilterSrcMACMatch,
    CheckDstMAC,
    CmpDstMAC,
    FilterDstMACMatch,
    CheckSrcIP,
    CmpSrcIP,
    FilterSrcIPMatch,
    CheckDstIP,
    CmpDstIP,
    FilterDstIPMatch,
    CheckSrcPort,
    CmpSrcPort,
    FilterSrcPortMatch,
    CheckDstPort,
    CmpDstPort,
    FilterDstPortMatch,
    CheckPkt,
    CmpPktCheck,
    CmpPktArea32,
    CmpPktArea24,
    CmpPktArea16,
    CmpPktArea8,
    CmpPktDone,
    FilterPkt,

    Send
  );

  TYPE istate_t IS RECORD
    s : state_t;

    led : STD_LOGIC_VECTOR(3 DOWNTO 0); -- LED register.
    pc : NATURAL RANGE 0 TO 15; -- packet counter
    
    ahc : NATURAL RANGE 0 TO 1023; -- hash counter
    ahv : STD_LOGIC_VECTOR(31 DOWNTO 0); -- hash value;
    amc : NATURAL RANGE 0 TO 15; -- admin MAC counter
    aic : NATURAL RANGE 0 TO 15; -- admin IP counter
    apc : NATURAL RANGE 0 TO 15; -- admin UDP counter
    adc : NATURAL RANGE 0 TO 15; -- admin DNS counter
    
    fsmc : NATURAL RANGE 0 TO 15; -- filter srcMAC counter
    fdmc : NATURAL RANGE 0 TO 15; -- filter dstMAC counter
    fsic : NATURAL RANGE 0 TO 15; -- filter srcIP counter
    fdic : NATURAL RANGE 0 TO 15; -- filter dstIP counter
    fspc : NATURAL RANGE 0 TO 15; -- filter srcUDP counter
    fdpc : NATURAL RANGE 0 TO 15; -- filter dstUDP counter
    fdnsc : NATURAL RANGE 0 TO 15; -- filter dns item counter
    fpktsc : NATURAL RANGE 0 TO 1023; -- filter pkt start position counter
    fpktc : NATURAL RANGE 0 TO 128; -- filter pkt bits left counter
    fpktmf : STD_LOGIC; -- filter pkt match flag
    
  END RECORD;

  SIGNAL s, sin : istate_t
  := istate_t'(
  s => Idle,
  
  led => x"0",
  pc => 0,
  
  ahc => 0,
  ahv => x"00000000",
  amc => 0,
  aic => 0,
  apc => 0,
  adc => 0,
  
  fsmc => 0,
  fdmc => 0,
  fsic => 0,
  fdic => 0,
  fspc => 0,
  fdpc => 0,
  fdnsc => 0,
  fpktsc => 0,
  fpktc => 0,
  fpktmf => '0'
  );

  SIGNAL rd : rcv_data_t
  := rcv_data_t'(
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipHeaderLength => 0, ipLength => 0,
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  dnsLength => 0,
  dnsPkt => (OTHERS => '0')
  );

  SIGNAL f : filter_t
  := filter_t'(
  --whitelist only VMWare MAC
  srcMACBW => '1',
  srcMACLength => 1,
  srcMACList => (x"ae295f290c00", x"000000000000"),

  --blacklist 00:0a:35:ff:ff:ff
  dstMACBW => '0',
  dstMACLength => 1,
  dstMACList => (x"ffffff350a00", x"000000000000"),

  --whitelist 0.0.0.0, 192.168.255.255
  srcIPBW => '1',
  srcIPLength => 2,
  srcIPList => (x"00000000", x"ffffa8c0"),

  --blacklist 1.2.3.4, 255.255.255.255
  dstIPBW => '0',
  dstIPLength => 2,
  dstIPList => (x"04030201", x"ffffffff"),

  --whitelist port 53 (0x35), 12345(0x3039)
  srcPortBW => '1',
  srcPortLength => 2,
  srcPortList => (x"3500", x"3930"),

  --whitelist port 53 (0x35), 23456(0x5ba0)
  dstPortBW => '1',
  dstPortLength => 2,
  dstPortList => (x"3500", x"a05b"),

  --blakclist apple.com (length 9 bytes), google.com(length 10 bytes)
  dnsBW => '0',
  dnsLength => 2,
  dnsItemEndPtr => (72, 80),
  dnsList => (x"000000000000006d6f632e656c707061", x"0000000000006d6f632e656c676f6f67")
  );

BEGIN

  rcv : PROCESS (clk)
    VARIABLE filterPktEndPtr : NATURAL RANGE 0 TO 1024 := 0;
    VARIABLE filterPktAreaEndPtr : NATURAL RANGE 0 TO 1024 := 0;
    VARIABLE filterPktItemEndPtr : NATURAL RANGE 0 TO 128 := 0;
    VARIABLE filterPktItemPtr : NATURAL RANGE 0 TO 2 := 0;
  BEGIN

    IF rising_edge(clk) THEN
      snd_en <= '0';
      el_rcv_ack <= '0';

      CASE s.s IS
        WHEN Idle =>
          IF (el_rcv_dv = '1') THEN
            sin.s <= Read;
          ELSE
            sin.s <= Idle;
          END IF;
          --DEBUG
          --sin.led <= STD_LOGIC_VECTOR(to_unsigned(f.srcMACLength, sin.led'length));

        WHEN Read =>
          rd <= el_rcv_data;
          el_rcv_ack <= '1';
          sin.s <= CheckAdmin;

        WHEN CheckAdmin =>
          IF (rd.dstMAC = g_admin_mac) THEN
            -- SIGNALS recognition of admin pkt
            sin.led <= x"f";
            sin.s <= CalcHash;
            sin.ahv <= g_admin_key;
            sin.ahc <= 0;
            sin.pc <= 0;
          ELSE
            sin.s <= CheckSrcMAC;
            sin.fsmc <= 0;
          END IF;
          
          --------ADMIN ROUTE--------          
        WHEN CalcHash =>
          sin.ahv <= s.ahv xor rd.dnsPkt(s.ahc + 31 DOWNTO s.ahc);
          IF (s.ahc = 992) THEN -- 1024 - 31 = 993
            sin.s <= HashAuth;
          ELSE
            sin.ahc <= s.ahc + 32;
          END IF;
          
        WHEN HashAuth =>
          IF (s.ahv = x"00000000") THEN
            sin.s <= UpdateFilterSrcMACMeta;
          ELSE
            sin.led <= x"8";
            sin.s <= Idle;
          END IF;
        
        WHEN UpdateFilterSrcMACMeta =>
          -- ALL filter elements shall be supplied, check against common.vhd
          -- SRC MAC
          f.srcMACBW <= rd.dnsPkt(0);
          -- filter depth affected this length here
          f.srcMACLength <= to_integer(unsigned(rd.dnsPkt(2 DOWNTO 1)));
          sin.s <= UpdateFilterSrcMACList;
          sin.amc <= 0;

        WHEN UpdateFilterSrcMACList =>
          --f.srcMACList(0) <= rd.dnsPkt(50 DOWNTO 3); --f.srcMACList(1) <= rd.dnsPkt(98 DOWNTO 51);
          -- 50 DOWNTO 3, 98 DOWNTO 51, s.c < 2 here is constant, filter_depth
          IF (s.amc = 0) THEN
            f.srcMACList(0) <= rd.dnsPkt(50 DOWNTO 3);
            sin.amc <= s.amc + 1;
          ELSIF (s.amc = 1) THEN
            f.srcMACList(1) <= rd.dnsPkt(98 DOWNTO 51);
            sin.amc <= s.amc + 1;
          ELSE
            sin.s <= UpdateFilterDstMACMeta;
          END IF;

        WHEN UpdateFilterDstMACMeta =>
          -- DST MAC
          f.dstMACBW <= rd.dnsPkt(99);
          -- filter depth affected this length here
          f.dstMACLength <= to_integer(unsigned(rd.dnsPkt(101 DOWNTO 100)));
          sin.s <= UpdateFilterDstMACList;
          sin.amc <= 0;

        WHEN UpdateFilterDstMACList =>
          --f.dstMACList(0) <= rd.dnsPkt(149 DOWNTO 102); --f.dstMACList(1) <= rd.dnsPkt(197 DOWNTO 150);
          -- 149 DOWNTO 102, 197 DOWNTO 150, s.c < 2 here is constant, filter_depth
          IF (s.amc = 0) THEN
            f.dstMACList(0) <= rd.dnsPkt(149 DOWNTO 102);
            sin.amc <= s.amc + 1;
          ELSIF (s.amc = 1) THEN
            f.dstMACList(1) <= rd.dnsPkt(197 DOWNTO 150);
            sin.amc <= s.amc + 1;
          ELSE
            sin.s <= UpdateFilterSrcIPMeta;
          END IF;

        WHEN UpdateFilterSrcIPMeta =>
          -- SRC IP
          f.srcIPBW <= rd.dnsPkt(198);
          -- filter depth affected this length here
          f.srcIPLength <= to_integer(unsigned(rd.dnsPkt(200 DOWNTO 199)));
          sin.s <= UpdateFilterSrcIPList;
          sin.aic <= 0;

        WHEN UpdateFilterSrcIPList =>
          --f.srcIPList(0) <= rd.dnsPkt(232 DOWNTO 201); --f.srcIPList(1) <= rd.dnsPkt(264 DOWNTO 233);
          -- 232 DOWNTO 201, 264 DOWNTO 233, s.c < 2 here is constant, filter_depth
          IF (s.aic = 0) THEN
            f.srcIPList(0) <= rd.dnsPkt(232 DOWNTO 201);
            sin.aic <= s.aic + 1;
          ELSIF (s.aic = 1) THEN
            f.srcIPList(1) <= rd.dnsPkt(264 DOWNTO 233);
            sin.aic <= s.aic + 1;
          ELSE
            sin.s <= UpdateFilterDstIPMeta;
          END IF;

        WHEN UpdateFilterDstIPMeta =>
          -- DST IP
          f.dstIPBW <= rd.dnsPkt(265);
          -- filter depth affected this length here
          f.dstIPLength <= to_integer(unsigned(rd.dnsPkt(267 DOWNTO 266)));
          sin.s <= UpdateFilterDstIPList;
          sin.aic <= 0;

        WHEN UpdateFilterDstIPList =>
          --f.dstIPList(0) <= rd.dnsPkt(299 DOWNTO 268); --f.dstIPList(1) <= rd.dnsPkt(331 DOWNTO 300);
          -- 299 DOWNTO 268, 331 DOWNTO 300, s.c < 2 here is constant, filter_depth
          IF (s.aic = 0) THEN
            f.dstIPList(0) <= rd.dnsPkt(299 DOWNTO 268);
            sin.aic <= s.aic + 1;
          ELSIF (s.aic = 1) THEN
            f.dstIPList(1) <= rd.dnsPkt(331 DOWNTO 300);
            sin.aic <= s.aic + 1;
          ELSE
            sin.s <= UpdateFilterSrcPortMeta;
          END IF;

        WHEN UpdateFilterSrcPortMeta =>
          -- SRC Port
          f.srcPortBW <= rd.dnsPkt(332);
          -- filter depth affected this length here
          f.srcPortLength <= to_integer(unsigned(rd.dnsPkt(334 DOWNTO 333)));
          sin.s <= UpdateFilterSrcPortList;
          sin.apc <= 0;

        WHEN UpdateFilterSrcPortList =>
          IF (s.apc = 0) THEN
            f.srcPortList(0) <= rd.dnsPkt(350 DOWNTO 335);
            sin.apc <= s.apc + 1;
          ELSIF (s.apc = 1) THEN
            f.srcPortList(1) <= rd.dnsPkt(366 DOWNTO 351);
            sin.apc <= s.apc + 1;
          ELSE
            sin.s <= UpdateFilterDstPortMeta;
          END IF;

        WHEN UpdateFilterDstPortMeta =>
          -- DST Port
          f.dstPortBW <= rd.dnsPkt(367);
          -- filter depth affected this length here
          f.dstPortLength <= to_integer(unsigned(rd.dnsPkt(369 DOWNTO 368)));
          sin.s <= UpdateFilterDstPortList;
          sin.apc <= 0;

        WHEN UpdateFilterDstPortList =>
          IF (s.apc = 0) THEN
            f.dstPortList(0) <= rd.dnsPkt(385 DOWNTO 370);
            sin.apc <= s.apc + 1;
          ELSIF (s.apc = 1) THEN
            f.dstPortList(1) <= rd.dnsPkt(401 DOWNTO 386);
            sin.apc <= s.apc + 1;
          ELSE
            sin.s <= UpdateFilterDNSMeta;
          END IF;

        WHEN UpdateFilterDNSMeta =>
          f.dnsBW <= rd.dnsPkt(402);
          f.dnsLength <= to_integer(unsigned(rd.dnsPkt(404 DOWNTO 403)));
          -- 0 to 128 (127 + 1), 8 bits
          f.dnsItemEndPtr(0) <= to_integer(unsigned(rd.dnsPkt(412 DOWNTO 405)));
          f.dnsItemEndPtr(1) <= to_integer(unsigned(rd.dnsPkt(420 DOWNTO 413)));
          sin.s <= UpdateFilterDNSList;
          sin.adc <= 0;
        
        WHEN UpdateFilterDNSList =>
          IF (s.adc = 0) THEN
            f.dnsList(0) <= rd.dnsPkt(548 DOWNTO 421);
            sin.adc <= s.adc + 1;
          ELSIF (s.adc = 1) THEN
            f.dnsList(1) <= rd.dnsPkt(676 DOWNTO 549);
            sin.adc <= s.adc + 1;
          ELSE
            sin.s <= Idle;
          END IF;

        --------FILTER ROUTE--------
        --SRCMAC
        WHEN CheckSrcMAC =>
          IF (s.fsmc = f.srcMACLength) THEN
            IF (f.srcMACBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckDstMAC;
              sin.fdmc <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fsmc <= 0;
            END IF;
          ELSE
            sin.s <= CmpSrcMAC;
            sin.fsmc <= s.fsmc;
          END IF;

        WHEN CmpSrcMAC =>
          -- check if srcMAC is on list
          IF (rd.srcMAC = f.srcMACList(s.fsmc)) THEN
            sin.s <= FilterSrcMACMatch;
            sin.fsmc <= s.fsmc;
          ELSE
            sin.s <= CheckSrcMAC;
            sin.fsmc <= s.fsmc + 1;
          END IF;

        WHEN FilterSrcMACMatch =>
          IF (f.srcMACBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fsmc <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckDstMAC;
            sin.fdmc <= 0;
          END IF;

          --DSTMAC
        WHEN CheckDstMAC =>
          IF (s.fdmc = f.dstMACLength) THEN
            IF (f.dstMACBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckSrcIP;
              sin.fsic <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fdmc <= 0;
            END IF;
          ELSE
            sin.s <= CmpDstMAC;
            sin.fdmc <= s.fdmc;
          END IF;

        WHEN CmpDstMAC =>
          -- check if srcMAC is on list
          IF (rd.dstMAC = f.dstMACList(s.fdmc)) THEN
            sin.s <= FilterDstMACMatch;
            sin.fdmc <= s.fdmc;
          ELSE
            sin.s <= CheckDstMAC;
            sin.fdmc <= s.fdmc + 1;
          END IF;

        WHEN FilterDstMACMatch =>
          IF (f.dstMACBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fdmc <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckSrcIP;
            sin.fsic <= 0;
          END IF;

          --SRCIP
        WHEN CheckSrcIP =>
          IF (s.fsic = f.srcIPLength) THEN
            IF (f.srcIPBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckDstIP;
              sin.fdic <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fsic <= 0;
            END IF;
          ELSE
            sin.s <= CmpSrcIP;
            sin.fsic <= s.fsic;
          END IF;

        WHEN CmpSrcIP =>
          -- check if srcIP is on list
          IF (rd.srcIP = f.srcIPList(s.fsic)) THEN
            sin.s <= FilterSrcIPMatch;
            sin.fsic <= s.fsic;
          ELSE
            sin.s <= CheckSrcIP;
            sin.fsic <= s.fsic + 1;
          END IF;

        WHEN FilterSrcIPMatch =>
          IF (f.srcIPBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fsic <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckDstIP;
            sin.fdic <= 0;
          END IF;

          --DSTIP
        WHEN CheckDstIP =>
          IF (s.fdic = f.dstIPLength) THEN
            IF (f.dstIPBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckSrcPort;
              sin.fspc <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fdic <= 0;
            END IF;
          ELSE
            sin.s <= CmpDstIP;
            sin.fdic <= s.fdic;
          END IF;

        WHEN CmpDstIP =>
          -- check if dstIP is on list
          IF (rd.dstIP = f.dstIPList(s.fdic)) THEN
            sin.s <= FilterDstIPMatch;
            sin.fdic <= s.fdic;
          ELSE
            sin.s <= CheckDstIP;
            sin.fdic <= s.fdic + 1;
          END IF;

        WHEN FilterDstIPMatch =>
          IF (f.dstIPBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fdic <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckSrcPort;
            sin.fspc <= 0;
          END IF;

          --SRCPORT
        WHEN CheckSrcPort =>
          IF (s.fspc = f.srcPortLength) THEN
            IF (f.srcPortBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckDstPort;
              sin.fdpc <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fspc <= 0;
            END IF;
          ELSE
            sin.s <= CmpSrcPort;
            sin.fspc <= s.fspc;
          END IF;

        WHEN CmpSrcPort =>
          -- check if srcPort is on list
          IF (rd.srcPort = f.srcPortList(s.fspc)) THEN
            sin.s <= FilterSrcPortMatch;
            sin.fspc <= s.fspc;
          ELSE
            sin.s <= CheckSrcPort;
            sin.fspc <= s.fspc + 1;
          END IF;

        WHEN FilterSrcPortMatch =>
          IF (f.srcPortBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fspc <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckDstPort;
            sin.fdpc <= 0;
          END IF;

          --DSTPORT
        WHEN CheckDstPort =>
          IF (s.fdpc = f.dstPortLength) THEN
            IF (f.dstPortBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= CheckPkt;
              sin.fdnsc <= 0;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fdpc <= 0;
            END IF;
          ELSE
            sin.s <= CmpDstPort;
            sin.fdpc <= s.fdpc;
          END IF;

        WHEN CmpDstPort =>
          -- check if dstPort is on list
          IF (rd.dstPort = f.dstPortList(s.fdpc)) THEN
            sin.s <= FilterDstPortMatch;
            sin.fdpc <= s.fdpc;
          ELSE
            sin.s <= CheckDstPort;
            sin.fdpc <= s.fdpc + 1;
          END IF;

        WHEN FilterDstPortMatch =>
          IF (f.dstPortBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fdpc <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= CheckPkt;
            sin.fdnsc <= 0;
          END IF;

          --PKT
        WHEN CheckPkt =>
          IF (s.fdnsc = f.dnsLength) THEN
            IF (f.dnsBW = '0') THEN
              -- exhaust blacklist, no ban
              sin.s <= Send;
            ELSE
              -- exhaust whitelist, ban
              sin.s <= Idle;
              sin.fpktsc <= 0;
            END IF;
          ELSE
            sin.s <= CmpPktCheck;
            sin.fpktsc <= 0;
            sin.fpktc <= f.dnsItemEndPtr(s.fdnsc);
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
            -- change with pkt size
            IF (rd.dnsLength > 128) THEN -- bytes
              filterPktEndPtr := 1024; -- bits
            ELSE
              filterPktEndPtr := rd.dnsLength * 8;
            END IF;
          END IF;

        WHEN CmpPktCheck =>
          filterPktAreaEndPtr := s.fpktsc + s.fpktc; 
          filterPktItemEndPtr := s.fpktc;
          filterPktItemPtr := s.fdnsc;
          IF (s.fpktc >= 32) THEN
            sin.s <= CmpPktArea32;
          ELSIF (s.fpktc >= 24) THEN
            sin.s <= CmpPktArea24;
          ELSIF (s.fpktc >= 16) THEN
            sin.s <= CmpPktArea16;
          ELSIF (s.fpktc >= 8) THEN
            sin.s <= CmpPktArea8;
          ELSE
            sin.s <= CmpPktDone;
            sin.fpktsc <= s.fpktsc;
            sin.fpktmf <= '1';
            sin.fdnsc <= s.fdnsc;
          END IF;
        
        WHEN CmpPktArea32 =>
          IF (rd.dnsPkt((filterPktAreaEndPtr - 1) DOWNTO (filterPktAreaEndPtr - 32))
            = f.dnsList(filterPktItemPtr)((filterPktItemEndPtr - 1) DOWNTO (filterPktItemEndPtr - 32))) THEN
            sin.s <= CmpPktCheck;
            sin.fpktsc <= s.fpktsc;
            sin.fpktc <= s.fpktc - 32;
            sin.fdnsc <= s.fdnsc;
          ELSE
            sin.s <= CmpPktDone;
            sin.fpktsc <= s.fpktsc;
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
          END IF;
          
        WHEN CmpPktArea24 =>
          IF (rd.dnsPkt((filterPktAreaEndPtr - 1) DOWNTO (filterPktAreaEndPtr - 24))
            = f.dnsList(filterPktItemPtr)((filterPktItemEndPtr - 1) DOWNTO (filterPktItemEndPtr - 24))) THEN
            sin.s <= CmpPktCheck;
            sin.fpktsc <= s.fpktsc;
            sin.fpktc <= s.fpktc - 24;
            sin.fdnsc <= s.fdnsc;
          ELSE
            sin.s <= CmpPktDone;
            sin.fpktsc <= s.fpktsc;
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
          END IF;
          
        WHEN CmpPktArea16 =>
          IF (rd.dnsPkt((filterPktAreaEndPtr - 1) DOWNTO (filterPktAreaEndPtr - 16))
            = f.dnsList(filterPktItemPtr)((filterPktItemEndPtr - 1) DOWNTO (filterPktItemEndPtr - 16))) THEN
            sin.s <= CmpPktCheck;
            sin.fpktsc <= s.fpktsc;
            sin.fpktc <= s.fpktc - 16;
            sin.fdnsc <= s.fdnsc;
          ELSE
            sin.s <= CmpPktDone;
            sin.fpktsc <= s.fpktsc;
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
          END IF;
        
        WHEN CmpPktArea8 =>
          IF (rd.dnsPkt((filterPktAreaEndPtr - 1) DOWNTO (filterPktAreaEndPtr - 8))
            = f.dnsList(filterPktItemPtr)((filterPktItemEndPtr - 1) DOWNTO (filterPktItemEndPtr - 8))) THEN
            sin.s <= CmpPktCheck;
            sin.fpktsc <= s.fpktsc;
            sin.fpktc <= s.fpktc - 8;
            sin.fdnsc <= s.fdnsc;
          ELSE
            sin.s <= CmpPktDone;
            sin.fpktsc <= s.fpktsc;
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
          END IF; 

        WHEN CmpPktDone =>
          IF (s.fpktmf = '1') THEN
            -- there's a match
            sin.s <= FilterPkt;
            sin.fdnsc <= s.fdnsc;
            -- update this line for pkt size change
          ELSIF (s.fpktsc + f.dnsItemEndPtr(s.fdnsc) >= filterPktEndPtr) THEN
            -- all check done
            sin.s <= CheckPkt;
            sin.fdnsc <= s.fdnsc + 1;
          ELSE
            -- increment pkt counter
            sin.s <= CmpPktCheck;
            sin.fpktsc <= s.fpktsc + 8;
            sin.fpktc <= f.dnsItemEndPtr(s.fdnsc);
            sin.fpktmf <= '0';
            sin.fdnsc <= s.fdnsc;
          END IF;

        WHEN FilterPkt =>
          IF (f.dnsBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.fdnsc <= 0;
          ELSE
            --it's on whitelist, move on to next step
            sin.s <= Send;
          END IF;

        WHEN Send =>
          snd_en <= '1'; -- Send Ethernet packet.
          IF (s.pc = 15) THEN
            sin.pc <= 0;
          ELSE
            sin.pc <= s.pc + 1;
          END IF;
          sin.led <= STD_LOGIC_VECTOR(to_unsigned(s.pc + 1, sin.led'length));
          sin.s <= Idle;

      END CASE;
    END IF;
  END PROCESS;

  LED <= s.led;
  snd_rcv_data <= rd;

  reg : PROCESS (clk)
  BEGIN
    IF falling_edge(clk) THEN
      s <= sin;
    END IF;
  END PROCESS;
END rtl;
