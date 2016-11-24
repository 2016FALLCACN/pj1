module MUX32 // for only R-type & addi
(
   data1_i,
   data2_i,
   select_i,
   data_o
);

// Ports
input	[31:0]		data1_i;
input	[31:0]		data2_i;
input				select_i;
output 	[31:0]		data_o;

// Wires & Registers
reg		[31:0]		data_o;


always@(*) begin
    if(select_i) begin // select_i = 1 -> addi
        data_o = data2_i; // sign_ext
    end
    else begin // select_i = 0 -> R-type
		data_o = data1_i; // Read_data2
    end
end

endmodule
