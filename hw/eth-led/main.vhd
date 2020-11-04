--------------------------------------------------------------------------------
-- ETHERLAB - FPGA To C# To LABVIEW Bridge                                    --
--------------------------------------------------------------------------------
-- Copyright (C)2012  Mathias H�rtnagl <mathias.hoertnagl@gmail.com>          --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.common.ALL;

ENTITY main IS
  PORT (
    clk : IN STD_LOGIC;

    E_COL : IN STD_LOGIC; -- Collision Detect.
    E_CRS : IN STD_LOGIC; -- Carrier Sense.
    E_MDC : OUT STD_LOGIC;
    E_MDIO : IN STD_LOGIC;
    E_RX_CLK : IN STD_LOGIC; -- Receiver Clock.
    E_RX_DV : IN STD_LOGIC; -- Received Data Valid.
    E_RXD : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Received Nibble.
    E_RX_ER : IN STD_LOGIC; -- Received Data Error.
    E_TX_CLK : IN STD_LOGIC; -- Sender Clock.
    E_TX_EN : OUT STD_LOGIC; -- Sender Enable.
    E_TXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sent Data.
    E_TX_ER : OUT STD_LOGIC; -- sent Data Error.

    SPI_MISO : IN STD_LOGIC; -- Serial data in.
    SPI_MOSI : OUT STD_LOGIC; -- Serial data out.
    SPI_SCK : OUT STD_LOGIC; -- Serial Interface clock.
    DAC_CS : OUT STD_LOGIC; -- D/A Converter chip sel.
    DAC_CLR : OUT STD_LOGIC; -- D/A Converter reset.

    SF_OE : OUT STD_LOGIC; -- StrataFlash.
    SF_CE : OUT STD_LOGIC;
    SF_WE : OUT STD_LOGIC;
    FPGA_INIT_B : OUT STD_LOGIC;
    AD_CONV : OUT STD_LOGIC; -- A/D Converter chip sel.
    SPI_SS_B : OUT STD_LOGIC;
    AMP_CS : OUT STD_LOGIC; -- Pre-Amplifier chip sel.

    DI : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- 6-pin header J1.
    DO : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 6-pin header J2.
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- SWITCHES.
    BTN : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- BUTTONS.
    LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- LEDs.
  );
END main;

ARCHITECTURE rtl OF main IS

  COMPONENT clock
    PORT (
      clkin_in : IN STD_LOGIC;
      rst_in : IN STD_LOGIC;
      clkin_ibufg_out : OUT STD_LOGIC;
      clk0_out : OUT STD_LOGIC;
      clk90_out : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT mac_rcv IS
    PORT (
      E_RX_CLK : IN STD_LOGIC; -- Receiver Clock.
      E_RX_DV : IN STD_LOGIC; -- Received Data Valid.
      E_RXD : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Received Nibble.
      el_chnl : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channels.
      el_data : OUT data_t; -- Channel metadata.
      el_dv : OUT STD_LOGIC; -- Data valid.
      el_ack : IN STD_LOGIC -- Packet reception ACK.
    );
  END COMPONENT;

  COMPONENT mac_snd IS
    PORT (
      E_TX_CLK : IN STD_LOGIC; -- Sender Clock.
      E_TX_EN : OUT STD_LOGIC; -- Sender Enable.
      E_TXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Sent Data.
      E_TX_ER : OUT STD_LOGIC; -- Sent Data Error.
      el_chnl : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channels.
      el_data : IN data_t; -- Actual Data
      en : IN STD_LOGIC -- User Start Send.
    );
  END COMPONENT;

  COMPONENT io IS
    PORT (
      clk : IN STD_LOGIC;
      clk90 : IN STD_LOGIC;
      -- data received.
      el_chnl : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      el_data : IN data_t;
      el_dv : IN STD_LOGIC;
      el_ack : OUT STD_LOGIC;
      -- data to send.
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
  END COMPONENT;

  SIGNAL el_chnl : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data channels.
  SIGNAL el_data : data_t; -- Actual data.
  SIGNAL el_dv : STD_LOGIC; -- Received data valid.
  SIGNAL el_ack : STD_LOGIC; -- Packet reception ACK.

  SIGNAL el_snd_chnl : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Send channels.
  SIGNAL el_snd_data : data_t; -- Send data.
  SIGNAL el_snd_en : STD_LOGIC; -- Enable sending.

  SIGNAL clk90 : STD_LOGIC; -- Clock shiftet 90 degree.
  SIGNAL clk0 : STD_LOGIC;
BEGIN

  SF_OE <= '1'; -- Turn off Strata Flash.
  SF_WE <= '1';
  SF_CE <= '1';
  FPGA_INIT_B <= '1'; -- Turn off Platform Flash.
  SPI_SS_B <= '1'; -- Turn off Serial Flash.

  E_MDC <= '0';

  inst_clock : clock PORT MAP(
    clkin_in => clk,
    rst_in => '0',
    clkin_ibufg_out => OPEN,
    clk0_out => clk0,
    clk90_out => clk90
  );

  mac_receive : mac_rcv PORT MAP(
    E_RX_CLK => E_RX_CLK,
    E_RX_DV => E_RX_DV,
    E_RXD => E_RXD,
    el_chnl => el_chnl,
    el_data => el_data,
    el_dv => el_dv,
    el_ack => el_ack
  );

  mac_send : mac_snd PORT MAP(
    E_TX_CLK => E_TX_CLK,
    E_TX_EN => E_TX_EN,
    E_TXD => E_TXD,
    E_TX_ER => E_TX_ER,
    en => el_snd_en,
    el_chnl => el_snd_chnl,
    el_data => el_snd_data
  );

  ioio : io PORT MAP(
    clk => clk0,
    clk90 => clk90,
    -- Data received.
    el_chnl => el_chnl,
    el_data => el_data,
    el_dv => el_dv,
    el_ack => el_ack,
    -- Data to send.
    el_snd_chnl => el_snd_chnl,
    el_snd_data => el_snd_data,
    el_snd_en => el_snd_en,
    -- DAC/ADC Connections.
    SPI_MISO => SPI_MISO,
    SPI_MOSI => SPI_MOSI,
    SPI_SCK => SPI_SCK,
    DAC_CS => DAC_CS,
    DAC_CLR => DAC_CLR,
    AD_CONV => AD_CONV,
    AMP_CS => AMP_CS,
    -- Digital lines.
    DI => DI,
    DO => DO,
    -- SWITCHES.
    SW => SW,
    -- BUTTONS.
    BTN => BTN,
    -- LEDs.
    LED => LED
  );
END rtl;