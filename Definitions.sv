//This file defines the parameters used in the alu
// CSE141L
package definitions;
    
// Instruction map
    const logic [2:0]kLSW   = 3'b000;
    // const logic [2:0]k   = 3'b001;
    const logic [2:0]kSET   = 3'b010;
    const logic [2:0]kBNE   = 3'b011;
    const logic [2:0]kPAR   = 3'b100;
	const logic [2:0]kADD   = 3'b101;
	const logic [2:0]kXOR   = 3'b110;
    const logic [2:0]kLSOR  = 3'b111;
// enum names will appear in timing diagram
    typedef enum logic[2:0] {
        LW, SW, SET, BNE,
        PAR, ADD, XOR, LSOR} op_mne;
// note: kADD is of type logic[2:0] (3-bit binary)
//   ADD is of type enum -- equiv., but watch casting
//   see ALU.sv for how to handle this   
endpackage // definitions
