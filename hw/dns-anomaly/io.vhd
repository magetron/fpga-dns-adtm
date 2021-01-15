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
  -----------------------------------------------------------------------------
  CONSTANT FREQ : NATURAL := 50; -- [MHz] Frequency.
  --CONSTANT PULSE_WIDTH : NATURAL := 1000; -- [msec] Time between two sends
  CONSTANT CYCLES_PER_MSEC : NATURAL := FREQ * 1000;

  TYPE state_t IS (
    Idle,
    Work,
    Send
  );

  TYPE iostate_t IS RECORD
    s : state_t;
    d : data_t; -- Data struct
    led : STD_LOGIC_VECTOR(7 DOWNTO 0); -- LED register.
    c : NATURAL RANGE 0 TO 255;
  END RECORD;

  SIGNAL s, sin : iostate_t
    := iostate_t'(
      s => Idle,
      d => (
        srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
        srcIP  => (OTHERS => '0'), dstIP => (OTHERS => '0'),
        ipHeaderLength => 0, ipLength => 0,
        srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'), dnsLength => 0
        --dns => (OTHERS => '0')
      ),
      led => x"00",
      c => 0
    );
  --SIGNAL reg_e_col : STD_LOGIC := '0';
  --SIGNAL reg_e_snd : STD_LOGIC := '0';
 BEGIN

  rcvsnd : PROCESS (s, el_rcv_data, el_rcv_dv, clk90)
  BEGIN

    sin <= s;
    el_snd_en <= '0';
    --el_rcv_ack <= '0'; -- Ethernet receiver data ready ACK.

    CASE s.s IS
      WHEN Idle =>
        IF el_rcv_dv = '1' THEN
          sin.d <= el_rcv_data;
          sin.s <= Work;
        END IF;

      WHEN Work =>
        -- DO Processing
        --sin.d.srcMAC <= x"000000350a00";
        --sin.d.dstMAC <= x"98dc6b4ce000";
        sin.d.srcMAC <= s.d.dstMAC;
        sin.d.dstMAC <= x"98dc6b4ce000";
        sin.d.srcIP <= s.d.dstIP;
        sin.d.dstIP <= s.d.srcIP;
        sin.d.srcPort <= s.d.dstPort;
        sin.d.dstPort <= s.d.srcPort;
        sin.s <= Send;

      WHEN Send =>
        el_snd_en <= '1'; -- Send Ethernet packet.
        sin.c <= s.c + 1;
        sin.led <= STD_LOGIC_VECTOR(to_unsigned(s.c + 1, sin.led'length));
        sin.s <= Idle;

    END CASE;
  END PROCESS;

  LED <= s.led;
  el_snd_data <= s.d;

  reg : PROCESS (clk) --, E_CRS, E_COL)
  BEGIN
    IF rising_edge(clk) THEN
      s <= sin;
    END IF;
  END PROCESS;
END rtl;