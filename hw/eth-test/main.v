`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:27:04 10/29/2020 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module main(
	input E_RX_CLK,
	input E_RX_DV,
	input E_RXD0,
	input E_RXD1,
	input E_RXD2,
	input E_RXD3,
	input E_RXD4, // RX_ERR
	output LED0,
	output LED1,
	output LED2,
	output LED3,
	output LED4,
	output LED5,
	output LED6
   );
	
	reg r0 = 0;
	reg r1 = 0;
	reg r2 = 0;
	reg r3 = 0;
	reg r4 = 0;
	
	assign LED0 = E_RX_DV;
	assign LED1 = E_RX_CLK;
	assign LED2 = r0 | E_RXD0;
	assign LED3 = r1 | E_RXD1;
	assign LED4 = r2 | E_RXD2;
	assign LED5 = r3 | E_RXD3;
	assign LED6 = r4 | E_RXD4;
	
	always @ (posedge E_RX_CLK) begin
		if (E_RXD0) begin
			r0 <= E_RXD0;
		end
		if (E_RXD1) begin
			r1 <= E_RXD1;
		end
		if (E_RXD2) begin
			r2 <= E_RXD2;
		end
		if (E_RXD3) begin
			r3 <= E_RXD3;
		end
		if (E_RXD4) begin
			r4 <= E_RXD4;
		end
	end
	
endmodule
