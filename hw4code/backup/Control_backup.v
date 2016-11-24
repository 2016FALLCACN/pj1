module Control // for only R-type & addi
(
    Op_i,
    RegDst_o,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o
);

// Ports
input	[0:5]		Op_i; // from wire_inst[31:26]
output				RegDst_o;
output	[1:0]		ALUOp_o;
output				ALUSrc_o;
output				RegWrite_o;

// Wires & Registers
reg					RegDst_o;
reg		[1:0]		ALUOp_o;
reg					ALUSrc_o;
reg					RegWrite_o;


always@(*) begin
    if(Op_i[2]) begin // op2 = 1 -> addi
        RegDst_o = 0;
		ALUOp_o = 2'b00;
		ALUSrc_o = 1;
		RegWrite_o = 1;
    end
    else begin // op2 = 0 -> R-type
        RegDst_o = 1;
		ALUOp_o = 2'b10;
		ALUSrc_o = 0;
		RegWrite_o = 1;
    end
end

endmodule
