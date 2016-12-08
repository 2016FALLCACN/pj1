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

wire	[1:0]		wire_idex_wb;
wire	[1:0]		wire_idex_m;
wire			wire_idex_ctrl_alusrc;
wire	[1:0] 		wire_idex_ctrl_aluop;
wire			wire_idex_ctrl_rd;
wire	[31:0]		wire_idex_data1;
wire	[31:0]		wire_idex_data2;
wire	[31:0]		wire_idex_signext;
wire	[4:0]		wire_idex_rsaddr;
wire	[4:0]		wire_idex_rtaddr;
wire	[4:0]		wire_idex_rdaddr;

wire	[1:0]		wire_fw_sel1;
wire	[1:0]		wire_fw_sel2;
wire	[31:0]		wire_fw_out1;
wire	[31:0]		wire_fw_out2;


wire 				wire_pc_stall;
wire 				wire_ifid_stall;
wire 				wire_mux8_stall;
wire 	[7:0]		wire_mux8_data_o;

wire 				wire_flush;



AND AND_Branch(
	.data1_i(wire_ctrl_br),
	.data2_i(wire_zero),
	.and_o(wire_isbr)
); 

OR OR_Flush(
	.data1_i(wire_ctrl_j),
	.data2_i(wire_isbr),
	.or_o(wire_flush)
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
    .stall_i 	(wire_pc_stall),
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
    .Stall_i		(wire_ifid_stall),
    .PC_i		(wire_pc_ret),
    .instruction_i	(wire_inst),
    .Flush_i		(wire_flush),
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

// HDU and mux8

HDU HDU(
	.instr_i 	(wire_ifid_inst[31:0]),
	.ID_EX_RegRt_i	(wire_idex_rtaddr),
	.MemRead_i	(wire_idex_m[0]),
	.PC_o 	(wire_pc_stall),
	.IF_ID_o 	(wire_ifid_stall),
	.mux8_o 		(wire_mux8_stall)
);

MUX8 MUX8(
	.data1_i({wire_reg_dst, wire_alu_op[1:0], wire_alu_src, wire_reg_wr, wire_ctrl_mw, wire_ctrl_mr, wire_ctrl_mtr}),
	.data2_i(8'b0),
	.select_i(wire_mux8_stall),
	.data_o(wire_mux8_data_o)
);

IDEX IDEX(
	.clk_i(clk_i),
//	.WB_i({wire_ctrl_mtr, wire_reg_wr}),
//	.M_i({wire_ctrl_mw, wire_ctrl_mr}),
//	.EX_i({wire_reg_dst, wire_alu_op, wire_alu_src}),
	.WB_i({wire_mux8_data_o[0], wire_mux8_data_o[3]}),
	.M_i(wire_mux8_data_o[2:1]),
	.EX_i(wire_mux8_data_o[7:4]),
	.PC_i(),
	.RegData1_i(wire_data1),
	.RegData2_i(wire_data2),
	.SignExt_i(wire_sign_ext),
	.RegAddrRs_i(wire_ifid_inst[25:21]),
	.RegAddrRt_i(wire_ifid_inst[20:16]),
	.RegAddrRd_i(wire_ifid_inst[15:11]),
	.WB_o(wire_idex_wb),
	.M_o(wire_idex_m),
	.ALUSrc_o(wire_idex_ctrl_alusrc),
	.ALUOp_o(wire_idex_ctrl_aluop),
	.RegDst_o(wire_idex_ctrl_rd),
	.PC_o(),
	.RegData1_o(wire_idex_data1),
	.RegData2_o(wire_idex_data2),
	.SignExt_o(wire_idex_signext),
	.RegAddrRs_o(wire_idex_rsaddr),
	.RegAddrRt_o(wire_idex_rtaddr),
	.RegAddrRd_o(wire_idex_rdaddr)
);

MUX32_3	MUX_FW1(
	.data1_i	(wire_idex_data1),
	.data2_i	(wire_mux32_wbsrc),
	.data3_i	(wire_exmem_alu_out),
	.select_i	(wire_fw_sel1),
	.data_o		(wire_fw_out1)
);

MUX32_3	MUX_FW2(
	.data1_i	(wire_idex_data2),
	.data2_i	(wire_mux32_wbsrc),
	.data3_i	(wire_exmem_alu_out),
	.select_i	(wire_fw_sel2),
	.data_o		(wire_fw_out2)
);

MUX32 MUX_ALUSrc(
    .data1_i    (wire_fw_out2), // from MUX_FW2
    .data2_i    (wire_idex_signext), // from Sign_Extend
    .select_i   (wire_idex_ctrl_alusrc), // from Control_ALUSrc
    .data_o     (wire_mux32_alusrc)
);

MUX5 MUX_RegDst(
    .data1_i    (wire_idex_rtaddr), // rt
    .data2_i    (wire_idex_rdaddr), // rd
    .select_i   (wire_idex_ctrl_rd), // from Control_RegDst
    .data_o     (wire_wr_reg)
);

ALU ALU(
    .data1_i    (wire_fw_out1), // from MUX_FW1
    .data2_i    (wire_mux32_alusrc),
    .ALUCtrl_i  (wire_alu_ctrl),
    .data_o     (wire_alu_out),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (wire_idex_signext[5:0]),
    .ALUOp_i    (wire_idex_ctrl_aluop),
    .ALUCtrl_o  (wire_alu_ctrl)
);

FWD FWD(
	.IDEX_RegRs_i	(wire_idex_rsaddr),
	.IDEX_RegRt_i	(wire_idex_rtaddr),
	.EXMEM_RegRd_i	(wire_exmem_wr_reg),
	.EXMEM_RegWr_i	(wire_exmem_wb[0]),
	.MEMWB_RegRd_i	(wire_memwb_wr_reg),
	.MEMWB_RegWr_i	(wire_memwb_ctrl_rw),
	.Fw1_o		(wire_fw_sel1),
	.Fw2_o		(wire_fw_sel2)
);

EXMEM EXMEM(
	.clk_i(clk_i),
	.WB_i(wire_idex_wb),
	.M_i(wire_idex_m),
	.RegAddr_i(wire_wr_reg),
	.RegData_i(wire_alu_out),
	.MemData_i(wire_fw_out2),
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

