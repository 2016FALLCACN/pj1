`timescale 10ns/100ps

module Data_Memory_tb();

reg [31:0] addr_i, data_i;
reg MemRead_i, MemWrite_i;
wire [31:0] data_o;

Data_Memory data_0(
		.addr_i(addr_i),
		.data_i(data_i),
		.MemWrite_i(MemWrite_i),
		.MemRead_i(MemRead_i),
		.data_o(data_o));

initial begin
	$dumpfile("data_memory.vcd");
	$dumpvars;
end

initial begin
	addr_i = 32'd0; 
	data_i = 32'd1024; 
	MemWrite_i = 1;
	MemRead_i = 0;
	# 100 addr_i = 32'd0; 
	MemWrite_i = 0;
	MemRead_i = 1;
	# 100 ;
	$finish;
end

endmodule
