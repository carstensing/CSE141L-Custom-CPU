// Create Date:    2017.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

module RegFile #(parameter W=8, D=3)(		  // W = data path width; D = pointer width
  input                Clk,
                       WriteEn,
  input        [D-1:0] RaddrA,				  // address pointers
                       RaddrB,
                       RaddrC,
                       Waddr,
  input        [W-1:0] DataIn,
  output logic [W-1:0] DataOutA,
                       DataOutB,
                       DataOutC,
                       Reg6
  );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];

initial begin
  Reg6 = Registers[6];
end

always_comb begin
  DataOutA = Registers[RaddrA];
  DataOutB = Registers[RaddrB];
  DataOutC = Registers[RaddrC];
end

// sequential (clocked) writes 
always_ff @ (posedge Clk)
  if (WriteEn)	                             // works just like data_memory writes
    Registers[Waddr] <= DataIn;

endmodule
