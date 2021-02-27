LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY io IS
  GENERIC (
    g_admin_mac : STD_LOGIC_VECTOR(47 DOWNTO 0) := x"ffffff350a00"
  );
  PORT (
    clk : IN STD_LOGIC;
    -- Data received.
    el_rcv_data : IN rcv_data_t;
    el_rcv_dv : IN STD_LOGIC;
    el_rcv_ack : OUT STD_LOGIC;
    -- Data to send.
    el_snd_data : OUT snd_data_t;
    el_snd_en : OUT STD_LOGIC;

    -- LEDs.
    LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END io;

ARCHITECTURE rtl OF io IS

  TYPE state_t IS (
    -- MINDFUL: must have odd number of stages to slip in an update
    -- within TX clk cycles
  
    Idle,
    
    Read,
    CheckAdmin,
    
    -- Admin Stages
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
    
    -- Finalising Stages
    MetaInfo,
    ChecksumCalc,
    ChecksumPopulate,
    IPHeader,
    UDPHeader,
    Finalise,
    Send
  );

  TYPE iostate_t IS RECORD
    s : state_t;
    --rd : rcv_data_t; -- Rcv Data struct
    --sd : snd_data_t; -- Snd Data struct
    chksumbuf : UNSIGNED(31 DOWNTO 0);
    led : STD_LOGIC_VECTOR(3 DOWNTO 0); -- LED register.
    pc : NATURAL RANGE 0 TO 15; -- packet counter
    amc : NATURAL RANGE 0 TO 15; -- admin MAC counter
    aic : NATURAL RANGE 0 TO 15; -- admin IP counter
    apc : NATURAL RANGE 0 TO 15; -- admin UDP counter
    fsmc : NATURAL RANGE 0 TO 15; -- filter srcMAC counter
    fdmc : NATURAL RANGE 0 TO 15; -- filter dstMAC counter
    fsic : NATURAL RANGE 0 TO 15; -- filter srcIP counter
    fdic : NATURAL RANGE 0 TO 15; -- filter dstIP counter
    fspc : NATURAL RANGE 0 TO 15; -- filter srcUDP counter
    fdpc : NATURAL RANGE 0 TO 15; -- filter dstUDP counter
  END RECORD;

  SIGNAL s, sin : iostate_t
  := iostate_t'(
  s => Idle,
  chksumbuf => x"00000000",
  led => x"0",
  pc => 0,
  amc => 0,
  aic => 0,
  apc => 0,
  fsmc => 0,
  fdmc => 0,
  fsic => 0,
  fdic => 0,
  fspc => 0,
  fdpc => 0
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
  
  SIGNAL sd: snd_data_t
  := snd_data_t'(
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipLength => (OTHERS => '0'), ipTTL => (OTHERS => '0'),
  ipChecksum => (OTHERS => '0'),
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  udpLength => (OTHERS => '0'), udpChecksum => (OTHERS => '0'),
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
    dnsList => (x"6170706c652e636f6d00000000000000", x"676f6f676c652e636f6d000000000000"),
    dnsItemLength => (9, 10)
    
   );

BEGIN

  rcvsnd : PROCESS (clk)
  VARIABLE ipLengthbuf : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  VARIABLE udpLengthbuf : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  VARIABLE srcIPchecksumbuf : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
  VARIABLE dstIPchecksumbuf : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
  BEGIN

    IF rising_edge(clk) THEN
      el_snd_en <= '0';
      el_rcv_ack <= '0';

      CASE s.s IS
        WHEN Idle =>
          IF (el_rcv_dv = '1') THEN
            sin.s <= Read;
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
            
            sin.s <= UpdateFilterSrcMACMeta;
            sin.pc <= 0;
          ELSE
            sin.s <= CheckSrcMAC;
            sin.fsmc <= 0;
          END IF;

        --------ADMIN ROUTE--------          
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
              sin.s <= MetaInfo;
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
            sin.s <= MetaInfo;
          END IF;
          
        ---------SEND PACKET STAGE----------
        WHEN MetaInfo =>
          sd.srcIP <= rd.dstIP;
          sd.dstIP <= rd.srcIP;
          sd.srcPort <= rd.dstPort;
          sd.dstPort <= rd.srcPort;
          sd.ipTTL <= x"40";
          ipLengthbuf := STD_LOGIC_VECTOR(to_unsigned(rd.ipLength, ipLengthbuf'length));
          udpLengthbuf := STD_LOGIC_VECTOR(to_unsigned(rd.dnsLength + 8, udpLengthbuf'length));
          srcIPchecksumbuf := unsigned(STD_LOGIC_VECTOR'(x"0000" & rd.dstIP(23 DOWNTO 16) & rd.dstIP(31 DOWNTO 24))) +
                              unsigned(STD_LOGIC_VECTOR'(x"0000" & rd.dstIP(7 DOWNTO 0) & rd.dstIP(15 DOWNTO 8)));
          dstIPchecksumbuf := unsigned(STD_LOGIC_VECTOR'(x"0000" & rd.srcIP(23 DOWNTO 16) & rd.srcIP(31 DOWNTO 24))) +
                              unsigned(STD_LOGIC_VECTOR'(x"0000" & rd.srcIP(7 DOWNTO 0) & rd.srcIP(15 DOWNTO 8)));
          sin.s <= ChecksumCalc;

        WHEN ChecksumCalc =>
          sin.chksumbuf <= x"00004500" +
                           unsigned(STD_LOGIC_VECTOR'(x"0000" & ipLengthbuf(3 DOWNTO 0) & ipLengthbuf(7 DOWNTO 4))) +
                           unsigned(STD_LOGIC_VECTOR'(x"0000" & sd.ipTTL & x"11")) +
                           srcIPchecksumbuf + dstIPchecksumbuf;
          sin.s <= ChecksumPopulate;

        WHEN ChecksumPopulate =>
          sin.chksumbuf <= NOT resize(s.chksumbuf(31 DOWNTO 16) + s.chksumbuf(15 DOWNTO 0), sin.chksumbuf'length);
          sd.udpChecksum <= x"0000";
          sin.s <= IPHeader;

        WHEN IPHeader =>
          sd.ipLength(3 DOWNTO 0) <= ipLengthbuf(15 DOWNTO 12);
          sd.ipLength(7 DOWNTO 4) <= ipLengthbuf(11 DOWNTO 8);
          sd.ipLength(11 DOWNTO 8) <= ipLengthbuf(7 DOWNTO 4);
          sd.ipLength(15 DOWNTO 12) <= ipLengthbuf(3 DOWNTO 0);
          sd.ipChecksum(15 DOWNTO 8) <= STD_LOGIC_VECTOR(s.chksumbuf(7 DOWNTO 0));
          sd.ipChecksum(7 DOWNTO 0) <= STD_LOGIC_VECTOR(s.chksumbuf(15 DOWNTO 8));
          sin.s <= UDPHeader;

        WHEN UDPHeader =>
          sd.udpLength(15 DOWNTO 8) <= udpLengthbuf(7 DOWNTO 0);
          sd.udpLength(7 DOWNTO 0) <= udpLengthbuf(15 DOWNTO 8);
          sin.s <= Finalise;

        WHEN Finalise =>
          sd.srcMAC <= x"000000350a00";
          sd.dstMAC <= x"d3f0f3d6f694";
          sd.dnsPkt <= rd.dnsPkt;
          sin.s <= Send;

        WHEN Send =>
          el_snd_en <= '1'; -- Send Ethernet packet.
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
  el_snd_data <= sd;

  reg : PROCESS (clk) --, E_CRS, E_COL)
  BEGIN
    IF falling_edge(clk) THEN
      s <= sin;
    END IF;
  END PROCESS;
END rtl;