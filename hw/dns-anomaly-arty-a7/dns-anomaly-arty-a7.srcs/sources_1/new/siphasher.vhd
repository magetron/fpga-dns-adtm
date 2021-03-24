LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;

ENTITY siphasher IS
PORT (
  clk : IN STD_LOGIC;
  in_key : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
  in_data : IN STD_LOGIC_VECTOR(959 DOWNTO 0);
  in_start : IN STD_LOGIC;
  out_data : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  out_ready : OUT STD_LOGIC
);
END siphasher;

ARCHITECTURE rtl OF siphasher IS
  TYPE state_t IS (
    Idle,
    InitV,
    InitKey,
    Compression,
    CompressionLength,
    Finalise,
    Output
  );

  TYPE hstate_t IS RECORD
    s : state_t;
    c : NATURAL RANGE 0 TO 1023;
    v0 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    v1 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    v2 : STD_LOGIC_VECTOR(63 DOWNTO 0);
    v3 : STD_LOGIC_VECTOR(63 DOWNTO 0);
  END RECORD;

  SIGNAL s, sin : hstate_t
  := hstate_t' (
    s => Idle,
    c => 0,
    v0 => (OTHERS => '0'),
    v1 => (OTHERS => '0'),
    v2 => (OTHERS => '0'),
    v3 => (OTHERS => '0')
  );

  SIGNAL d : STD_LOGIC_VECTOR(959 DOWNTO 0) := (OTHERS => '0');
  SIGNAL k : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');

  PROCEDURE compression_sipround_2(
    SIGNAL v0_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v1_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v2_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v3_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v0_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v1_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v2_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v3_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    d_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0)
  ) IS
  VARIABLE v0, v1, v2, v3, d : UNSIGNED(63 downto 0);
  begin
    v0 := UNSIGNED(v0_in);
    v1 := UNSIGNED(v1_in);
    v2 := UNSIGNED(v2_in);
    v3 := UNSIGNED(v3_in);
    d := UNSIGNED(d_in);

    v3 := v3 xor d;

    FOR i in 0 TO 1 LOOP
      v0 := v0 + v1;
      v2 := v2 + v3;
      v1 := rotate_left(v1, 13);
      v3 := rotate_left(v3, 16);
      v1 := v1 xor v0;
      v3 := v3 xor v2;
      v0 := rotate_left(v0, 32);
      v0 := v0 + v3;
      v2 := v2 + v1;
      v1 := rotate_left(v1, 17);
      v3 := rotate_left(v3, 21);
      v1 := v1 xor v2;
      v3 := v3 xor v0;
      v2 := rotate_left(v2, 32);
    END LOOP;

    v0 := v0 xor d;

    v0_out <= STD_LOGIC_VECTOR(v0);
    v1_out <= STD_LOGIC_VECTOR(v1);
    v2_out <= STD_LOGIC_VECTOR(v2);
    v3_out <= STD_LOGIC_VECTOR(v3);

  END compression_sipround_2;

  PROCEDURE finalise_sipround_4(
    SIGNAL v0_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v1_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v2_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v3_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v0_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v1_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v2_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v3_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  ) IS
  VARIABLE v0, v1, v2, v3 : UNSIGNED(63 downto 0);
  BEGIN

    v0 := UNSIGNED(v0_in);
    v1 := UNSIGNED(v1_in);
    v2 := UNSIGNED(v2_in);
    v3 := UNSIGNED(v3_in);

    v2 := v2 xor x"00000000000000ff";

    FOR i in 0 TO 3 LOOP
      v0 := v0 + v1;
      v2 := v2 + v3;
      v1 := rotate_left(v1, 13);
      v3 := rotate_left(v3, 16);
      v1 := v1 xor v0;
      v3 := v3 xor v2;
      v0 := rotate_left(v0, 32);
      v0 := v0 + v3;
      v2 := v2 + v1;
      v1 := rotate_left(v1, 17);
      v3 := rotate_left(v3, 21);
      v1 := v1 xor v2;
      v3 := v3 xor v0;
      v2 := rotate_left(v2, 32);
    END LOOP;

    v0 := v0 xor v1 xor v2 xor v3;

    v0_out <= STD_LOGIC_VECTOR(v0);
    v1_out <= STD_LOGIC_VECTOR(v1);
    v2_out <= STD_LOGIC_VECTOR(v2);
    v3_out <= STD_LOGIC_VECTOR(v3);

  END finalise_sipround_4;

BEGIN
  hash : PROCESS (clk)

  BEGIN
    IF rising_edge(clk) THEN
      out_ready <= '0';

      CASE s.s IS
        WHEN Idle =>
          IF (in_start = '1') THEN
            sin.s <= InitV;
            d <= in_data;
            k <= in_key;
          ELSE
            sin.s <= Idle;
          END IF;

        WHEN InitV =>
          sin.v0 <= x"736f6d6570736575";
          sin.v1 <= x"646f72616e646f6d";
          sin.v2 <= x"6c7967656e657261";
          sin.v3 <= x"7465646279746573";
          sin.s <= InitKey;

        WHEN InitKey =>
          sin.v3 <= s.v3 xor (k(127 DOWNTO 64));
          sin.v2 <= s.v2 xor (k(63 DOWNTO 0));
          sin.v1 <= s.v1 xor (k(127 DOWNTO 64));
          sin.v0 <= s.v0 xor (k(63 DOWNTO 0));
          sin.c <= 0;
          sin.s <= Compression;

        WHEN Compression =>
          IF (s.c = 960) THEN
            sin.s <= CompressionLength;
          ELSE
            compression_sipround_2(s.v0, s.v1, s.v2, s.v3, sin.v0, sin.v1, sin.v2, sin.v3, d(s.c + 63 DOWNTO s.c));
            sin.c <= s.c + 64;
          END IF;

        WHEN CompressionLength =>
          compression_sipround_2(s.v0, s.v1, s.v2, s.v3, sin.v0, sin.v1, sin.v2, sin.v3, x"7800000000000000");
          sin.s <= Finalise;

        WHEN Finalise =>
          finalise_sipround_4(s.v0, s.v1, s.v2, s.v3, sin.v0, sin.v1, sin.v2, sin.v3);
          sin.s <= Output;

        WHEN Output =>
          out_ready <= '1';
          sin.s <= Idle;

      END CASE;
    END IF;
  END PROCESS;

  out_data <= s.v0;

  reg : PROCESS(clk)
  BEGIN
    IF falling_edge(clk) THEN
      s <= sin;
    END IF;
  END PROCESS;

END rtl;
