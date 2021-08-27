module ProgCtr_tb;
    logic       Reset,
                Clk,
                BranchRel
                Zero;
    logic [7:0] Target;
    wire  [7:0] PC;

    ProgCtr pc (
        .Reset,
        .Clk,
        .BranchRel,
        .Zero,
        .Target,
        .PC
    );

    initial begin
        $display("testing . . .");
        Zero = 1;
        Reset = 1;
        #10ns
        Reset = 0;
        BranchRel = 0;
        #100ns
        BranchRel = 1;
        Target = 'd2;
    end

    always begin   // clock period = 10 Verilog time units
        #5ns  Clk = 'b1;
        #5ns  Clk = 'b0;
    end

endmodule