// One-bit OR Gate

module OR(
	data1_i,
	data2_i,
	or_o
);

input data1_i, data2_i;
output or_o;

assign or_o = data1_i | data2_i;

endmodule
