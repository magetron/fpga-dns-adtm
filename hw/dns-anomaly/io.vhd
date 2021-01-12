LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY io IS
  PORT (
    clk : IN STD_LOGIC;
    clk90 : IN STD_LOGIC;
    -- Data received.
    el_rcv_data : IN data_t;
    el_rcv_dv : IN STD_LOGIC;
    --el_rcv_ack : OUT STD_LOGIC;
    -- Data to send.
    el_snd_data : OUT data_t;
    el_snd_en : OUT STD_LOGIC;

    --E_CRS : IN STD_LOGIC;
    --E_COL : IN STD_LOGIC;
    -- LEDs.
    LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END io;

ARCHITECTURE rtl OF io IS

  -----------------------------------------------------------------------------
  -- SETTING:                                                                --
  --  + FREQ: Clock frequency. Usually 50 MHz.                               --
  --  + PULSE_WIDTH: Time between two EtherLab transmissions.                --
  -----------------------------------------------------------------------------
  CONSTANT FREQ : NATURAL := 50; -- [MHz] Frequency.
  CONSTANT PULSE_WIDTH : NATURAL := 1000; -- [msec] Time between two sends.

  CONSTANT CYCLES_PER_MSEC : NATURAL := FREQ * 1000;

  TYPE state_t IS (
    Idle,
    Ready,
    Send
  );

  TYPE reg_t IS RECORD
    s : state_t;
    d : data_t; -- Data struct
    led : STD_LOGIC_VECTOR(7 DOWNTO 0); -- LED register.
    --c : NATURAL RANGE 0 TO 23;
  END RECORD;

  TYPE snd_state_t IS (
    Idle,
    Pulse,
    Transmit
  );

  TYPE snd_t IS RECORD
    s : snd_state_t;
    d : data_t; -- Data struct.
    q : NATURAL RANGE 0 TO CYCLES_PER_MSEC - 1; -- Milliseconds counter.
    p : NATURAL RANGE 0 TO PULSE_WIDTH - 1; -- Pulse counter.
  END RECORD;

  SIGNAL r, rin : reg_t
    := reg_t'(
      s => Idle,
      d => (
        srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
        srcIP  => (OTHERS => '0'), dstIP => (OTHERS => '0'), ipLength => 0,
        srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'), dnsLength => 0,
        dns => (OTHERS => '0')
      ),
      led => x"00"
    );
  SIGNAL s, sin : snd_t
    := snd_t'(
      s => Idle,
      d => (
        srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
        srcIP  => (OTHERS => '0'), dstIP => (OTHERS => '0'), ipLength => 0,
        srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'), dnsLength => 0,
        dns => (OTHERS => '0')
      ),
      q => 0,
      p => 0
    );
  --SIGNAL reg_e_col : STD_LOGIC := '0';
  --SIGNAL reg_e_snd : STD_LOGIC := '0';
 BEGIN

  snd : PROCESS (s) --, E_CRS)
  BEGIN

    sin <= s;

    el_snd_en <= '0'; -- Turn off Ethernet packet sending.

    CASE s.s IS

      WHEN Idle =>
        IF s.q = (CYCLES_PER_MSEC - 1) THEN
          sin.q <= 0;
          IF s.p = (PULSE_WIDTH - 1) THEN
            sin.p <= 0;
            sin.s <= Pulse;
          ELSE
            sin.p <= s.p + 1;
          END IF;
        ELSE
          sin.q <= s.q + 1;
        END IF;

      WHEN Pulse =>
        sin.d <= s.d;
        sin.s <= Transmit;

      WHEN Transmit =>
        --el_snd_en <= '1'; -- Send Ethernet packet.
        sin.s <= Idle;
        --reg_e_snd <= '1';

    END CASE;
  END PROCESS;

  el_snd_data <= s.d;

  nsl : PROCESS (r, el_rcv_data, el_rcv_dv, clk90)
  BEGIN

    rin <= r;
    --el_rcv_ack <= '0'; -- Ethernet receiver data ready ACK.

    CASE r.s IS
      WHEN Idle =>
        IF el_rcv_dv = '1' THEN
          rin.s <= Ready;
        END IF;

      WHEN Ready =>
        rin.led(0) <= '1';
        rin.s <= Send;

      WHEN Send =>
        rin.led(7 DOWNTO 1) <= "1111111";
        rin.led(0) <= '0';
        rin.s <= Idle;

    END CASE;
  END PROCESS;

  LED <= r.led;

  reg : PROCESS (clk) --, E_CRS, E_COL)
  BEGIN
    IF rising_edge(clk) THEN
      r <= rin;
      s <= sin;
    END IF;
  END PROCESS;
END rtl;