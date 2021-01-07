//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:34:05 10/26/2020 
// Design Name: 
// Module Name:    topmodule 
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
module topmodule(
	input clk, 
	output lcd_rs,
	output lcd_rw,
	output lcd_e, 
	output [11:8] sf_d
	);

	wire [7:0] charmem_bus;
	wire [4:0] charmem_addr;
	
	charmem charmem (charmem_addr, charmem_bus);
	lcd lcd (clk, lcd_rs, lcd_rw, lcd_e, sf_d, charmem_addr, charmem_bus);

endmodule