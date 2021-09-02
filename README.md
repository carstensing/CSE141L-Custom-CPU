# CSE1401L: Custom CPU

This is a custom CPU, instruction set and compiler that runs three programs. Program 1 is an encrypter using LFSR. Program 2 decrypts what program 1 encrypts. Program 3 is program 2 with error detection in the form of a parity bit.

compiler.py takes the user-level assembly code, trims it of everything but code, calcuates the correct JUMP distances, and converts the assembly code into machine code.

The output of compiler.py is put into the src folder and to run a specific machine code on the CPU, the file needs to be renamed to "machine_code.txt".
EX: machine_code1.txt --> machine_code.txt

The three user-level assembly code files are program1.txt, program2.txt, and program3.txt.

Diagram of CPU is a paint.net file and you can set the layers to visible to see their data path throught the CPU.

The architecture is very MIPS-like but with the idea of an accumulator to save bits.
About half of the instructions use the ALU and store into reg[0] which I call "Acc".
I needed a way to set registers to other things after being stored in Acc so I have a set instruction.
Then, I needed a way to load and store to data memory so I have those.
Last, I needed a branch statement. I made the value adding to PC signed so that I could do forward and backward branches.

8 instructions and 8 registers.
Registers are 8 bits wide.
Indirect addressing of registers and memory.
Instructions are 9 bits for 1 instr, and then 1 or 2 reg addresses, or an immediate value.
Look at Definitions.sv to see what binary digits map to what instructions.

Instructions:  
set x y  
// reg[x] = reg[y]  

lsw 0 y  
// DM[reg[y]] = reg[6]  
// store  

lsw x 0  
// reg[7] = DM[reg[x]]  
// load  

bne x y  
// if Acc != reg[x] then PC-=reg[y]  

xor x y  
// Acc = {1'b0, (reg[x][6:0] ^ reg[y][6:0])}  

add x  
// Acc = Acc + x  
// x is a 6 bit immediate value  

par x y  
// Acc = {7'b0, (^(reg[x] & reg[y]))}  
// Acc = a 7 bit 0 or 1  

errflg x  
// Acc = {^reg[x][6:0], reg[x][6:0]}  
// x is a 3 bit reg address  

lsor x y  
// Acc = {1'b0, ((reg[x][6:0] << 1) | reg[y][6:0])}  
// Acc = left-shift(reg[x]) or reg[y]  

Some notes about my user-level code:  
	"#!# LOOP_NAME" is used to denote the start and end of a loop.  
	"--> add LOOP_NAME" is used to add a positive value to the PC.  
	"<-- add LOOP_NAME" is used to add a negative value to the PC.  
	Anything before "START" is considered a comment.  
	Anything but valid instructions after "START" are considered comments.  
		
EX of a forward branch:  
	...  
	--> add LOOP1  
	...  
	#!# LOOP1  
	bne x y  
	...  
	#!# LOOP1 END  
				
	The compiler will get rid of anything after LOOP_NAME so "END" is just there for readability.  
This will branch to the instruction AFTER "#!# LOOP_NAME END"  
				
EX of a backward branch:  
	#!# LOOP2  
	...  
	<-- add LOOP2  
	...  
	bne x y  
	#!# LOOP2 END  
				
This will branch backward and start the PC at the instruction AFTER "#!# LOOP_NAME"  
			
				
		
