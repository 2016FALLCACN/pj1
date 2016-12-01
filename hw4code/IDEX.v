module IDEX 
(
	clk_i,
	WB_i,
	M_i,
	EX_i,
	PC_i,
	RegData1_i,
	RegData2_i,
	SignExt_i,
	RegAddrRs_i,
	RegAddrRt_i,
	RegAddrRd_i,
	WB_o,
	M_o,
	ALUSrc_o,
	ALUOp_o,
	RegDst_o,
	PC_o,
	RegData1_o,
	RegData2_o,
	SignExt_o,
	RegAddrRs_o,
	RegAddrRt_o,
	RegAddrRd_o
);

input clk_i;
input [1:0] WB_i, M_i;
input [3:0] EX_i;
input [4:0] RegAddrRs_i, RegAddrRt_i, RegAddrRd_i;
input [31:0] PC_i, RegData1_i, RegData2_i, SignExt_i;

output ALUSrc_o, RegDst_o;
output [1:0] WB_o, M_o;
output [1:0] ALUOp_o;
output [4:0] RegAddrRs_o, RegAddrRt_o, RegAddrRd_o;
output [31:0] PC_o, RegData1_o, RegData2_o, SignExt_o;

reg ALUSrc_o, RegDst_o;
reg [1:0] WB_o, M_o;
reg [1:0] ALUOp_o;
reg [4:0] RegAddrRs_o, RegAddrRt_o, RegAddrRd_o;
reg [31:0] PC_o, RegData1_o, RegData2_o, SignExt_o;

always @ (posedge clk_i) begin
	WB_o <= WB_i;
	M_o <= M_i;
	ALUSrc_o <= EX_i[0];
	ALUOp_o <= EX_i[2:1];
	RegDst_o <= EX_i[3];
	PC_o <= PC_i;
	RegData1_o <= RegData1_i;
	RegData2_o <= RegData2_i;
	SignExt_o <= SignExt_i;
	RegAddrRs_o <= RegAddrRs_i;
	RegAddrRt_o <= RegAddrRt_i;
	RegAddrRd_o <= RegAddrRd_i;
end
endmodule
