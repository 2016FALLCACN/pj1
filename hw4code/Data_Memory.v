module Data_Memory
(
    addr_i, 
    data_i,
    MemWrite_i,
    MemRead_i,
    data_o
);

// Interface
input   [31:0]      addr_i;
input   [31:0]      data_i;
input		    MemWrite_i;
input		    MemRead_i;
output  [31:0]      data_o;
reg	[31:0]	    data_o;

// Instruction memory
reg     [7:0]     memory  [0:31];

always @(*)
begin
	if (MemWrite_i)
	begin
		memory[addr_i] <= data_i[7:0];
		memory[addr_i+1] <= data_i[15:8];
		memory[addr_i+2] <= data_i[23:16];
		memory[addr_i+3] <= data_i[31:24];
	end
	else if (MemRead_i)
	begin
		data_o[7:0] <= memory[addr_i];
		data_o[15:8] <= memory[addr_i+1];
		data_o[23:16] <= memory[addr_i+2];
		data_o[31:24] <= memory[addr_i+3];
	end
	else ;
end

endmodule
