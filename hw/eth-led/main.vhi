
-- VHDL Instantiation Created from source file main.vhd -- 23:18:56 11/22/2020
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT main
	PORT(
		clk : IN std_logic;
		E_COL : IN std_logic;
		E_CRS : IN std_logic;
		E_MDIO : IN std_logic;
		E_RX_CLK : IN std_logic;
		E_RX_DV : IN std_logic;
		E_RXD : IN std_logic_vector(3 downto 0);
		E_RX_ER : IN std_logic;
		E_TX_CLK : IN std_logic;
		SPI_MISO : IN std_logic;
		DI : IN std_logic_vector(3 downto 0);
		SW : IN std_logic_vector(3 downto 0);
		BTN : IN std_logic_vector(3 downto 0);          
		E_MDC : OUT std_logic;
		E_TX_EN : OUT std_logic;
		E_TXD : OUT std_logic_vector(3 downto 0);
		E_TX_ER : OUT std_logic;
		SPI_MOSI : OUT std_logic;
		SPI_SCK : OUT std_logic;
		DAC_CS : OUT std_logic;
		DAC_CLR : OUT std_logic;
		SF_OE : OUT std_logic;
		SF_CE : OUT std_logic;
		SF_WE : OUT std_logic;
		FPGA_INIT_B : OUT std_logic;
		AD_CONV : OUT std_logic;
		SPI_SS_B : OUT std_logic;
		AMP_CS : OUT std_logic;
		DO : OUT std_logic_vector(3 downto 0);
		LED : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_main: main PORT MAP(
		clk => ,
		E_COL => ,
		E_CRS => ,
		E_MDC => ,
		E_MDIO => ,
		E_RX_CLK => ,
		E_RX_DV => ,
		E_RXD => ,
		E_RX_ER => ,
		E_TX_CLK => ,
		E_TX_EN => ,
		E_TXD => ,
		E_TX_ER => ,
		SPI_MISO => ,
		SPI_MOSI => ,
		SPI_SCK => ,
		DAC_CS => ,
		DAC_CLR => ,
		SF_OE => ,
		SF_CE => ,
		SF_WE => ,
		FPGA_INIT_B => ,
		AD_CONV => ,
		SPI_SS_B => ,
		AMP_CS => ,
		DI => ,
		DO => ,
		SW => ,
		BTN => ,
		LED => 
	);


