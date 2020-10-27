//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:32:50 10/26/2020 
// Design Name: 
// Module Name:    charmem 
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
module charmem(
    input  [4:0] addr,
    output [7:0] bus
    );
	 
	parameter LINES = 2;
	parameter CHARS_PER_LINE = 16;
	parameter BITS_PER_CHAR = 8;
	parameter STR_SIZE = LINES * CHARS_PER_LINE * BITS_PER_CHAR;
	
	parameter [0:STR_SIZE-1] str = " Hello, world!   Spartan-3E LCD ";

	assign bus = str[{addr[4:0], 3'b000}+:8];
endmodule
