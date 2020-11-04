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
    el_chnl : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    el_data : IN data_t;
    el_dv : IN STD_LOGIC;
    el_ack : OUT STD_LOGIC;
    -- Data to send.
    el_snd_chnl : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    el_snd_data : OUT data_t;
    el_snd_en : OUT STD_LOGIC;
    -- DAC/ADC Connections.
    SPI_MISO : IN STD_LOGIC;
    SPI_MOSI : OUT STD_LOGIC;
    SPI_SCK : OUT STD_LOGIC;
    DAC_CS : OUT STD_LOGIC;
    DAC_CLR : OUT STD_LOGIC;
    AD_CONV : OUT STD_LOGIC;
    AMP_CS : OUT STD_LOGIC;
    -- Digital lines.
    DI : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    DO : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    -- SWITCHES.
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    -- BUTTONS.
    BTN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
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
  CONSTANT PULSE_WIDTH : NATURAL := 100; -- [msec] Time between two sends.

  CONSTANT CYCLES_PER_MSEC : NATURAL := 1000000/FREQ;

  TYPE state_t IS (Idle, Ready, AnalogOut, Send);

  TYPE reg_t IS RECORD
    s : state_t;
    chnl : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Channel latch.
    ao : STD_LOGIC_VECTOR(23 DOWNTO 4); -- Analog out register.
    do : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Digital out register.
    led : STD_LOGIC_VECTOR(7 DOWNTO 0); -- LED register.
    c : NATURAL RANGE 0 TO 23;
  END RECORD;

  TYPE snd_state_t IS (Idle, Pulse, Transmit);

  TYPE snd_t IS RECORD
    s : snd_state_t;
    d : data_t; -- Data struct.
    q : NATURAL RANGE 0 TO CYCLES_PER_MSEC - 1; -- Milliseconds counter.
    p : NATURAL RANGE 0 TO PULSE_WIDTH - 1; -- Pulse counter.
  END RECORD;

  SIGNAL r, rin : reg_t := reg_t'(Idle, x"00", x"00000", x"0", x"00", 0);
  SIGNAL s, sin : snd_t := snd_t'(Idle, (OTHERS => (OTHERS => '0')), 0, 0);
BEGIN

  snd : PROCESS (s, SW, BTN)
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
        sin.d(CHANNEL_E) <= x"000" & DI; -- Sample digital input.
        sin.d(CHANNEL_G) <= x"000" & BTN; -- Sample buttons.
        sin.d(CHANNEL_H) <= x"000" & SW; -- Sample switches.
        sin.s <= Transmit;

      WHEN Transmit =>
        el_snd_en <= '1'; -- Send Ethernet packet.
        sin.s <= Idle;

    END CASE;
  END PROCESS;

  el_snd_chnl <= "11010000";
  el_snd_data <= s.d;

  nsl : PROCESS (r, el_chnl, el_data, el_dv, clk90, SPI_MISO)

    -- DAC Commands and Addresses.
    CONSTANT CMD_UP : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT ADR_OA : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT ADR_OB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT ADR_OC : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT ADR_OD : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
  BEGIN

    rin <= r;

    SPI_MOSI <= r.ao(23); -- Send always the MSBit of the data register.
    SPI_SCK <= '0'; -- Pull down SPI clock.
    DAC_CLR <= '1'; -- Disable D/A Converter.
    DAC_CS <= '1';
    AD_CONV <= '0'; -- Disable A/D Converter.
    AMP_CS <= '1'; -- Disable Pre Amplifier.

    el_ack <= '0'; -- Ethernet receiver data ready ACK.

    CASE r.s IS
      WHEN Idle =>
        IF el_dv = '1' THEN
          rin.chnl <= el_chnl;
          rin.s <= Ready;
        END IF;

        -- IMPROVE: Merge Ready and AnalogOut states.
      WHEN Ready =>
        --------------------------------------------------------------------
        -- LED Control                                                    --
        --------------------------------------------------------------------
        IF isSet(r.chnl, CHANNEL_H) THEN
          rin.led <= el_data(CHANNEL_H)(7 DOWNTO 0);
          rin.chnl(CHANNEL_H) <= '0';
        END IF;
        --------------------------------------------------------------------
        -- Digital Out Control                                            --
        --------------------------------------------------------------------
        IF isSet(r.chnl, CHANNEL_G) THEN
          rin.do <= el_data(CHANNEL_G)(3 DOWNTO 0);
          rin.chnl(CHANNEL_G) <= '0';
        END IF;
        --------------------------------------------------------------------
        -- Analog Out Control                                             --
        --------------------------------------------------------------------
        IF r.chnl(3 DOWNTO 0) /= x"0" THEN
          rin.s <= AnalogOut;
        ELSE
          rin.s <= Idle;
        END IF;

        -----------------------------------------------------------------------
        -- Analog Out Control                                                --
        -----------------------------------------------------------------------
        -- Send data to DAC. Since all DACs are controlled via a singe serial
        -- interface, the setting of new data follows the following precedence:
        -- A > B > C > D. Thus if data is ready for analog output A, it will be
        -- sent first. Next is analog output B, then C and finally D.
      WHEN AnalogOut =>
        IF isSet(r.chnl, CHANNEL_A) THEN
          rin.ao <= CMD_UP & ADR_OA & el_data(CHANNEL_A)(11 DOWNTO 0);
          rin.chnl(CHANNEL_A) <= '0'; -- Clear channel flag.
          rin.s <= Send;
        ELSIF isSet(r.chnl, CHANNEL_B) THEN
          rin.ao <= CMD_UP & ADR_OB & el_data(CHANNEL_B)(11 DOWNTO 0);
          rin.chnl(CHANNEL_B) <= '0';
          rin.s <= Send;
        ELSIF isSet(r.chnl, CHANNEL_C) THEN
          rin.ao <= CMD_UP & ADR_OC & el_data(CHANNEL_C)(11 DOWNTO 0);
          rin.chnl(CHANNEL_C) <= '0';
          rin.s <= Send;
        ELSIF isSet(r.chnl, CHANNEL_D) THEN
          rin.ao <= CMD_UP & ADR_OD & el_data(CHANNEL_D)(11 DOWNTO 0);
          rin.chnl(CHANNEL_D) <= '0';
          rin.s <= Send;
        ELSE
          rin.s <= Idle; -- All flags are cleared and DACs are updated.
        END IF;

        -- To send data at maximum speed, we send clk90, wich is the clock
        -- signal phase shifted by 90 degree. This is necessary to meet the
        -- timing constraints t1 and t2 defined.
      WHEN Send =>
        DAC_CS <= '0';
        SPI_SCK <= clk90;
        rin.ao <= r.ao(22 DOWNTO 4) & '0';
        IF r.c = 23 THEN
          rin.c <= 0;
          rin.s <= AnalogOut;
        ELSE
          rin.c <= r.c + 1;
          rin.s <= Send;
        END IF;

        -----------------------------------------------------------------------
        -- TODO: Analog In Control                                           --
        -----------------------------------------------------------------------
        -- Pulse the ADC and capture the data from the last pulse.
        -- when Pulse =>
        -- AD_CONV <= '1';
        -- SPI_SCK <= clk90;
        -- rin.c   <= 0;
        -- rin.d(CHANNEL_E) <= x"000" & DI;       -- Sample digital input.
        -- rin.d(CHANNEL_G) <= x"000" & BTN;      -- Sample buttons.
        -- rin.d(CHANNEL_H) <= x"000" & SW;       -- Sample switches.
        -- rin.s   <= Transmit; --Wait0;

        -- when Wait0 =>
        -- SPI_SCK <= clk90;
        -- if r.c = 1 then
        -- rin.c <= 0;
        -- rin.s <= Receive0;
        -- else
        -- rin.c <= r.c + 1;
        -- end if;

        -- when Receive0 =>
        -- SPI_SCK <= clk90;
        -- rin.d(CHANNEL_A) <= r.d(CHANNEL_A)(15 downto 1) & SPI_MISO;
        -- if r.c = 13 then
        -- rin.c <= 0;
        -- rin.s <= Wait1;
        -- else
        -- rin.c <= r.c + 1;
        -- end if;

        -- when Wait1 =>
        -- SPI_SCK <= clk90;
        -- if r.c = 1 then
        -- rin.c <= 0;
        -- rin.s <= Receive1;
        -- else
        -- rin.c <= r.c + 1;
        -- end if;

        -- when Receive1 =>
        -- SPI_SCK <= clk90;
        -- rin.d(CHANNEL_B) <= r.d(CHANNEL_B)(15 downto 1) & SPI_MISO;
        -- if r.c = 13 then
        -- rin.c <= 0;
        -- rin.s <= Transmit;
        -- else
        -- rin.c <= r.c + 1;
        -- end if;

    END CASE;
  END PROCESS;

  DO <= r.do;
  LED <= r.led;

  reg : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      r <= rin;
      s <= sin;
    END IF;
  END PROCESS;
END rtl;