`define	ADD 6'b100000
`define	SUB 6'b100010
`define	AND 6'b100100
`define	OR  6'b100101
`define	MUL	6'b011000

module ALU_Control // for only R-type & addi
(
   funct_i,
   ALUOp_i,
   ALUCtrl_o
);

// Ports
input	[5:0]		funct_i;
input	[1:0]		ALUOp_i;
output	[2:0]		ALUCtrl_o;

// Wires & Registers
reg		[2:0]		ALUCtrl_o;


always@(*) begin
    if(ALUOp_i[1]) begin // ALUOp_i = 2'b10 -> R-type
        case(funct_i)
			`ADD:       ALUCtrl_o = 3'b000;
			`SUB:       ALUCtrl_o = 3'b001;
			`AND:       ALUCtrl_o = 3'b010;
			`OR:        ALUCtrl_o = 3'b011;
			`MUL:		ALUCtrl_o = 3'b100;
			default:    ALUCtrl_o = 3'b111;
		endcase
    end
    else begin // ALUOp_i = 2'b00 -> addi
		ALUCtrl_o = 3'b000;
    end
end

endmodule
