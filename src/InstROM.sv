module InstROM #(parameter L=8, W=9) (
  input        [L-1:0] InstAddress,
  output logic [W-1:0] InstOut
  );

  logic[W-1:0] inst_rom[2**(L)];

  always_comb 
    InstOut = inst_rom[InstAddress];
 
  initial begin  // load from external text file
  	$readmemb("machine_code.txt", inst_rom);
  end 
  
endmodule
