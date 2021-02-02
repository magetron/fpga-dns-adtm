LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY io IS
  PORT (
    clk : IN STD_LOGIC;
    -- Data received.
    el_rcv_data : IN rcv_data_t;
    el_rcv_dv : IN STD_LOGIC;
    el_rcv_rdy : OUT STD_LOGIC;
    -- Data to send.
    el_snd_data : OUT snd_data_t;
    el_snd_en : OUT STD_LOGIC;

    -- LEDs.
    LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END io;

ARCHITECTURE rtl OF io IS

  TYPE state_t IS (
    Idle,
    Work,
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
    c : NATURAL RANGE 0 TO 255;
  END RECORD;

  SIGNAL s, sin : iostate_t
  := iostate_t'(
  s => Idle,
  rd => (
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipHeaderLength => 0, ipLength => 0,
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  dnsLength => 0
  --dns => (OTHERS => '1')
  ),
  sd => (
  srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
  srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
  ipLength => (OTHERS => '0'), ipTTL => (OTHERS => '0'),
  ipChecksum => (OTHERS => '0'),
  srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
  udpLength => (OTHERS => '0'), udpChecksum => (OTHERS => '0')
  --dns => (OTHERS => '1')
  ),
  chksumbuf => x"00000000",
  led => x"0",
  c => 0
  );
  --SIGNAL reg_e_col : STD_LOGIC := '0';
  --SIGNAL reg_e_snd : STD_LOGIC := '0';
BEGIN

  rcvsnd : PROCESS (clk)
  BEGIN

    IF rising_edge(clk) THEN
      el_snd_en <= '0';
      el_rcv_rdy <= '0';

      CASE s.s IS
        WHEN Idle =>
          IF el_rcv_dv = '1' THEN
            el_rcv_rdy <= '1';
            sin.rd <= el_rcv_data;
            sin.sd.ipLength <= STD_LOGIC_VECTOR(to_unsigned(s.rd.ipLength, sin.sd.ipLength'length));
            sin.sd.udpLength <= STD_LOGIC_VECTOR(to_unsigned(s.rd.dnsLength + 8, sin.sd.udpLength'length));
            sin.s <= Work;
          END IF;

        WHEN Work =>
          -- DO Processing
          --sin.sd.dns <= s.rd.dns;
          sin.s <= MetaInfo;

        WHEN MetaInfo =>
          sin.sd.srcIP <= s.rd.dstIP;
          sin.sd.dstIP <= s.rd.srcIP;
          sin.sd.srcPort <= s.rd.dstPort;
          sin.sd.dstPort <= s.rd.srcPort;
          sin.sd.ipTTL <= x"40";
          sin.s <= ChecksumCalc;

        WHEN ChecksumCalc =>
          sin.chksumbuf <= x"00004500" +
                           unsigned(x"0000" & s.sd.ipLength(3 DOWNTO 0) & s.sd.ipLength(7 DOWNTO 4)) +
                           unsigned(x"0000" & s.sd.ipTTL & x"11") +
                           unsigned(x"0000" & s.sd.srcIP(23 DOWNTO 16) & s.sd.srcIP(31 DOWNTO 24)) +
                           unsigned(x"0000" & s.sd.srcIP(7 DOWNTO 0) & s.sd.srcIP(15 DOWNTO 8)) +
                           unsigned(x"0000" & s.sd.dstIP(23 DOWNTO 16) & s.sd.dstIP(31 DOWNTO 24)) +
                           unsigned(x"0000" & s.sd.dstIP(7 DOWNTO 0) & s.sd.dstIP(15 DOWNTO 8));
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
          sin.s <= Send;

        WHEN Send =>
          el_snd_en <= '1'; -- Send Ethernet packet.
          sin.c <= s.c + 1;
          sin.led <= STD_LOGIC_VECTOR(to_unsigned(s.c + 1, sin.led'length));
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