import definitions::*;

module Ctrl_tb;
  logic [5:0] Instruction;
  wire        RegWrite,
              MemWrite,
              MemRead,
              BranchRel,
              RegMemSel,
              ALUSrcSel,
              DataSrcSel,
              ReadAddrSel;
  wire  [1:0] WriteAddrSel;
  wire  [2:0] ALUOp;

  Ctrl ctrl (
    .Instruction,
    .RegWrite,
    .MemWrite,
    .MemRead,
    .BranchRel,
    .RegMemSel,
    .ALUSrcSel,
    .DataSrcSel,
    .ReadAddrSel,
    .WriteAddrSel,
    .ALUOp
  );

  initial begin
    $display("testing . . .");
    Instruction = {kLSW, 3'b011, 3'b000}[8:3];
    #20ns
    Instruction = {kADD, 6'b000001}[8:3];
    #20ns
    Instruction = {kBNE, 3'b011, 3'b010}[8:3];
    #20ns
    Instruction = {kXOR, 3'b011, 3'b010}[8:3];
    #20ns
    $stop;
  end

endmodule