LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY mac_rcv IS
  PORT (
    E_RX_CLK : IN STD_LOGIC; -- Receiver Clock.
    E_RX_DV : IN STD_LOGIC; -- Received Data Valid.
    E_RXD : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Received Nibble.
    el_chnl : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channels.
    el_data : OUT data_t; -- Channel data.
    el_dv : OUT STD_LOGIC; -- Data valid.
    el_ack : IN STD_LOGIC -- Packet reception ACK.
  );
END mac_rcv;

ARCHITECTURE rtl OF mac_rcv IS

  TYPE state_t IS (
    Preamble, StartOfFrame, -- 7 Bytes 0x55, 1 Byte 0x5d.
    MACS, -- 12 Byte MAC addresses.
    EtherTypeCheck, -- Next Protocol 0x00?
    Version, -- Data - Version.
    Channel, -- Data - Channel.
    DataU, DataL, -- Data - Channel data.
    Notify -- Inform other hardware components.
  );

  TYPE rcv_t IS RECORD
    s : state_t;
    chnl : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channel field.
    d : data_t; -- Channel data.
    c : NATURAL RANGE 0 TO 23;
    a : NATURAL RANGE 0 TO 7;
  END RECORD;

  SIGNAL r, rin : rcv_t
  := rcv_t'(Preamble, x"00", (OTHERS => (OTHERS => '0')), 0, 0);
BEGIN

  rcv_nsl : PROCESS (r, E_RX_DV, E_RXD, el_ack)
  BEGIN

    rin <= r;
    el_dv <= '0';

    IF E_RX_DV = '1' THEN
      CASE r.s IS

          --------------------------------------------------------------------
          -- Ethernet II - Preamble and Start Of Frame.                     --
          --------------------------------------------------------------------
        WHEN Preamble =>
          IF E_RXD = x"5" THEN
            IF r.c = 14 THEN
              rin.c <= 0;
              rin.s <= StartOfFrame;
            ELSE
              rin.c <= r.c + 1;
            END IF;
          ELSE
            rin.c <= 0;
          END IF;

        WHEN StartOfFrame =>
          IF E_RXD = x"d" THEN
            rin.s <= MACS;
          ELSE
            rin.s <= Preamble;
          END IF;

          --------------------------------------------------------------------
          -- Ethernet II - 12 Byte MAC addresses.                           --
          --------------------------------------------------------------------
        WHEN MACS =>
          IF r.c = 23 THEN
            rin.c <= 0;
            rin.s <= EtherTypeCheck;
          ELSE
            rin.c <= r.c + 1;
          END IF;

          --------------------------------------------------------------------
          -- Ethernet II - Next Layer 0x00?                                 --
          --------------------------------------------------------------------
        WHEN EtherTypeCheck =>
          IF E_RXD = x"0" THEN
            IF r.c = 3 THEN
              rin.c <= 0;
              rin.s <= Version;
            ELSE
              rin.c <= r.c + 1;
            END IF;
          ELSE
            rin.c <= 0;
            rin.s <= Preamble;
          END IF;

          --------------------------------------------------------------------
          -- Data - Version                                                 --
          --------------------------------------------------------------------
        WHEN Version =>
          IF r.c = 1 THEN
            rin.c <= 0;
            rin.s <= Channel;
          ELSE
            rin.c <= r.c + 1;
          END IF;

          --------------------------------------------------------------------
          -- Channel Flags.                                                 --
          --------------------------------------------------------------------
        WHEN Channel =>
          rin.chnl(7 DOWNTO 0) <= E_RXD & r.chnl(7 DOWNTO 4);
          IF r.c = 1 THEN
            rin.c <= 0;
            rin.a <= 0;
            rin.s <= DataU;
          ELSE
            rin.c <= r.c + 1;
          END IF;

          --------------------------------------------------------------------
          -- Data. 8 channels each 16 bit.                                  --
          --------------------------------------------------------------------
        WHEN DataU =>
          rin.d(r.a)(15 DOWNTO 8) <= E_RXD & r.d(r.a)(15 DOWNTO 12);
          IF r.c = 1 THEN
            rin.c <= 0;
            rin.s <= DataL;
          ELSE
            rin.c <= r.c + 1;
          END IF;

        WHEN DataL =>
          rin.d(r.a)(7 DOWNTO 0) <= E_RXD & r.d(r.a)(7 DOWNTO 4);
          IF r.c = 1 THEN
            rin.c <= 0;
            IF r.a = 7 THEN
              rin.a <= 0;
              rin.s <= Notify;
            ELSE
              rin.a <= r.a + 1;
              rin.s <= DataU;
            END IF;
          ELSE
            rin.c <= r.c + 1;
          END IF;

          --------------------------------------------------------------------
          -- Notification                                                   --
          --------------------------------------------------------------------
        WHEN Notify =>
          el_dv <= '1';
          rin.s <= Preamble;

      END CASE;
    END IF;
  END PROCESS;

  snd_reg : PROCESS (E_RX_CLK)
  BEGIN
    IF rising_edge(E_RX_CLK) THEN
      r <= rin;
    END IF;
  END PROCESS;

  el_chnl <= r.chnl;
  el_data <= r.d;
END rtl;