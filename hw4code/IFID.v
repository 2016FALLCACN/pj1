module IFID
(
	clk_i,
	Stall_i,
	PC_i,
	instruction_i,
	Flush_i,
	PC_o,
	instruction_o
);

input clk_i, Stall_i, Flush_i;
input [31:0] PC_i, instruction_i;
output [31:0] PC_o, instruction_o;
reg instruction_o, PC_o;

always @ (posedge clk_i) begin
	if (Stall_i) begin
		instruction_o <= instruction_o;
		PC_o <= PC_o;
	end
	else if (Flush_i)
		;
	else begin
		instruction_o <= instruction_i;
		PC_o <= PC_i;
	end
end

endmodule
