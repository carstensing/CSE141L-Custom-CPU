module ProgCtr #(parameter W=8) (
    input                Reset,
                         Clk,
                         BranchRel,
                         Zero,
    input        [W-1:0] Target,
    output logic [W-1:0] PC
    );

    logic Branch;

    always_comb
        case(Zero)
        'b0     : Branch = BranchRel;
        default : Branch = 'b0;
        endcase

    always_ff @(posedge Clk) begin
        if (Reset)
            PC <= 0;
        else if (Branch)
            if (Target[W-1] == 1)
                PC <= PC - {1'b0, Target[W-2:0]};
            else
                PC <= PC + Target;
        else
            PC <= PC + 'b1;
    end

endmodule