module MUX8 // mux8
(
   data1_i,
   data2_i,
   select_i,
   data_o
);

// Ports
input	[7:0]		data1_i;
input	[7:0]		data2_i;
input				select_i;  // aka isstall_i
output 	[7:0]		data_o;

// Wires & Registers
reg		[7:0]		data_o;


always@(*) begin
    if(select_i) begin 
        data_o = data2_i; 
    end
    else begin 
		data_o = data1_i; 
    end
end

endmodule