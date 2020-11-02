library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PCK_CRC32_D4.all;
use work.common.all;

entity mac_snd is
   port(
      E_TX_CLK : in  std_logic;                       -- Sender Clock.
      E_TX_EN  : out std_logic;                       -- Sender Enable.
      E_TXD    : out std_logic_vector(3 downto 0);    -- Sent Data.
      E_TX_ER  : out std_logic;                       -- Sent Data Error.
      el_chnl  : in  std_logic_vector(7 downto 0);    -- Data channels.
      el_data  : in  data_t;                          -- Actual data.
      en       : in  std_logic                        -- User Start Send.
   );
end mac_snd;

architecture rtl of mac_snd is

   type mem_t is array(0 to 14) of std_logic_vector(7 downto 0);

   signal mem : mem_t := (
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
      -- EtherType Field: 0x0000                                  --
      --------------------------------------------------------------------------
      -- 0xc - 0xd
      x"00", x"00",

      --------------------------------------------------------------------------
      -- Data Header                                                      --
      --------------------------------------------------------------------------
      -- Data Version.
      -- Hardware returns Version 2 packets to distinguish them from Version 1
      -- packets sent by the host who captures in promiscuous mode only. This
      -- would cause the host to read it's own Version 1 packets as well.
      -- 0xe
      x"02"
   );

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of mem: signal is "BLOCK";

   type state_t is (
      Idle,                      -- Wait for signal en.
      Preamble,                  -- 55 55 55 55 55 55 55 5
      StartOfFrame,              -- d
      Upper,                     -- Send upper Nibble.
      Lower,                     -- Send lower Nibble.
      Channel,                   -- Send Data channel.
      DataU, DataL,              -- Send Actual data.
      FrameCheck,                -- No Frame Check for now.
      InterframeGap              -- Gap between two cosecutive frames (93 Bit).
   );

   type snd_t is record
      s   : state_t;
      crc : std_logic_vector(31 downto 0);   -- CRC32 latch.
      c   : natural range 0 to 63;
      a   : natural range 0 to 7;
   end record;

   signal s, sin : snd_t := snd_t'(Idle, x"ffffffff", 0, 0);
begin

   snd_nsl : process(s, mem, en, el_chnl, el_data)
   begin

      sin     <= s;
      E_TX_EN <= '0';
      E_TXD   <= x"0";
      E_TX_ER <= '0';

      case s.s is
         when Idle =>
            if en = '1' then
               sin.c <= 0;
               sin.s <= Preamble;
            end if;

         -----------------------------------------------------------------------
         -- Ethernet II - Preamble and Start Of Frame.                        --
         -----------------------------------------------------------------------
         when Preamble =>
            E_TXD   <= x"5";
            E_TX_EN <= '1';
            if s.c = 14 then
               sin.c <= 0;
               sin.s <= StartOfFrame;
            else
               sin.c <= s.c + 1;
            end if;

         when StartOfFrame =>
            E_TXD   <= x"d";
            E_TX_EN <= '1';
            sin.crc <= x"ffffffff";
            sin.s   <= Upper;

         -----------------------------------------------------------------------
         -- Custom Protocol Transmit.                                         --
         -----------------------------------------------------------------------
         when Upper =>
            E_TXD   <= mem(s.c)(3 downto 0);
            E_TX_EN <= '1';
            sin.crc <= nextCRC32_D4(mem(s.c)(3 downto 0), s.crc);
            sin.s   <= Lower;

         when Lower =>
            E_TXD   <= mem(s.c)(7 downto 4);
            E_TX_EN <= '1';
            sin.crc <= nextCRC32_D4(mem(s.c)(7 downto 4), s.crc);
            if s.c = 14 then
               sin.c <= 0;
               sin.s <= Channel;
            else
               sin.c <= s.c + 1;
               sin.s <= Upper;
            end if;

         -----------------------------------------------------------------------
         -- Data - Channel Flags.                                             --
         -----------------------------------------------------------------------
         when Channel =>
            E_TXD   <= el_chnl(4*s.c+3 downto 4*s.c);
            E_TX_EN <= '1';
            sin.crc <= nextCRC32_D4(el_chnl(4*s.c+3 downto 4*s.c), s.crc);
            if s.c = 1 then
               sin.c <= 0;
               sin.a <= 0;
               sin.s <= DataU;
            else
               sin.c <= s.c + 1;
            end if;

         -----------------------------------------------------------------------
         --  Data. 8 channels  16 bit.                                        --
         -----------------------------------------------------------------------
         when DataU =>
            E_TXD   <= el_data(s.a)(4*s.c+11 downto 4*s.c+8);
            E_TX_EN <= '1';
            sin.crc <= nextCRC32_D4(el_data(s.a)(4*s.c+11 downto 4*s.c+8), s.crc);
            if s.c = 1 then
               sin.c <= 0;
               sin.s <= DataL;
            else
               sin.c <= s.c + 1;
            end if;

         when DataL =>
            E_TXD   <= el_data(s.a)(4*s.c+3 downto 4*s.c);
            E_TX_EN <= '1';
            sin.crc <= nextCRC32_D4(el_data(s.a)(4*s.c+3 downto 4*s.c), s.crc);
            if s.c = 1 then
               sin.c <= 0;
               if s.a = 7 then
                  sin.a <= 0;
                  sin.s <= FrameCheck;
               else
                  sin.a <= s.a + 1;
                  sin.s <= DataU;
               end if;
            else
               sin.c <= s.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- Ethernet II - Frame Check.                                        --
         -----------------------------------------------------------------------
         when FrameCheck =>
            E_TXD   <= not s.crc(4*s.c+3 downto 4*s.c);
            E_TX_EN <= '1';
            if s.c = 7 then
               sin.c <= 0;
               sin.s <= InterframeGap;
            else
               sin.c <= s.c + 1;
            end if;

         -----------------------------------------------------------------------
         -- Ethernet II - Interframe Gap.                                     --
         -----------------------------------------------------------------------
         when InterframeGap =>
            if s.c = 23 then
               sin.c <= 0;
               sin.s <= Idle;
            else
               sin.c <= s.c + 1;
            end if;
      end case;
   end process;

   snd_reg : process(E_TX_CLK)
   begin
      if rising_edge(E_TX_CLK) then
         s <= sin;
      end if;
   end process;
end rtl;