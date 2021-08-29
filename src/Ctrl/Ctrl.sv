import definitions::*;

module Ctrl (
  input        [5:0] Instruction,
  output logic       RegWrite,
                     MemWrite,
                     BranchRel,
                     RegMemSel,
                     ALUSrcSel,
                     DataSrcSel,
                     ReadAddrSel,
                     LdStSel,
  output logic [1:0] WriteAddrSel,
  output logic [2:0] ALUOp
  );

  op_mne op_mnemonic;

  logic [2:0] OP,
              LOrS;

  assign OP   = Instruction[5:3];
  assign LOrS = Instruction[2:0];

  always_comb
    op_mnemonic = op_mne'(OP);

  always_comb begin
    RegWrite      = 'b0;
    MemWrite      = 'b0;
    BranchRel     = 'b0;
    RegMemSel     = 'b0;
    ALUSrcSel     = 'b0;
    DataSrcSel    = 'b0;
    ReadAddrSel   = 'b0;
    LdStSel       = 'b0;
    WriteAddrSel  = 'b0;
    ALUOp         = 'b0;

    case(OP)
      kLSW    : begin
                  if (!LOrS) begin // SW
                    MemWrite      = 'b1;
                  end
                  else begin // LW
                    RegWrite      = 'b1;
                    LdStSel       = 'b1;
                  end
                end
      kERRFLG : begin
                  RegWrite      = 'b1;
                  DataSrcSel    = 'b1;
                  WriteAddrSel  = 'b1;
                  ALUOp         = kERRFLG;
                end
      kSET    : begin
                  RegWrite      = 'b1;
                  RegMemSel     = 'b1;
                  WriteAddrSel  = 'b10;
                end
      kBNE    : begin
                  BranchRel     = 'b1;
                  ReadAddrSel   = 'b1;
                  ALUOp         = kBNE;
                end
      kPAR    : begin
                  RegWrite      = 'b1;
                  DataSrcSel    = 'b1;
                  WriteAddrSel  = 'b1;
                  ALUOp         = kPAR;
                end
      kADD    : begin
                  RegWrite      = 'b1;
                  ALUSrcSel     = 'b1;
                  DataSrcSel    = 'b1;
                  ReadAddrSel   = 'b1;
                  WriteAddrSel  = 'b1;
                  ALUOp         = kADD;
                end
      kXOR    : begin
                  RegWrite      = 'b1;
                  DataSrcSel    = 'b1;
                  WriteAddrSel  = 'b1;
                  ALUOp         = kXOR;
                end
      kLSOR   : begin
                  RegWrite      = 'b1;
                  DataSrcSel    = 'b1;
                  WriteAddrSel  = 'b1;
                  ALUOp         = kLSOR;
                end
    endcase
  end

endmodule

