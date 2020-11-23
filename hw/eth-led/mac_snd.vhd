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
    el_chnl : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channels.
    el_data : IN data_t; -- Actual data.
    en : IN STD_LOGIC -- User Start Send.
  );
END mac_snd;

ARCHITECTURE rtl OF mac_snd IS

  TYPE mem_t IS ARRAY(0 TO 14) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL mem : mem_t := (
    --------------------------------------------------------------------------
    -- Host PC MAC Address                                                  --
    --------------------------------------------------------------------------
    -- 0x0 - 0x5
    x"00", x"0c", x"29", x"5f", x"29", x"ae",

    --------------------------------------------------------------------------
    -- FPGA MAC Address (Xilinx OUI)                                        --
    --------------------------------------------------------------------------
    -- 0x6 - 0xb
    x"00", x"0a", x"35", x"00", x"00", x"00",

    --------------------------------------------------------------------------
    -- EtherType Field: 0x0000                                              --
    --------------------------------------------------------------------------
    -- 0xc - 0xd
    x"00", x"00",

    --------------------------------------------------------------------------
    -- Data Header                                                          --
    --------------------------------------------------------------------------
    -- Data Version.
    -- Hardware returns Version 2 packets to distinguish them from Version 1
    -- packets sent by the host who captures in promiscuous mode only. This
    -- would cause the host to read it's own Version 1 packets as well.
    -- 0xe
    x"02"
  );

  ATTRIBUTE RAM_STYLE : STRING;
  ATTRIBUTE RAM_STYLE OF mem : SIGNAL IS "BLOCK";

  TYPE state_t IS (
    Idle, -- Wait for signal en.
    Preamble, -- 55 55 55 55 55 55 55 5
    StartOfFrame, -- d
    Upper, -- Send upper Nibble.
    Lower, -- Send lower Nibble.
    Channel, -- Send Data channel.
    DataU, DataL, -- Send Actual data.
    Padding, -- Send Padding 28 00s
    FrameCheck, -- No Frame Check for now.
    InterframeGap -- Gap between two cosecutive frames (93 Bit).
  );

  TYPE snd_t IS RECORD
    s : state_t;
    crc : STD_LOGIC_VECTOR(31 DOWNTO 0); -- CRC32 latch.
    c : NATURAL RANGE 0 TO 63;
    a : NATURAL RANGE 0 TO 7;
  END RECORD;

  SIGNAL s, sin : snd_t := snd_t'(Idle, x"ffffffff", 0, 0);
BEGIN

  snd_nsl : PROCESS (s, mem, en, el_chnl, el_data)
  BEGIN

    sin <= s;
    E_TX_EN <= '0';
    E_TXD <= x"0";
    E_TX_ER <= '0';

    CASE s.s IS
      WHEN Idle =>
        IF en = '1' THEN
          sin.c <= 0;
          sin.s <= Preamble;
        END IF;

        -----------------------------------------------------------------------
        -- Ethernet II - Preamble and Start Of Frame.                        --
        -----------------------------------------------------------------------
      WHEN Preamble =>
        E_TXD <= x"5";
        E_TX_EN <= '1';
        IF s.c = 14 THEN
          sin.c <= 0;
          sin.s <= StartOfFrame;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      WHEN StartOfFrame =>
        E_TXD <= x"d";
        E_TX_EN <= '1';
        sin.crc <= x"ffffffff";
        sin.s <= Upper;

        -----------------------------------------------------------------------
        -- Custom Protocol Transmit.                                         --
        -----------------------------------------------------------------------
      WHEN Upper =>
        E_TXD <= mem(s.c)(3 DOWNTO 0);
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(mem(s.c)(3 DOWNTO 0), s.crc);
        sin.s <= Lower;

      WHEN Lower =>
        E_TXD <= mem(s.c)(7 DOWNTO 4);
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(mem(s.c)(7 DOWNTO 4), s.crc);
        IF s.c = 14 THEN
          sin.c <= 0;
          sin.s <= Channel;
        ELSE
          sin.c <= s.c + 1;
          sin.s <= Upper;
        END IF;

        -----------------------------------------------------------------------
        -- Data - Channel Flags.                                             --
        -----------------------------------------------------------------------
      WHEN Channel =>
        E_TXD <= el_chnl(4 * s.c + 3 DOWNTO 4 * s.c);
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(el_chnl(4 * s.c + 3 DOWNTO 4 * s.c), s.crc);
        IF s.c = 1 THEN
          sin.c <= 0;
          sin.a <= 0;
          sin.s <= DataU;
        ELSE
          sin.c <= s.c + 1;
        END IF;

        -----------------------------------------------------------------------
        --  Data. 8 channels  16 bit.                                        --
        -----------------------------------------------------------------------
      WHEN DataU =>
        E_TXD <= el_data(s.a)(4 * s.c + 11 DOWNTO 4 * s.c + 8);
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(el_data(s.a)(4 * s.c + 11 DOWNTO 4 * s.c + 8), s.crc);
        IF s.c = 1 THEN
          sin.c <= 0;
          sin.s <= DataL;
        ELSE
          sin.c <= s.c + 1;
        END IF;

      WHEN DataL =>
        E_TXD <= el_data(s.a)(4 * s.c + 3 DOWNTO 4 * s.c);
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(el_data(s.a)(4 * s.c + 3 DOWNTO 4 * s.c), s.crc);
        IF s.c = 1 THEN
          sin.c <= 0;
          IF s.a = 7 THEN
            sin.a <= 0;
            sin.s <= Padding;
          ELSE
            sin.a <= s.a + 1;
            sin.s <= DataU;
          END IF;
        ELSE
          sin.c <= s.c + 1;
        END IF;

        -----------------------------------------------------------------------
        -- Ethernet II - Padding. 28 00s                                        --
        -----------------------------------------------------------------------
      WHEN Padding =>
        E_TXD <= x"0";
        E_TX_EN <= '1';
        sin.crc <= nextCRC32_D4(x"0", s.crc);
        IF s.c = 55 THEN
          sin.c <= 0;
          sin.s <= FrameCheck;
        ELSE
          sin.c <= s.c + 1;
        END IF;

        -----------------------------------------------------------------------
        -- Ethernet II - Frame Check.                                        --
        -----------------------------------------------------------------------
      WHEN FrameCheck =>
        E_TXD <= NOT s.crc(4 * s.c + 3 DOWNTO 4 * s.c);
        E_TX_EN <= '1';
        IF s.c = 7 THEN
          sin.c <= 0;
          sin.s <= InterframeGap;
        ELSE
          sin.c <= s.c + 1;
        END IF;

        -----------------------------------------------------------------------
        -- Ethernet II - Interframe Gap.                                     --
        -----------------------------------------------------------------------
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