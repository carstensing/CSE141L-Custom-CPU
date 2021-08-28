module TopLevel (
  input        Reset,	   // init/reset, active high
			         Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
  output logic Ack	   // done flag from DUT
  );

  wire [8:0] Instruction;
  wire [7:0] PC,
             Target,
             ALUSrcOut,
             RegMemOut,
             DataSrcOut,
             RegOutA,
             RegOutB,
             RegOutC,
             Reg6,
             MemOut,
             ALUOut;
  wire [2:0] ALUOp,
             ReadAddrOut,
             WriteAddrOut,
             LdStOut;
  wire [1:0] WriteAddrSel;
  wire       Zero,
             Parity,
             RegWrite,
             MemWrite,
             BranchRel,
             RegMemSel,
             ALUSrcSel,
             DataSrcSel,
             ReadAddrSel,
             LdStSel;

  always_comb	begin
    case(Instruction)
    'b0     : Ack = 1'b1;
	  default : Ack = 1'b0;
    endcase
  end
  
  ProgCtr pc (
    .Reset,
    .Clk,
    .BranchRel,
    .Zero,
    .Target,
    .PC
  );

  InstROM instr (
    .InstAddress  (PC),
    .InstOut      (Instruction)
  );

  Ctrl ctrl (
    .Instruction   (Instruction[8:3]),
    .RegWrite,
    .MemWrite,
    .BranchRel,
    .RegMemSel,
    .ALUSrcSel,
    .DataSrcSel,
    .ReadAddrSel,
    .LdStSel,
    .WriteAddrSel,
    .ALUOp
  );

  RegFile regfile (
    .Clk,
    .Reset,
    .WriteEn   (RegWrite),
    .RaddrA    (Instruction[5:3]),
    .RaddrB    (ReadAddrOut),
    .RaddrC    (LdStOut),
    .Waddr     (WriteAddrOut),
    .DataIn    (DataSrcOut),
    .DataOutA  (RegOutA),
    .DataOutB  (RegOutB),
    .DataOutC  (RegOutC),
    .Reg6      (Reg6)
  );

  DataMem mem (
    .Clk,
    .Reset,
    .WriteEn      (MemWrite),
    .DataAddress  (RegOutC),
    .DataIn       (Reg6),
    .DataOut      (MemOut)
  );

  ALU alu (
    .InputA  (ALUSrcOut),
    .InputB  (RegOutB),
    .OP      (ALUOp),
    .Out     (ALUOut),		
    .Zero,  
    .Parity  (Parity)
  );

  Mux2 readaddr (
    .d0 (Instruction[2:0]), 
    .d1 (3'b0), 
    .s  (ReadAddrSel), 
    .y  (ReadAddrOut)
  );

  Mux2 alusrc (
    .d0 (RegOutA), 
    .d1 ({2'b0, Instruction[5:0]}), 
    .s  (ALUSrcSel), 
    .y  (ALUSrcOut)
  );

  Mux2 regmem (
    .d0 (MemOut), 
    .d1 (RegOutC), 
    .s  (RegMemSel), 
    .y  (RegMemOut)
  );

  Mux2 datasrc (
    .d0 (RegMemOut), 
    .d1 (ALUOut), 
    .s  (DataSrcSel), 
    .y  (DataSrcOut)
  );

  Mux2 loadstore (
    .d0 (Instruction[2:0]), 
    .d1 (Instruction[5:3]), 
    .s  (LdStSel), 
    .y  (LdStOut)
  );

  Mux3 writeaddr (
    .d0 (3'd7), 
    .d1 (3'b0), 
    .d2 (Instruction[5:3]),
    .s  (WriteAddrSel),
    .y  (WriteAddrOut)
  );

endmodule