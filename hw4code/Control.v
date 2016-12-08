module Control // for only R-type & addi
(
    Op_i,
    RegDst_o,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemWrite_o,
    MemRead_o,
    MemtoReg_o,
    Branch_o,
    Jump_o
);

// Ports
input	[5:0]			Op_i; // from wire_inst[31:26]
output				RegDst_o;
output	[1:0]			ALUOp_o;
output				ALUSrc_o;
output				RegWrite_o;
output				MemWrite_o;
output				MemRead_o;
output				MemtoReg_o;
output				Branch_o;
output				Jump_o;

// Wires & Registers
reg				RegDst_o;
reg		[1:0]		ALUOp_o;
reg				ALUSrc_o;
reg				RegWrite_o;
reg				MemWrite_o;
reg				MemRead_o;
reg				MemtoReg_o;
reg				Branch_o;
reg				Jump_o;


always@(*) begin
    if(Op_i == 6'b001000) begin // addi
        RegDst_o = 0;
	ALUOp_o = 2'b00;
	ALUSrc_o = 1;
	RegWrite_o = 1;
	MemWrite_o = 0;
	MemRead_o = 0;
	MemtoReg_o = 0; 
   	Branch_o = 0;
   	Jump_o = 0;
    end
    else if (Op_i == 6'b000000) begin // R-type
        RegDst_o = 1;
	ALUOp_o = 2'b10;
	ALUSrc_o = 0;
	RegWrite_o = 1;
	MemWrite_o = 0;
	MemRead_o = 0;
	MemtoReg_o = 0;
   	Branch_o = 0;
   	Jump_o = 0;
    end
    else if (Op_i == 6'b100011) begin // lw instruction
        RegDst_o = 0;
	ALUOp_o = 2'b00;
	ALUSrc_o = 1;
	RegWrite_o = 1;
	MemWrite_o = 0;
	MemRead_o = 1;
	MemtoReg_o = 1;
   	Branch_o = 0;
   	Jump_o = 0;
    end
    else if (Op_i == 6'b101011) begin // sw instruction
        RegDst_o = 0;
	ALUOp_o = 2'b00;
	ALUSrc_o = 1;
	RegWrite_o = 0;
	MemWrite_o = 1;
	MemRead_o = 0;
	MemtoReg_o = 1;
   	Branch_o = 0;
   	Jump_o = 0;
    end
    else if (Op_i == 6'b000100) begin // beq instruction
        RegDst_o = 0; // don't care
	ALUOp_o = 2'b00; // don't care
	ALUSrc_o = 1; // don't care
	RegWrite_o = 0;
	MemWrite_o = 0;
	MemRead_o = 0;
	MemtoReg_o = 1; // don't care
   	Branch_o = 1;
   	Jump_o = 0;
    end
    else if (Op_i == 6'b000010) begin // j instruction
        RegDst_o = 0; // don't care
	ALUOp_o = 2'b00; // don't care
	ALUSrc_o = 1; // don't care
	RegWrite_o = 0;
	MemWrite_o = 0;
	MemRead_o = 0;
	MemtoReg_o = 1; // don't care
   	Branch_o = 0;
   	Jump_o = 1;
    end
    else begin // just do something
        RegDst_o = 0;
	ALUOp_o = 2'b00;
	ALUSrc_o = 0;
	RegWrite_o = 0;
	MemWrite_o = 0;
	MemRead_o = 0;
	MemtoReg_o = 0;
   	Branch_o = 0;
   	Jump_o = 0;
    end

    $display("[Control]Op_i = %b, MemtoReg_o = %b\n", Op_i, MemtoReg_o);
end

endmodule
