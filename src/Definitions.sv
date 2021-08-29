package definitions;
    
// Instruction map
    const logic [2:0]kLSW    = 3'b000;
    const logic [2:0]kERRFLG = 3'b001;
    const logic [2:0]kSET    = 3'b010;
    const logic [2:0]kBNE    = 3'b011;
    const logic [2:0]kPAR    = 3'b100;
	const logic [2:0]kADD    = 3'b101;
	const logic [2:0]kXOR    = 3'b110;
    const logic [2:0]kLSOR   = 3'b111;

// enum names will appear in timing diagram
    typedef enum logic[2:0] {
        LSW, ERRFLG, SET, BNE,
        PAR, ADD, XOR, LSOR} op_mne;

endpackage // definitions
