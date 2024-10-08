module DataMem (
  input              Clk,
                     Reset,
                     WriteEn,
  input [7:0]        DataAddress,
                     DataIn,
  output logic[7:0]  DataOut
  );

  logic [7:0] Core[256];			// 8x256 two-dimensional array -- the memory itself

  always_comb
    DataOut = Core[DataAddress]; // read

  always_ff @ (posedge Clk)	begin	 // writes are sequential
    if (Reset) begin
      Core[130] <= 7'h60;         // tap_pattern_list
      Core[131] <= 7'h48;      
      Core[132] <= 7'h78;      
      Core[133] <= 7'h72;      
      Core[134] <= 7'h6A;      
      Core[135] <= 7'h69;      
      Core[136] <= 7'h5C;      
      Core[137] <= 7'h7E;      
      Core[138] <= 7'h7B;      
      Core[140] <= 8'h20;         // space_char
      Core[141] <= 8'b0;          // delimiter_char
	  end
    else if (WriteEn) begin
      Core[DataAddress] <= DataIn;
      // if (DataAddress >= 64 && DataAddress <= 127)
      //   Core[DataAddress] <= {^DataIn, DataIn[6:0]};
      // else
      //   Core[DataAddress] <= DataIn;
    end
  end
endmodule
