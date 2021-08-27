
module mux2 #(parameter W=8) (
  input        [W-1:0] d0, 
                       d1, 
  input                s, 
  output logic [W-1:0] y
  );
			  
// s   y
// 0   d0
// 1   d1

  always_comb begin
    case(s)
		0: y = d0;
		1: y = d1;
	  endcase
  end

endmodule


