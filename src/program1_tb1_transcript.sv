// program1_tb
// testbench for programmable message encryption (Program #1)
// CSE141L    Winter 2021
// runs program 1 (encrypt a message)
// notes:
//   1. 
module encrypt_tb ()        ;
  logic      clk   = 1'b0   ,      // advances simulation step-by-step
             init  = 1'b1   ,      // init (reset) command to DUT
             start = 1'b1   ;      // req (start program) command to DUT
  wire       done           ;      // ack (program done) flag returned by DUT
  logic[7:0] pre_length     ;      // space char. bytes before first char. in message  
  logic[7:0] message1[49]   ,      // original raw message, in binary, up to 49 characters in length
             msg_padded1[64],      // original message, plus pre- and post-padding w/ ASCII spaces
             msg_crypto1[64];      // encrypted message according to the DUT
  logic[6:0] lfsr_ptrn      ,      // chosen one of 9 maximal length 7-tap shift reg. ptrns
             LFSR_ptrn[9]   ,      // the 9 candidate maximal-length 7-bit LFSR tap ptrns
             lfsr1[64]      ,      // states of program 1 encrypting LFSR
             LFSR_init      ;      // one of 127 possible NONZERO starting states
  int        score          ;      // count of correct encyrpted characters
// our original American Standard Code for Information Interchange message follows
// note in practice your design should be able to handle ANY ASCII string that is
//  restricted to characters between space (0x20) and script f (0x9f) and shorter than 
//  49 characters in length
  string     str1  = "Mr. Watson, come here. I want to see you.";     // sample program 1 input
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // alternative inputs
//  string     str1  = "  01234546789abcdefghijklmnopqrstuvwxyz. ";   //   (make up your own,
//  string     str1  = "         A joke is a very serious thing.";   // 	as well)
//  string     str1  = "                           Ajok          ";   // 
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // 

// displayed encrypted string will go here:
  string     str_enc1[64];           // program 1 desired output will go here
  int strlen;                        // incoming string length 
  logic[7:0] pt_no;          // select LFSR pattern, value 0 through 8
  int f1,f2,f3;                       // write to file
// the 9 possible maximal-length feedback tap patterns from which to choose
  assign LFSR_ptrn[0] = 7'h60;	     // 110_0000  
  assign LFSR_ptrn[1] = 7'h48;		 // 100_1000
  assign LFSR_ptrn[2] = 7'h78;
  assign LFSR_ptrn[3] = 7'h72;
  assign LFSR_ptrn[4] = 7'h6A;
  assign LFSR_ptrn[5] = 7'h69;
  assign LFSR_ptrn[6] = 7'h5C;
  assign LFSR_ptrn[7] = 7'h7E;
  assign LFSR_ptrn[8] = 7'h7B;
  always_comb begin
    pt_no = $random;											
    if(pt_no[3:0]==8) pt_no = pt_no[3:0];
    else         pt_no = pt_no[2:0];  // restrict to 0 through 8 (our legal patterns)
    lfsr_ptrn = LFSR_ptrn[pt_no];  // engage the selected pattern
  end
// now select a starting LFSR state -- any nonzero value will do
  always_comb begin					   
    LFSR_init = $random>>2;          // or set a value, such as 7'b1, for debug
    if(!LFSR_init) LFSR_init = 7'b1; // prevents illegal starting state = 7'b0; 
  end

// set preamble length for the program run (always > 9 but < 26)
  always_comb begin
    pre_length = $random>>10 ;        // program 1 run
    if(pre_length < 10) pre_length = 10;   // prevents pre_length < 10
	else if(pre_length > 15) pre_length = 15; 
  end

// ***** instantiate your own top level design here *****
  TopLevel dut(
    .Clk     (clk  ),   // input: use your own port names, if different
    .Reset   (init ),   // input: some prefer to call this ".reset"
    .Start    (start),   // input: launch program
    .Ack     (done )    // output: "program run complete"
  );

  initial begin
//***** pre-load your instruction ROM here or inside itself	*****
//    $readmemb("encoder.bin", dut.instr_rom.rom);
// you may also pre-load desired constants, etc. into
//   your data_mem here -- the upper addresses are reserved for your use
//    dut.data_mem.mem[128]=8'hfe;       //whatever constants you want	
    f1 = $fopen("msg_encoder_out.txt");		 // create your output file	 32'b0...010

    #0ns strlen = str1.len;             // length of string 1 (# characters between " ")
    $display("%h",f1);
    if(strlen>49) strlen = 49;          // clip message at 49 characters
    // program 1 -- precompute encrypted message
    lfsr1[0]     = LFSR_init;           // any nonzero value (zero may be helpful for debug)
    $fdisplay(3,"run encryption program; original message = ");
    $fdisplay(3,"%s",str1);       // print original message in transcript window
    $fdisplay(3,"pt_no = %b",pt_no);
    $fdisplay(3,"LFSR_ptrn = 0x%h, LFSR_init = 0x%h",lfsr_ptrn,LFSR_init);

    for(int j=0; j<64; j++)             // pre-fill message_padded with ASCII space characters
      msg_padded1[j] = 8'h20;          
    for(int l=0; l<strlen; l++)         // overwrite up to 54 of these spaces w/ message itself
      msg_padded1[pre_length+l] = str1[l];  
// compute and store the LFSR sequence
    for (int ii=0;ii<63;ii++)
      lfsr1[ii+1] = {(lfsr1[ii][5:0]),(^(lfsr1[ii]&lfsr_ptrn))};

// encrypt the message character-by-character, then prepend the parity
//  testbench will change on falling clocks to avoid race conditions at rising clocks
    for (int i=0; i<64; i++) begin
      msg_crypto1[i]        = (msg_padded1[i] ^ lfsr1[i]);
	    msg_crypto1[i][7]     = ^msg_crypto1[i][6:0];       // prepend parity bit into MSB
      $fdisplay(3,"i=%d, msg_pad=0x%h, lfsr=%b msg_crypt w/ parity = 0x%h",
         i,msg_padded1[i],lfsr1[i],msg_crypto1[i]);
// for display purposes only, add 8'h20 to avoid nonprintable characters (<8'h20)
      str_enc1[i]           = string'(msg_crypto1[i][6:0]+8'h20);
    end
	  $fdisplay(3,"encrypted string =  "); 
	  for(int jj=0; jj<64; jj++)
      $fwrite(3,"%s",str_enc1[jj]);
    $fdisplay(3,"\n");

// run encryption program
// ***** load operands into your data memory *****
// ***** use your instance name for data memory and its internal Core *****
    for(int m=0; m<61; m++)
	    dut.mem.Core[m] = 8'b0;            // delimiter_char
    for(int m=64; m<128; m++)
	    dut.mem.Core[m] = 8'b0;            // delimiter_char
    for(int m=0; m<strlen; m++)
      dut.mem.Core[m] = str1[m];       // overwrite/copy original string into device's data memory[0:strlen-1]
    dut.mem.Core[61] = pre_length;     // number of bytes preceding message
    dut.mem.Core[62] = pt_no;          // LFSR feedback tap positions (9 possible ptrns)
    dut.mem.Core[63] = LFSR_init;      // LFSR starting state (nonzero)
    #20ns init  = 1'b0;				        // suggestion: reset = 1 forces your program counter to 0
	  #10ns start = 1'b0; 			        // request/start = 1 holds your program counter 
    #60ns;                            // wait for 6 clock cycles of nominal 10ns each
    wait(done);                       // wait for DUT's ack/done flag to go high
//    #2000ns; 
    #10ns $fdisplay(3,"");
    $fdisplay(3,"program 1:");
// ***** reads your results and compares to test bench
// ***** use your instance name for data memory and its internal Core *****
    for(int n=0; n<64; n++)	begin
	  if(msg_crypto1[n]==dut.mem.Core[n+64])	begin
        $fdisplay(3,"%d bench msg: %s %h dut msg: %h",
          n, msg_crypto1[n][6:0]+8'h20, msg_crypto1[n], dut.mem.Core[n+64]);
		    score++;
	  end
      else
        $fdisplay(3,"%d bench msg: %s %h dut msg: %h  OOPS!",
          n, msg_crypto1[n][6:0]+8'h20, msg_crypto1[n], dut.mem.Core[n+64]);
    end
    $fdisplay(3,"score = %d/64",score);
    #20ns $fclose(f1);
    #20ns $stop;
  end

always begin     // continuous loop
  #5ns clk = 1;  // clock tick
  #5ns clk = 0;  // clock tock
end

endmodule