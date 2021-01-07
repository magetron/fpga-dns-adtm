////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: main_synthesis.v
// /___/   /\     Timestamp: Thu Oct 29 22:24:50 2020
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -insert_glbl true -w -dir netgen/synthesis -ofmt verilog -sim main.ngc main_synthesis.v 
// Device	: xc3s500e-4-fg320
// Input file	: main.ngc
// Output file	: /mnt/hgfs/patrick/Dropbox/University-College-London/UCL-CS/Year-3/Research-Project/cpu-fpga-nwofle/hw/eth-test/netgen/synthesis/main_synthesis.v
// # of Modules	: 1
// Design Name	: main
// Xilinx        : /opt/Xilinx/14.7/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module main (
  E_RX_CLK, LED0, LED1, LED2, LED3, LED4, LED5, LED6, E_RXD0, E_RXD1, E_RXD2, E_RXD3, E_RX_DV, E_RXD4
);
  input E_RX_CLK;
  output LED0;
  output LED1;
  output LED2;
  output LED3;
  output LED4;
  output LED5;
  output LED6;
  input E_RXD0;
  input E_RXD1;
  input E_RXD2;
  input E_RXD3;
  input E_RX_DV;
  input E_RXD4;
  wire E_RXD0_IBUF_1;
  wire E_RXD1_IBUF_3;
  wire E_RXD2_IBUF_5;
  wire E_RXD3_IBUF_7;
  wire E_RXD4_IBUF_9;
  wire LED0_OBUF_13;
  wire LED1_OBUF_15;
  wire LED1_OBUF1;
  wire LED2_OBUF_18;
  wire LED3_OBUF_20;
  wire LED4_OBUF_22;
  wire LED5_OBUF_24;
  wire LED6_OBUF_26;
  wire N1;
  wire r0_28;
  wire r1_29;
  wire r2_30;
  wire r3_31;
  wire r4_32;
  VCC   XST_VCC (
    .P(N1)
  );
  FDE #(
    .INIT ( 1'b0 ))
  r2 (
    .C(LED1_OBUF_15),
    .CE(E_RXD2_IBUF_5),
    .D(N1),
    .Q(r2_30)
  );
  FDE #(
    .INIT ( 1'b0 ))
  r0 (
    .C(LED1_OBUF_15),
    .CE(E_RXD0_IBUF_1),
    .D(N1),
    .Q(r0_28)
  );
  FDE #(
    .INIT ( 1'b0 ))
  r1 (
    .C(LED1_OBUF_15),
    .CE(E_RXD1_IBUF_3),
    .D(N1),
    .Q(r1_29)
  );
  FDE #(
    .INIT ( 1'b0 ))
  r3 (
    .C(LED1_OBUF_15),
    .CE(E_RXD3_IBUF_7),
    .D(N1),
    .Q(r3_31)
  );
  FDE #(
    .INIT ( 1'b0 ))
  r4 (
    .C(LED1_OBUF_15),
    .CE(E_RXD4_IBUF_9),
    .D(N1),
    .Q(r4_32)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  LED61 (
    .I0(r4_32),
    .I1(E_RXD4_IBUF_9),
    .O(LED6_OBUF_26)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  LED51 (
    .I0(r3_31),
    .I1(E_RXD3_IBUF_7),
    .O(LED5_OBUF_24)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  LED41 (
    .I0(r2_30),
    .I1(E_RXD2_IBUF_5),
    .O(LED4_OBUF_22)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  LED31 (
    .I0(r1_29),
    .I1(E_RXD1_IBUF_3),
    .O(LED3_OBUF_20)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  LED21 (
    .I0(r0_28),
    .I1(E_RXD0_IBUF_1),
    .O(LED2_OBUF_18)
  );
  IBUF   E_RX_CLK_IBUF (
    .I(E_RX_CLK),
    .O(LED1_OBUF1)
  );
  IBUF   E_RXD0_IBUF (
    .I(E_RXD0),
    .O(E_RXD0_IBUF_1)
  );
  IBUF   E_RXD1_IBUF (
    .I(E_RXD1),
    .O(E_RXD1_IBUF_3)
  );
  IBUF   E_RXD2_IBUF (
    .I(E_RXD2),
    .O(E_RXD2_IBUF_5)
  );
  IBUF   E_RXD3_IBUF (
    .I(E_RXD3),
    .O(E_RXD3_IBUF_7)
  );
  IBUF   E_RX_DV_IBUF (
    .I(E_RX_DV),
    .O(LED0_OBUF_13)
  );
  IBUF   E_RXD4_IBUF (
    .I(E_RXD4),
    .O(E_RXD4_IBUF_9)
  );
  OBUF   LED0_OBUF (
    .I(LED0_OBUF_13),
    .O(LED0)
  );
  OBUF   LED1_OBUF (
    .I(LED1_OBUF1),
    .O(LED1)
  );
  OBUF   LED2_OBUF (
    .I(LED2_OBUF_18),
    .O(LED2)
  );
  OBUF   LED3_OBUF (
    .I(LED3_OBUF_20),
    .O(LED3)
  );
  OBUF   LED4_OBUF (
    .I(LED4_OBUF_22),
    .O(LED4)
  );
  OBUF   LED5_OBUF (
    .I(LED5_OBUF_24),
    .O(LED5)
  );
  OBUF   LED6_OBUF (
    .I(LED6_OBUF_26),
    .O(LED6)
  );
  BUFG   LED1_OBUF_BUFG (
    .I(LED1_OBUF1),
    .O(LED1_OBUF_15)
  );
endmodule


`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

