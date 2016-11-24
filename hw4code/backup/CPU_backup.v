module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire	[31:0] 		wire_pc;
wire	[31:0]		wire_pc_ret;
wire	[31:0]		wire_inst;
wire				wire_reg_dst; // from Control
wire				wire_reg_wr; // from Control
wire				wire_alu_src; // from Control
wire	[1:0]		wire_alu_op; // from Control
wire	[2:0]		wire_alu_ctrl; // from ALU_Control
wire	[4:0]		wire_wr_reg; // from MUX5
wire	[31:0]		wire_data1; // from Registers
wire	[31:0]		wire_data2; // from Registers
wire	[31:0]		wire_sign_ext; // from Sign_Extend
wire	[31:0]		wire_mux32; // from MUX32
wire	[31:0]		wire_alu_out;

Control Control(
    .Op_i       (wire_inst[31:26]),
    .RegDst_o   (wire_reg_dst),
    .ALUOp_o    (wire_alu_op),
    .ALUSrc_o   (wire_alu_src),
    .RegWrite_o (wire_reg_wr)
);

Adder Add_PC(
    .data1_i   (wire_pc),
    .data2_i   (4),
    .data_o     (wire_pc_ret)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (wire_pc_ret),
    .pc_o       (wire_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (wire_pc), 
    .instr_o    (wire_inst)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (wire_inst[25:21]),
    .RTaddr_i   (wire_inst[20:16]),
    .RDaddr_i   (wire_wr_reg), 
    .RDdata_i   (wire_alu_out), // from ALU
    .RegWrite_i (wire_reg_wr), // from Control_RegWrite
    .RSdata_o   (wire_data1), 
    .RTdata_o   (wire_data2) 
);

MUX5 MUX_RegDst(
    .data1_i    (wire_inst[20:16]), // rt
    .data2_i    (wire_inst[15:11]), // rd
    .select_i   (wire_reg_dst), // from Control_RegDst
    .data_o     (wire_wr_reg)
);

MUX32 MUX_ALUSrc(
    .data1_i    (wire_data2), // from Registers
    .data2_i    (wire_sign_ext), // from Sign_Extend
    .select_i   (wire_alu_src), // from Control_ALUSrc
    .data_o     (wire_mux32)
);

Sign_Extend Sign_Extend(
    .data_i     (wire_inst[15:0]),
    .data_o     (wire_sign_ext)
);

ALU ALU(
    .data1_i    (wire_data1),
    .data2_i    (wire_mux32),
    .ALUCtrl_i  (wire_alu_ctrl),
    .data_o     (wire_alu_out),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (wire_inst[5:0]),
    .ALUOp_i    (wire_alu_op),
    .ALUCtrl_o  (wire_alu_ctrl)
);

endmodule

