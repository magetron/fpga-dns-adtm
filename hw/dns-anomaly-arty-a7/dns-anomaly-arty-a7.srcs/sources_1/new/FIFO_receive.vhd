LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;


ENTITY FIFO_rcv IS
  GENERIC (
    g_depth : NATURAL := 1;
    g_sync_ratio : NATURAL := 2
  );
  PORT (
    clk : IN STD_LOGIC; -- FIFO buffer Clock
    
    w_en : IN STD_LOGIC; -- Write Enable
    w_data : IN rcv_data_t; -- Ethernet Receving Data in
    buf_full : OUT STD_LOGIC; -- Buffer Full
    
    r_en : IN STD_LOGIC; -- Read Enable
    r_data : OUT rcv_data_t; -- Ethernet Receving Data out
    buf_not_empty : OUT STD_LOGIC -- Buffer NOT Empty
  );
END FIFO_rcv;

ARCHITECTURE rtl of FIFO_rcv is
    
  TYPE buf_t IS ARRAY (0 TO g_depth - 1) of rcv_data_t;
  
  SIGNAL buf : buf_t := (OTHERS => (
      srcMAC => (OTHERS => '0'), dstMAC => (OTHERS => '0'),
      srcIP => (OTHERS => '0'), dstIP => (OTHERS => '0'),
      ipHeaderLength => 0, ipLength => 0,
      srcPort => (OTHERS => '0'), dstPort => (OTHERS => '0'),
      dnsLength => 0, dnsPkt => (OTHERS => '0')));
  
  TYPE buf_state_t IS RECORD
    w_en_dcnt : NATURAL RANGE 0 TO g_sync_ratio - 1;
--    w_index : NATURAL RANGE 0 TO g_depth - 1;
--    r_index : NATURAL RANGE 0 TO g_depth - 1;
    c : INTEGER RANGE 0 TO g_depth;
  END RECORD;
    
  SIGNAL b, bin : buf_state_t 
  := buf_state_t'(
  w_en_dcnt => 0,
--  w_index => 0,
--  r_index => 0,
  c => 0
  );
    
BEGIN

  fifo_nsl : PROCESS(clk)
  BEGIN
    IF (rising_edge(clk)) THEN

      -- avoid slow clk in PHY affect the FIFO and causing 4 times more writes
      IF (w_en = '1' and b.w_en_dcnt = 0) THEN
        bin.w_en_dcnt <= g_sync_ratio - 1;
      ELSIF (b.w_en_dcnt > 0) THEN
        bin.w_en_dcnt <= b.w_en_dcnt - 1;
      END IF;
 
      IF (w_en = '1' and b.w_en_dcnt = 0 and r_en = '0' and b.c < g_depth) THEN
        bin.c <= b.c + 1;
      ELSIF ((w_en = '0' or b.w_en_dcnt > 0) and r_en = '1' and b.c > 0) THEN
        bin.c <= b.c - 1;
      END IF;
      
      IF (w_en = '1' and b.w_en_dcnt = 0) THEN
        buf(0) <= w_data;
--        buf(b.w_index) <= w_data;
--        IF (b.w_index = g_depth - 1) THEN
--          bin.w_index <= 0;
--        ELSE
--          bin.w_index <= b.w_index + 1;
--        END IF;
--      ELSE
--        bin.w_index <= b.w_index;
      END IF;
      
--      IF (r_en = '1') THEN
--        IF (b.r_index = g_depth - 1) THEN
--          bin.r_index <= 0;
--        ELSE
--          bin.r_index <= b.r_index + 1;
--        END IF;
--      ELSE
--        bin.r_index <= b.r_index;
--      END IF;

    END IF;
  END PROCESS;
  
--  r_data <= buf(b.r_index);
  r_data <= buf(0);
  buf_full <= '1' WHEN b.c = g_depth ELSE '0';
  buf_not_empty <= '0' WHEN b.c = 0 ELSE '1';
  
  fifo_reg : PROCESS (clk)
  BEGIN
    IF falling_edge(clk) THEN
      b <= bin;
    END IF;
  END PROCESS;
  
END rtl;
