`define	ADD 3'b000
`define	SUB 3'b001
`define	AND 3'b010
`define	OR  3'b011
`define	MUL	3'b100

module ALU // for only R-type & addi
(
   data1_i,
   data2_i,
   ALUCtrl_i,
   data_o,
   Zero_o
);

// Ports
input	[31:0]		data1_i;
input	[31:0]		data2_i;
input	[2:0]		ALUCtrl_i;
output 	[31:0]		data_o;
output				Zero_o;

// Wires & Registers
reg		[31:0]		data_o;
reg					Zero_o;


always @(*) begin
	Zero_o = 0;
	case(ALUCtrl_i)
		`ADD:       data_o <= data1_i + data2_i;
		`SUB:       data_o <= data1_i - data2_i;
		`AND:       data_o <= data1_i & data2_i;
		`OR:        data_o <= data1_i | data2_i;
		`MUL:		data_o <= data1_i * data2_i;
		default:    data_o <= 0;
	endcase
end

endmodule
