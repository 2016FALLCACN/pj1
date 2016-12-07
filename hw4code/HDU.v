module HDU
(
	instr_i,
	ID_EX_RegRt_i,
	MemRead_i,
	PC_o,
	IF_ID_o,
	mux8_o
);


// Ports

input	[31:0]		instr_i;
input	[4:0]		ID_EX_RegRt_i;
input				MemRead_i;
output				PC_o;
output				IF_ID_o;
output				mux8_o;


reg 	PC_o;
reg 	IF_ID_o;
reg 	mux8_o;


always@(*) begin
	if (MemRead_i && ( ID_EX_RegRt_i == instr_i[25:21] || ID_EX_RegRt_i == instr_i[20:16] )) begin
		$display("[HDU]Stall next cycle, ID_EX_RegRt_i = %b, instr_i_Rs = %b, instr_i_Rt = %b\n", 
			ID_EX_RegRt_i, instr_i[25:21], instr_i[20:16]);
		PC_o = 1'b1;
		IF_ID_o = 1'b1;
		mux8_o = 1'b1;
	end
	else begin
		PC_o = 1'b0;
		IF_ID_o = 1'b0;
		mux8_o = 1'b0;
	end
end

endmodule
