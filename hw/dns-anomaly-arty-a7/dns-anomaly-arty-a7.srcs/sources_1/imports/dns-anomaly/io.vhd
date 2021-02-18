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
    
    -- Filtering Stages
    FilterSrcMAC,
    FilterDstMAC,
    
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
    rd : rcv_data_t; -- Rcv Data struct
    sd : snd_data_t; -- Snd Data struct
    chksumbuf : UNSIGNED(31 DOWNTO 0);
    led : STD_LOGIC_VECTOR(3 DOWNTO 0); -- LED register.
    pc : NATURAL RANGE 0 TO 15; -- packet counter
    c : NATURAL RANGE 0 TO 255; -- general purpose array counter 
  END RECORD;

  SIGNAL s, sin : iostate_t
  := iostate_t'(
  s => Idle,
  rd => (
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipHeaderLength => 0, ipLength => 0,
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  dnsLength => 0,
  dnsPkt => (OTHERS => '0')
  ),
  sd => (
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipLength => (OTHERS => '0'), ipTTL => (OTHERS => '0'),
  ipChecksum => (OTHERS => '0'),
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  udpLength => (OTHERS => '0'), udpChecksum => (OTHERS => '0'),
  dnsPkt => (OTHERS => '0')
  ),
  chksumbuf => x"00000000",
  led => x"0",
  pc => 0,
  c => 0
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
          sin.rd <= el_rcv_data;
          el_rcv_ack <= '1';
          sin.s <= CheckAdmin;
          
        WHEN CheckAdmin =>
          IF (s.rd.dstMAC = g_admin_mac) THEN
            -- ALL filter elements shall be supplied, check against common.vhd

            -- SRC MAC
            f.srcMACBW <= s.rd.dnsPkt(0);
            -- filter depth affected this length here
            f.srcMACLength <= to_integer(unsigned(s.rd.dnsPkt(2 DOWNTO 1)));
            f.srcMacList(0) <= s.rd.dnsPkt(50 DOWNTO 3);
            f.srcMacList(1) <= s.rd.dnsPkt(98 DOWNTO 51);

            -- DST MAC
            f.dstMACBW <= s.rd.dnsPkt(99);
            -- filter depth affected this length here
            f.dstMACLength <= to_integer(unsigned(s.rd.dnsPkt(101 DOWNTO 100)));
            f.dstMacList(0) <= s.rd.dnsPkt(149 DOWNTO 102);
            f.dstMacList(1) <= s.rd.dnsPkt(197 DOWNTO 150);
           
            sin.s <= Idle;
            sin.pc <= 0;
            -- SIGNALS recognition of admin pkt
            sin.led <= x"f";
          ELSE
            sin.s <= FilterSrcMAC;
            sin.c <= 0;
          END IF;

        WHEN FilterSrcMAC =>
          IF (s.c = f.srcMACLength) THEN
            sin.s <= FilterDstMAC;
            sin.c <= 0;
          ELSE
            -- check if srcMAC is on list
            IF (s.rd.srcMAC = f.srcMACList(s.c)) THEN
              IF (f.srcMACBW = '0') THEN
                --it's on blacklist
                sin.s <= Idle;
                sin.c <= 0;
              ELSE 
                sin.c <= s.c + 1;
              END IF;
            ELSE
              IF (f.srcMACBW = '0') THEN
                --it's not on blacklist
                sin.c <= s.c + 1;
              ELSE
                sin.s <= Idle;
                sin.c <= 0;
              END IF;
            END IF;
          END IF;
          
        WHEN FilterDstMAC =>
          IF (s.c = f.dstMACLength) THEN
            sin.s <= MetaInfo;
            sin.c <= 0;
          ELSE
            -- check if dstMAC is on list
            IF (s.rd.dstMAC = f.dstMACList(s.c)) THEN
              IF (f.dstMACBW = '0') THEN
                --it's on blacklist
                sin.s <= Idle;
                sin.c <= 0;
              ELSE 
                sin.c <= s.c + 1;
              END IF;
            ELSE
              IF (f.dstMACBW = '0') THEN
                --it's not on blacklist
                sin.c <= s.c + 1;
              ELSE
                sin.s <= Idle;
                sin.c <= 0;
              END IF;
            END IF;
          END IF;

        WHEN MetaInfo =>
          sin.sd.srcIP <= s.rd.dstIP;
          sin.sd.dstIP <= s.rd.srcIP;
          sin.sd.srcPort <= s.rd.dstPort;
          sin.sd.dstPort <= s.rd.srcPort;
          sin.sd.ipTTL <= x"40";
          sin.sd.ipLength <= STD_LOGIC_VECTOR(to_unsigned(s.rd.ipLength, sin.sd.ipLength'length));
          sin.sd.udpLength <= STD_LOGIC_VECTOR(to_unsigned(s.rd.dnsLength + 8, sin.sd.udpLength'length));
          srcIPchecksumbuf := unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.srcIP(23 DOWNTO 16) & s.sd.srcIP(31 DOWNTO 24))) +
                              unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.srcIP(7 DOWNTO 0) & s.sd.srcIP(15 DOWNTO 8)));
          dstIPchecksumbuf := unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.dstIP(23 DOWNTO 16) & s.sd.dstIP(31 DOWNTO 24))) +
                              unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.dstIP(7 DOWNTO 0) & s.sd.dstIP(15 DOWNTO 8)));
          sin.s <= ChecksumCalc;

        WHEN ChecksumCalc =>
          sin.chksumbuf <= x"00004500" +
                           unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.ipLength(3 DOWNTO 0) & s.sd.ipLength(7 DOWNTO 4))) +
                           unsigned(STD_LOGIC_VECTOR'(x"0000" & s.sd.ipTTL & x"11")) +
                           srcIPchecksumbuf + dstIPchecksumbuf;
          sin.s <= ChecksumPopulate;

        WHEN ChecksumPopulate =>
          sin.sd.ipChecksum <= STD_LOGIC_VECTOR(NOT resize(s.chksumbuf(31 DOWNTO 16) + s.chksumbuf(15 DOWNTO 0), sin.sd.ipChecksum'length));
          sin.sd.udpChecksum <= x"0000";
          sin.s <= IPHeader;

        WHEN IPHeader =>
          sin.sd.ipLength(3 DOWNTO 0) <= s.sd.ipLength(15 DOWNTO 12);
          sin.sd.ipLength(7 DOWNTO 4) <= s.sd.ipLength(11 DOWNTO 8);
          sin.sd.ipLength(11 DOWNTO 8) <= s.sd.ipLength(7 DOWNTO 4);
          sin.sd.ipLength(15 DOWNTO 12) <= s.sd.ipLength(3 DOWNTO 0);
          sin.sd.ipChecksum(15 DOWNTO 8) <= s.sd.ipChecksum(7 DOWNTO 0);
          sin.sd.ipChecksum(7 DOWNTO 0) <= s.sd.ipChecksum(15 DOWNTO 8);
          sin.s <= UDPHeader;

        WHEN UDPHeader =>
          sin.sd.udpLength(15 DOWNTO 8) <= s.sd.udpLength(7 DOWNTO 0);
          sin.sd.udpLength(7 DOWNTO 0) <= s.sd.udpLength(15 DOWNTO 8);
          sin.s <= Finalise;

        WHEN Finalise =>
          sin.sd.srcMAC <= x"000000350a00";
          sin.sd.dstMAC <= x"d3f0f3d6f694";
          sin.sd.dnsPkt <= s.rd.dnsPkt;
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
  el_snd_data <= s.sd;

  reg : PROCESS (clk) --, E_CRS, E_COL)
  BEGIN
    IF falling_edge(clk) THEN
      s <= sin;
    END IF;
  END PROCESS;
END rtl;