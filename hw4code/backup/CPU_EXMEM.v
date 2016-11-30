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
wire	[31:0]		wire_ifid_pc_ret;
wire	[31:0]		wire_inst;
wire	[31:0]		wire_ifid_inst;
wire				wire_reg_dst; // from Control
wire				wire_reg_wr; // from Control
wire				wire_alu_src; // from Control
wire				wire_ctrl_mtr; // from Control to mux32 WBSrc
wire				wire_ctrl_mw; // from Control to Data_Memory
wire				wire_ctrl_mr; // from Control to Data_Memory
wire				wire_ctrl_br; // from Control to AND_Branch
wire				wire_ctrl_j; // from Control to MUX_Jump
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
wire    [31:0]		wire_mux32_j; // from MUX_Jump
wire	[31:0]		wire_alu_out; // from ALU
wire    [31:0]		wire_mem_out; // from Data_Memory
wire    [31:0]		wire_sll_br; // from ssl_branch
wire    [31:0]		wire_sll_j; // from ssl_j
wire    [31:0]		wire_add_br; // from Add_Branch

wire			wire_memwb_ctrl_rw;
wire			wire_memwb_ctrl_mtr;
wire	[31:0]		wire_memwb_alu_out;
wire	[31:0]		wire_memwb_mem_out;
wire	[4:0]		wire_memwb_wr_reg;

wire			wire_exmem_ctrl_mr;
wire			wire_exmem_ctrl_mw;
wire	[1:0]		wire_exmem_wb;
wire	[4:0]		wire_exmem_wr_reg;
wire	[31:0]		wire_exmem_alu_out;
wire	[31:0]		wire_exmem_data2;


AND AND_Branch(
	.data1_i(wire_ctrl_br),
	.data2_i(wire_zero),
	.and_o(wire_isbr)
); 

MUX32 MUX_Branch(
    .data1_i    (wire_pc_ret), // from PC + 4
    .data2_i    (wire_add_br), // from Add_branch
    .select_i   (wire_isbr), 
    .data_o     (wire_mux32_br)
);

MUX32 MUX_Jump(
    .data1_i    (wire_mux32_br), // from MUX_Branch
    .data2_i    ({wire_mux32_br[31:28], wire_sll_j[27:0]}), // from MUX_Branch and Sll_Jump
    .select_i   (wire_ctrl_j),
    .data_o     (wire_mux32_j)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (wire_mux32_j),
    .pc_o       (wire_pc)
);

Adder Add_PC(
    .data1_i   (wire_pc),
    .data2_i   (4),
    .data_o     (wire_pc_ret)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (wire_pc), 
    .instr_o    (wire_inst)
);

IFID IFID(
    .clk_i		(clk_i),
    .Stall_i		(0),
    .PC_i		(wire_pc_ret),
    .instruction_i	(wire_inst),
    .Flush_i		(0),
    .PC_o		(wire_ifid_pc_ret),
    .instruction_o	(wire_ifid_inst)
);

Control Control(
    .Op_i       (wire_ifid_inst[31:26]),
    .RegDst_o   (wire_reg_dst),
    .ALUOp_o    (wire_alu_op),
    .ALUSrc_o   (wire_alu_src),
    .RegWrite_o (wire_reg_wr),
    .MemWrite_o (wire_ctrl_mw),
    .MemRead_o  (wire_ctrl_mr),
    .MemtoReg_o (wire_ctrl_mtr),
    .Branch_o   (wire_ctrl_br),
    .Jump_o	(wire_ctrl_j)
);

Sll Sll_Jump(
	.data_i(wire_ifid_inst),
	.lshift(5'd2),
	.data_o(wire_sll_j)
);

Sll Sll_Branch(
	.data_i(wire_sign_ext),
	.lshift(5'd2),
	.data_o(wire_sll_br)
);

Adder Add_Branch(
    .data1_i   (wire_sll_br),
    .data2_i   (wire_pc_ret),
    .data_o     (wire_add_br)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (wire_ifid_inst[25:21]),
    .RTaddr_i   (wire_ifid_inst[20:16]),
    .RDaddr_i   (wire_memwb_wr_reg), 
    .RDdata_i   (wire_mux32_wbsrc), // from mux32 wbsrc
    .RegWrite_i (wire_memwb_ctrl_rw), // from Control_RegWrite
    .RSdata_o   (wire_data1), 
    .RTdata_o   (wire_data2) 
);

EQ EQ(
	.data1_i(wire_data1), // from Registers.RSdata_o
	.data2_i(wire_data2), // from Registers.RTdata_o
	.eq_o(wire_zero)
);

Sign_Extend Sign_Extend(
    .data_i     (wire_ifid_inst[15:0]),
    .data_o     (wire_sign_ext)
);

MUX32 MUX_ALUSrc(
    .data1_i    (wire_data2), // from Registers
    .data2_i    (wire_sign_ext), // from Sign_Extend
    .select_i   (wire_alu_src), // from Control_ALUSrc
    .data_o     (wire_mux32_alusrc)
);

MUX5 MUX_RegDst(
    .data1_i    (wire_ifid_inst[20:16]), // rt
    .data2_i    (wire_ifid_inst[15:11]), // rd
    .select_i   (wire_reg_dst), // from Control_RegDst
    .data_o     (wire_wr_reg)
);

ALU ALU(
    .data1_i    (wire_data1),
    .data2_i    (wire_mux32_alusrc),
    .ALUCtrl_i  (wire_alu_ctrl),
    .data_o     (wire_alu_out),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (wire_ifid_inst[5:0]),
    .ALUOp_i    (wire_alu_op),
    .ALUCtrl_o  (wire_alu_ctrl)
);

EXMEM EXMEM(
	.clk_i(clk_i),
	.WB_i({wire_ctrl_mtr, wire_reg_wr}),
	.M_i({wire_ctrl_mw, wire_ctrl_mr}),
	.RegAddr_i(wire_wr_reg),
	.RegData_i(wire_alu_out),
	.MemData_i(wire_data2),
	.MemRead_o(wire_exmem_ctrl_mr),
	.MemWrite_o(wire_exmem_ctrl_mw),
	.WB_o(wire_exmem_wb),
	.RegAddr_o(wire_exmem_wr_reg),
	.RegData_o(wire_exmem_alu_out),
	.MemData_o(wire_exmem_data2)
);

Data_Memory Data_Memory(
	.addr_i(wire_exmem_alu_out),
	.data_i(wire_exmem_data2),
	.MemWrite_i(wire_exmem_ctrl_mw),
	.MemRead_i(wire_exmem_ctrl_mr),
	.data_o(wire_mem_out)
);

MEMWB MEMWB(
	.clk_i(clk_i),
	.WB_i(wire_exmem_wb),
	.MemData_i(wire_mem_out),
	.RegData_i(wire_exmem_alu_out),
	.RegAddr_i(wire_exmem_wr_reg),
	.RegWrite_o(wire_memwb_ctrl_rw),
	.MemtoReg_o(wire_memwb_ctrl_mtr),
	.MemData_o(wire_memwb_mem_out),
	.RegData_o(wire_memwb_alu_out),
	.RegAddr_o(wire_memwb_wr_reg)
);

MUX32 MUX_WBSrc(
    .data1_i    (wire_memwb_alu_out), // from ALU
    .data2_i    (wire_memwb_mem_out), // from Data_Memory
    .select_i   (wire_memwb_ctrl_mtr), // from Control
    .data_o     (wire_mux32_wbsrc)
);

endmodule

