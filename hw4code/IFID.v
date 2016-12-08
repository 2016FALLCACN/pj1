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

always @ (posedge clk_i ) begin
	//$display("[IFID]instruction = %b, %d, %d, PC + 4 = %d\n", instruction_i[31:26], instruction_i[25:21], instruction_i[20:16], PC_i);
	if (Stall_i) begin
		instruction_o <= instruction_o;
		PC_o <= PC_o;
	end
	else if (Flush_i) begin
		$display("[IFID]Instruction Flushed, instruction = %b, PC + 4 = %d\n", instruction_i[31:26], PC_i);
		//instruction_o <= instruction_i;
		//PC_o <= PC_i;
		instruction_o <= 32'b0;
		PC_o <= 32'b0;
	end
	else begin
		instruction_o <= instruction_i;
		PC_o <= PC_i;
	end
end

endmodule
