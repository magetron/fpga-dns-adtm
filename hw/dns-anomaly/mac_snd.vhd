LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.PCK_CRC32_D4.ALL;
USE work.common.ALL;

ENTITY mac_snd IS
  PORT (
    E_TX_CLK : IN STD_LOGIC; -- Sender Clock.
    E_TX_EN : OUT STD_LOGIC; -- Sender Enable.
    E_TXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sent Data.
    E_TX_ER : OUT STD_LOGIC; -- Sent Data Error.
    el_data : IN data_t; -- Actual data.
    el_snd_en : IN STD_LOGIC -- User Start Send.
  );
END mac_snd;

ARCHITECTURE rtl OF mac_snd IS

  TYPE mem_t IS ARRAY(0 TO 14) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- TO BE REMOVED
  SIGNAL mem : mem_t := (
    -- DST MAC Address
    x"00", x"e0", x"4c", x"6b", x"dc", x"98",

    -- FPGA MAC Address (Xilinx OUI)                                        --
    x"00", x"0a", x"35", x"00", x"00", x"00",

    -- EtherType Field: 0x0000                                              --
    x"08", x"00",

    -- Data Header                                                          --
    x"45"
  );

  ATTRIBUTE RAM_STYLE : STRING;
  ATTRIBUTE RAM_STYLE OF mem : SIGNAL IS "BLOCK";

  TYPE state_t IS (
    Idle, -- Wait for signal en.
    Preamble, -- 55 55 55 55 55 55 55 5
    StartOfFrame, -- d
    EtherMACDST, -- 6 Byte MAC address DST
    EtherMACSRC, -- 6 Byte MAC address SRC
    EtherType, -- 0x0800
    IPVersion, -- 0x4
    IPIHL, -- 0x5
    IPDSCPECN, -- 0x00
    IPLength, -- ipLength
    -- IPID, -- 0x00
    -- IPFlagsFragment, -- 0x00
    -- IPTTL, -- 0x40
    -- IPProtocol, -- 0x11
    -- IPChecksum, -- Checksum
    -- IPAddrSRC, -- IPAddr SRC
    -- IPAddrDST, -- IPAddr DST
    -- UDPPortSRC, -- 2 byte UDP SRC
    -- UDPPortDST, -- 2 byte UDP DST
    -- UDPChecksum, -- Checksum,
    -- DNSMsg, -- 1472 Max bytes
    FrameCheck, -- CRC32
    InterframeGap -- Gap between two cosecutive frames (24 Bit).
  );

  TYPE snd_t IS RECORD
    s : state_t;
    d : data_t;
    crc : STD_LOGIC_VECTOR(31 DOWNTO 0); -- CRC32 latch.
    c : NATURAL RANGE 0 TO 367;
  END RECORD;

  SIGNAL s, sin : snd_t
    := snd_t'(
      s => Idle,
      d => (
        srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
        srcIP  => (OTHERS => '0'), dstIP => (OTHERS => '0'),
        ipHeaderLength => 0, ipLength => 0,
        srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'), dnsLength => 0
        --dns => (OTHERS => '0')
      ),
      crc => x"ffffffff",
      c => 0
    );

BEGIN

  snd_nsl : PROCESS (s, mem, el_snd_en, el_data)
  BEGIN

    sin <= s;
    sin.d <= el_data;
    E_TX_EN <= '0';
    E_TXD <= x"0";
    E_TX_ER <= '0';

    CASE s.s IS
      WHEN Idle =>
        IF el_snd_en = '1' THEN
          sin.c <= 0;
          sin.s <= Preamble;
        END IF;

      -- Preamble, 15 5s (including nibble for start of frame)
      WHEN Preamble =>
        E_TXD <= x"5";
        E_TX_EN <= '1';
        IF s.c = 14 THEN
          sin.c <= 0;
          sin.s <= StartOfFrame;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      -- start of frame (0xd)
      WHEN StartOfFrame =>
        E_TXD <= x"d";
        E_TX_EN <= '1';

        -- TO BE REMOVED
        sin.d.srcMAC <= (x"000000350a00");
        sin.d.dstMAC <= (x"98dc6b4ce000");

        sin.crc <= x"ffffffff";
        sin.s <= EtherMACDST;

      -- Ethernet DST MAC
      WHEN EtherMACDST =>
        E_TXD <= s.d.dstMAC((s.c * 4 + 3) DOWNTO (s.c * 4));
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(s.d.dstMAC((s.c * 4 + 3) DOWNTO (s.c * 4)), s.crc);
        IF s.c = 11 THEN
          sin.c <= 0;
          sin.s <= EtherMACSRC;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      -- Ethernet SRC MAC
      WHEN EtherMACSRC =>
        E_TXD <= s.d.srcMAC((s.c * 4 + 3) DOWNTO (s.c * 4));
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(s.d.srcMAC((s.c * 4 + 3) DOWNTO (s.c * 4)), s.crc);
        IF s.c = 11 THEN
          sin.c <= 0;
          sin.s <= EtherType;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      -- Ethertype 0x0800
      WHEN EtherType =>
        IF s.c = 0 THEN
          E_TXD <= x"8";
          E_TX_EN <= '1';
          sin.crc <= nextCRC32_D4(x"8", s.crc);
          sin.c <= s.c + 1;
        ELSE
          E_TXD <= x"0";
          E_TX_EN <= '1';
          sin.crc <= nextCRC32_D4(x"0", s.crc);
          IF s.c = 3 THEN
            sin.c <= 0;
            sin.s <= IPIHL;
          ELSE
            sin.c <= s.c + 1;
          END IF;
        END IF;

      -- IP IHL 5
      WHEN IPIHL =>
        E_TXD <= x"5";
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(x"5", s.crc);
        sin.c <= 0;
        sin.s <= IPVersion;

      -- IP Version 4
      WHEN IPVersion =>
        E_TXD <= x"4";
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(x"4", s.crc);
        sin.c <= 0;
        sin.s <= IPDSCPECN;

      -- IP DSCP ECN 0x00
      WHEN IPDSCPECN =>
        E_TXD <= x"0";
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(x"0", s.crc);
        IF s.c = 1 THEN
          sin.c <= 0;
          sin.s <= IPLength;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      WHEN IPLength =>
        -- TODO: FIX THIS
        E_TXD <= x"0";
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(x"0", s.crc);
        IF s.c = 50 THEN
          sin.c <= 0;
          sin.s <= IPLength;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      -- Ethernet Frame Check Sequence
      WHEN FrameCheck =>
        E_TXD <= NOT s.crc(4 * s.c + 3 DOWNTO 4 * s.c);
        E_TX_EN <= '1';
        IF s.c = 7 THEN
          sin.c <= 0;
          sin.s <= InterframeGap;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      -- Ethernet Interframe Gap
      WHEN InterframeGap =>
        IF s.c = 23 THEN
          sin.c <= 0;
          sin.s <= Idle;
        ELSE
          sin.c <= s.c + 1;
        END IF;
    END CASE;
  END PROCESS;

  snd_reg : PROCESS (E_TX_CLK)
  BEGIN
    IF rising_edge(E_TX_CLK) THEN
      s <= sin;
    END IF;
  END PROCESS;
END rtl;