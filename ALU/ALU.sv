import definitions::*;	

module ALU (
  input        [7:0] InputA,  // data inputs
                     InputB,
  input        [2:0] OP,		  // opcode
  output logic [7:0] Out,		  // result
  output logic       Zero,    // flags
                     Parity
  );								    

  op_mne op_mnemonic;			    // type enum: used for convenient waveform viewing

  always_comb begin
    Out = 'b0;              // No Op = default
    case(OP)
      kBNE  : Out = InputA - InputB;
      kPAR  : Out = ^InputA;
      kADD  : Out = InputA + InputB;
      kXOR  : Out = InputA ^ InputB;
      kLSOR : Out = {1'b0, ((InputA[6:0] << 1) | InputB[6:0])};
    endcase
  end

  always_comb	// assign Zero = !Out;
    case(Out)
    'b0     : Zero = 1'b1;
	  default : Zero = 1'b0;
    endcase
  
  assign Parity = ^Out;

  always_comb
    op_mnemonic = op_mne'(OP);  // displays operation name in waveform viewer

endmodule