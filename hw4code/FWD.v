module FWD
(
	IDEX_RegRs_i,
	IDEX_RegRt_i,
	EXMEM_RegRd_i,
	EXMEM_RegWr_i,
	MEMWB_RegRd_i,
	MEMWB_RegWr_i,
	Fw1_o,
	Fw2_o
);

// Ports
input	[4:0] 		IDEX_RegRs_i;
input	[4:0]		IDEX_RegRt_i;
input	[4:0]		EXMEM_RegRd_i;
input			EXMEM_RegWr_i;
input	[4:0]		MEMWB_RegRd_i;
input			MEMWB_RegWr_i;
output	[1:0]		Fw1_o;
output	[1:0]		Fw2_o;

// Wires & Registers
reg	[1:0]		Fw1_o;
reg	[1:0]		Fw2_o;

always@(*) begin
	$display("[FWD]IDEX_RegRs_i = %b, IDEX_RegRt_i = %b\n", IDEX_RegRs_i, IDEX_RegRt_i);
	$display("[FWD]EXMEM_RegRd_i = %b, EXMEM_RegWr_i = %b\n", EXMEM_RegRd_i, EXMEM_RegWr_i);
	$display("[FWD]MEMWB_RegRd_i = %b, MEMWB_RegWr_i = %b\n", MEMWB_RegRd_i, MEMWB_RegWr_i);
	
	if (EXMEM_RegWr_i && EXMEM_RegRd_i && IDEX_RegRs_i == EXMEM_RegRd_i) // from ALU, to Rs
		Fw1_o = 2'b10;
	else if (MEMWB_RegWr_i && MEMWB_RegRd_i && IDEX_RegRs_i == MEMWB_RegRd_i) // from DM, to Rs
		Fw1_o = 2'b01;
	else
		Fw1_o = 2'b00;

	if (EXMEM_RegWr_i && EXMEM_RegRd_i && IDEX_RegRt_i == EXMEM_RegRd_i) // from ALU, to Rt
		Fw2_o = 2'b10;
	else if (MEMWB_RegWr_i && MEMWB_RegWr_i && IDEX_RegRt_i == MEMWB_RegRd_i) // from DM, to Rt
		Fw2_o = 2'b01;
	else
		Fw2_o = 2'b00;	
end

endmodule
