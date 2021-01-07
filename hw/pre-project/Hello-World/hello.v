// Verilog Test Fixture Template

  `timescale 1 ns / 1 ps

  module hello_world;
	
	reg  [15:0] a;
	reg  [15:0] b;
	wire [15:0] s;
	
	Sum sumTest ( .a ( a ), .b ( b ), .s ( s ) );
	
   initial begin
	  $display ("Hello World!");
	  a = 89;
	  b = 64;
	  $monitor ("The sum of %d and %d = %d", a, b, s);
	  #80 $finish;
   end

  endmodule
