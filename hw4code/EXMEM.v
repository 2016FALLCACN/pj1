module EXMEM
(
	clk_i,
	WB_i,
	M_i,
	RegData_i,
	MemData_i,
	RegAddr_i,
	WB_o,
	MemRead_o,
	MemWrite_o,
	RegData_o,
	MemData_o,
	RegAddr_o
);

input clk_i;
input [1:0] WB_i, M_i;
input [4:0] RegAddr_i;
input [31:0] RegData_i, MemData_i;
output MemRead_o, MemWrite_o;
output [1:0] WB_o;
output [4:0] RegAddr_o;
output [31:0] RegData_o, MemData_o;
reg	MemRead_o, MemWrite_o,
	WB_o, RegAddr_o, 
	RegData_o, MemData_o;

always @ (posedge clk_i) begin
	$display("[EXMEM]M_i[0] = %b, M_i[1] = %b\n", M_i[0], M_i[1]);
	$display("[EXMEM]WB_i[0] = %b, WB_i[1] = %b\n", WB_i[0], WB_i[1]);
	MemRead_o <= M_i[0];
	MemWrite_o <= M_i[1];
	WB_o <= WB_i;
	RegAddr_o <= RegAddr_i;
	RegData_o <= RegData_i;
	MemData_o <= MemData_i;
end

endmodule
