module MUX5 // for only R-type & addi
(
   data1_i,
   data2_i,
   select_i,
   data_o
);

// Ports
input	[4:0]		data1_i;
input	[4:0]		data2_i;
input				select_i;
output 	[4:0]		data_o;

// Wires & Registers
reg		[4:0]		data_o;


always@(*) begin
    if(select_i) begin // select_i = 1 -> R-type
        data_o = data2_i; // rd
    end
    else begin // select_i = 0 -> addi
		data_o = data1_i; // rt
    end
end

endmodule
