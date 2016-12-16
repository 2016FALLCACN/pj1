module MEMWB
(
	clk_i,
	WB_i,
	MemData_i,
	RegData_i,
	RegAddr_i,
	RegWrite_o,
	MemtoReg_o,
	MemData_o,
	RegData_o,
	RegAddr_o
);

input clk_i;
input [1:0] WB_i;
input [31:0] MemData_i, RegData_i;
input [4:0] RegAddr_i;
output RegWrite_o, MemtoReg_o;
output [31:0] MemData_o, RegData_o;
output [4:0] RegAddr_o;
reg 	RegWrite_o,
	MemtoReg_o, 
	MemData_o,
	RegData_o,
	RegAddr_o;

always @ (posedge clk_i) begin
//	$display("[MEMWB]WB_i[0] = %b, WB_i[1] = %b\n", WB_i[0], WB_i[1]);
 	RegWrite_o <= WB_i[0];
	MemtoReg_o <= WB_i[1];
	MemData_o <= MemData_i;
	RegData_o <= RegData_i;
	RegAddr_o <= RegAddr_i;
end

endmodule
