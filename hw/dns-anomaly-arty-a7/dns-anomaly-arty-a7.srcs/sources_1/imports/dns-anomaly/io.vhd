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
    UpdateFilterSrcMAC,
    UpdateFilterDstMAC,
    
    -- Filtering Stages
    CheckSrcMAC,
    FilterSrcMACMatch,
    FilterSrcMACUnMatch,
    CheckDstMAC,
    FilterDstMACMatch,
    FilterDstMACUnMatch,
    
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
    c : NATURAL RANGE 0 TO 255; -- general purpose array counter 
  END RECORD;

  SIGNAL s, sin : iostate_t
  := iostate_t'(
  s => Idle,
  chksumbuf => x"00000000",
  led => x"0",
  pc => 0,
  c => 0
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
    dstMACList => (x"ffffff350a00", x"000000000000")
    
    --srcIPBW => '0',
    --srcIPList => (OTHERS => (OTHERS => '0')),
    --dstIPBW => '0',
    --dstIPList => (OTHERS => (OTHERS => '0')),
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
            
            sin.s <= UpdateFilterSrcMAC;
            sin.pc <= 0;
            sin.c <= 0;
          ELSE
            sin.s <= CheckSrcMAC;
            sin.c <= 0;
          END IF;
          
        WHEN UpdateFilterSrcMAC =>
          -- ALL filter elements shall be supplied, check against common.vhd
          -- SRC MAC
          f.srcMACBW <= rd.dnsPkt(0);
          -- filter depth affected this length here
          f.srcMACLength <= to_integer(unsigned(rd.dnsPkt(2 DOWNTO 1)));
          f.srcMacList(0) <= rd.dnsPkt(50 DOWNTO 3);
          f.srcMacList(1) <= rd.dnsPkt(98 DOWNTO 51);
          sin.s <= UpdateFilterDstMAC;
          --sin.s <= Idle;

        WHEN UpdateFilterDstMAC =>
          -- DST MAC
          f.dstMACBW <= rd.dnsPkt(99);
          -- filter depth affected this length here
          f.dstMACLength <= to_integer(unsigned(rd.dnsPkt(101 DOWNTO 100)));
          f.dstMacList(0) <= rd.dnsPkt(149 DOWNTO 102);
          f.dstMacList(1) <= rd.dnsPkt(197 DOWNTO 150);
          sin.s <= Idle; 

        WHEN CheckSrcMAC =>
          IF (s.c = f.srcMACLength) THEN
            sin.s <= CheckDstMAC;
            sin.c <= 0;
          ELSE
            -- check if srcMAC is on list
            IF (rd.srcMAC = f.srcMACList(s.c)) THEN
              sin.s <= FilterSrcMACMatch;
            ELSE
              sin.s <= FilterSrcMACUnMatch;
            END IF;
          END IF;   

        WHEN FilterSrcMACMatch =>
          IF (f.srcMACBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.c <= 0;
          ELSE
            --it's on whitelist
            sin.c <= s.c + 1;
            sin.s <= CheckSrcMAC;
          END IF;
        
        WHEN FilterSrcMACUnMatch =>
          IF (f.srcMACBW = '0') THEN
            --it's not on blacklist
            sin.c <= s.c + 1;
            sin.s <= CheckSrcMAC;
          ELSE
            --it's not on whitelist;
            sin.s <= Idle;
            sin.c <= 0;
          END IF;
          
        WHEN CheckDstMAC =>
          IF (s.c = f.dstMACLength) THEN
            sin.s <= MetaInfo;
            sin.c <= 0;
          ELSE
            -- check if dstMAC is on list
            IF (rd.dstMAC = f.dstMACList(s.c)) THEN
              sin.s <= FilterDstMACMatch;
            ELSE
              sin.s <= FilterDstMACUnMatch;
            END IF;
          END IF;
          
        WHEN FilterDstMACMatch =>
          IF (f.dstMACBW = '0') THEN
            --it's on blacklist
            sin.s <= Idle;
            sin.c <= 0;
          ELSE
            --it's on whitelist
            sin.c <= s.c + 1;
            sin.s <= CheckDstMAC;
          END IF;
          
        WHEN FilterDstMACUnMatch =>
          IF (f.dstMACBW = '0') THEN
            --it's not on blacklist
            sin.c <= s.c + 1;
            sin.s <= CheckDstMAC;
          ELSE
            --it's not on whitelist
            sin.s <= Idle;
            sin.c <= 0;
          END IF;

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
          sin.pc <= s.pc + 1;
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