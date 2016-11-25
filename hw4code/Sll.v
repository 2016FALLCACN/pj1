module Sll(
	data_i,
	lshift,
	data_o
);

input [31:0] data_i; 
input [4:0] lshift;
output [31:0] data_o;

assign data_o = data_i << lshift;

endmodule
