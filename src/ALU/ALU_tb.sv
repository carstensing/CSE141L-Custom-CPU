import definitions::*;

module ALU_tb;
  logic        [7:0] InputA,
                     InputB;
  logic        [2:0] OP;	
  wire         [7:0] Out;		
  wire               Zero,  
                     Parity;

  ALU alu (
    .InputA,
    .InputB,
    .OP,
    .Out,		
    .Zero,  
    .Parity
  );

  initial begin
    $display("testing . . .");
    OP = kBNE;
    InputA = 'd3;
    InputB = 'd2;
    #20ns

    OP = kBNE;
    InputA = 'd2;
    InputB = 'd2;
    #20ns

    OP = kPAR;
    InputA = 'b1101;
    InputB = 'b0;
    #20ns

    OP = kPAR;
    InputA = 'b01101010;
    InputB = 'b0;
    #20ns

    OP = kADD;
    InputA = 'd200;
    InputB = 'd20;
    #20ns

    OP = kXOR;
    InputA = 'b00110101;
    InputB = 'b00010010;
    #20ns

    OP = kLSOR;
    InputA = 'b01111110;
    InputB = 'b1;
    #20ns

    $stop;
  end

endmodule