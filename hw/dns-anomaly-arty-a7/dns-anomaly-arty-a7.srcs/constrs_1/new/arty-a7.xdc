## This file is a general .xdc for the Arty A7-35 Rev. D
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Switches
#set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]
#set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L13P_T2_MRCC_16 Sch=sw[1]
#set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L13N_T2_MRCC_16 Sch=sw[2]
#set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L14P_T2_SRCC_16 Sch=sw[3]

## RGB LEDs
#set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L18N_T2_35 Sch=led0_b
#set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { led0_g }]; #IO_L19N_T3_VREF_35 Sch=led0_g
#set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L19P_T3_35 Sch=led0_r
#set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { led1_b }]; #IO_L20P_T3_35 Sch=led1_b
#set_property -dict { PACKAGE_PIN J4    IOSTANDARD LVCMOS33 } [get_ports { led1_g }]; #IO_L21P_T3_DQS_35 Sch=led1_g
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { led1_r }]; #IO_L20N_T3_35 Sch=led1_r
#set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { led2_b }]; #IO_L21N_T3_DQS_35 Sch=led2_b
#set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { led2_g }]; #IO_L22N_T3_35 Sch=led2_g
#set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports { led2_r }]; #IO_L22P_T3_35 Sch=led2_r
#set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { led3_b }]; #IO_L23P_T3_35 Sch=led3_b
#set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { led3_g }]; #IO_L24P_T3_35 Sch=led3_g
#set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { led3_r }]; #IO_L23N_T3_35 Sch=led3_r

## LEDs
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]

## Buttons
#set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L6N_T0_VREF_16 Sch=btn[0]
#set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L11P_T1_SRCC_16 Sch=btn[1]
#set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L11N_T1_SRCC_16 Sch=btn[2]
#set_property -dict { PACKAGE_PIN B8    IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L12P_T1_MRCC_16 Sch=btn[3]

## Pmod Header JA
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_0_15 Sch=ja[1]
#set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L4P_T0_15 Sch=ja[2]
#set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L4N_T0_15 Sch=ja[3]
#set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L6P_T0_15 Sch=ja[4]
#set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L6N_T0_VREF_15 Sch=ja[7]
#set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L10P_T1_AD11P_15 Sch=ja[8]
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L10N_T1_AD11N_15 Sch=ja[9]
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_25_15 Sch=ja[10]

## Pmod Header JB
#set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { jb[0] }]; #IO_L11P_T1_SRCC_15 Sch=jb_p[1]
#set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { jb[1] }]; #IO_L11N_T1_SRCC_15 Sch=jb_n[1]
#set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { jb[2] }]; #IO_L12P_T1_MRCC_15 Sch=jb_p[2]
#set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { jb[3] }]; #IO_L12N_T1_MRCC_15 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { jb[4] }]; #IO_L23P_T3_FOE_B_15 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { jb[5] }]; #IO_L23N_T3_FWE_B_15 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { jb[6] }]; #IO_L24P_T3_RS1_15 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { jb[7] }]; #IO_L24N_T3_RS0_15 Sch=jb_n[4]

## Pmod Header JC
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { jc[0] }]; #IO_L20P_T3_A08_D24_14 Sch=jc_p[1]
#set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { jc[1] }]; #IO_L20N_T3_A07_D23_14 Sch=jc_n[1]
#set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { jc[2] }]; #IO_L21P_T3_DQS_14 Sch=jc_p[2]
#set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { jc[3] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=jc_n[2]
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { jc[4] }]; #IO_L22P_T3_A05_D21_14 Sch=jc_p[3]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { jc[5] }]; #IO_L22N_T3_A04_D20_14 Sch=jc_n[3]
#set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { jc[6] }]; #IO_L23P_T3_A03_D19_14 Sch=jc_p[4]
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { jc[7] }]; #IO_L23N_T3_A02_D18_14 Sch=jc_n[4]

## Pmod Header JD
#set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { jd[0] }]; #IO_L11N_T1_SRCC_35 Sch=jd[1]
#set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports { jd[1] }]; #IO_L12N_T1_MRCC_35 Sch=jd[2]
#set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { jd[2] }]; #IO_L13P_T2_MRCC_35 Sch=jd[3]
#set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { jd[3] }]; #IO_L13N_T2_MRCC_35 Sch=jd[4]
#set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS33 } [get_ports { jd[4] }]; #IO_L14P_T2_SRCC_35 Sch=jd[7]
#set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports { jd[5] }]; #IO_L14N_T2_SRCC_35 Sch=jd[8]
#set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]; #IO_L15P_T2_DQS_35 Sch=jd[9]
#set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]; #IO_L15N_T2_DQS_35 Sch=jd[10]

## USB-UART Interface
#set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_out }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in

## ChipKit Outer Digital Header
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { ck_io0  }]; #IO_L16P_T2_CSI_B_14          Sch=ck_io[0]
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { ck_io1  }]; #IO_L18P_T2_A12_D28_14        Sch=ck_io[1]
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { ck_io2  }]; #IO_L8N_T1_D12_14             Sch=ck_io[2]
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { ck_io3  }]; #IO_L19P_T3_A10_D26_14        Sch=ck_io[3]
#set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { ck_io4  }]; #IO_L5P_T0_D06_14             Sch=ck_io[4]
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { ck_io5  }]; #IO_L14P_T2_SRCC_14           Sch=ck_io[5]
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { ck_io6  }]; #IO_L14N_T2_SRCC_14           Sch=ck_io[6]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { ck_io7  }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=ck_io[7]
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { ck_io8  }]; #IO_L11P_T1_SRCC_14           Sch=ck_io[8]
#set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { ck_io9  }]; #IO_L10P_T1_D14_14            Sch=ck_io[9]
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { ck_io10 }]; #IO_L18N_T2_A11_D27_14        Sch=ck_io[10]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { ck_io11 }]; #IO_L17N_T2_A13_D29_14        Sch=ck_io[11]
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ck_io12 }]; #IO_L12N_T1_MRCC_14           Sch=ck_io[12]
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { ck_io13 }]; #IO_L12P_T1_MRCC_14           Sch=ck_io[13]

## ChipKit Inner Digital Header
#set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { ck_io26 }]; #IO_L19N_T3_A09_D25_VREF_14 	Sch=ck_io[26]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { ck_io27 }]; #IO_L16N_T2_A15_D31_14 		Sch=ck_io[27]
#set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { ck_io28 }]; #IO_L6N_T0_D08_VREF_14 		Sch=ck_io[28]
#set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { ck_io29 }]; #IO_25_14 		 			Sch=ck_io[29]
#set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { ck_io30 }]; #IO_0_14  		 			Sch=ck_io[30]
#set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { ck_io31 }]; #IO_L5N_T0_D07_14 			Sch=ck_io[31]
#set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { ck_io32 }]; #IO_L13N_T2_MRCC_14 			Sch=ck_io[32]
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { ck_io33 }]; #IO_L13P_T2_MRCC_14 			Sch=ck_io[33]
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ck_io34 }]; #IO_L15P_T2_DQS_RDWR_B_14 	Sch=ck_io[34]
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { ck_io35 }]; #IO_L11N_T1_SRCC_14 			Sch=ck_io[35]
#set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { ck_io36 }]; #IO_L8P_T1_D11_14 			Sch=ck_io[36]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { ck_io37 }]; #IO_L17P_T2_A14_D30_14 		Sch=ck_io[37]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { ck_io38 }]; #IO_L7N_T1_D10_14 			Sch=ck_io[38]
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { ck_io39 }]; #IO_L7P_T1_D09_14 			Sch=ck_io[39]
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { ck_io40 }]; #IO_L9N_T1_DQS_D13_14 		Sch=ck_io[40]
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { ck_io41 }]; #IO_L9P_T1_DQS_14 			Sch=ck_io[41]

## ChipKit Outer Analog Header - as Single-Ended Analog Inputs
## NOTE: These ports can be used as single-ended analog inputs with voltages from 0-3.3V (ChipKit analog pins A0-A5) or as digital I/O.
## WARNING: Do not use both sets of constraints at the same time!
## NOTE: The following constraints should be used with the XADC IP core when using these ports as analog inputs.
#set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { vaux4_n  }]; #IO_L1N_T0_AD4N_35 		Sch=ck_an_n[0]	ChipKit pin=A0
#set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { vaux4_p  }]; #IO_L1P_T0_AD4P_35 		Sch=ck_an_p[0]	ChipKit pin=A0
#set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { vaux5_n  }]; #IO_L3N_T0_DQS_AD5N_35 	Sch=ck_an_n[1]	ChipKit pin=A1
#set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { vaux5_p  }]; #IO_L3P_T0_DQS_AD5P_35 	Sch=ck_an_p[1]	ChipKit pin=A1
#set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { vaux6_n  }]; #IO_L7N_T1_AD6N_35 		Sch=ck_an_n[2]	ChipKit pin=A2
#set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { vaux6_p  }]; #IO_L7P_T1_AD6P_35 		Sch=ck_an_p[2]	ChipKit pin=A2
#set_property -dict { PACKAGE_PIN A1    IOSTANDARD LVCMOS33 } [get_ports { vaux7_n  }]; #IO_L9N_T1_DQS_AD7N_35 	Sch=ck_an_n[3]	ChipKit pin=A3
#set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports { vaux7_p  }]; #IO_L9P_T1_DQS_AD7P_35 	Sch=ck_an_p[3]	ChipKit pin=A3
#set_property -dict { PACKAGE_PIN B2    IOSTANDARD LVCMOS33 } [get_ports { vaux15_n }]; #IO_L10N_T1_AD15N_35 	Sch=ck_an_n[4]	ChipKit pin=A4
#set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { vaux15_p }]; #IO_L10P_T1_AD15P_35 	Sch=ck_an_p[4]	ChipKit pin=A4
#set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { vaux0_n  }]; #IO_L1N_T0_AD0N_15 		Sch=ck_an_n[5]	ChipKit pin=A5
#set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { vaux0_p  }]; #IO_L1P_T0_AD0P_15 		Sch=ck_an_p[5]	ChipKit pin=A5
## ChipKit Outer Analog Header - as Digital I/O
## NOTE: the following constraints should be used when using these ports as digital I/O.
#set_property -dict { PACKAGE_PIN F5    IOSTANDARD LVCMOS33 } [get_ports { ck_a0 }]; #IO_0_35           	Sch=ck_a[0]		ChipKit pin=A0
#set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { ck_a1 }]; #IO_L4P_T0_35      	Sch=ck_a[1]		ChipKit pin=A1
#set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { ck_a2 }]; #IO_L4N_T0_35      	Sch=ck_a[2]		ChipKit pin=A2
#set_property -dict { PACKAGE_PIN E7    IOSTANDARD LVCMOS33 } [get_ports { ck_a3 }]; #IO_L6P_T0_35      	Sch=ck_a[3]		ChipKit pin=A3
#set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { ck_a4 }]; #IO_L6N_T0_VREF_35 	Sch=ck_a[4]		ChipKit pin=A4
#set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { ck_a5 }]; #IO_L11P_T1_SRCC_35	Sch=ck_a[5]		ChipKit pin=A5

## ChipKit Inner Analog Header - as Differential Analog Inputs
## NOTE: These ports can be used as differential analog inputs with voltages from 0-1.0V (ChipKit Analog pins A6-A11) or as digital I/O.
## WARNING: Do not use both sets of constraints at the same time!
## NOTE: The following constraints should be used with the XADC core when using these ports as analog inputs.
#set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { vaux12_p }]; #IO_L2P_T0_AD12P_35	Sch=ad_p[12]	ChipKit pin=A6
#set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { vaux12_n }]; #IO_L2N_T0_AD12N_35	Sch=ad_n[12]	ChipKit pin=A7
#set_property -dict { PACKAGE_PIN E6    IOSTANDARD LVCMOS33 } [get_ports { vaux13_p }]; #IO_L5P_T0_AD13P_35	Sch=ad_p[13]	ChipKit pin=A8
#set_property -dict { PACKAGE_PIN E5    IOSTANDARD LVCMOS33 } [get_ports { vaux13_n }]; #IO_L5N_T0_AD13N_35	Sch=ad_n[13]	ChipKit pin=A9
#set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { vaux14_p }]; #IO_L8P_T1_AD14P_35	Sch=ad_p[14]	ChipKit pin=A10
#set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { vaux14_n }]; #IO_L8N_T1_AD14N_35	Sch=ad_n[14]	ChipKit pin=A11
## ChipKit Inner Analog Header - as Digital I/O
## NOTE: the following constraints should be used when using the inner analog header ports as digital I/O.
#set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { ck_io20 }]; #IO_L2P_T0_AD12P_35	Sch=ad_p[12]	ChipKit pin=A6
#set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { ck_io21 }]; #IO_L2N_T0_AD12N_35	Sch=ad_n[12]	ChipKit pin=A7
#set_property -dict { PACKAGE_PIN E6    IOSTANDARD LVCMOS33 } [get_ports { ck_io22 }]; #IO_L5P_T0_AD13P_35	Sch=ad_p[13]	ChipKit pin=A8
#set_property -dict { PACKAGE_PIN E5    IOSTANDARD LVCMOS33 } [get_ports { ck_io23 }]; #IO_L5N_T0_AD13N_35	Sch=ad_n[13]	ChipKit pin=A9
#set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { ck_io24 }]; #IO_L8P_T1_AD14P_35	Sch=ad_p[14]	ChipKit pin=A10
#set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { ck_io25 }]; #IO_L8N_T1_AD14N_35	Sch=ad_n[14]	ChipKit pin=A11

## ChipKit SPI
#set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { ck_miso }]; #IO_L17N_T2_35 Sch=ck_miso
#set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { ck_mosi }]; #IO_L17P_T2_35 Sch=ck_mosi
#set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { ck_sck }]; #IO_L18P_T2_35 Sch=ck_sck
#set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports { ck_ss }]; #IO_L16N_T2_35 Sch=ck_ss

## ChipKit I2C
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { ck_scl }]; #IO_L4P_T0_D04_14 Sch=ck_scl
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { ck_sda }]; #IO_L4N_T0_D05_14 Sch=ck_sda
#set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports { scl_pup }]; #IO_L9N_T1_DQS_AD3N_15 Sch=scl_pup
#set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports { sda_pup }]; #IO_L9P_T1_DQS_AD3P_15 Sch=sda_pup

## Misc. ChipKit Ports
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { ck_ioa }]; #IO_L10N_T1_D15_14 Sch=ck_ioa
#set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { ck_rst }]; #IO_L16P_T2_35 Sch=ck_rst

## SMSC Ethernet PHY
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { eth_col }]; #IO_L16N_T2_A27_15 Sch=eth_col
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { eth_crs }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=eth_crs
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { eth_mdc }]; #IO_L14N_T2_SRCC_15 Sch=eth_mdc
#set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { eth_mdio }]; #IO_L17P_T2_A26_15 Sch=eth_mdio
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports E_REF_CLK]
#set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { eth_rstn }]; #IO_L20P_T3_A20_15 Sch=eth_rstn
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports E_RX_CLK]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports E_RX_DV]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {E_RXD[0]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {E_RXD[1]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {E_RXD[2]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {E_RXD[3]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports E_RX_ER]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports E_TX_CLK]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports E_TX_EN]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {E_TXD[0]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {E_TXD[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {E_TXD[2]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {E_TXD[3]}]

## Quad SPI Flash
#set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]

## Power Measurements
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33     } [get_ports { vsnsvu_n }]; #IO_L7N_T1_AD2N_15 Sch=ad_n[2]
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33     } [get_ports { vsnsvu_p }]; #IO_L7P_T1_AD2P_15 Sch=ad_p[2]
#set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33     } [get_ports { vsns5v0_n }]; #IO_L3N_T0_DQS_AD1N_15 Sch=ad_n[1]
#set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33     } [get_ports { vsns5v0_p }]; #IO_L3P_T0_DQS_AD1P_15 Sch=ad_p[1]
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33     } [get_ports { isns5v0_n }]; #IO_L5N_T0_AD9N_15 Sch=ad_n[9]
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33     } [get_ports { isns5v0_p }]; #IO_L5P_T0_AD9P_15 Sch=ad_p[9]
#set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33     } [get_ports { isns0v95_n }]; #IO_L8N_T1_AD10N_15 Sch=ad_n[10]
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33     } [get_ports { isns0v95_p }]; #IO_L8P_T1_AD10P_15 Sch=ad_p[10]

create_clock -period 40.000 -name E_RX_CLK -waveform {0.000 20.000} [get_ports E_RX_CLK]
create_clock -period 40.000 -name E_TX_CLK -waveform {0.000 20.000} [get_ports E_TX_CLK]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list E_RX_CLK_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 512 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {el_rcv_data_phy[dnsPkt][0]} {el_rcv_data_phy[dnsPkt][1]} {el_rcv_data_phy[dnsPkt][2]} {el_rcv_data_phy[dnsPkt][3]} {el_rcv_data_phy[dnsPkt][4]} {el_rcv_data_phy[dnsPkt][5]} {el_rcv_data_phy[dnsPkt][6]} {el_rcv_data_phy[dnsPkt][7]} {el_rcv_data_phy[dnsPkt][8]} {el_rcv_data_phy[dnsPkt][9]} {el_rcv_data_phy[dnsPkt][10]} {el_rcv_data_phy[dnsPkt][11]} {el_rcv_data_phy[dnsPkt][12]} {el_rcv_data_phy[dnsPkt][13]} {el_rcv_data_phy[dnsPkt][14]} {el_rcv_data_phy[dnsPkt][15]} {el_rcv_data_phy[dnsPkt][16]} {el_rcv_data_phy[dnsPkt][17]} {el_rcv_data_phy[dnsPkt][18]} {el_rcv_data_phy[dnsPkt][19]} {el_rcv_data_phy[dnsPkt][20]} {el_rcv_data_phy[dnsPkt][21]} {el_rcv_data_phy[dnsPkt][22]} {el_rcv_data_phy[dnsPkt][23]} {el_rcv_data_phy[dnsPkt][24]} {el_rcv_data_phy[dnsPkt][25]} {el_rcv_data_phy[dnsPkt][26]} {el_rcv_data_phy[dnsPkt][27]} {el_rcv_data_phy[dnsPkt][28]} {el_rcv_data_phy[dnsPkt][29]} {el_rcv_data_phy[dnsPkt][30]} {el_rcv_data_phy[dnsPkt][31]} {el_rcv_data_phy[dnsPkt][32]} {el_rcv_data_phy[dnsPkt][33]} {el_rcv_data_phy[dnsPkt][34]} {el_rcv_data_phy[dnsPkt][35]} {el_rcv_data_phy[dnsPkt][36]} {el_rcv_data_phy[dnsPkt][37]} {el_rcv_data_phy[dnsPkt][38]} {el_rcv_data_phy[dnsPkt][39]} {el_rcv_data_phy[dnsPkt][40]} {el_rcv_data_phy[dnsPkt][41]} {el_rcv_data_phy[dnsPkt][42]} {el_rcv_data_phy[dnsPkt][43]} {el_rcv_data_phy[dnsPkt][44]} {el_rcv_data_phy[dnsPkt][45]} {el_rcv_data_phy[dnsPkt][46]} {el_rcv_data_phy[dnsPkt][47]} {el_rcv_data_phy[dnsPkt][48]} {el_rcv_data_phy[dnsPkt][49]} {el_rcv_data_phy[dnsPkt][50]} {el_rcv_data_phy[dnsPkt][51]} {el_rcv_data_phy[dnsPkt][52]} {el_rcv_data_phy[dnsPkt][53]} {el_rcv_data_phy[dnsPkt][54]} {el_rcv_data_phy[dnsPkt][55]} {el_rcv_data_phy[dnsPkt][56]} {el_rcv_data_phy[dnsPkt][57]} {el_rcv_data_phy[dnsPkt][58]} {el_rcv_data_phy[dnsPkt][59]} {el_rcv_data_phy[dnsPkt][60]} {el_rcv_data_phy[dnsPkt][61]} {el_rcv_data_phy[dnsPkt][62]} {el_rcv_data_phy[dnsPkt][63]} {el_rcv_data_phy[dnsPkt][64]} {el_rcv_data_phy[dnsPkt][65]} {el_rcv_data_phy[dnsPkt][66]} {el_rcv_data_phy[dnsPkt][67]} {el_rcv_data_phy[dnsPkt][68]} {el_rcv_data_phy[dnsPkt][69]} {el_rcv_data_phy[dnsPkt][70]} {el_rcv_data_phy[dnsPkt][71]} {el_rcv_data_phy[dnsPkt][72]} {el_rcv_data_phy[dnsPkt][73]} {el_rcv_data_phy[dnsPkt][74]} {el_rcv_data_phy[dnsPkt][75]} {el_rcv_data_phy[dnsPkt][76]} {el_rcv_data_phy[dnsPkt][77]} {el_rcv_data_phy[dnsPkt][78]} {el_rcv_data_phy[dnsPkt][79]} {el_rcv_data_phy[dnsPkt][80]} {el_rcv_data_phy[dnsPkt][81]} {el_rcv_data_phy[dnsPkt][82]} {el_rcv_data_phy[dnsPkt][83]} {el_rcv_data_phy[dnsPkt][84]} {el_rcv_data_phy[dnsPkt][85]} {el_rcv_data_phy[dnsPkt][86]} {el_rcv_data_phy[dnsPkt][87]} {el_rcv_data_phy[dnsPkt][88]} {el_rcv_data_phy[dnsPkt][89]} {el_rcv_data_phy[dnsPkt][90]} {el_rcv_data_phy[dnsPkt][91]} {el_rcv_data_phy[dnsPkt][92]} {el_rcv_data_phy[dnsPkt][93]} {el_rcv_data_phy[dnsPkt][94]} {el_rcv_data_phy[dnsPkt][95]} {el_rcv_data_phy[dnsPkt][96]} {el_rcv_data_phy[dnsPkt][97]} {el_rcv_data_phy[dnsPkt][98]} {el_rcv_data_phy[dnsPkt][99]} {el_rcv_data_phy[dnsPkt][100]} {el_rcv_data_phy[dnsPkt][101]} {el_rcv_data_phy[dnsPkt][102]} {el_rcv_data_phy[dnsPkt][103]} {el_rcv_data_phy[dnsPkt][104]} {el_rcv_data_phy[dnsPkt][105]} {el_rcv_data_phy[dnsPkt][106]} {el_rcv_data_phy[dnsPkt][107]} {el_rcv_data_phy[dnsPkt][108]} {el_rcv_data_phy[dnsPkt][109]} {el_rcv_data_phy[dnsPkt][110]} {el_rcv_data_phy[dnsPkt][111]} {el_rcv_data_phy[dnsPkt][112]} {el_rcv_data_phy[dnsPkt][113]} {el_rcv_data_phy[dnsPkt][114]} {el_rcv_data_phy[dnsPkt][115]} {el_rcv_data_phy[dnsPkt][116]} {el_rcv_data_phy[dnsPkt][117]} {el_rcv_data_phy[dnsPkt][118]} {el_rcv_data_phy[dnsPkt][119]} {el_rcv_data_phy[dnsPkt][120]} {el_rcv_data_phy[dnsPkt][121]} {el_rcv_data_phy[dnsPkt][122]} {el_rcv_data_phy[dnsPkt][123]} {el_rcv_data_phy[dnsPkt][124]} {el_rcv_data_phy[dnsPkt][125]} {el_rcv_data_phy[dnsPkt][126]} {el_rcv_data_phy[dnsPkt][127]} {el_rcv_data_phy[dnsPkt][128]} {el_rcv_data_phy[dnsPkt][129]} {el_rcv_data_phy[dnsPkt][130]} {el_rcv_data_phy[dnsPkt][131]} {el_rcv_data_phy[dnsPkt][132]} {el_rcv_data_phy[dnsPkt][133]} {el_rcv_data_phy[dnsPkt][134]} {el_rcv_data_phy[dnsPkt][135]} {el_rcv_data_phy[dnsPkt][136]} {el_rcv_data_phy[dnsPkt][137]} {el_rcv_data_phy[dnsPkt][138]} {el_rcv_data_phy[dnsPkt][139]} {el_rcv_data_phy[dnsPkt][140]} {el_rcv_data_phy[dnsPkt][141]} {el_rcv_data_phy[dnsPkt][142]} {el_rcv_data_phy[dnsPkt][143]} {el_rcv_data_phy[dnsPkt][144]} {el_rcv_data_phy[dnsPkt][145]} {el_rcv_data_phy[dnsPkt][146]} {el_rcv_data_phy[dnsPkt][147]} {el_rcv_data_phy[dnsPkt][148]} {el_rcv_data_phy[dnsPkt][149]} {el_rcv_data_phy[dnsPkt][150]} {el_rcv_data_phy[dnsPkt][151]} {el_rcv_data_phy[dnsPkt][152]} {el_rcv_data_phy[dnsPkt][153]} {el_rcv_data_phy[dnsPkt][154]} {el_rcv_data_phy[dnsPkt][155]} {el_rcv_data_phy[dnsPkt][156]} {el_rcv_data_phy[dnsPkt][157]} {el_rcv_data_phy[dnsPkt][158]} {el_rcv_data_phy[dnsPkt][159]} {el_rcv_data_phy[dnsPkt][160]} {el_rcv_data_phy[dnsPkt][161]} {el_rcv_data_phy[dnsPkt][162]} {el_rcv_data_phy[dnsPkt][163]} {el_rcv_data_phy[dnsPkt][164]} {el_rcv_data_phy[dnsPkt][165]} {el_rcv_data_phy[dnsPkt][166]} {el_rcv_data_phy[dnsPkt][167]} {el_rcv_data_phy[dnsPkt][168]} {el_rcv_data_phy[dnsPkt][169]} {el_rcv_data_phy[dnsPkt][170]} {el_rcv_data_phy[dnsPkt][171]} {el_rcv_data_phy[dnsPkt][172]} {el_rcv_data_phy[dnsPkt][173]} {el_rcv_data_phy[dnsPkt][174]} {el_rcv_data_phy[dnsPkt][175]} {el_rcv_data_phy[dnsPkt][176]} {el_rcv_data_phy[dnsPkt][177]} {el_rcv_data_phy[dnsPkt][178]} {el_rcv_data_phy[dnsPkt][179]} {el_rcv_data_phy[dnsPkt][180]} {el_rcv_data_phy[dnsPkt][181]} {el_rcv_data_phy[dnsPkt][182]} {el_rcv_data_phy[dnsPkt][183]} {el_rcv_data_phy[dnsPkt][184]} {el_rcv_data_phy[dnsPkt][185]} {el_rcv_data_phy[dnsPkt][186]} {el_rcv_data_phy[dnsPkt][187]} {el_rcv_data_phy[dnsPkt][188]} {el_rcv_data_phy[dnsPkt][189]} {el_rcv_data_phy[dnsPkt][190]} {el_rcv_data_phy[dnsPkt][191]} {el_rcv_data_phy[dnsPkt][192]} {el_rcv_data_phy[dnsPkt][193]} {el_rcv_data_phy[dnsPkt][194]} {el_rcv_data_phy[dnsPkt][195]} {el_rcv_data_phy[dnsPkt][196]} {el_rcv_data_phy[dnsPkt][197]} {el_rcv_data_phy[dnsPkt][198]} {el_rcv_data_phy[dnsPkt][199]} {el_rcv_data_phy[dnsPkt][200]} {el_rcv_data_phy[dnsPkt][201]} {el_rcv_data_phy[dnsPkt][202]} {el_rcv_data_phy[dnsPkt][203]} {el_rcv_data_phy[dnsPkt][204]} {el_rcv_data_phy[dnsPkt][205]} {el_rcv_data_phy[dnsPkt][206]} {el_rcv_data_phy[dnsPkt][207]} {el_rcv_data_phy[dnsPkt][208]} {el_rcv_data_phy[dnsPkt][209]} {el_rcv_data_phy[dnsPkt][210]} {el_rcv_data_phy[dnsPkt][211]} {el_rcv_data_phy[dnsPkt][212]} {el_rcv_data_phy[dnsPkt][213]} {el_rcv_data_phy[dnsPkt][214]} {el_rcv_data_phy[dnsPkt][215]} {el_rcv_data_phy[dnsPkt][216]} {el_rcv_data_phy[dnsPkt][217]} {el_rcv_data_phy[dnsPkt][218]} {el_rcv_data_phy[dnsPkt][219]} {el_rcv_data_phy[dnsPkt][220]} {el_rcv_data_phy[dnsPkt][221]} {el_rcv_data_phy[dnsPkt][222]} {el_rcv_data_phy[dnsPkt][223]} {el_rcv_data_phy[dnsPkt][224]} {el_rcv_data_phy[dnsPkt][225]} {el_rcv_data_phy[dnsPkt][226]} {el_rcv_data_phy[dnsPkt][227]} {el_rcv_data_phy[dnsPkt][228]} {el_rcv_data_phy[dnsPkt][229]} {el_rcv_data_phy[dnsPkt][230]} {el_rcv_data_phy[dnsPkt][231]} {el_rcv_data_phy[dnsPkt][232]} {el_rcv_data_phy[dnsPkt][233]} {el_rcv_data_phy[dnsPkt][234]} {el_rcv_data_phy[dnsPkt][235]} {el_rcv_data_phy[dnsPkt][236]} {el_rcv_data_phy[dnsPkt][237]} {el_rcv_data_phy[dnsPkt][238]} {el_rcv_data_phy[dnsPkt][239]} {el_rcv_data_phy[dnsPkt][240]} {el_rcv_data_phy[dnsPkt][241]} {el_rcv_data_phy[dnsPkt][242]} {el_rcv_data_phy[dnsPkt][243]} {el_rcv_data_phy[dnsPkt][244]} {el_rcv_data_phy[dnsPkt][245]} {el_rcv_data_phy[dnsPkt][246]} {el_rcv_data_phy[dnsPkt][247]} {el_rcv_data_phy[dnsPkt][248]} {el_rcv_data_phy[dnsPkt][249]} {el_rcv_data_phy[dnsPkt][250]} {el_rcv_data_phy[dnsPkt][251]} {el_rcv_data_phy[dnsPkt][252]} {el_rcv_data_phy[dnsPkt][253]} {el_rcv_data_phy[dnsPkt][254]} {el_rcv_data_phy[dnsPkt][255]} {el_rcv_data_phy[dnsPkt][256]} {el_rcv_data_phy[dnsPkt][257]} {el_rcv_data_phy[dnsPkt][258]} {el_rcv_data_phy[dnsPkt][259]} {el_rcv_data_phy[dnsPkt][260]} {el_rcv_data_phy[dnsPkt][261]} {el_rcv_data_phy[dnsPkt][262]} {el_rcv_data_phy[dnsPkt][263]} {el_rcv_data_phy[dnsPkt][264]} {el_rcv_data_phy[dnsPkt][265]} {el_rcv_data_phy[dnsPkt][266]} {el_rcv_data_phy[dnsPkt][267]} {el_rcv_data_phy[dnsPkt][268]} {el_rcv_data_phy[dnsPkt][269]} {el_rcv_data_phy[dnsPkt][270]} {el_rcv_data_phy[dnsPkt][271]} {el_rcv_data_phy[dnsPkt][272]} {el_rcv_data_phy[dnsPkt][273]} {el_rcv_data_phy[dnsPkt][274]} {el_rcv_data_phy[dnsPkt][275]} {el_rcv_data_phy[dnsPkt][276]} {el_rcv_data_phy[dnsPkt][277]} {el_rcv_data_phy[dnsPkt][278]} {el_rcv_data_phy[dnsPkt][279]} {el_rcv_data_phy[dnsPkt][280]} {el_rcv_data_phy[dnsPkt][281]} {el_rcv_data_phy[dnsPkt][282]} {el_rcv_data_phy[dnsPkt][283]} {el_rcv_data_phy[dnsPkt][284]} {el_rcv_data_phy[dnsPkt][285]} {el_rcv_data_phy[dnsPkt][286]} {el_rcv_data_phy[dnsPkt][287]} {el_rcv_data_phy[dnsPkt][288]} {el_rcv_data_phy[dnsPkt][289]} {el_rcv_data_phy[dnsPkt][290]} {el_rcv_data_phy[dnsPkt][291]} {el_rcv_data_phy[dnsPkt][292]} {el_rcv_data_phy[dnsPkt][293]} {el_rcv_data_phy[dnsPkt][294]} {el_rcv_data_phy[dnsPkt][295]} {el_rcv_data_phy[dnsPkt][296]} {el_rcv_data_phy[dnsPkt][297]} {el_rcv_data_phy[dnsPkt][298]} {el_rcv_data_phy[dnsPkt][299]} {el_rcv_data_phy[dnsPkt][300]} {el_rcv_data_phy[dnsPkt][301]} {el_rcv_data_phy[dnsPkt][302]} {el_rcv_data_phy[dnsPkt][303]} {el_rcv_data_phy[dnsPkt][304]} {el_rcv_data_phy[dnsPkt][305]} {el_rcv_data_phy[dnsPkt][306]} {el_rcv_data_phy[dnsPkt][307]} {el_rcv_data_phy[dnsPkt][308]} {el_rcv_data_phy[dnsPkt][309]} {el_rcv_data_phy[dnsPkt][310]} {el_rcv_data_phy[dnsPkt][311]} {el_rcv_data_phy[dnsPkt][312]} {el_rcv_data_phy[dnsPkt][313]} {el_rcv_data_phy[dnsPkt][314]} {el_rcv_data_phy[dnsPkt][315]} {el_rcv_data_phy[dnsPkt][316]} {el_rcv_data_phy[dnsPkt][317]} {el_rcv_data_phy[dnsPkt][318]} {el_rcv_data_phy[dnsPkt][319]} {el_rcv_data_phy[dnsPkt][320]} {el_rcv_data_phy[dnsPkt][321]} {el_rcv_data_phy[dnsPkt][322]} {el_rcv_data_phy[dnsPkt][323]} {el_rcv_data_phy[dnsPkt][324]} {el_rcv_data_phy[dnsPkt][325]} {el_rcv_data_phy[dnsPkt][326]} {el_rcv_data_phy[dnsPkt][327]} {el_rcv_data_phy[dnsPkt][328]} {el_rcv_data_phy[dnsPkt][329]} {el_rcv_data_phy[dnsPkt][330]} {el_rcv_data_phy[dnsPkt][331]} {el_rcv_data_phy[dnsPkt][332]} {el_rcv_data_phy[dnsPkt][333]} {el_rcv_data_phy[dnsPkt][334]} {el_rcv_data_phy[dnsPkt][335]} {el_rcv_data_phy[dnsPkt][336]} {el_rcv_data_phy[dnsPkt][337]} {el_rcv_data_phy[dnsPkt][338]} {el_rcv_data_phy[dnsPkt][339]} {el_rcv_data_phy[dnsPkt][340]} {el_rcv_data_phy[dnsPkt][341]} {el_rcv_data_phy[dnsPkt][342]} {el_rcv_data_phy[dnsPkt][343]} {el_rcv_data_phy[dnsPkt][344]} {el_rcv_data_phy[dnsPkt][345]} {el_rcv_data_phy[dnsPkt][346]} {el_rcv_data_phy[dnsPkt][347]} {el_rcv_data_phy[dnsPkt][348]} {el_rcv_data_phy[dnsPkt][349]} {el_rcv_data_phy[dnsPkt][350]} {el_rcv_data_phy[dnsPkt][351]} {el_rcv_data_phy[dnsPkt][352]} {el_rcv_data_phy[dnsPkt][353]} {el_rcv_data_phy[dnsPkt][354]} {el_rcv_data_phy[dnsPkt][355]} {el_rcv_data_phy[dnsPkt][356]} {el_rcv_data_phy[dnsPkt][357]} {el_rcv_data_phy[dnsPkt][358]} {el_rcv_data_phy[dnsPkt][359]} {el_rcv_data_phy[dnsPkt][360]} {el_rcv_data_phy[dnsPkt][361]} {el_rcv_data_phy[dnsPkt][362]} {el_rcv_data_phy[dnsPkt][363]} {el_rcv_data_phy[dnsPkt][364]} {el_rcv_data_phy[dnsPkt][365]} {el_rcv_data_phy[dnsPkt][366]} {el_rcv_data_phy[dnsPkt][367]} {el_rcv_data_phy[dnsPkt][368]} {el_rcv_data_phy[dnsPkt][369]} {el_rcv_data_phy[dnsPkt][370]} {el_rcv_data_phy[dnsPkt][371]} {el_rcv_data_phy[dnsPkt][372]} {el_rcv_data_phy[dnsPkt][373]} {el_rcv_data_phy[dnsPkt][374]} {el_rcv_data_phy[dnsPkt][375]} {el_rcv_data_phy[dnsPkt][376]} {el_rcv_data_phy[dnsPkt][377]} {el_rcv_data_phy[dnsPkt][378]} {el_rcv_data_phy[dnsPkt][379]} {el_rcv_data_phy[dnsPkt][380]} {el_rcv_data_phy[dnsPkt][381]} {el_rcv_data_phy[dnsPkt][382]} {el_rcv_data_phy[dnsPkt][383]} {el_rcv_data_phy[dnsPkt][384]} {el_rcv_data_phy[dnsPkt][385]} {el_rcv_data_phy[dnsPkt][386]} {el_rcv_data_phy[dnsPkt][387]} {el_rcv_data_phy[dnsPkt][388]} {el_rcv_data_phy[dnsPkt][389]} {el_rcv_data_phy[dnsPkt][390]} {el_rcv_data_phy[dnsPkt][391]} {el_rcv_data_phy[dnsPkt][392]} {el_rcv_data_phy[dnsPkt][393]} {el_rcv_data_phy[dnsPkt][394]} {el_rcv_data_phy[dnsPkt][395]} {el_rcv_data_phy[dnsPkt][396]} {el_rcv_data_phy[dnsPkt][397]} {el_rcv_data_phy[dnsPkt][398]} {el_rcv_data_phy[dnsPkt][399]} {el_rcv_data_phy[dnsPkt][400]} {el_rcv_data_phy[dnsPkt][401]} {el_rcv_data_phy[dnsPkt][402]} {el_rcv_data_phy[dnsPkt][403]} {el_rcv_data_phy[dnsPkt][404]} {el_rcv_data_phy[dnsPkt][405]} {el_rcv_data_phy[dnsPkt][406]} {el_rcv_data_phy[dnsPkt][407]} {el_rcv_data_phy[dnsPkt][408]} {el_rcv_data_phy[dnsPkt][409]} {el_rcv_data_phy[dnsPkt][410]} {el_rcv_data_phy[dnsPkt][411]} {el_rcv_data_phy[dnsPkt][412]} {el_rcv_data_phy[dnsPkt][413]} {el_rcv_data_phy[dnsPkt][414]} {el_rcv_data_phy[dnsPkt][415]} {el_rcv_data_phy[dnsPkt][416]} {el_rcv_data_phy[dnsPkt][417]} {el_rcv_data_phy[dnsPkt][418]} {el_rcv_data_phy[dnsPkt][419]} {el_rcv_data_phy[dnsPkt][420]} {el_rcv_data_phy[dnsPkt][421]} {el_rcv_data_phy[dnsPkt][422]} {el_rcv_data_phy[dnsPkt][423]} {el_rcv_data_phy[dnsPkt][424]} {el_rcv_data_phy[dnsPkt][425]} {el_rcv_data_phy[dnsPkt][426]} {el_rcv_data_phy[dnsPkt][427]} {el_rcv_data_phy[dnsPkt][428]} {el_rcv_data_phy[dnsPkt][429]} {el_rcv_data_phy[dnsPkt][430]} {el_rcv_data_phy[dnsPkt][431]} {el_rcv_data_phy[dnsPkt][432]} {el_rcv_data_phy[dnsPkt][433]} {el_rcv_data_phy[dnsPkt][434]} {el_rcv_data_phy[dnsPkt][435]} {el_rcv_data_phy[dnsPkt][436]} {el_rcv_data_phy[dnsPkt][437]} {el_rcv_data_phy[dnsPkt][438]} {el_rcv_data_phy[dnsPkt][439]} {el_rcv_data_phy[dnsPkt][440]} {el_rcv_data_phy[dnsPkt][441]} {el_rcv_data_phy[dnsPkt][442]} {el_rcv_data_phy[dnsPkt][443]} {el_rcv_data_phy[dnsPkt][444]} {el_rcv_data_phy[dnsPkt][445]} {el_rcv_data_phy[dnsPkt][446]} {el_rcv_data_phy[dnsPkt][447]} {el_rcv_data_phy[dnsPkt][448]} {el_rcv_data_phy[dnsPkt][449]} {el_rcv_data_phy[dnsPkt][450]} {el_rcv_data_phy[dnsPkt][451]} {el_rcv_data_phy[dnsPkt][452]} {el_rcv_data_phy[dnsPkt][453]} {el_rcv_data_phy[dnsPkt][454]} {el_rcv_data_phy[dnsPkt][455]} {el_rcv_data_phy[dnsPkt][456]} {el_rcv_data_phy[dnsPkt][457]} {el_rcv_data_phy[dnsPkt][458]} {el_rcv_data_phy[dnsPkt][459]} {el_rcv_data_phy[dnsPkt][460]} {el_rcv_data_phy[dnsPkt][461]} {el_rcv_data_phy[dnsPkt][462]} {el_rcv_data_phy[dnsPkt][463]} {el_rcv_data_phy[dnsPkt][464]} {el_rcv_data_phy[dnsPkt][465]} {el_rcv_data_phy[dnsPkt][466]} {el_rcv_data_phy[dnsPkt][467]} {el_rcv_data_phy[dnsPkt][468]} {el_rcv_data_phy[dnsPkt][469]} {el_rcv_data_phy[dnsPkt][470]} {el_rcv_data_phy[dnsPkt][471]} {el_rcv_data_phy[dnsPkt][472]} {el_rcv_data_phy[dnsPkt][473]} {el_rcv_data_phy[dnsPkt][474]} {el_rcv_data_phy[dnsPkt][475]} {el_rcv_data_phy[dnsPkt][476]} {el_rcv_data_phy[dnsPkt][477]} {el_rcv_data_phy[dnsPkt][478]} {el_rcv_data_phy[dnsPkt][479]} {el_rcv_data_phy[dnsPkt][480]} {el_rcv_data_phy[dnsPkt][481]} {el_rcv_data_phy[dnsPkt][482]} {el_rcv_data_phy[dnsPkt][483]} {el_rcv_data_phy[dnsPkt][484]} {el_rcv_data_phy[dnsPkt][485]} {el_rcv_data_phy[dnsPkt][486]} {el_rcv_data_phy[dnsPkt][487]} {el_rcv_data_phy[dnsPkt][488]} {el_rcv_data_phy[dnsPkt][489]} {el_rcv_data_phy[dnsPkt][490]} {el_rcv_data_phy[dnsPkt][491]} {el_rcv_data_phy[dnsPkt][492]} {el_rcv_data_phy[dnsPkt][493]} {el_rcv_data_phy[dnsPkt][494]} {el_rcv_data_phy[dnsPkt][495]} {el_rcv_data_phy[dnsPkt][496]} {el_rcv_data_phy[dnsPkt][497]} {el_rcv_data_phy[dnsPkt][498]} {el_rcv_data_phy[dnsPkt][499]} {el_rcv_data_phy[dnsPkt][500]} {el_rcv_data_phy[dnsPkt][501]} {el_rcv_data_phy[dnsPkt][502]} {el_rcv_data_phy[dnsPkt][503]} {el_rcv_data_phy[dnsPkt][504]} {el_rcv_data_phy[dnsPkt][505]} {el_rcv_data_phy[dnsPkt][506]} {el_rcv_data_phy[dnsPkt][507]} {el_rcv_data_phy[dnsPkt][508]} {el_rcv_data_phy[dnsPkt][509]} {el_rcv_data_phy[dnsPkt][510]} {el_rcv_data_phy[dnsPkt][511]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets E_RX_CLK_IBUF_BUFG]
