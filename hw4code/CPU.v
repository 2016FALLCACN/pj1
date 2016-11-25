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
wire				wire_ctrl_mtr; // from Control to mux32 WBSrc
wire				wire_ctrl_mw; // from Control to Data_Memory
wire				wire_ctrl_mr; // from Control to Data_Memory
wire				wire_ctrl_br; // from Control to AND_Branch
wire				wire_zero; // from EQ to AND_Branch
wire				wire_isbr; // from AND_Branch to MUX_Branch
wire	[1:0]		wire_alu_op; // from Control
wire	[2:0]		wire_alu_ctrl; // from ALU_Control
wire	[4:0]		wire_wr_reg; // from MUX5
wire	[31:0]		wire_data1; // from Registers
wire	[31:0]		wire_data2; // from Registers
wire	[31:0]		wire_sign_ext; // from Sign_Extend
wire	[31:0]		wire_mux32_alusrc; // from MUX32 alusrc
wire	[31:0]		wire_mux32_wbsrc; // from MUX32 wbsrc
wire    [31:0]		wire_mux32_br; // from MUX_Branch
wire	[31:0]		wire_alu_out; // from ALU
wire    [31:0]		wire_mem_out; // from Data_Memory
wire    [31:0]		wire_sll_br; // from branch_sll
wire    [31:0]		wire_add_br; // from Add_Branch


Control Control(
    .Op_i       (wire_inst[31:26]),
    .RegDst_o   (wire_reg_dst),
    .ALUOp_o    (wire_alu_op),
    .ALUSrc_o   (wire_alu_src),
    .RegWrite_o (wire_reg_wr),
    .MemWrite_o (wire_ctrl_mw),
    .MemRead_o  (wire_ctrl_mr),
    .MemtoReg_o (wire_ctrl_mtr),
    .Branch_o   (wire_ctrl_br)
);

AND AND_Branch(
	.data1_i(wire_ctrl_br),
	.data2_i(wire_zero),
	.and_o(wire_isbr)
); 

Adder Add_PC(
    .data1_i   (wire_pc),
    .data2_i   (4),
    .data_o     (wire_pc_ret)
);

Adder Add_Branch(
    .data1_i   (wire_sll_br),
    .data2_i   (wire_pc_ret),
    .data_o     (wire_add_br)
);

MUX32 MUX_Branch(
    .data1_i    (wire_pc_ret), // from Add_branch
    .data2_i    (wire_add_br), // from PC
    .select_i   (wire_isbr), // from AND_Branch
    .data_o     (wire_mux32_br)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (wire_mux32_br),
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
    .RDdata_i   (wire_mux32_wbsrc), // from mux32 wbsrc
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

EQ EQ(
	.data1_i(wire_data1), // from Registers.RSdata_o
	.data2_i(wire_data2), // from Registers.RTdata_o
	.eq_o(wire_zero)
);

MUX32 MUX_ALUSrc(
    .data1_i    (wire_data2), // from Registers
    .data2_i    (wire_sign_ext), // from Sign_Extend
    .select_i   (wire_alu_src), // from Control_ALUSrc
    .data_o     (wire_mux32_alusrc)
);

MUX32 MUX_WBSrc(
    .data1_i    (wire_alu_out), // from ALU
    .data2_i    (wire_mem_out), // from Data_Memory
    .select_i   (wire_ctrl_mtr), // from Control
    .data_o     (wire_mux32_wbsrc)
);

Sign_Extend Sign_Extend(
    .data_i     (wire_inst[15:0]),
    .data_o     (wire_sign_ext)
);

Sll Sll_Branch(
	.data_i(wire_sign_ext),
	.lshift(5'd2),
	.data_o(wire_sll_br)
);

ALU ALU(
    .data1_i    (wire_data1),
    .data2_i    (wire_mux32_alusrc),
    .ALUCtrl_i  (wire_alu_ctrl),
    .data_o     (wire_alu_out),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (wire_inst[5:0]),
    .ALUOp_i    (wire_alu_op),
    .ALUCtrl_o  (wire_alu_ctrl)
);

Data_Memory Data_Memory(
	.addr_i(wire_alu_out),
	.data_i(wire_data2),
	.MemWrite_i(wire_ctrl_mw),
	.MemRead_i(wire_ctrl_mr),
	.data_o(wire_mem_out)
);

endmodule

