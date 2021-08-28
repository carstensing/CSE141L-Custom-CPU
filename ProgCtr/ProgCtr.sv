module ProgCtr #(parameter W=8) (
    input                Reset,
                         Clk,
                         BranchRel,
                         Zero,
    input        [W-1:0] Target,
    output logic [W-1:0] PC
    );

    logic Branch;

    always_ff @(posedge Clk) begin
        Branch = BranchRel & Zero;
        if (Reset)
            PC <= 0;
        else if (Branch)
            PC <= PC - Target;
        else
            PC <= PC + 'b1;
    end

endmodule