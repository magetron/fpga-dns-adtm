LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY sndtest IS
END sndtest;

ARCHITECTURE behavior OF sndtest IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT main
    PORT (
      clk : IN STD_LOGIC;
      E_COL : IN STD_LOGIC;
      E_CRS : IN STD_LOGIC;
      E_MDC : OUT STD_LOGIC;
      E_MDIO : IN STD_LOGIC;
      E_RX_CLK : IN STD_LOGIC;
      E_RX_DV : IN STD_LOGIC;
      E_RXD : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      E_RX_ER : IN STD_LOGIC;
      E_TX_CLK : IN STD_LOGIC;
      E_TX_EN : OUT STD_LOGIC;
      E_TXD : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      E_TX_ER : OUT STD_LOGIC;
      SPI_MISO : IN STD_LOGIC;
      SPI_MOSI : OUT STD_LOGIC;
      SPI_SCK : OUT STD_LOGIC;
      DAC_CS : OUT STD_LOGIC;
      DAC_CLR : OUT STD_LOGIC;
      SF_OE : OUT STD_LOGIC;
      SF_CE : OUT STD_LOGIC;
      SF_WE : OUT STD_LOGIC;
      FPGA_INIT_B : OUT STD_LOGIC;
      AD_CONV : OUT STD_LOGIC;
      SPI_SS_B : OUT STD_LOGIC;
      AMP_CS : OUT STD_LOGIC;
      DI : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      DO : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      BTN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;
  --Inputs
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL E_COL : STD_LOGIC := '0';
  SIGNAL E_CRS : STD_LOGIC := '0';
  SIGNAL E_MDIO : STD_LOGIC := '0';
  SIGNAL E_RX_CLK : STD_LOGIC := '0';
  SIGNAL E_RX_DV : STD_LOGIC := '0';
  SIGNAL E_RXD : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL E_RX_ER : STD_LOGIC := '0';
  SIGNAL E_TX_CLK : STD_LOGIC := '0';
  SIGNAL SPI_MISO : STD_LOGIC := '0';
  SIGNAL DI : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL SW : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL BTN : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

  --Outputs
  SIGNAL E_MDC : STD_LOGIC;
  SIGNAL E_TX_EN : STD_LOGIC;
  SIGNAL E_TXD : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL E_TX_ER : STD_LOGIC;
  SIGNAL SPI_MOSI : STD_LOGIC;
  SIGNAL SPI_SCK : STD_LOGIC;
  SIGNAL DAC_CS : STD_LOGIC;
  SIGNAL DAC_CLR : STD_LOGIC;
  SIGNAL SF_OE : STD_LOGIC;
  SIGNAL SF_CE : STD_LOGIC;
  SIGNAL SF_WE : STD_LOGIC;
  SIGNAL FPGA_INIT_B : STD_LOGIC;
  SIGNAL AD_CONV : STD_LOGIC;
  SIGNAL SPI_SS_B : STD_LOGIC;
  SIGNAL AMP_CS : STD_LOGIC;
  SIGNAL DO : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL LED : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : TIME := 20 ns;
  CONSTANT E_RX_CLK_period : TIME := 40 ns;
  CONSTANT E_TX_CLK_period : TIME := 40 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : main PORT MAP(
    clk => clk,
    E_COL => E_COL,
    E_CRS => E_CRS,
    E_MDC => E_MDC,
    E_MDIO => E_MDIO,
    E_RX_CLK => E_RX_CLK,
    E_RX_DV => E_RX_DV,
    E_RXD => E_RXD,
    E_RX_ER => E_RX_ER,
    E_TX_CLK => E_TX_CLK,
    E_TX_EN => E_TX_EN,
    E_TXD => E_TXD,
    E_TX_ER => E_TX_ER,
    SPI_MISO => SPI_MISO,
    SPI_MOSI => SPI_MOSI,
    SPI_SCK => SPI_SCK,
    DAC_CS => DAC_CS,
    DAC_CLR => DAC_CLR,
    SF_OE => SF_OE,
    SF_CE => SF_CE,
    SF_WE => SF_WE,
    FPGA_INIT_B => FPGA_INIT_B,
    AD_CONV => AD_CONV,
    SPI_SS_B => SPI_SS_B,
    AMP_CS => AMP_CS,
    DI => DI,
    DO => DO,
    SW => SW,
    BTN => BTN,
    LED => LED
  );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  E_RX_CLK_process : PROCESS
  BEGIN
    E_RX_CLK <= '0';
    WAIT FOR E_RX_CLK_period/2;
    E_RX_CLK <= '1';
    WAIT FOR E_RX_CLK_period/2;
  END PROCESS;

  E_TX_CLK_process : PROCESS
  BEGIN
    E_TX_CLK <= '0';
    WAIT FOR E_TX_CLK_period/2;
    E_TX_CLK <= '1';
    WAIT FOR E_TX_CLK_period/2;
  END PROCESS;
  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;

    WAIT FOR clk_period * 10;

    -- insert stimulus here
    --BTN(0) <= '1';
    --BTN(1) <= '1';

    WAIT FOR 1 sec;

    --BTN(1) <= '0';
    --BTN(0) <= '0';

    WAIT;
  END PROCESS;

END;